# Testing Strategy

## Testing Pyramid (Kim tự tháp Kiểm thử)

```
              E2E Tests (Playwright)
             /                    \
    Integration Tests (xUnit + Testcontainers)
           /                            \
  Frontend Unit (Jest)      Backend Unit (xUnit)
```

## Test Organization (Tổ chức Kiểm thử)

### Frontend Tests (Kiểm thử Frontend)

```
angular/tests/
├── unit/                           # Component and service unit tests
│   ├── components/
│   │   ├── order-processing.component.spec.ts
│   │   ├── menu-management.component.spec.ts
│   │   └── payment-processing.component.spec.ts
│   ├── services/
│   │   ├── order.service.spec.ts
│   │   ├── signalr.service.spec.ts
│   │   └── menu.service.spec.ts
│   └── pipes/
│       ├── vietnamese-currency.pipe.spec.ts
│       └── vietnamese-date.pipe.spec.ts
├── integration/                    # Service integration tests
│   ├── order-workflow.integration.spec.ts
│   ├── payment-workflow.integration.spec.ts
│   └── kitchen-signalr.integration.spec.ts
└── mocks/                         # Test data and mocks
    ├── order.mock.ts
    ├── menu.mock.ts
    └── signalr.mock.ts
```

### Backend Tests (Kiểm thử Backend)

```
test/
├── SmartRestaurant.Domain.Tests/
│   ├── Orders/
│   │   ├── OrderManager_Tests.cs
│   │   └── OrderDomainService_Tests.cs
│   ├── Menu/
│   │   ├── MenuItemManager_Tests.cs
│   │   └── MenuAvailabilityService_Tests.cs
│   └── Payments/
│       └── PaymentDomainService_Tests.cs
├── SmartRestaurant.Application.Tests/
│   ├── Orders/
│   │   ├── OrderAppService_Tests.cs
│   │   └── OrderCreation_Tests.cs
│   ├── Menu/
│   │   ├── MenuItemAppService_Tests.cs
│   │   └── VietnameseTextSearch_Tests.cs
│   └── Payments/
│       └── PaymentAppService_Tests.cs
└── SmartRestaurant.HttpApi.Tests/
    ├── Controllers/
    │   ├── OrderController_Tests.cs
    │   └── PaymentController_Tests.cs
    └── SignalR/
        ├── KitchenHub_Tests.cs
        └── TableHub_Tests.cs
```

### E2E Tests (Kiểm thử E2E)

```
tests/e2e/
├── order-processing.e2e.ts        # Complete order workflow
├── payment-processing.e2e.ts      # Vietnamese payment flow
├── kitchen-workflow.e2e.ts        # Kitchen display and updates
├── menu-management.e2e.ts         # Menu CRUD operations
├── table-management.e2e.ts        # Table status management
└── reservation-workflow.e2e.ts    # Phone reservation process
```

## Test Examples (Ví dụ Kiểm thử)

### Frontend Component Test (Kiểm thử Component Frontend)

```typescript
// order-processing.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { MockStore, provideMockStore } from '@ngrx/store/testing';
import { OrderProcessingComponent } from './order-processing.component';
import { OrderService } from '@shared/services/order.service';
import { SignalRService } from '@core/signalr/signalr.service';

describe('OrderProcessingComponent', () => {
  let component: OrderProcessingComponent;
  let fixture: ComponentFixture<OrderProcessingComponent>;
  let store: MockStore;
  let orderService: jasmine.SpyObj<OrderService>;
  let signalRService: jasmine.SpyObj<SignalRService>;

  const initialState = {
    orders: {
      orders: [],
      selectedOrder: null,
      loading: false
    },
    tables: {
      tables: [
        { tableId: '1', tableNumber: 'B01', capacity: 4, status: 'Available' }
      ]
    }
  };

  beforeEach(async () => {
    const orderServiceSpy = jasmine.createSpyObj('OrderService', 
      ['createOrder', 'getAvailableMenuItems']);
    const signalRServiceSpy = jasmine.createSpyObj('SignalRService', 
      ['updateOrderStatus']);

    await TestBed.configureTestingModule({
      declarations: [OrderProcessingComponent],
      providers: [
        provideMockStore({ initialState }),
        { provide: OrderService, useValue: orderServiceSpy },
        { provide: SignalRService, useValue: signalRServiceSpy }
      ]
    }).compileComponents();

    store = TestBed.inject(MockStore);
    orderService = TestBed.inject(OrderService) as jasmine.SpyObj<OrderService>;
    signalRService = TestBed.inject(SignalRService) as jasmine.SpyObj<SignalRService>;

    fixture = TestBed.createComponent(OrderProcessingComponent);
    component = fixture.componentInstance;
  });

  it('should create order when table selected and items added', async () => {
    // Arrange
    const table = { tableId: '1', tableNumber: 'B01', capacity: 4, status: 'Available' };
    const menuItem = { 
      menuItemId: '1', 
      name: 'Phở Bò', 
      price: 65000, 
      isAvailable: true 
    };
    orderService.createOrder.and.returnValue(Promise.resolve({ orderId: '123' }));

    // Act
    component.onTableSelected(table);
    component.onMenuItemSelected(menuItem, 2);
    await component.confirmOrder();

    // Assert
    expect(orderService.createOrder).toHaveBeenCalledWith(
      jasmine.objectContaining({
        tableId: '1',
        orderItems: jasmine.arrayContaining([
          jasmine.objectContaining({
            menuItemId: '1',
            quantity: 2
          })
        ])
      })
    );
  });

  it('should handle Vietnamese currency formatting', () => {
    // Test Vietnamese dong formatting
    component.currentOrder = {
      orderId: '1',
      totalAmount: 150000,
      orderItems: []
    };
    
    fixture.detectChanges();
    
    const totalElement = fixture.debugElement.query(By.css('.total-amount'));
    expect(totalElement.nativeElement.textContent).toContain('150.000 ₫');
  });
});
```

