using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.Logging;
using SmartRestaurant.MenuManagement.MenuItems;
using SmartRestaurant.Orders;
using SmartRestaurant.Kitchen.Dtos;
using Volo.Abp.Domain.Entities;
using Volo.Abp.Domain.Services;

namespace SmartRestaurant.Kitchen
{
    /// <summary>
    /// Domain Manager quản lý độ ưu tiên bếp (Kitchen Priority Management)
    /// 
    /// Chức năng chính:
    /// - Tính toán và sắp xếp độ ưu tiên món ăn cần nấu
    /// - Cập nhật trạng thái món ăn từ Kitchen Dashboard  
    /// - Quản lý workflow nấu nướng theo business rules
    /// - Tối ưu hiệu suất bếp với thuật toán multi-level priority
    /// 
    /// Thuật toán Priority (từ cao xuống thấp):
    /// 1. Quick-Cook dishes: +100 điểm (ưu tiên tuyệt đối)
    /// 2. Empty Table priority: +50 điểm (bàn trống), +25 điểm (1 món)
    /// 3. Takeaway priority: +30 điểm (đơn mang về)
    /// 4. FIFO time-based: +1 điểm/phút chờ (công bằng theo thời gian)
    /// 
    /// Ví dụ: Món nấu nhanh của bàn trống chờ 15 phút = 100 + 50 + 15 = 165 điểm
    /// </summary>
    public class KitchenPriorityManager : DomainService
    {
        private readonly IOrderRepository _orderRepository;
        private readonly IMenuItemRepository _menuItemRepository;

        public KitchenPriorityManager(
            IOrderRepository orderRepository,
            IMenuItemRepository menuItemRepository)
        {
            _orderRepository = orderRepository;
            _menuItemRepository = menuItemRepository;
        }

