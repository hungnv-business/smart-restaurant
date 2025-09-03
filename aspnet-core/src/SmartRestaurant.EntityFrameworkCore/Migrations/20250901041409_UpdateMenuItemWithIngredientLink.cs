using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class UpdateMenuItemWithIngredientLink : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
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
        }
    }
}
