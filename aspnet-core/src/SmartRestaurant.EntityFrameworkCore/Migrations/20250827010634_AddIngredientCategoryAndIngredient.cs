using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddIngredientCategoryAndIngredient : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImageMetadata",
                table: "AppMenuCategories");

            migrationBuilder.CreateTable(
                name: "AppIngredientCategories",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    Description = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
                    DisplayOrder = table.Column<int>(type: "integer", nullable: false),
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
                    table.PrimaryKey("PK_AppIngredientCategories", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AppIngredients",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CategoryId = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(128)", maxLength: 128, nullable: false),
                    Description = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
                    Unit = table.Column<string>(type: "character varying(32)", maxLength: 32, nullable: false),
                    CostPerUnit = table.Column<decimal>(type: "numeric(18,2)", nullable: true),
                    SupplierInfo = table.Column<string>(type: "character varying(512)", maxLength: 512, nullable: true),
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
                    table.PrimaryKey("PK_AppIngredients", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppIngredients_AppIngredientCategories_CategoryId",
                        column: x => x.CategoryId,
                        principalTable: "AppIngredientCategories",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientCategories_DisplayOrder",
                table: "AppIngredientCategories",
                column: "DisplayOrder");

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientCategories_IsActive_DisplayOrder",
                table: "AppIngredientCategories",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredientCategories_Name",
                table: "AppIngredientCategories",
                column: "Name");

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredients_CategoryId",
                table: "AppIngredients",
                column: "CategoryId");

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredients_CategoryId_IsActive",
                table: "AppIngredients",
                columns: new[] { "CategoryId", "IsActive" });

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredients_Name",
                table: "AppIngredients",
                column: "Name");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AppIngredients");

            migrationBuilder.DropTable(
                name: "AppIngredientCategories");

            migrationBuilder.AddColumn<string>(
                name: "ImageMetadata",
                table: "AppMenuCategories",
                type: "jsonb",
                nullable: true);
        }
    }
}