        /// <summary>
        /// Tính toán điểm ưu tiên nâng cao cho món ăn cần nấu
        /// 
        /// Thuật toán Multi-Level Priority:
        /// 
        /// Level 1 - Quick Cook Priority (Ưu tiên tuyệt đối):
        /// - Món nấu nhanh (IsQuickCook = true): +100 điểm
        /// - Lý do: Món nấu nhanh giúp tối ưu thời gian, giải tỏa áp lực bếp
        /// 
        /// Level 2 - Table/Order Type Priority:
        /// - Bàn trống (0 món đã phục vụ): +50 điểm (khách đói, cần ưu tiên cao)
        /// - Bàn ít món (1 món đã phục vụ): +25 điểm (đang ăn, vẫn cần ưu tiên)
        /// - Đơn mang về/giao hàng: +30 điểm (khách chờ, không thể ăn món khác)
        /// - Bàn nhiều món (≥2 món): +0 điểm (khách có món ăn, có thể chờ)
        /// 
        /// Level 3 - FIFO Time-Based (Công bằng theo thời gian):
        /// - +1 điểm cho mỗi phút chờ từ lúc gọi món
        /// - Đảm bảo món gọi trước được ưu tiên khi cùng mức độ khác
        /// 
        /// Ví dụ thực tế:
        /// - Món nấu nhanh bàn trống chờ 15 phút: 100+50+15 = 165 điểm
        /// - Món thường mang về chờ 10 phút: 0+30+10 = 40 điểm  
        /// - Món thường bàn đã có 2 món chờ 20 phút: 0+0+20 = 20 điểm
        /// </summary>
        /// <param name="orderItemId">ID của OrderItem cần tính điểm</param>
        /// <param name="tableId">ID của bàn (Guid.Empty nếu là takeaway/delivery)</param>
        /// <param name="isQuickCook">True nếu món này có thể nấu nhanh (từ MenuItem)</param>
        /// <param name="requiresCooking">True nếu món này cần nấu (từ MenuItem)</param>
        /// <param name="orderTime">Thời gian gọi món (từ Order.CreationTime)</param>
        /// <returns>
        /// Điểm ưu tiên tổng (càng cao càng ưu tiên)
        /// - Trả về 0 nếu món không cần nấu (không hiển thị trên Kitchen Dashboard)
        /// - Trả về điểm tổng nếu cần nấu (dùng để sắp xếp thứ tự ưu tiên)
        /// </returns>
        public async Task<int> CalculateAdvancedPriorityScoreAsync(
            Guid orderItemId,
            Guid tableId,
            bool isQuickCook,
            bool requiresCooking,
            DateTime orderTime)
        {
            // Bước 0: Kiểm tra món có cần nấu không
            // Chỉ tính priority cho món RequiresCooking = true
            if (!requiresCooking)
            {
                Logger.LogDebug("OrderItem {OrderItemId}: Không cần nấu, bỏ qua priority calculation", orderItemId);
                return 0; // Trả về 0 = không hiển thị trên Kitchen Dashboard
            }

            int totalScore = 0; // Khởi tạo điểm tổng

            // ========== LEVEL 1: QUICK-COOK PRIORITY (Ưu tiên tuyệt đối) ==========
            // Món nấu nhanh được ưu tiên cao nhất để giải tỏa áp lực bếp
            if (isQuickCook)
            {
                totalScore += 100; // Bonus 100 điểm
                Logger.LogDebug("OrderItem {OrderItemId}: Quick-cook bonus +100 điểm", orderItemId);
            }

            // ========== LEVEL 2: TABLE/ORDER TYPE PRIORITY ==========
            if (tableId == Guid.Empty)
            {
                // TAKEAWAY/DELIVERY: Khách không thể ăn món khác nên cần ưu tiên trung bình
                totalScore += 30; // Bonus 30 điểm
                Logger.LogDebug("OrderItem {OrderItemId}: Takeaway/Delivery bonus +30 điểm", orderItemId);
            }
            else
            {
                // DINE-IN: Priority dựa trên "mức độ đói" của bàn
                var servedDishesCount = await GetServedDishesCountAsync(tableId);
                
                if (servedDishesCount == 0)
                {
                    // Bàn trống (0 món đã phục vụ): Khách đói, ưu tiên cao nhất
                    totalScore += 50; // Bonus 50 điểm
                    Logger.LogDebug("OrderItem {OrderItemId}: Bàn trống (0 món) bonus +50 điểm", orderItemId);
                }
                else if (servedDishesCount == 1)
                {
                    // Bàn có 1 món: Đang ăn nhưng vẫn cần thêm món, ưu tiên trung bình
                    totalScore += 25; // Bonus 25 điểm
                    Logger.LogDebug("OrderItem {OrderItemId}: Bàn ít món (1 món) bonus +25 điểm", orderItemId);
                }
                // servedDishesCount >= 2: Bàn đã có nhiều món, không bonus (+0 điểm)
                else
                {
                    Logger.LogDebug("OrderItem {OrderItemId}: Bàn đã có {ServedCount} món, không bonus", 
                        orderItemId, servedDishesCount);
                }
            }

            // ========== LEVEL 3: FIFO TIME-BASED PRIORITY (Công bằng) ==========
            // Mỗi phút chờ = +1 điểm, đảm bảo món gọi trước được ưu tiên khi cùng level khác
            var waitingMinutes = (int)(DateTime.UtcNow - orderTime).TotalMinutes;
            var fifoBonus = Math.Max(0, waitingMinutes); // Đảm bảo không âm
            totalScore += fifoBonus;
            
            Logger.LogDebug("OrderItem {OrderItemId}: FIFO time bonus +{FifoBonus} điểm ({WaitingMinutes} phút chờ)", 
                orderItemId, fifoBonus, waitingMinutes);

            // ========== LOGGING KẾT QUẢ CUỐI CÙNG ==========
            var orderType = tableId == Guid.Empty ? "Takeaway/Delivery" : "Dine-In";
            var quickCookBonus = isQuickCook ? 100 : 0;
            var tableBonus = totalScore - quickCookBonus - fifoBonus;
            
            Logger.LogInformation(
                "✅ Priority calculated for OrderItem {OrderItemId} ({OrderType}): " +
                "Total={Total} điểm (QuickCook={QuickCook} + TableBonus={TableBonus} + FIFO={FIFO})",
                orderItemId, orderType, totalScore, quickCookBonus, tableBonus, fifoBonus);

            return totalScore; // Trả về điểm priority tổng cộng
        }

