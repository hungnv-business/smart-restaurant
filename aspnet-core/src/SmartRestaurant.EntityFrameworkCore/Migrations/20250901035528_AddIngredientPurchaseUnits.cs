using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddIngredientPurchaseUnits : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AppIngredientPurchaseUnits",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    IngredientId = table.Column<Guid>(type: "uuid", nullable: false),
                    UnitId = table.Column<Guid>(type: "uuid", nullable: false),
                    ConversionRatio = table.Column<int>(type: "integer", nullable: false),
                    IsBaseUnit = table.Column<bool>(type: "boolean", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
                    CreationTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    CreatorId = table.Column<Guid>(type: "uuid", nullable: true),
                    LastModificationTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    LastModifierId = table.Column<Guid>(type: "uuid", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    DeleterId = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletionTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppIngredientPurchaseUnits", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppIngredientPurchaseUnits_AppIngredients_IngredientId",
                        column: x => x.IngredientId,
                        principalTable: "AppIngredients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AppIngredientPurchaseUnits_AppUnits_UnitId",
                        column: x => x.UnitId,
                        principalTable: "AppUnits",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            // Data Migration: Create base unit entries for existing ingredients
            // Each existing ingredient's UnitId becomes its base unit with ConversionRatio = 1
            migrationBuilder.Sql(@"
                INSERT INTO ""AppIngredientPurchaseUnits"" 
                (""Id"", ""IngredientId"", ""UnitId"", ""ConversionRatio"", ""IsBaseUnit"", ""IsActive"", ""CreationTime"")
                SELECT 
                    gen_random_uuid() as ""Id"",
                    ""Id"" as ""IngredientId"",
                    ""UnitId"" as ""UnitId"",
                    1 as ""ConversionRatio"",
                    true as ""IsBaseUnit"",
                    true as ""IsActive"",
                    CURRENT_TIMESTAMP as ""CreationTime""
                FROM ""AppIngredients""
                WHERE ""IsDeleted"" = false;
            ");

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientPurchaseUnits_IngredientId",
                table: "AppIngredientPurchaseUnits",
                column: "IngredientId",
                unique: true,
                filter: "\"IsBaseUnit\" = true");

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientPurchaseUnits_IngredientId_IsActive",
                table: "AppIngredientPurchaseUnits",
                columns: new[] { "IngredientId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientPurchaseUnits_IngredientId_UnitId",
                table: "AppIngredientPurchaseUnits",
                columns: new[] { "IngredientId", "UnitId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientPurchaseUnits_UnitId",
                table: "AppIngredientPurchaseUnits",
                column: "UnitId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AppIngredientPurchaseUnits");
        }
    }
}
