using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.SignalR;
using SmartRestaurant.HttpApi.Host.Hubs;

namespace SmartRestaurant.HttpApi.Host.Controllers;

[ApiController]
[Route("api/[controller]")]
public class TestController : ControllerBase
{
    private readonly IHubContext<KitchenHub> _kitchenHubContext;

    public TestController(IHubContext<KitchenHub> kitchenHubContext)
    {
        _kitchenHubContext = kitchenHubContext;
    }

    [HttpPost("send-test-order")]
    public async Task<IActionResult> SendTestOrder()
    {
        try
        {
            Console.WriteLine("🧪 TestController: Sending test order notification with Vietnamese message");
            
            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("NewOrderReceived", new
            {
                Order = new
                {
                    OrderNumber = "TEST-001",
                    TableName = "Bàn Test"
                },
                NotifiedAt = DateTime.UtcNow,
                Message = "Đơn hàng mới số TEST-001 từ Bàn Test cần chuẩn bị ngay"
            });
            
            Console.WriteLine("✅ TestController: Test Vietnamese message notification sent");
            return Ok("Test Vietnamese message notification sent");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ TestController: Error - {ex.Message}");
            return BadRequest($"Error: {ex.Message}");
        }
    }

    [HttpPost("send-test-quantity-update")]
    public async Task<IActionResult> SendTestQuantityUpdate()
    {
        try
        {
            Console.WriteLine("🧪 TestController: Sending test quantity update notification");
            
            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemQuantityUpdated", new
            {
                OrderNumber = "TEST-002",
                OrderItemId = Guid.NewGuid(),
                NewQuantity = 3,
                UpdatedAt = DateTime.UtcNow,
                Message = "Đơn hàng TEST-002 đã cập nhật số lượng Phở Bò thành 3 phần"
            });
            
            Console.WriteLine("✅ TestController: Test Vietnamese quantity update notification sent");
            return Ok("Test Vietnamese quantity update notification sent");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ TestController: Error - {ex.Message}");
            return BadRequest($"Error: {ex.Message}");
        }
    }

    [HttpPost("send-test-add-items")]
    public async Task<IActionResult> SendTestAddItems()
    {
        try
        {
            Console.WriteLine("🧪 TestController: Sending test add items notification");
            
            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemsAdded", new
            {
                OrderNumber = "TEST-003",
                ItemsCount = 2,
                AddedAt = DateTime.UtcNow,
                Message = "Đơn hàng TEST-003 đã thêm 2 món mới: Bún Bò Huế và Cơm Tấm"
            });
            
            Console.WriteLine("✅ TestController: Test Vietnamese add items notification sent");
            return Ok("Test Vietnamese add items notification sent");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ TestController: Error - {ex.Message}");
            return BadRequest($"Error: {ex.Message}");
        }
    }

    [HttpPost("send-test-remove-item")]
    public async Task<IActionResult> SendTestRemoveItem()
    {
        try
        {
            Console.WriteLine("🧪 TestController: Sending test remove item notification");
            
            await _kitchenHubContext.Clients.Group("Kitchen").SendAsync("OrderItemRemoved", new
            {
                OrderNumber = "TEST-004",
                OrderItemId = Guid.NewGuid(),
                MenuItemName = "Phở Bò",
                RemovedAt = DateTime.UtcNow,
                Message = "Đơn hàng TEST-004 đã xóa món Phở Bò tái nạm ra khỏi order"
            });
            
            Console.WriteLine("✅ TestController: Test Vietnamese remove item notification sent");
            return Ok("Test Vietnamese remove item notification sent");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ TestController: Error - {ex.Message}");
            return BadRequest($"Error: {ex.Message}");
        }
    }
}