        /// <summary>
        /// Lấy danh sách món ăn cần nấu đã được sắp xếp theo độ ưu tiên
        /// 
        /// Chức năng chính:
        /// - Chỉ hiển thị món có RequiresCooking = true (lọc bỏ thức uống, món ăn sẵn)
        /// - Áp dụng thuật toán multi-level priority để sắp xếp
        /// - Tính toán thời gian chờ real-time cho từng món
        /// - Hỗ trợ cả đơn ăn tại chỗ và mang về/giao hàng
        /// 
        /// Tối ưu Performance:
        /// - Sử dụng GetActiveOrdersWithDetailsAsync() để tránh N+1 query
        /// - Batch tính served dishes count cho tất cả bàn cùng lúc
        /// - Pre-calculate tất cả priority score trước khi sắp xếp
        /// 
        /// Kết quả trả về:
        /// - Danh sách được sắp xếp từ priority cao xuống thấp
        /// - Món ưu tiên cao nhất (quick-cook, bàn trống) sẽ ở đầu danh sách
        /// - Bao gồm đầy đủ thông tin để Kitchen Dashboard hiển thị
        /// 
        /// Business Logic:
        /// - Bàn trống được ưu tiên cao (khách đói)
        /// - Món nấu nhanh được ưu tiên tuyệt đối (tối ưu workflow)
        /// - Đơn mang về có ưu tiên trung bình (khách không thể chờ lâu)
        /// - FIFO đảm bảo công bằng theo thời gian gọi món
        /// </summary>
        /// <returns>
        /// Danh sách KitchenOrderItemDto đã sắp xếp theo priority (cao → thấp)
        /// Mỗi item chứa đầy đủ thông tin: món ăn, bàn, thời gian, priority score
        /// </returns>
        public async Task<List<KitchenOrderItemDto>> GetPriorizedOrderItemsAsync()
        {
            Logger.LogInformation("Getting prioritized cooking order items");

            // Lấy tất cả orders đang active với đầy đủ relations trong một query duy nhất
            var activeOrders = await _orderRepository.GetActiveOrdersWithDetailsAsync();

            // Pre-calculate served dishes count cho các bàn có TableId
            var tableIds = activeOrders.Where(o => o.TableId.HasValue).Select(o => o.TableId!.Value).Distinct().ToList();
            var servedDishesCountDict = await GetServedDishesCountBatchAsync(tableIds);

            var result = new List<KitchenOrderItemDto>();

            foreach (var order in activeOrders)
            {
                // Lấy các món cần nấu từ Order domain method
                var cookingItems = order.GetCookingItems();
                
                foreach (var orderItem in cookingItems)
                {
                    var menuItem = orderItem.MenuItem;
                    if (menuItem == null)
                    {
                        Logger.LogWarning("MenuItem not found for OrderItem {OrderItemId}", orderItem.Id);
                        continue;
                    }

                    // Xử lý cho cả đơn hàng có bàn và mang về
                    string tableNumber = string.Empty;
                    int servedDishesCount = 0;
                    bool isEmptyTablePriority = false;

                    if (!order.IsTakeaway && order.Table != null)
                    {
                        // Đơn hàng ăn tại chỗ
                        tableNumber = order.Table.TableNumber;
                        servedDishesCount = servedDishesCountDict.GetValueOrDefault(order.TableId!.Value, 0);
                        isEmptyTablePriority = servedDishesCount <= 1;
                    }
                    else
                    {
                        // Đơn hàng mang về hoặc delivery
                        var orderTypeText = order.OrderType == OrderType.Takeaway ? "Mang về" : "Giao hàng";
                        tableNumber = $"{orderTypeText} #{order.OrderNumber}";
                    }

                    var priorityScore = await CalculateAdvancedPriorityScoreAsync(
                        orderItem.Id, 
                        order.TableId ?? Guid.Empty, // Dùng Empty cho takeaway
                        menuItem.IsQuickCook, 
                        menuItem.RequiresCooking, 
                        order.CreationTime);

                    result.Add(new KitchenOrderItemDto
                    {
                        OrderId = order.Id,
                        OrderItemId = orderItem.Id,
                        TableNumber = tableNumber,
                        MenuItemName = menuItem.Name,
                        Quantity = orderItem.Quantity,
                        OrderTime = order.CreationTime,
                        IsQuickCook = menuItem.IsQuickCook,
                        RequiresCooking = menuItem.RequiresCooking,
                        IsEmptyTablePriority = isEmptyTablePriority,
                        ServedDishesCount = servedDishesCount,
                        PriorityScore = priorityScore,
                        Status = orderItem.Status,
                        OrderType = order.OrderType,
                        WaitingMinutes = (int)(DateTime.UtcNow - order.CreationTime).TotalMinutes
                    });
                }
            }

            // Sắp xếp theo priority score (cao xuống thấp)
            var sortedResult = result.OrderByDescending(x => x.PriorityScore).ToList();

            Logger.LogInformation("Found {Count} cooking items with priority scores", sortedResult.Count);
            
            return sortedResult;
        }

