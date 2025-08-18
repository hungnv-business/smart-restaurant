# Monitoring and Observability (Giám sát và Quan sát Hệ thống)

## Monitoring Stack (Hệ thống Giám sát)

- **Frontend Monitoring (Giám sát Frontend):** Application Insights với các chỉ số chuyên biệt cho nhà hàng như tỷ lệ hoàn thành đơn hàng, thời gian luân chuyển bàn
- **Backend Monitoring (Giám sát Backend):** Application Insights + Serilog để ghi log có cấu trúc cho các hoạt động nhà hàng
- **Error Tracking (Theo dõi Lỗi):** Application Insights để phát hiện và phân loại lỗi theo tiếng Việt
- **Performance Monitoring (Giám sát Hiệu suất):** Application Insights với các chỉ số KPI chuyên biệt cho nhà hàng như thời gian xử lý đơn trung bình, hiệu suất trong giờ đông khách

## Key Metrics (Các Chỉ số Chính)

**Frontend Metrics (Chỉ số Frontend):**
- Core Web Vitals (LCP < 2.5s, FID < 100ms, CLS < 0.1) (Chỉ số Web cốt lõi)
- JavaScript errors categorized by restaurant feature (orders, menu, payments) (Lỗi JavaScript phân loại theo chức năng nhà hàng: đơn hàng, thực đơn, thanh toán)
- API response times for critical paths (menu loading, order submission) (Thời gian phản hồi API cho các luồng quan trọng: tải thực đơn, gửi đơn hàng)
- User interactions (table selections, menu searches, payment completions) (Tương tác người dùng: chọn bàn, tìm kiếm thực đơn, hoàn tất thanh toán)

**Backend Metrics (Chỉ số Backend):**
- Request rate (orders per minute during peak hours) (Tần suất yêu cầu: số đơn hàng/phút trong giờ đông khách)
- Error rate (< 1% for order processing, < 0.1% for payments) (Tỷ lệ lỗi: < 1% xử lý đơn hàng, < 0.1% thanh toán)
- Response time (< 200ms for menu queries, < 500ms for order processing) (Thời gian phản hồi: < 200ms truy vấn thực đơn, < 500ms xử lý đơn hàng)
- Database query performance (Vietnamese text search performance, concurrent order handling) (Hiệu suất cơ sở dữ liệu: tìm kiếm tiếng Việt, xử lý đồng thời nhiều đơn hàng)

**Restaurant-Specific Metrics (Chỉ số Riêng cho Nhà hàng):**
- Table turnover rate (tables per hour) (Tốc độ luân chuyển bàn: số bàn/giờ)
- Order completion time (order creation to payment) (Thời gian hoàn thành đơn: từ tạo đơn đến thanh toán)
- Kitchen efficiency (order preparation time by dish category) (Hiệu quả bếp: thời gian chuẩn bị theo từng loại món)
- Payment method distribution (cash vs bank transfer usage) (Phân bố phương thức thanh toán: tiền mặt vs chuyển khoản)
- Peak hour performance (system responsiveness during 11:30-13:30, 18:00-21:00) (Hiệu suất giờ đông khách: khả năng đáp ứng trong khung 11:30-13:30, 18:00-21:00)

## Logging Strategy (Chiến lược Ghi nhận)

**Structured Logging with Serilog (Ghi nhận có cấu trúc với Serilog):**
```csharp
// src/SmartRestaurant.HttpApi.Host/Program.cs
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Information()
    .MinimumLevel.Override("Microsoft", LogEventLevel.Warning)
    .Enrich.FromLogContext()
    .Enrich.WithProperty("Application", "SmartRestaurant")
    .Enrich.WithProperty("Environment", Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT"))
    .WriteTo.Console()
    .WriteTo.ApplicationInsights(services.GetRequiredService<TelemetryConfiguration>(), TelemetryConverter.Traces)
    .WriteTo.File("logs/smartrestaurant-.txt", 
        rollingInterval: RollingInterval.Day,
        retainedFileCountLimit: 7,
        shared: true)
    .CreateLogger();
```

**Restaurant-Specific Log Events (Các sự kiện ghi nhận riêng cho nhà hàng):**
```csharp
// Order processing logs (Ghi nhận quá trình xử lý đơn hàng)
_logger.LogInformation("Order {OrderNumber} created for table {TableNumber} with {ItemCount} items and total {TotalAmount:C}", 
    order.OrderNumber, table.TableNumber, order.OrderItems.Count, order.TotalAmount);

// Kitchen workflow logs (Ghi nhận luồng làm việc bếp)
_logger.LogInformation("Kitchen received order {OrderNumber} - dishes: {DishNames}", 
    order.OrderNumber, string.Join(", ", order.OrderItems.Select(oi => oi.MenuItem.Name)));

// Payment processing logs (Ghi nhận quá trình thanh toán)
_logger.LogInformation("Payment {PaymentId} completed for order {OrderNumber} using {PaymentMethod} - amount: {Amount:C}", 
    payment.Id, order.OrderNumber, payment.PaymentMethod, payment.Amount);

// Performance monitoring logs (Ghi nhận giám sát hiệu suất)
_logger.LogWarning("Slow query detected: {QueryType} took {Duration}ms - threshold exceeded", 
    "MenuItemSearch", duration.TotalMilliseconds);
```

