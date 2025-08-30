using System;
using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddDimDateAndUpdatePurchaseInvoice : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_AppPurchaseInvoices_InvoiceDate",
                table: "AppPurchaseInvoices");

            migrationBuilder.DropColumn(
                name: "InvoiceDate",
                table: "AppPurchaseInvoices");

            migrationBuilder.AddColumn<int>(
                name: "InvoiceDateId",
                table: "AppPurchaseInvoices",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.CreateTable(
                name: "AppDimDates",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    date = table.Column<DateTime>(type: "timestamp without time zone", nullable: false),
                    date_vn_format = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    date_vn_short_format = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    date_uk_format = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    date_uk_short_format = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    date_us_format = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    date_us_short_format = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    date_iso_format = table.Column<string>(type: "character varying(10)", maxLength: 10, nullable: false),
                    num_year = table.Column<int>(type: "integer", nullable: false),
                    num_quarter_in_year = table.Column<int>(type: "integer", nullable: false),
                    num_month_in_year = table.Column<int>(type: "integer", nullable: false),
                    num_month_in_quarter = table.Column<int>(type: "integer", nullable: false),
                    num_week_in_year = table.Column<int>(type: "integer", nullable: false),
                    num_week_in_quarter = table.Column<int>(type: "integer", nullable: false),
                    num_week_in_month = table.Column<int>(type: "integer", nullable: false),
                    num_day_in_year = table.Column<int>(type: "integer", nullable: false),
                    num_day_in_quarter = table.Column<int>(type: "integer", nullable: false),
                    num_day_in_month = table.Column<int>(type: "integer", nullable: false),
                    num_day_in_week = table.Column<int>(type: "integer", nullable: false),
                    is_holiday_us = table.Column<bool>(type: "boolean", nullable: false),
                    name_month_en = table.Column<string>(type: "character varying(9)", maxLength: 9, nullable: false),
                    name_month_abbreviated_en = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false),
                    name_day_en = table.Column<string>(type: "character varying(9)", maxLength: 9, nullable: false),
                    name_day_abbreviated_en = table.Column<string>(type: "character varying(3)", maxLength: 3, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AppDimDates", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AppPurchaseInvoices_InvoiceDateId",
                table: "AppPurchaseInvoices",
                column: "InvoiceDateId");

            migrationBuilder.CreateIndex(
                name: "IX_AppDimDates_date",
                table: "AppDimDates",
                column: "date",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_AppPurchaseInvoices_AppDimDates_InvoiceDateId",
                table: "AppPurchaseInvoices",
                column: "InvoiceDateId",
                principalTable: "AppDimDates",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppPurchaseInvoices_AppDimDates_InvoiceDateId",
                table: "AppPurchaseInvoices");

            migrationBuilder.DropTable(
                name: "AppDimDates");

            migrationBuilder.DropIndex(
                name: "IX_AppPurchaseInvoices_InvoiceDateId",
                table: "AppPurchaseInvoices");

            migrationBuilder.DropColumn(
                name: "InvoiceDateId",
                table: "AppPurchaseInvoices");

            migrationBuilder.AddColumn<DateTime>(
                name: "InvoiceDate",
                table: "AppPurchaseInvoices",
                type: "timestamp without time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.CreateIndex(
                name: "IX_AppPurchaseInvoices_InvoiceDate",
                table: "AppPurchaseInvoices",
                column: "InvoiceDate");
        }
    }
}
