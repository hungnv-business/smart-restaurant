using System;

namespace SmartRestaurant.Common.Dto
{
    /// <summary>
    /// Lookup DTO cho ID kiểu int (TableStatus, OrderStatus, etc.)
    /// </summary>
    public class IntLookupItemDto
    {
        /// <summary>ID của item (int)</summary>
        public int Id { get; set; }
        
        /// <summary>Tên hiển thị của item</summary>
        public string DisplayName { get; set; } = string.Empty;
    }

    /// <summary>
    /// Lookup DTO cho ID kiểu Guid (User, Role, Section, etc.)
    /// </summary>
    public class GuidLookupItemDto
    {
        /// <summary>ID của item (Guid)</summary>
        public Guid Id { get; set; }
        
        /// <summary>Tên hiển thị của item</summary>
        public string DisplayName { get; set; } = string.Empty;
    }

    /// <summary>
    /// Lookup DTO cho ID kiểu string (Permission, Setting Key, etc.)
    /// </summary>
    public class StringLookupItemDto
    {
        /// <summary>ID của item (string)</summary>
        public string Id { get; set; } = string.Empty;
        
        /// <summary>Tên hiển thị của item</summary>
        public string DisplayName { get; set; } = string.Empty;
    }
}