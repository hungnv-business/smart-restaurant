using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddNavigationPropertyToPurchaseInvoiceItem : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddForeignKey(
                name: "FK_AppPurchaseInvoiceItems_AppIngredients_IngredientId",
                table: "AppPurchaseInvoiceItems",
                column: "IngredientId",
                principalTable: "AppIngredients",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppPurchaseInvoiceItems_AppIngredients_IngredientId",
                table: "AppPurchaseInvoiceItems");
        }
    }
}
