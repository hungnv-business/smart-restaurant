using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddMenuItemIngredients : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppMenuItems_AppIngredients_PrimaryIngredientId",
                table: "AppMenuItems");

            migrationBuilder.DropIndex(
                name: "IX_AppMenuItems_PrimaryIngredientId",
                table: "AppMenuItems");

            migrationBuilder.DropColumn(
                name: "PrimaryIngredientId",
                table: "AppMenuItems");

            migrationBuilder.DropColumn(
                name: "RequiredQuantity",
                table: "AppMenuItems");

            migrationBuilder.CreateTable(
                name: "AppMenuItemIngredients",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    MenuItemId = table.Column<Guid>(type: "uuid", nullable: false),
                    IngredientId = table.Column<Guid>(type: "uuid", nullable: false),
                    RequiredQuantity = table.Column<int>(type: "integer", nullable: false),
                    IsOptional = table.Column<bool>(type: "boolean", nullable: false),
                    PreparationNotes = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    DisplayOrder = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppMenuItemIngredients", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppMenuItemIngredients_AppIngredients_IngredientId",
                        column: x => x.IngredientId,
                        principalTable: "AppIngredients",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AppMenuItemIngredients_AppMenuItems_MenuItemId",
                        column: x => x.MenuItemId,
                        principalTable: "AppMenuItems",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AppMenuItemIngredients_IngredientId",
                table: "AppMenuItemIngredients",
                column: "IngredientId");

            migrationBuilder.CreateIndex(
                name: "IX_AppMenuItemIngredients_MenuItemId",
                table: "AppMenuItemIngredients",
                column: "MenuItemId");

            migrationBuilder.CreateIndex(
                name: "IX_AppMenuItemIngredients_MenuItemId_DisplayOrder",
                table: "AppMenuItemIngredients",
                columns: new[] { "MenuItemId", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_AppMenuItemIngredients_MenuItemId_IngredientId",
                table: "AppMenuItemIngredients",
                columns: new[] { "MenuItemId", "IngredientId" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AppMenuItemIngredients");

            migrationBuilder.AddColumn<Guid>(
                name: "PrimaryIngredientId",
                table: "AppMenuItems",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "RequiredQuantity",
                table: "AppMenuItems",
                type: "integer",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_AppMenuItems_PrimaryIngredientId",
                table: "AppMenuItems",
                column: "PrimaryIngredientId");

            migrationBuilder.AddForeignKey(
                name: "FK_AppMenuItems_AppIngredients_PrimaryIngredientId",
                table: "AppMenuItems",
                column: "PrimaryIngredientId",
                principalTable: "AppIngredients",
                principalColumn: "Id");
        }
    }
}
