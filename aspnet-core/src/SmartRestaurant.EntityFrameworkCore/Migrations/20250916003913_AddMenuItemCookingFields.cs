using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddMenuItemCookingFields : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsQuickCook",
                table: "AppMenuItems",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "RequiresCooking",
                table: "AppMenuItems",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsQuickCook",
                table: "AppMenuItems");

            migrationBuilder.DropColumn(
                name: "RequiresCooking",
                table: "AppMenuItems");
        }
    }
}