### Backend API Test (Kiểm thử API Backend)

```csharp
// OrderAppService_Tests.cs
using Xunit;
using Shouldly;
using System.Threading.Tasks;
using SmartRestaurant.Orders;
using SmartRestaurant.Tables;

namespace SmartRestaurant.Application.Tests.Orders
{
    public class OrderAppService_Tests : SmartRestaurantApplicationTestBase
    {
        private readonly IOrderAppService _orderAppService;
        private readonly ITableAppService _tableAppService;

        public OrderAppService_Tests()
        {
            _orderAppService = GetRequiredService<IOrderAppService>();
            _tableAppService = GetRequiredService<ITableAppService>();
        }

        [Fact]
        public async Task Should_Create_Order_With_Vietnamese_Items()
        {
            // Arrange
            var table = await CreateTestTableAsync();
            var menuItems = await CreateTestMenuItemsAsync();
            
            var createOrderDto = new CreateOrderDto
            {
                TableId = table.Id,
                OrderType = OrderType.DineIn,
                OrderItems = new List<CreateOrderItemDto>
                {
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItems[0].Id, // Phở Bò
                        Quantity = 2,
                        ItemNotes = "Không hành"
                    },
                    new CreateOrderItemDto
                    {
                        MenuItemId = menuItems[1].Id, // Cơm Tấm
                        Quantity = 1
                    }
                }
            };

            // Act
            var result = await _orderAppService.CreateAsync(createOrderDto);

            // Assert
            result.ShouldNotBeNull();
            result.TableId.ShouldBe(table.Id);
            result.OrderType.ShouldBe(OrderType.DineIn);
            result.OrderItems.Count.ShouldBe(2);
            result.TotalAmount.ShouldBe(195000); // 65000*2 + 65000
            result.OrderNumber.ShouldNotBeNullOrEmpty();
            
            // Verify table status updated
            var updatedTable = await _tableAppService.GetAsync(table.Id);
            updatedTable.Status.ShouldBe(TableStatus.Occupied);
        }

        [Fact]
        public async Task Should_Process_Vietnamese_Payment_Workflow()
        {
            // Arrange
            var order = await CreateTestOrderAsync();
            
            var paymentDto = new InitiatePaymentDto
            {
                PaymentMethod = PaymentMethod.BankTransfer,
                Amount = order.TotalAmount
            };

            // Act - Initiate payment
            var payment = await _orderAppService.InitiatePaymentAsync(order.Id, paymentDto);
            
            // Assert payment created
            payment.ShouldNotBeNull();
            payment.Status.ShouldBe(PaymentStatus.Pending);
            payment.QRCodeData.ShouldNotBeNullOrEmpty();

            // Act - Confirm payment (staff confirmation)
            await _orderAppService.ConfirmPaymentAsync(payment.Id);
            
            // Assert payment confirmed and table reset
            var confirmedPayment = await GetPaymentAsync(payment.Id);
            confirmedPayment.Status.ShouldBe(PaymentStatus.Confirmed);
            confirmedPayment.ConfirmedBy.ShouldNotBeNull();
            
            var updatedOrder = await _orderAppService.GetAsync(order.Id);
            updatedOrder.Status.ShouldBe(OrderStatus.Paid);
            
            var table = await _tableAppService.GetAsync(order.TableId);
            table.Status.ShouldBe(TableStatus.Available);
        }

        private async Task<TableDto> CreateTestTableAsync()
        {
            return await _tableAppService.CreateAsync(new CreateTableDto
            {
                TableNumber = "B01",
                Capacity = 4,
                Location = "Tầng 1"
            });
        }

        private async Task<List<MenuItemDto>> CreateTestMenuItemsAsync()
        {
            var category = await CreateTestCategoryAsync("Món chính");
            
            return new List<MenuItemDto>
            {
                await CreateTestMenuItemAsync("Phở Bò", 65000, category.Id),
                await CreateTestMenuItemAsync("Cơm Tấm", 65000, category.Id),
                await CreateTestMenuItemAsync("Bún Bò Huế", 70000, category.Id)
            };
        }
    }
}
```

