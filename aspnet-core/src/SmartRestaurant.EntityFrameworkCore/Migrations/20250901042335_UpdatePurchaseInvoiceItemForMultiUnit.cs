using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class UpdatePurchaseInvoiceItemForMultiUnit : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppMenuItems_AppIngredients_PrimaryIngredientId",
                table: "AppMenuItems");

            migrationBuilder.AlterColumn<int>(
                name: "RequiredQuantity",
                table: "AppMenuItems",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<Guid>(
                name: "PrimaryIngredientId",
                table: "AppMenuItems",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"),
                oldClrType: typeof(Guid),
                oldType: "uuid",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_AppMenuItems_AppIngredients_PrimaryIngredientId",
                table: "AppMenuItems",
                column: "PrimaryIngredientId",
                principalTable: "AppIngredients",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppMenuItems_AppIngredients_PrimaryIngredientId",
                table: "AppMenuItems");

            migrationBuilder.AlterColumn<int>(
                name: "RequiredQuantity",
                table: "AppMenuItems",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<Guid>(
                name: "PrimaryIngredientId",
                table: "AppMenuItems",
                type: "uuid",
                nullable: true,
                oldClrType: typeof(Guid),
                oldType: "uuid");

            migrationBuilder.AddForeignKey(
                name: "FK_AppMenuItems_AppIngredients_PrimaryIngredientId",
                table: "AppMenuItems",
                column: "PrimaryIngredientId",
                principalTable: "AppIngredients",
                principalColumn: "Id");
        }
    }
}
