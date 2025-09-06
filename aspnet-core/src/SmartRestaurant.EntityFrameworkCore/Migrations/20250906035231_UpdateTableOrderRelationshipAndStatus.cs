using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class UpdateTableOrderRelationshipAndStatus : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "CurrentOrderId",
                table: "AppTables",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "CurrentOrderId1",
                table: "AppTables",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedTime",
                table: "AppOrders",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<DateTime>(
                name: "CanceledTime",
                table: "AppOrderItems",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PendingTime",
                table: "AppOrderItems",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ServedTime",
                table: "AppOrderItems",
                type: "timestamp without time zone",
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

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppTables_AppOrders_CurrentOrderId1",
                table: "AppTables");

            migrationBuilder.DropIndex(
                name: "IX_AppTables_CurrentOrderId1",
                table: "AppTables");

            migrationBuilder.DropColumn(
                name: "CurrentOrderId",
                table: "AppTables");

            migrationBuilder.DropColumn(
                name: "CurrentOrderId1",
                table: "AppTables");

            migrationBuilder.DropColumn(
                name: "CreatedTime",
                table: "AppOrders");

            migrationBuilder.DropColumn(
                name: "CanceledTime",
                table: "AppOrderItems");

            migrationBuilder.DropColumn(
                name: "PendingTime",
                table: "AppOrderItems");

            migrationBuilder.DropColumn(
                name: "ServedTime",
                table: "AppOrderItems");
        }
    }
}