        /// <summary>
        /// Đếm số món đã được phục vụ cho một bàn cụ thể
        /// 
        /// Mục đích:
        /// - Xác định mức độ "đói" của bàn để tính empty table priority
        /// - Bàn có 0 món được phục vụ = bàn trống = ưu tiên cao (+50 điểm)
        /// - Bàn có 1 món được phục vụ = đang ăn = ưu tiên trung bình (+25 điểm)  
        /// - Bàn có ≥2 món được phục vụ = no priority bonus (+0 điểm)
        /// 
        /// Logic:
        /// - Lấy tất cả orders của bàn này (có thể có nhiều orders cho 1 bàn)
        /// - Đếm tất cả OrderItems có status = Served
        /// - Trả về tổng số món đã phục vụ
        /// 
        /// Performance Note:
        /// - Method này được gọi cho từng bàn riêng lẻ
        /// - Nếu cần tính cho nhiều bàn, nên dùng GetServedDishesCountBatchAsync()
        /// </summary>
        /// <param name="tableId">ID của bàn cần đếm món đã phục vụ</param>
        /// <returns>
        /// Số lượng món đã được phục vụ cho bàn này
        /// - 0: Bàn trống (chưa có món nào được phục vụ)
        /// - 1: Đã phục vụ 1 món
        /// - ≥2: Đã phục vụ nhiều món
        /// </returns>
        public async Task<int> GetServedDishesCountAsync(Guid tableId)
        {
            var orders = await _orderRepository.GetListAsync(o => o.TableId == tableId);
            
            var servedCount = orders
                .SelectMany(o => o.OrderItems)
                .Count(oi => oi.IsServed());

            Logger.LogDebug("Table {TableId} has {ServedCount} served dishes", tableId, servedCount);
            
            return servedCount;
        }

        /// <summary>
        /// Batch tính số món đã được phục vụ cho nhiều bàn cùng lúc (Performance Optimization)
        /// 
        /// Lý do tối ưu:
        /// - Thay vì gọi GetServedDishesCountAsync() cho từng bàn (N queries)
        /// - Method này chỉ cần 1 query duy nhất để tính cho tất cả bàn
        /// - Giảm đáng kể database round-trips khi có nhiều bàn active
        /// 
        /// Cách hoạt động:
        /// 1. Lấy tất cả orders của tất cả bàn trong danh sách (1 query)
        /// 2. Group theo tableId và đếm served items cho mỗi bàn
        /// 3. Trả về Dictionary để lookup O(1) khi tính priority
        /// 
        /// Performance Impact:
        /// - Trước: N queries (N = số bàn active)
        /// - Sau: 1 query + in-memory processing
        /// - Hiệu quả rõ rệt khi có ≥ 3 bàn active
        /// 
        /// Sử dụng trong:
        /// - GetPriorizedOrderItemsAsync() để pre-calculate cho tất cả bàn
        /// - Batch operations khi cần tính priority cho nhiều bàn
        /// </summary>
        /// <param name="tableIds">
        /// Danh sách ID các bàn cần tính served dishes count
        /// - Có thể empty (trả về empty dictionary)
        /// - Duplicate tableIds sẽ được xử lý đúng (Distinct tự động)
        /// </param>
        /// <returns>
        /// Dictionary&lt;tableId, servedCount&gt; với:
        /// - Key: TableId của bàn
        /// - Value: Số món đã phục vụ cho bàn đó
        /// - Bàn không có order nào sẽ có value = 0
        /// </returns>
        public async Task<Dictionary<Guid, int>> GetServedDishesCountBatchAsync(List<Guid> tableIds)
        {
            // Kiểm tra edge case: danh sách bàn trống
            if (!tableIds.Any())
            {
                Logger.LogDebug("No tables to calculate served dishes count");
                return new Dictionary<Guid, int>();
            }

            // Lấy tất cả orders của các bàn này trong một query duy nhất
            // Điều kiện: Order phải có TableId và nằm trong danh sách cần tính
            var orders = await _orderRepository.GetListAsync(
                predicate: o => o.TableId.HasValue && tableIds.Contains(o.TableId.Value),
                includeDetails: true); // Quan trọng: Include OrderItems để tránh lazy loading

            Logger.LogDebug("Found {OrderCount} orders for {TableCount} tables", orders.Count, tableIds.Count);

            // Khởi tạo result dictionary với tất cả bàn = 0 món đã phục vụ
            // Đảm bảo mọi bàn đều có entry, kể cả bàn chưa có order nào
            var result = tableIds.ToDictionary(tableId => tableId, tableId => 0);
            
            // Duyệt qua từng order và cộng dồn số món đã phục vụ cho mỗi bàn
            foreach (var order in orders)
            {
                if (order.TableId.HasValue)
                {
                    // Đếm số OrderItems có status = Served trong order này
                    var servedCount = order.OrderItems.Count(oi => oi.IsServed());
                    
                    // Cộng dồn vào tổng của bàn (vì 1 bàn có thể có nhiều orders)
                    result[order.TableId.Value] += servedCount;
                    
                    if (servedCount > 0)
                    {
                        Logger.LogDebug("Table {TableId} has {ServedCount} served dishes in order {OrderId}", 
                            order.TableId.Value, servedCount, order.Id);
                    }
                }
            }

            Logger.LogDebug("Batch calculated served dishes for {TableCount} tables", tableIds.Count);
            
            return result;
        }

