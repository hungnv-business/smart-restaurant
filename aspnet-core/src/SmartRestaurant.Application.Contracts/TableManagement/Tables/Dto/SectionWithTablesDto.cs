using System;
using System.Collections.Generic;
using System.Linq;

namespace SmartRestaurant.TableManagement.Tables.Dto
{
    /// <summary>
    /// DTO chứa thông tin khu vực và danh sách bàn trong khu vực đó
    /// </summary>
    public class SectionWithTablesDto
    {
        /// <summary>ID khu vực</summary>
        public Guid Id { get; set; }
        
        /// <summary>Tên khu vực</summary>
        public string SectionName { get; set; } = string.Empty;
        
        /// <summary>Mô tả khu vực</summary>
        public string? Description { get; set; }
        
        /// <summary>Thứ tự hiển thị của khu vực</summary>
        public int DisplayOrder { get; set; }
        
        /// <summary>Trạng thái kích hoạt của khu vực</summary>
        public bool IsActive { get; set; }
        
        /// <summary>Danh sách bàn trong khu vực này</summary>
        public List<TableDto> Tables { get; set; } = [];
        
        /// <summary>Tổng số bàn trong khu vực</summary>
        public int TotalTables => Tables.Count;
        
        /// <summary>Số bàn đang hoạt động</summary>
        public int ActiveTables => Tables.Count(t => t.IsActive);
    }
}