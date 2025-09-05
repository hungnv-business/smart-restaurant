using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddOrderManagement : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "AppOrders",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrderNumber = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false),
                    TableId = table.Column<Guid>(type: "uuid", nullable: true),
                    OrderType = table.Column<int>(type: "integer", nullable: false),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    TotalAmount = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    Notes = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: true),
                    ConfirmedTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    PreparingTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    ReadyTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    ServedTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    PaidTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    ExtraProperties = table.Column<string>(type: "text", nullable: false),
                    ConcurrencyStamp = table.Column<string>(type: "character varying(40)", maxLength: 40, nullable: false),
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
                    table.PrimaryKey("PK_AppOrders", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppOrders_AppTables_TableId",
                        column: x => x.TableId,
                        principalTable: "AppTables",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "AppOrderItems",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OrderId = table.Column<Guid>(type: "uuid", nullable: false),
                    MenuItemId = table.Column<Guid>(type: "uuid", nullable: false),
                    MenuItemName = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Quantity = table.Column<int>(type: "integer", nullable: false),
                    UnitPrice = table.Column<decimal>(type: "numeric(18,2)", nullable: false),
                    Notes = table.Column<string>(type: "character varying(300)", maxLength: 300, nullable: true),
                    Status = table.Column<int>(type: "integer", nullable: false),
                    PreparationStartTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
                    PreparationCompleteTime = table.Column<DateTime>(type: "timestamp without time zone", nullable: true),
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
                    table.PrimaryKey("PK_AppOrderItems", x => x.Id);
                    table.ForeignKey(
                        name: "FK_AppOrderItems_AppMenuItems_MenuItemId",
                        column: x => x.MenuItemId,
                        principalTable: "AppMenuItems",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AppOrderItems_AppOrders_OrderId",
                        column: x => x.OrderId,
                        principalTable: "AppOrders",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AppOrderItems_MenuItemId",
                table: "AppOrderItems",
                column: "MenuItemId");

            migrationBuilder.CreateIndex(
                name: "IX_AppOrderItems_OrderId",
                table: "AppOrderItems",
                column: "OrderId");

            migrationBuilder.CreateIndex(
                name: "IX_AppOrderItems_OrderId_Status",
                table: "AppOrderItems",
                columns: new[] { "OrderId", "Status" });

            migrationBuilder.CreateIndex(
                name: "IX_AppOrders_CreationTime",
                table: "AppOrders",
                column: "CreationTime");

            migrationBuilder.CreateIndex(
                name: "IX_AppOrders_OrderNumber",
                table: "AppOrders",
                column: "OrderNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AppOrders_Status",
                table: "AppOrders",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_AppOrders_Status_CreationTime",
                table: "AppOrders",
                columns: new[] { "Status", "CreationTime" });

            migrationBuilder.CreateIndex(
                name: "IX_AppOrders_TableId",
                table: "AppOrders",
                column: "TableId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AppOrderItems");

            migrationBuilder.DropTable(
                name: "AppOrders");
        }
    }
}
