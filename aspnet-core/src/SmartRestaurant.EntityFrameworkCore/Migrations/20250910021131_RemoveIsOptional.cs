using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace SmartRestaurant.Migrations
{
    /// <inheritdoc />
    public partial class RemoveIsOptional : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "IsOptional",
                table: "AppMenuItemIngredients");

            migrationBuilder.DropColumn(
                name: "PreparationNotes",
                table: "AppMenuItemIngredients");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "IsOptional",
                table: "AppMenuItemIngredients",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<string>(
                name: "PreparationNotes",
                table: "AppMenuItemIngredients",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);
        }
    }
}
