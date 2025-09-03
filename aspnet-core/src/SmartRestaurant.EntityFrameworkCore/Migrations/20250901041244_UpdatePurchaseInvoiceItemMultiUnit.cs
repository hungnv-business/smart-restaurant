using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePurchaseInvoiceItemMultiUnit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "UnitId",
                table: "AppPurchaseInvoiceItems",
                newName: "PurchaseUnitId");

            migrationBuilder.AddColumn<int>(
                name: "BaseUnitQuantity",
                table: "AppPurchaseInvoiceItems",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateIndex(
                name: "IX_AppPurchaseInvoiceItems_PurchaseUnitId",
                table: "AppPurchaseInvoiceItems",
                column: "PurchaseUnitId");

            migrationBuilder.AddForeignKey(
                name: "FK_AppPurchaseInvoiceItems_AppIngredientPurchaseUnits_Purchase~",
                table: "AppPurchaseInvoiceItems",
                column: "PurchaseUnitId",
                principalTable: "AppIngredientPurchaseUnits",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppPurchaseInvoiceItems_AppIngredientPurchaseUnits_Purchase~",
                table: "AppPurchaseInvoiceItems");

            migrationBuilder.DropIndex(
                name: "IX_AppPurchaseInvoiceItems_PurchaseUnitId",
                table: "AppPurchaseInvoiceItems");

            migrationBuilder.DropColumn(
                name: "BaseUnitQuantity",
                table: "AppPurchaseInvoiceItems");

            migrationBuilder.RenameColumn(
                name: "PurchaseUnitId",
                table: "AppPurchaseInvoiceItems",
                newName: "UnitId");
        }
    }
}
