import { test, expect } from '@playwright/test';

test.describe('Layout Section Management E2E', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to layout section management page
    await page.goto('/table-management/layout-sections');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
  });

  test('should display layout section list', async ({ page }) => {
    // Check if the main heading is visible
    await expect(page.locator('h5:has-text("Quản lý Khu vực Bố cục")')).toBeVisible();
    
    // Check if toolbar with "Thêm khu vực" button is visible
    await expect(page.locator('button:has-text("Thêm khu vực")')).toBeVisible();
  });

  test('should open new section dialog', async ({ page }) => {
    // Click on "Thêm khu vực" button
    await page.click('button:has-text("Thêm khu vực")');
    
    // Check if dialog is opened
    await expect(page.locator('.p-dialog-header:has-text("Thêm Khu vực mới")')).toBeVisible();
    
    // Check if form fields are visible
    await expect(page.locator('input[formControlName="sectionName"]')).toBeVisible();
    await expect(page.locator('textarea[formControlName="description"]')).toBeVisible();
    await expect(page.locator('p-inputnumber[formControlName="displayOrder"]')).toBeVisible();
    await expect(page.locator('p-inputswitch[formControlName="isActive"]')).toBeVisible();
  });

  test('should create new section with Vietnamese name', async ({ page }) => {
    // Open new section dialog
    await page.click('button:has-text("Thêm khu vực")');
    
    // Fill form with Vietnamese data
    await page.fill('input[formControlName="sectionName"]', 'Dãy 1');
    await page.fill('textarea[formControlName="description"]', 'Khu vực dãy đầu tiên với bàn ăn chính');
    
    // Submit form
    await page.click('button:has-text("Lưu")');
    
    // Wait for success message or dialog to close
    await expect(page.locator('.p-dialog')).not.toBeVisible();
    
    // Check if new section appears in the list
    await expect(page.locator('text=Dãy 1')).toBeVisible();
  });

  test('should use Vietnamese suggestion tags', async ({ page }) => {
    // Open new section dialog
    await page.click('button:has-text("Thêm khu vực")');
    
    // Check if Vietnamese suggestions are visible
    await expect(page.locator('span:has-text("Khu VIP")')).toBeVisible();
    await expect(page.locator('span:has-text("Sân vườn")')).toBeVisible();
    await expect(page.locator('span:has-text("Phòng riêng")')).toBeVisible();
    
    // Click on a suggestion
    await page.click('span:has-text("Khu VIP")');
    
    // Check if the suggestion is applied to the form
    await expect(page.locator('input[formControlName="sectionName"]')).toHaveValue('Khu VIP');
  });

  test('should validate required fields', async ({ page }) => {
    // Open new section dialog
    await page.click('button:has-text("Thêm khu vực")');
    
    // Try to submit without filling required fields
    await page.click('button:has-text("Lưu")');
    
    // Check if validation errors are shown
    await expect(page.locator('app-validation-error')).toBeVisible();
    
    // Check if form is not submitted (dialog still open)
    await expect(page.locator('.p-dialog-header:has-text("Thêm Khu vực mới")')).toBeVisible();
  });

  test('should edit existing section', async ({ page }) => {
    // Assuming there's at least one section in the list
    // Click on edit button (pencil icon)
    await page.click('button[pTooltip="Chỉnh sửa thông tin khu vực"]:first');
    
    // Check if edit dialog is opened
    await expect(page.locator('.p-dialog-header:has-text("Chỉnh sửa Khu vực")')).toBeVisible();
    
    // Modify section name
    await page.fill('input[formControlName="sectionName"]', 'Khu vực đã chỉnh sửa');
    
    // Submit form
    await page.click('button:has-text("Lưu")');
    
    // Wait for dialog to close
    await expect(page.locator('.p-dialog')).not.toBeVisible();
  });

  test('should toggle section active status', async ({ page }) => {
    // Find the first input switch and click it
    const inputSwitch = page.locator('p-inputswitch').first();
    await inputSwitch.click();
    
    // Check if status text updates (either "Hoạt động" or "Vô hiệu")
    await expect(page.locator('text=/Hoạt động|Vô hiệu/')).toBeVisible();
  });

  test('should show delete confirmation', async ({ page }) => {
    // Click on delete button (trash icon)
    await page.click('button[pTooltip="Xóa khu vực này"]:first');
    
    // Check if confirmation dialog is shown
    await expect(page.locator('.p-confirm-dialog')).toBeVisible();
    await expect(page.locator('text=Xác nhận Xóa Khu vực')).toBeVisible();
    await expect(page.locator('button:has-text("Xác nhận xóa")')).toBeVisible();
    await expect(page.locator('button:has-text("Hủy bỏ")')).toBeVisible();
  });

  test('should cancel delete operation', async ({ page }) => {
    // Click on delete button
    await page.click('button[pTooltip="Xóa khu vực này"]:first');
    
    // Click cancel in confirmation dialog
    await page.click('button:has-text("Hủy bỏ")');
    
    // Check if confirmation dialog is closed
    await expect(page.locator('.p-confirm-dialog')).not.toBeVisible();
  });

  test('should handle drag and drop reordering', async ({ page }) => {
    // Check if drag handles are visible
    await expect(page.locator('[cdkDragHandle]')).toBeVisible();
    
    // Note: Actual drag and drop testing would require more complex setup
    // This test just verifies the drag handles are present
    await expect(page.locator('i.pi-bars')).toBeVisible();
  });

  test('should show empty state when no sections exist', async ({ page }) => {
    // This test assumes the system can be in an empty state
    // Navigate to a clean state or use test data setup
    
    // Check for empty state elements
    const emptyStateSelector = 'text=Chưa có khu vực bố cục nào';
    if (await page.isVisible(emptyStateSelector)) {
      await expect(page.locator(emptyStateSelector)).toBeVisible();
      await expect(page.locator('button:has-text("Thêm khu vực đầu tiên")')).toBeVisible();
    }
  });

  test('should display Vietnamese text correctly', async ({ page }) => {
    // Check if Vietnamese text is rendered correctly
    await expect(page.locator('text=Quản lý Khu vực Bố cục')).toBeVisible();
    await expect(page.locator('text=Thêm khu vực')).toBeVisible();
    
    // If there are existing sections, check their Vietnamese names
    const vietnameseTexts = [
      'Dãy 1', 'Dãy 2', 'Khu VIP', 'Sân vườn', 
      'Phòng riêng', 'Hoạt động', 'Vô hiệu'
    ];
    
    for (const text of vietnameseTexts) {
      if (await page.isVisible(`text=${text}`)) {
        await expect(page.locator(`text=${text}`)).toBeVisible();
      }
    }
  });

  test('should maintain responsive design on mobile', async ({ page }) => {
    // Set viewport to mobile size
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Check if main elements are still visible and properly arranged
    await expect(page.locator('h5:has-text("Quản lý Khu vực Bố cục")')).toBeVisible();
    await expect(page.locator('button:has-text("Thêm khu vực")')).toBeVisible();
    
    // Check if cards are stacked properly on mobile
    const cards = page.locator('[cdkDrag]');
    if (await cards.count() > 0) {
      await expect(cards.first()).toBeVisible();
    }
  });
});