-- Migration script để chuyển dữ liệu từ MenuItem.PrimaryIngredientId sang MenuItemIngredients table
-- Chạy script này sau khi đã tạo MenuItemIngredients table thành công

-- Insert MenuItemIngredient records từ existing PrimaryIngredientId data
INSERT INTO "AppMenuItemIngredients" (
    "Id", 
    "MenuItemId", 
    "IngredientId", 
    "RequiredQuantity", 
    "IsOptional", 
    "PreparationNotes", 
    "DisplayOrder",
    "CreationTime"
)
SELECT 
    gen_random_uuid() as "Id",
    mi."Id" as "MenuItemId",
    mi."PrimaryIngredientId" as "IngredientId",
    COALESCE(mi."RequiredQuantity", 1) as "RequiredQuantity",
    false as "IsOptional", -- Primary ingredient là bắt buộc
    NULL as "PreparationNotes",
    0 as "DisplayOrder", -- Primary ingredient có priority cao nhất
    NOW() as "CreationTime"
FROM "AppMenuItems" mi 
WHERE mi."PrimaryIngredientId" IS NOT NULL
  AND mi."RequiredQuantity" IS NOT NULL;

-- Verification query - kiểm tra số lượng records đã migrate
-- SELECT 
--     COUNT(*) as TotalMigratedRecords,
--     COUNT(DISTINCT "MenuItemId") as UniqueMenuItems
-- FROM "AppMenuItemIngredients" 
-- WHERE "DisplayOrder" = 0 AND "IsOptional" = false;

-- Optional: Log migration results
-- INSERT INTO "AppMigrationLog" ("Id", "MigrationName", "ExecutedAt", "RecordsProcessed", "Notes")
-- SELECT 
--     gen_random_uuid(),
--     'MigratePrimaryIngredientToMenuItemIngredients',
--     NOW(),
--     COUNT(*),
--     'Migrated PrimaryIngredientId to MenuItemIngredients relationship'
-- FROM "AppMenuItemIngredients" 
-- WHERE "DisplayOrder" = 0 AND "IsOptional" = false;

-- Note: Không xóa PrimaryIngredientId và RequiredQuantity columns ngay lập tức
-- Giữ chúng với Obsolete attribute để backward compatibility
-- Sẽ xóa trong future release sau khi confirm migration thành công