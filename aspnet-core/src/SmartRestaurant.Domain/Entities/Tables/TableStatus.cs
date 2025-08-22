namespace SmartRestaurant.Entities.Tables
{
    /// <summary>Trạng thái của bàn ăn trong nhà hàng</summary>
    public enum TableStatus
    {
        /// <summary>Bàn có sẵn, sẵn sàng phục vụ khách hàng</summary>
        Available = 0,
        
        /// <summary>Bàn đang được sử dụng bởi khách hàng</summary>
        Occupied = 1,
        
        /// <summary>Bàn đã được đặt trước</summary>
        Reserved = 2,
        
        /// <summary>Bàn tạm thời ngưng phục vụ (bảo trì, dọn dẹp, v.v.)</summary>
        OutOfService = 3
    }
}