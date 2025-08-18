# API Specification (Thông số kỹ thuật API)

## REST API Specification (Thông số kỹ thuật REST API)

**ABP Auto API Controllers (ABP Auto API Controllers):** ABP Framework automatically generates REST API controllers from Application Services without manual controller development. You only need to create Application Services, and ABP will automatically expose them as Web API endpoints (ABP Framework tự động tạo REST API controllers từ Application Services mà không cần phát triển controller thủ công. Bạn chỉ cần tạo Application Services, và ABP sẽ tự động expose chúng như Web API endpoints).

**Application Service Example (Ví dụ Application Service):**
```csharp
// aspnet-core/src/SmartRestaurant.Application/Orders/OrderAppService.cs
public class OrderAppService : ApplicationService, IOrderAppService
{
    private readonly IOrderRepository _orderRepository;
    
    public async Task<PagedResultDto<OrderDto>> GetListAsync(GetOrdersInput input)
    {
        // Business logic implementation
        // ABP tự động tạo: GET /api/app/orders
    }
    
    public async Task<OrderDto> CreateAsync(CreateOrderDto input)
    {
        // Business logic implementation  
        // ABP tự động tạo: POST /api/app/order
    }
    
    public async Task UpdateStatusAsync(Guid id, UpdateOrderStatusDto input)
    {
        // Business logic implementation
        // ABP tự động tạo: PUT /api/app/order/{id}/status
    }
    
    public async Task DeleteAsync(Guid id)
    {
        // ABP tự động tạo: DELETE /api/app/order/{id}
    }
}

// aspnet-core/src/SmartRestaurant.Application.Contracts/Orders/IOrderAppService.cs
public interface IOrderAppService : IApplicationService
{
    Task<PagedResultDto<OrderDto>> GetListAsync(GetOrdersInput input);
    Task<OrderDto> CreateAsync(CreateOrderDto input);
    Task UpdateStatusAsync(Guid id, UpdateOrderStatusDto input);
    Task DeleteAsync(Guid id);
}
```

**ABP Auto API Configuration (Cấu hình ABP Auto API):**
```csharp
// aspnet-core/src/SmartRestaurant.HttpApi.Host/SmartRestaurantHttpApiHostModule.cs
[DependsOn(typeof(SmartRestaurantApplicationModule))]
public class SmartRestaurantHttpApiHostModule : AbpModule
{
    public override void ConfigureServices(ServiceConfigurationContext context)
    {
        // ABP tự động quét và tạo controllers từ Application Services
        Configure<AbpAspNetCoreMvcOptions>(options =>
        {
            options.ConventionalControllers.Create(typeof(SmartRestaurantApplicationModule).Assembly);
        });
    }
}
```

**Resulting OpenAPI Specification (Đặc tả OpenAPI được tạo):**
```yaml
openapi: 3.0.0
info:
  title: Smart Restaurant Management API
  version: 1.0.0
  description: ABP Framework REST API for Vietnamese restaurant operations
servers:
  - url: https://restaurant.example.com/api
    description: Production server
  - url: https://localhost:44391/api  
    description: Development server

paths:
  /orders:
    get:
      summary: Get orders with filtering
      parameters:
        - name: tableId
          in: query
          schema:
            type: string
        - name: status
          in: query
          schema:
            type: string
            enum: [Pending, Confirmed, Preparing, Ready, Served, Paid]
      responses:
        200:
          description: List of orders
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Order'
    post:
      summary: Create new order
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateOrderDto'
      responses:
        201:
          description: Order created
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Order'

  /orders/{id}/status:
    patch:
      summary: Update order status
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      requestBody:
        required: true
        content:
          application/json:
            schema:
              type: object
              properties:
                status:
                  type: string
                  enum: [Confirmed, Preparing, Ready, Served]
      responses:
        200:
          description: Status updated

  /menu-items:
    get:
      summary: Get menu items with availability
      parameters:
        - name: categoryId
          in: query
          schema:
            type: string
        - name: search
          in: query
          schema:
            type: string
          description: Vietnamese text search
      responses:
        200:
          description: Menu items list
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/MenuItem'

  /tables:
    get:
      summary: Get all tables with current status
      responses:
        200:
          description: Table list with real-time status
          content:
            application/json:
              schema:
                type: array
                items:
                  $ref: '#/components/schemas/Table'

  /payments:
    post:
      summary: Process payment
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreatePaymentDto'
      responses:
        201:
          description: Payment initiated

  /payments/{id}/confirm:
    patch:
      summary: Staff confirm payment completion
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
      responses:
        200:
          description: Payment confirmed

components:
  schemas:
    Order:
      type: object
      properties:
        orderId:
          type: string
        tableId:
          type: string
        orderNumber:
          type: string
        orderType:
          type: string
          enum: [DineIn, Takeaway]
        status:
          type: string
          enum: [Pending, Confirmed, Preparing, Ready, Served, Paid]
        orderItems:
          type: array
          items:
            $ref: '#/components/schemas/OrderItem'
        totalAmount:
          type: number
        createdAt:
          type: string
          format: date-time
        notes:
          type: string
    
    MenuItem:
      type: object
      properties:
        menuItemId:
          type: string
        categoryId:
          type: string
        name:
          type: string
        description:
          type: string
        price:
          type: number
        isAvailable:
          type: boolean
        preparationTime:
          type: number
        kitchenStation:
          type: string
          enum: [Hotpot, Grilled, Drinking, General]
```