### E2E Test (Kiểm thử E2E)

```typescript
// order-processing.e2e.ts
import { test, expect } from '@playwright/test';

test.describe('Restaurant Order Processing', () => {
  test.beforeEach(async ({ page }) => {
    // Login as restaurant staff
    await page.goto('/login');
    await page.fill('[data-test="username"]', 'staff@restaurant.com');
    await page.fill('[data-test="password"]', 'Staff123!');
    await page.click('[data-test="login-button"]');
    await page.waitForURL('/dashboard');
  });

  test('complete order workflow: table selection to payment', async ({ page }) => {
    // Step 1: Select available table
    await page.click('[data-test="table-B01"]');
    await expect(page.locator('[data-test="selected-table"]')).toContainText('Bàn B01');

    // Step 2: Browse menu and add items
    await page.click('[data-test="menu-tab"]');
    await page.click('[data-test="category-mon-chinh"]');
    
    // Add Phở Bò (2 servings)
    await page.click('[data-test="menu-item-pho-bo"]');
    await page.fill('[data-test="quantity-input"]', '2');
    await page.fill('[data-test="item-notes"]', 'Không hành');
    await page.click('[data-test="add-to-order"]');

    // Add Cơm Tấm (1 serving)
    await page.click('[data-test="menu-item-com-tam"]');
    await page.click('[data-test="add-to-order"]');

    // Verify order summary
    await expect(page.locator('[data-test="order-total"]')).toContainText('195.000 ₫');

    // Step 3: Confirm order
    await page.click('[data-test="confirm-order"]');
    await expect(page.locator('[data-test="order-status"]')).toContainText('Đã xác nhận');

    // Verify kitchen bill printed (mock check)
    await expect(page.locator('[data-test="kitchen-notification"]')).toBeVisible();

    // Step 4: Simulate order preparation
    // Switch to kitchen view
    await page.goto('/kitchen');
    await page.click(`[data-test="order-item-preparing"]`);
    await page.click(`[data-test="mark-ready"]`);

    // Step 5: Return to order management and process payment
    await page.goto('/dashboard');
    await page.click('[data-test="table-B01"]');
    await page.click('[data-test="payment-button"]');

    // Auto-print invoice
    await expect(page.locator('[data-test="invoice-printed"]')).toBeVisible();

    // Staff confirms cash payment
    await page.click('[data-test="cash-payment"]');
    await page.click('[data-test="payment-completed"]');

    // Verify table reset to available
    await expect(page.locator('[data-test="table-B01-status"]')).toContainText('Khả dụng');
  });

  test('takeaway order workflow', async ({ page }) => {
    // Start takeaway order (no table selection)
    await page.click('[data-test="takeaway-order"]');

    // Add menu items
    await page.click('[data-test="menu-item-pho-bo"]');
    await page.fill('[data-test="quantity-input"]', '3');
    await page.click('[data-test="add-to-order"]');

    // Confirm order
    await page.click('[data-test="confirm-order"]');

    // Verify kitchen display shows "MANG VỀ" marking
    await page.goto('/kitchen');
    await expect(page.locator('[data-test="takeaway-marker"]')).toContainText('MANG VỀ');

    // Complete takeaway workflow
    await page.click('[data-test="mark-ready"]');
    await page.goto('/dashboard');
    await page.click('[data-test="complete-takeaway"]');
  });

  test('Vietnamese payment methods', async ({ page }) => {
    // Create order first
    await createTestOrder(page);

    // Test bank transfer payment
    await page.click('[data-test="bank-transfer-payment"]');
    await expect(page.locator('[data-test="qr-code"]')).toBeVisible();
    await expect(page.locator('[data-test="payment-amount"]')).toContainText('₫');

    // Staff confirms bank transfer received
    await page.click('[data-test="confirm-bank-transfer"]');
    await expect(page.locator('[data-test="payment-completed"]')).toBeVisible();
  });

  async function createTestOrder(page) {
    await page.click('[data-test="table-B02"]');
    await page.click('[data-test="menu-item-pho-bo"]');
    await page.click('[data-test="add-to-order"]');
    await page.click('[data-test="confirm-order"]');
  }
});
```
