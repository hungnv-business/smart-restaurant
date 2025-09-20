﻿using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class ChangePaymentToOneToOne : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_AppPayments_OrderId",
                table: "AppPayments");

            migrationBuilder.CreateIndex(
                name: "IX_AppPayments_OrderId",
                table: "AppPayments",
                column: "OrderId",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_AppPayments_OrderId",
                table: "AppPayments");

            migrationBuilder.CreateIndex(
                name: "IX_AppPayments_OrderId",
                table: "AppPayments",
                column: "OrderId");
        }
    }
}