        /// <summary>
        /// Kiểm tra món ăn có thuộc loại nấu nhanh không
        /// 
        /// Quick-Cook Items là những món:
        /// - Có thể chuẩn bị trong thời gian ngắn (≤ 10 phút)
        /// - Không cần process phức tạp (salad, đồ uống, món ăn sẵn)
        /// - Được ưu tiên tuyệt đối trong kitchen workflow (+100 điểm)
        /// 
        /// Lý do ưu tiên Quick-Cook:
        /// - Giải tỏa áp lực bếp nhanh chóng
        /// - Làm hài lòng khách hàng (có món ăn ngay)  
        /// - Tối ưu workflow (làm món dễ trước, khó sau)
        /// - Giảm thời gian chờ tổng thể của toàn bộ kitchen
        /// 
        /// Ví dụ Quick-Cook:
        /// - Salad, gỏi cuốn, nước uống
        /// - Món ăn kèm (cơm, bánh mì)
        /// - Món không cần nấu (bánh flan, chè)
        /// </summary>
        /// <param name="menuItemId">ID của MenuItem cần kiểm tra</param>
        /// <returns>
        /// True: Món thuộc loại nấu nhanh (IsQuickCook = true)
        /// False: Món nấu thường (IsQuickCook = false)
        /// </returns>
        /// <exception cref="EntityNotFoundException">Không tìm thấy MenuItem với ID này</exception>
        public async Task<bool> IsQuickCookItemAsync(Guid menuItemId)
        {
            // Lấy thông tin MenuItem từ database
            var menuItem = await _menuItemRepository.GetAsync(menuItemId);
            
            // Trả về thuộc tính IsQuickCook của MenuItem
            return menuItem.IsQuickCook;
        }