## Application Insights Configuration (Thiết lập Application Insights)

**Custom Telemetry for Restaurant Operations (Theo dõi tùy chỉnh cho hoạt động nhà hàng):**
```csharp
// src/SmartRestaurant.Application/Orders/OrderAppService.cs
public class OrderAppService : ApplicationService, IOrderAppService
{
    private readonly TelemetryClient _telemetryClient;

    public async Task<OrderDto> CreateAsync(CreateOrderDto input)
    {
        var stopwatch = Stopwatch.StartNew();
        
        try
        {
            var order = await CreateOrderInternalAsync(input);
            
            // Track successful order creation (Theo dõi việc tạo đơn hàng thành công)
            _telemetryClient.TrackEvent("OrderCreated", new Dictionary<string, string>
            {
                ["OrderId"] = order.Id.ToString(),
                ["TableNumber"] = order.Table.TableNumber,
                ["OrderType"] = order.OrderType.ToString(),
                ["ItemCount"] = order.OrderItems.Count.ToString(),
                ["TotalAmount"] = order.TotalAmount.ToString("C")
            });
            
            return order;
        }
        catch (Exception ex)
        {
            // Track order creation failures (Theo dõi lỗi khi tạo đơn hàng)
            _telemetryClient.TrackException(ex, new Dictionary<string, string>
            {
                ["Operation"] = "OrderCreation",
                ["TableId"] = input.TableId.ToString(),
                ["ErrorCategory"] = "BusinessLogic"
            });
            throw;
        }
        finally
        {
            // Track operation duration (Theo dõi thời gian xử lý)
            _telemetryClient.TrackDependency("Database", "CreateOrder", 
                DateTime.UtcNow.Subtract(TimeSpan.FromMilliseconds(stopwatch.ElapsedMilliseconds)), 
                stopwatch.Elapsed, true);
        }
    }
}
```

## Health Checks (Kiểm tra tình trạng hệ thống)

**Comprehensive Health Monitoring (Giám sát tình trạng toàn diện):**
```csharp
// src/SmartRestaurant.HttpApi.Host/HealthChecks/RestaurantHealthCheck.cs
public class RestaurantHealthCheck : IHealthCheck
{
    private readonly SmartRestaurantDbContext _dbContext;
    private readonly IOrderRepository _orderRepository;

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        try
        {
            // Check database connectivity (Kiểm tra kết nối cơ sở dữ liệu)
            await _dbContext.Database.CanConnectAsync(cancellationToken);
            
            // Check recent order processing (Kiểm tra việc xử lý đơn hàng gần đây)
            var recentOrdersCount = await _orderRepository.CountAsync(o => o.CreationTime >= DateTime.UtcNow.AddMinutes(-5));
            
            // Check for system overload (Kiểm tra tình trạng quá tải hệ thống)
            var pendingOrdersCount = await _orderRepository.CountAsync(o => o.Status == OrderStatus.Pending);
            
            if (pendingOrdersCount > 50) // Too many pending orders (Quá nhiều đơn hàng đang chờ xử lý)
            {
                return HealthCheckResult.Degraded($"High number of pending orders: {pendingOrdersCount}");
            }
            
            return HealthCheckResult.Healthy($"Restaurant system operational. Recent orders: {recentOrdersCount}, Pending: {pendingOrdersCount}");
        }
        catch (Exception ex)
        {
            return HealthCheckResult.Unhealthy($"Restaurant health check failed: {ex.Message}", ex);
        }
    }
}

// Program.cs registration (Khai báo trong Program.cs)
builder.Services.AddHealthChecks()
    .AddCheck<RestaurantHealthCheck>("restaurant")
    .AddDbContextCheck<SmartRestaurantDbContext>("database")
    .AddCheck("external-payment-api", () => 
    {
        // Check payment gateway availability (Kiểm tra hoạt động của cổng thanh toán)
        return HealthCheckResult.Healthy("Payment gateway responsive");
    });
```

## Performance Dashboards (Bảng điều khiển hiệu suất)

**Custom Restaurant Metrics Dashboard (Bảng điều khiển chỉ số tùy chỉnh cho nhà hàng):**
- **Order Flow Metrics (Chỉ số luồng đơn hàng):** Order creation rate, completion time, cancellation rate (Tốc độ tạo đơn, thời gian hoàn thành, tỷ lệ hủy đơn)
- **Kitchen Performance (Hiệu suất bếp):** Average preparation time by dish category, kitchen queue length (Thời gian chuẩn bị trung bình theo loại món, số lượng đơn đang chờ trong bếp)
- **Table Management (Quản lý bàn):** Table occupancy rate, turnover time, reservation accuracy (Tỷ lệ sử dụng bàn, thời gian luân chuyển bàn, độ chính xác khi đặt bàn)
- **Payment Analytics (Phân tích thanh toán):** Payment method distribution, transaction success rate, average transaction value (Phân bố phương thức thanh toán, tỷ lệ giao dịch thành công, giá trị giao dịch trung bình)
- **System Health (Tình trạng hệ thống):** API response times, error rates, database performance (Thời gian phản hồi API, tỷ lệ lỗi, hiệu suất cơ sở dữ liệu)

---
