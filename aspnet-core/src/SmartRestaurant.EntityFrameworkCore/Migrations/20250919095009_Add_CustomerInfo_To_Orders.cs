using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class Add_CustomerInfo_To_Orders : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "CustomerName",
                table: "AppOrders",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "CustomerPhone",
                table: "AppOrders",
                type: "character varying(20)",
                maxLength: 20,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CustomerName",
                table: "AppOrders");

            migrationBuilder.DropColumn(
                name: "CustomerPhone",
                table: "AppOrders");
        }
    }
}