## SignalR Hubs (Các Hub SignalR)

**Real-time Communication for Restaurant Operations (Giao tiếp Thời gian Thực cho Hoạt động Nhà hàng):** SignalR provides instant updates between kitchen, serving staff, and management interfaces (SignalR cung cấp cập nhật tức thì giữa bếp, nhân viên phục vụ và giao diện quản lý).

**Backend Hub Implementation (Triển khai Hub Backend):**
```csharp
// aspnet-core/src/SmartRestaurant.HttpApi.Host/Hubs/KitchenHub.cs
public class KitchenHub : AbpHub
{
    /// <summary>Tham gia nhóm bếp để nhận cập nhật đơn hàng</summary>
    public async Task JoinKitchenGroup()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "Kitchen");
    }
    
    /// <summary>Cập nhật trạng thái đơn hàng từ bếp</summary>
    public async Task UpdateOrderStatus(string orderId, string status)
    {
        await Clients.All.SendAsync("OrderStatusChanged", orderId, status);
    }
    
    /// <summary>Đánh dấu món ăn đã sẵn sàng</summary>
    public async Task MarkItemReady(string orderId, string itemId)
    {
        await Clients.All.SendAsync("OrderItemReady", orderId, itemId);
    }
}

// aspnet-core/src/SmartRestaurant.HttpApi.Host/Hubs/TableHub.cs
public class TableHub : AbpHub
{
    /// <summary>Tham gia nhóm quản lý bàn</summary>
    public async Task JoinTableGroup()
    {
        await Groups.AddToGroupAsync(Context.ConnectionId, "TableManagement");
    }
    
    /// <summary>Cập nhật trạng thái bàn</summary>
    public async Task UpdateTableStatus(string tableId, string status)
    {
        await Clients.Group("TableManagement").SendAsync("TableStatusChanged", tableId, status);
    }
}
```

**Frontend Hub Interface (Interface Hub Frontend):**
```typescript
// Kitchen Updates Hub (Hub Cập nhật Bếp)
interface KitchenHub {
  // Server to Client (Server gửi đến Client)
  /** Thông báo thay đổi trạng thái đơn hàng */
  OrderStatusChanged(orderId: string, status: string): void;
  
  /** Thông báo đơn hàng mới */
  NewOrderReceived(order: Order): void;
  
  /** Thông báo món ăn đã sẵn sàng */
  OrderItemReady(orderId: string, itemId: string): void;
  
  // Client to Server (Client gửi đến Server)
  /** Tham gia nhóm bếp */
  JoinKitchenGroup(): Promise<void>;
  
  /** Cập nhật trạng thái đơn hàng */
  UpdateOrderStatus(orderId: string, status: string): Promise<void>;
  
  /** Đánh dấu món đã sẵn sàng */
  MarkItemReady(orderId: string, itemId: string): Promise<void>;
}

// Table Management Hub (Hub Quản lý Bàn)
interface TableHub {
  // Server to Client (Server gửi đến Client)
  /** Thông báo thay đổi trạng thái bàn */
  TableStatusChanged(tableId: string, status: string): void;
  
  /** Thông báo cập nhật đơn hàng cho bàn */
  OrderUpdated(tableId: string, order: Order): void;
  
  // Client to Server (Client gửi đến Server)
  /** Tham gia nhóm quản lý bàn */
  JoinTableGroup(): Promise<void>;
  
  /** Cập nhật trạng thái bàn */
  UpdateTableStatus(tableId: string, status: string): Promise<void>;
}
```
