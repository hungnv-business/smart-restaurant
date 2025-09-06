using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class RemoveRedundantOrderTimestamps : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ConfirmedTime",
                table: "AppOrders");

            migrationBuilder.DropColumn(
                name: "PreparingTime",
                table: "AppOrders");

            migrationBuilder.DropColumn(
                name: "ReadyTime",
                table: "AppOrders");

            migrationBuilder.DropColumn(
                name: "ServedTime",
                table: "AppOrders");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "ConfirmedTime",
                table: "AppOrders",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PreparingTime",
                table: "AppOrders",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ReadyTime",
                table: "AppOrders",
                type: "timestamp without time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ServedTime",
                table: "AppOrders",
                type: "timestamp without time zone",
                nullable: true);
        }
    }
}
