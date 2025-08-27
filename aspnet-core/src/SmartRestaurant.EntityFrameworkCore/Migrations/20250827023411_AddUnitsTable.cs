using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class AddUnitsTable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Unit",
                table: "AppIngredients");

            migrationBuilder.AddColumn<Guid>(
                name: "UnitId",
                table: "AppIngredients",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateTable(
                name: "AppUnits",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Name = table.Column<string>(type: "character varying(64)", maxLength: 64, nullable: false),
                    DisplayOrder = table.Column<int>(type: "integer", nullable: false),
                    IsActive = table.Column<bool>(type: "boolean", nullable: false),
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
                    table.PrimaryKey("PK_AppUnits", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_AppIngredients_UnitId",
                table: "AppIngredients",
                column: "UnitId");

            migrationBuilder.CreateIndex(
                name: "IX_AppUnits_DisplayOrder",
                table: "AppUnits",
                column: "DisplayOrder");

            migrationBuilder.CreateIndex(
                name: "IX_AppUnits_IsActive_DisplayOrder",
                table: "AppUnits",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_AppUnits_Name",
                table: "AppUnits",
                column: "Name",
                unique: true);

            migrationBuilder.AddForeignKey(
                name: "FK_AppIngredients_AppUnits_UnitId",
                table: "AppIngredients",
                column: "UnitId",
                principalTable: "AppUnits",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_AppIngredients_AppUnits_UnitId",
                table: "AppIngredients");

            migrationBuilder.DropTable(
                name: "AppUnits");

            migrationBuilder.DropIndex(
                name: "IX_AppIngredients_UnitId",
                table: "AppIngredients");

            migrationBuilder.DropColumn(
                name: "UnitId",
                table: "AppIngredients");

            migrationBuilder.AddColumn<string>(
                name: "Unit",
                table: "AppIngredients",
                type: "character varying(32)",
                maxLength: 32,
                nullable: false,
                defaultValue: "");
        }
    }
}
