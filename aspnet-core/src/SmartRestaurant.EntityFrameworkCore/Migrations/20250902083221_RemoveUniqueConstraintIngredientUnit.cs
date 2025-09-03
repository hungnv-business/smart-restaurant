using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class RemoveUniqueConstraintIngredientUnit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_AppIngredientPurchaseUnits_IngredientId_UnitId",
                table: "AppIngredientPurchaseUnits");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientPurchaseUnits_IngredientId_UnitId",
                table: "AppIngredientPurchaseUnits",
                columns: new[] { "IngredientId", "UnitId" },
                unique: true);
        }
    }
}
