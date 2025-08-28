using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class UpdateMenuCategoryWithMenuItems : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "MenuCategoryId",
                table: "AppMenuItems",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_AppMenuItems_MenuCategoryId",
                table: "AppMenuItems",
                column: "MenuCategoryId");

            migrationBuilder.AddForeignKey(
                name: "FK_AppMenuItems_AppMenuCategories_MenuCategoryId",
                table: "AppMenuItems",
                column: "MenuCategoryId",
                principalTable: "AppMenuCategories",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppMenuItems_AppMenuCategories_MenuCategoryId",
                table: "AppMenuItems");

            migrationBuilder.DropIndex(
                name: "IX_AppMenuItems_MenuCategoryId",
                table: "AppMenuItems");

            migrationBuilder.DropColumn(
                name: "MenuCategoryId",
                table: "AppMenuItems");
        }
    }
}
