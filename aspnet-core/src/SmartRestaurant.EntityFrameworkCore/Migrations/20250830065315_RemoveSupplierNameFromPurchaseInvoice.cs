using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class RemoveSupplierNameFromPurchaseInvoice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_AppPurchaseInvoices_SupplierName",
                table: "AppPurchaseInvoices");

            migrationBuilder.DropColumn(
                name: "SupplierName",
                table: "AppPurchaseInvoices");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SupplierName",
                table: "AppPurchaseInvoices",
                type: "character varying(200)",
                maxLength: 200,
                nullable: false,
                defaultValue: "");

            migrationBuilder.CreateIndex(
                name: "IX_AppPurchaseInvoices_SupplierName",
                table: "AppPurchaseInvoices",
                column: "SupplierName");
        }
    }
}
