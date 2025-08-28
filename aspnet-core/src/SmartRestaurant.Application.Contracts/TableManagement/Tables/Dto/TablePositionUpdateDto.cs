using System;

namespace SmartRestaurant.TableManagement.Tables.Dto
{
    public class TablePositionUpdateDto
    {
        public Guid TableId { get; set; }
        public Guid LayoutSectionId { get; set; }
        public int DisplayOrder { get; set; }
    }
}