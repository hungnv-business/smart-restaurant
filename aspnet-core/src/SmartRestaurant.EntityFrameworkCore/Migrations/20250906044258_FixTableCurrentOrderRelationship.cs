using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class FixTableCurrentOrderRelationship : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppTables_AppOrders_CurrentOrderId1",
                table: "AppTables");

            migrationBuilder.DropIndex(
                name: "IX_AppTables_CurrentOrderId1",
                table: "AppTables");

            migrationBuilder.DropColumn(
                name: "CurrentOrderId1",
                table: "AppTables");

            migrationBuilder.CreateIndex(
                name: "IX_AppTables_CurrentOrderId",
                table: "AppTables",
                column: "CurrentOrderId",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_AppTables_AppOrders_CurrentOrderId",
                table: "AppTables",
                column: "CurrentOrderId",
                principalTable: "AppOrders",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppTables_AppOrders_CurrentOrderId",
                table: "AppTables");

            migrationBuilder.DropIndex(
                name: "IX_AppTables_CurrentOrderId",
                table: "AppTables");

            migrationBuilder.AddColumn<Guid>(
                name: "CurrentOrderId1",
                table: "AppTables",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_AppTables_CurrentOrderId1",
                table: "AppTables",
                column: "CurrentOrderId1");

            migrationBuilder.AddForeignKey(
                name: "FK_AppTables_AppOrders_CurrentOrderId1",
                table: "AppTables",
                column: "CurrentOrderId1",
                principalTable: "AppOrders",
                principalColumn: "Id");
        }
    }
}