        /// <summary>
        /// Lấy dữ liệu Kitchen Dashboard được nhóm theo bàn (Table-Grouped View)
        /// 
        /// Mục đích:
        /// - Tổ chức món ăn theo từng bàn để bếp dễ quản lý
        /// - Mỗi bàn hiển thị tất cả món cần nấu của bàn đó
        /// - Sắp xếp bàn theo độ ưu tiên và thời gian
        /// - Cung cấp view tổng quan cho Kitchen Dashboard UI
        /// 
        /// Thuật toán nhóm:
        /// 1. Lấy tất cả món cần nấu đã được prioritized
        /// 2. Group theo (TableNumber + OrderType) để tách biệt:
        ///    - Bàn ăn tại chỗ: "B01", "B02", etc.
        ///    - Đơn mang về: "Mang về #001", "Giao hàng #002", etc.
        /// 3. Tính thống kê cho mỗi nhóm bàn
        /// 4. Sắp xếp bàn theo priority (bàn urgent lên đầu)
        /// 
        /// Sắp xếp Logic:
        /// - Bàn có món ưu tiên cao nhất lên đầu (HighestPriority DESC)
        /// - Cùng priority thì bàn gọi trước lên đầu (EarliestOrderTime ASC)
        /// - Trong mỗi bàn: món priority cao lên đầu, cùng priority thì FIFO
        /// 
        /// Kết quả cho Kitchen Dashboard:
        /// - View dễ nhìn: mỗi card = 1 bàn với danh sách món
        /// - Bàn urgent (đỏ) hiển thị đầu tiên
        /// - Thông tin đầy đủ: số món, thời gian chờ, loại đơn hàng
        /// </summary>
        /// <returns>
        /// Danh sách KitchenTableGroupDto đã được sắp xếp theo priority:
        /// - Mỗi item = 1 bàn/đơn hàng với thông tin tổng hợp
        /// - Chứa danh sách món cần nấu của bàn đó (đã sắp xếp)
        /// - Bao gồm metadata: tổng món, highest priority, earliest time
        /// </returns>
        public async Task<List<KitchenTableGroupDto>> GetKitchenDashboardGroupedAsync()
        {
            Logger.LogInformation("Getting kitchen dashboard data grouped by table");

            // Bước 1: Lấy tất cả món cần nấu với priority đã được tính sẵn
            var orderItems = await GetPriorizedOrderItemsAsync();

            // Bước 2: Group theo bàn (TableNumber + OrderType để tách biệt dine-in vs takeaway)
            var groupedByTable = orderItems
                .GroupBy(item => new { item.TableNumber, item.OrderType })
                .Select(group => new KitchenTableGroupDto
                {
                    // Thông tin cơ bản của bàn/đơn hàng
                    TableNumber = group.Key.TableNumber,
                    IsTakeaway = group.Key.OrderType == OrderType.Takeaway || group.Key.OrderType == OrderType.Delivery,
                    OrderType = group.Key.OrderType,
                    
                    // Thống kê tổng hợp cho bàn này
                    TotalItems = group.Count(), // Tổng số món cần nấu
                    HighestPriority = group.Max(x => x.PriorityScore), // Điểm ưu tiên cao nhất
                    EarliestOrderTime = group.Min(x => x.OrderTime), // Thời gian gọi món sớm nhất
                    
                    // Danh sách món cần nấu của bàn này (đã sắp xếp)
                    OrderItems = group
                        .OrderByDescending(x => x.PriorityScore) // Món urgent lên đầu
                        .ThenBy(x => x.OrderTime) // Cùng priority thì FIFO (công bằng)
                        .Select(item => new KitchenOrderItemDto
                        {
                            // Copy toàn bộ thông tin từ item gốc
                            OrderId = item.OrderId,
                            OrderItemId = item.OrderItemId,
                            TableNumber = item.TableNumber,
                            MenuItemName = item.MenuItemName,
                            Quantity = item.Quantity,
                            OrderTime = item.OrderTime,
                            IsQuickCook = item.IsQuickCook,
                            RequiresCooking = item.RequiresCooking,
                            IsEmptyTablePriority = item.IsEmptyTablePriority,
                            ServedDishesCount = item.ServedDishesCount,
                            PriorityScore = item.PriorityScore,
                            Status = item.Status,
                            OrderType = item.OrderType,
                            // Real-time calculation: thời gian chờ hiện tại
                            WaitingMinutes = (int)(DateTime.UtcNow - item.OrderTime).TotalMinutes
                        })
                        .ToList()
                })
                // Bước 3: Sắp xếp các bàn theo độ ưu tiên
                .OrderByDescending(table => table.HighestPriority) // Bàn có món urgent nhất lên đầu
                .ThenBy(table => table.EarliestOrderTime) // Cùng priority thì bàn gọi trước lên đầu
                .ToList();

            Logger.LogInformation("Grouped {ItemCount} items into {TableCount} tables", 
                orderItems.Count, groupedByTable.Count);

            return groupedByTable;
        }

        /// <summary>
        /// Cập nhật trạng thái OrderItem từ Kitchen Dashboard
        /// 
        /// Business Rules cho Kitchen:
        /// - Chỉ cho phép bếp cập nhật: Pending → Preparing → Ready → Canceled
        /// - KHÔNG cho phép cập nhật: Served (do nhân viên phục vụ thực hiện)
        /// - Áp dụng domain validation rules với CanTransitionTo()
        /// - Tự động ghi lại thời gian audit cho từng trạng thái
        /// 
        /// Kitchen Workflow:
        /// 1. Pending: Món vừa được gọi, chờ bếp xử lý
        /// 2. Preparing: Bếp bắt đầu nấu món này
        /// 3. Ready: Món đã nấu xong, chờ phục vụ mang ra
        /// 4. Canceled: Hủy món (nếu cần thiết)
        /// </summary>
        /// <param name="orderItemId">ID của OrderItem cần cập nhật trạng thái</param>
        /// <param name="status">Trạng thái mới (chỉ Preparing, Ready, hoặc Canceled)</param>
        /// <exception cref="OrderValidationException">
        /// - Khi trạng thái không được phép (VD: Served) 
        /// - Khi không tìm thấy OrderItem
        /// - Khi chuyển đổi trạng thái không hợp lệ (VD: Ready → Pending)
        /// </exception>
        public async Task UpdateOrderItemStatusAsync(Guid orderItemId, OrderItemStatus status)
        {
            // Kiểm tra bếp chỉ được phép cập nhật 3 trạng thái này
            // Served phải do nhân viên phục vụ thực hiện, không phải bếp
            if (status != OrderItemStatus.Preparing && 
                status != OrderItemStatus.Ready && 
                status != OrderItemStatus.Canceled)
            {
                Logger.LogWarning("Kitchen attempted to update OrderItem {OrderItemId} to invalid status {Status}", 
                    orderItemId, status);
                throw OrderValidationException.UnsupportedStatusTransition(status);
            }

            Logger.LogInformation("Kitchen đang cập nhật trạng thái OrderItem {OrderItemId} thành {Status}", 
                orderItemId, status);

            // Tìm đơn hàng chứa món ăn này
            var targetOrder = await _orderRepository.GetByOrderItemIdAsync(orderItemId);
            if (targetOrder == null)
            {
                Logger.LogWarning("Không tìm thấy Order chứa OrderItem {OrderItemId}", orderItemId);
                throw OrderValidationException.OrderItemNotFound(orderItemId);
            }

            // Lấy món ăn cụ thể từ đơn hàng
            var orderItem = targetOrder.OrderItems.FirstOrDefault(oi => oi.Id == orderItemId);
            if (orderItem == null)
            {
                Logger.LogWarning("Không tìm thấy OrderItem {OrderItemId} trong Order {OrderId}", 
                    orderItemId, targetOrder.Id);
                throw OrderValidationException.OrderItemNotFound(orderItemId);
            }

            // Kiểm tra business rule: có thể chuyển từ trạng thái hiện tại sang trạng thái mới không
            // VD: không thể chuyển từ Ready → Pending hoặc Served → Preparing
            if (!orderItem.CanTransitionTo(status))
            {
                Logger.LogWarning("Không thể chuyển OrderItem {OrderItemId} từ {CurrentStatus} sang {NewStatus}", 
                    orderItemId, orderItem.Status, status);
                throw OrderValidationException.InvalidStatusTransition(orderItem.Status, status);
            }

            // Sử dụng domain methods để đảm bảo business logic được thực hiện đúng
            // Mỗi method sẽ tự động cập nhật timestamp tương ứng
            switch (status)
            {
                case OrderItemStatus.Preparing:
                    // Bắt đầu nấu món, ghi lại thời gian bắt đầu
                    orderItem.StartPreparation();
                    Logger.LogDebug("OrderItem {OrderItemId} bắt đầu được chuẩn bị lúc {Time}", 
                        orderItemId, DateTime.UtcNow);
                    break;
                    
                case OrderItemStatus.Ready:
                    // Món đã nấu xong, chờ phục vụ mang ra
                    orderItem.MarkAsReady();
                    Logger.LogDebug("OrderItem {OrderItemId} đã sẵn sàng lúc {Time}", 
                        orderItemId, DateTime.UtcNow);
                    break;
                    
                case OrderItemStatus.Canceled:
                    // Hủy món (thường do hết nguyên liệu, khách đổi ý, v.v.)
                    orderItem.Cancel();
                    Logger.LogInformation("OrderItem {OrderItemId} đã được hủy bởi bếp lúc {Time}", 
                        orderItemId, DateTime.UtcNow);
                    break;
            }

            // Lưu thay đổi vào database
            await _orderRepository.UpdateAsync(targetOrder);

            Logger.LogInformation("Kitchen đã cập nhật thành công OrderItem {OrderItemId} từ {OldStatus} sang {NewStatus}", 
                orderItemId, orderItem.Status, status);
        }
    }

}