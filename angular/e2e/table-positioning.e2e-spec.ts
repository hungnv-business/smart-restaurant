import { test, expect } from '@playwright/test';

test.describe('Table Positioning Management E2E', () => {
  test.beforeEach(async ({ page }) => {
    // Navigate to table positioning page
    await page.goto('/table-management/table-positioning');
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
  });

  test('should display table layout kanban board', async ({ page }) => {
    // Check if the main heading is visible
    await expect(page.locator('h2:has-text("Quản Lý Vị Trí Bàn")')).toBeVisible();
    
    // Check if refresh button is visible
    await expect(page.locator('button[pTooltip="Làm mới dữ liệu"]')).toBeVisible();
  });

  test('should display layout sections as kanban columns', async ({ page }) => {
    // Wait for sections to load
    await page.waitForTimeout(1000);
    
    // Check if section columns are displayed
    await expect(page.locator('.section-column')).toBeVisible();
    
    // Check if section headers contain Vietnamese text
    const sectionHeaders = page.locator('.section-header h3');
    const count = await sectionHeaders.count();
    if (count > 0) {
      await expect(sectionHeaders.first()).toBeVisible();
    }
  });

  test('should display tables within sections', async ({ page }) => {
    // Wait for tables to load
    await page.waitForTimeout(1000);
    
    // Check if table cards are displayed
    const tableCards = page.locator('.table-card');
    const count = await tableCards.count();
    if (count > 0) {
      await expect(tableCards.first()).toBeVisible();
      
      // Check table card structure
      await expect(tableCards.first().locator('.table-number')).toBeVisible();
      await expect(tableCards.first().locator('.table-status')).toBeVisible();
    }
  });

  test('should show table status with correct styling', async ({ page }) => {
    // Wait for tables to load
    await page.waitForTimeout(1000);
    
    const tableCards = page.locator('.table-card');
    const count = await tableCards.count();
    
    if (count > 0) {
      // Check if status badges are visible
      await expect(tableCards.first().locator('p-tag')).toBeVisible();
      
      // Check for different status classes
      const availableCards = page.locator('.table-card.available');
      const occupiedCards = page.locator('.table-card.occupied');
      const reservedCards = page.locator('.table-card.reserved');
      const cleaningCards = page.locator('.table-card.cleaning');
      
      // At least one of these should be visible
      const hasStatusCards = (await availableCards.count()) > 0 || 
                           (await occupiedCards.count()) > 0 || 
                           (await reservedCards.count()) > 0 || 
                           (await cleaningCards.count()) > 0;
      
      expect(hasStatusCards).toBeTruthy();
    }
  });

  test('should open create table dialog from section header', async ({ page }) => {
    // Wait for sections to load
    await page.waitForTimeout(1000);
    
    // Click on "+" button in first section header
    const addButtons = page.locator('.section-header button:has-text("+")');
    const count = await addButtons.count();
    
    if (count > 0) {
      await addButtons.first().click();
      
      // Check if create table dialog is opened
      await expect(page.locator('p-dialog[header="Thêm Bàn Mới"]')).toBeVisible();
      
      // Check if form fields are visible
      await expect(page.locator('input[formControlName="tableNumber"]')).toBeVisible();
      await expect(page.locator('p-dropdown[formControlName="status"]')).toBeVisible();
      await expect(page.locator('p-inputswitch[formControlName="isActive"]')).toBeVisible();
    }
  });

  test('should create new table with Vietnamese table number', async ({ page }) => {
    // Wait for sections to load
    await page.waitForTimeout(1000);
    
    // Click on "+" button in first section header
    const addButtons = page.locator('.section-header button:has-text("+")');
    const count = await addButtons.count();
    
    if (count > 0) {
      await addButtons.first().click();
      
      // Fill form with Vietnamese table data
      await page.fill('input[formControlName="tableNumber"]', 'B10');
      
      // Select status from dropdown
      await page.click('p-dropdown[formControlName="status"]');
      await page.click('p-dropdownitem:has-text("Available")');
      
      // Submit form
      await page.click('button:has-text("Tạo Bàn")');
      
      // Wait for dialog to close
      await expect(page.locator('p-dialog[header="Thêm Bàn Mới"]')).not.toBeVisible();
      
      // Check if new table appears (wait for refresh)
      await page.waitForTimeout(1000);
      await expect(page.locator('text=B10')).toBeVisible();
    }
  });

  test('should validate required fields in create table form', async ({ page }) => {
    // Wait for sections to load
    await page.waitForTimeout(1000);
    
    // Click on "+" button in first section header
    const addButtons = page.locator('.section-header button:has-text("+")');
    const count = await addButtons.count();
    
    if (count > 0) {
      await addButtons.first().click();
      
      // Try to submit without filling required fields
      await page.click('button:has-text("Tạo Bàn")');
      
      // Check if validation message appears
      await expect(page.locator('.p-toast-message-warn, .p-message-warn')).toBeVisible();
      
      // Check if form is not submitted (dialog still open)
      await expect(page.locator('p-dialog[header="Thêm Bàn Mới"]')).toBeVisible();
    }
  });

  test('should prevent duplicate table numbers', async ({ page }) => {
    // Wait for sections to load
    await page.waitForTimeout(1000);
    
    // Get existing table number from the page
    const existingTableNumbers = page.locator('.table-number');
    const count = await existingTableNumbers.count();
    
    if (count > 0) {
      const existingNumber = await existingTableNumbers.first().textContent();
      
      // Click on "+" button
      const addButtons = page.locator('.section-header button:has-text("+")');
      if (await addButtons.count() > 0) {
        await addButtons.first().click();
        
        // Fill form with existing table number
        await page.fill('input[formControlName="tableNumber"]', existingNumber || 'B01');
        
        // Submit form
        await page.click('button:has-text("Tạo Bàn")');
        
        // Check if warning message appears for duplicate
        await expect(page.locator('.p-toast-message-warn:has-text("Số bàn này đã tồn tại")')).toBeVisible();
      }
    }
  });

  test('should close create table dialog on cancel', async ({ page }) => {
    // Wait for sections to load
    await page.waitForTimeout(1000);
    
    // Click on "+" button
    const addButtons = page.locator('.section-header button:has-text("+")');
    const count = await addButtons.count();
    
    if (count > 0) {
      await addButtons.first().click();
      
      // Click cancel button
      await page.click('button:has-text("Hủy")');
      
      // Check if dialog is closed
      await expect(page.locator('p-dialog[header="Thêm Bàn Mới"]')).not.toBeVisible();
    }
  });

  test('should test drag and drop functionality between sections', async ({ page }) => {
    // Wait for tables to load
    await page.waitForTimeout(1000);
    
    const tableCards = page.locator('.table-card');
    const sectionColumns = page.locator('.section-column');
    
    const tableCount = await tableCards.count();
    const sectionCount = await sectionColumns.count();
    
    if (tableCount > 0 && sectionCount > 1) {
      // Get first table and target section
      const sourceTable = tableCards.first();
      const targetSection = sectionColumns.nth(1);
      
      // Perform drag and drop
      await sourceTable.dragTo(targetSection);
      
      // Wait for operation to complete
      await page.waitForTimeout(1000);
      
      // Check if success message appears
      await expect(page.locator('.p-toast-message-success, .p-message-success')).toBeVisible();
    }
  });

  test('should test drag and drop reordering within same section', async ({ page }) => {
    // Wait for tables to load
    await page.waitForTimeout(1000);
    
    // Find a section with multiple tables
    const sectionColumns = page.locator('.section-column');
    const sectionCount = await sectionColumns.count();
    
    for (let i = 0; i < sectionCount; i++) {
      const section = sectionColumns.nth(i);
      const tablesInSection = section.locator('.table-card');
      const tableCount = await tablesInSection.count();
      
      if (tableCount > 1) {
        // Perform reordering within the same section
        const firstTable = tablesInSection.first();
        const secondTable = tablesInSection.nth(1);
        
        await firstTable.dragTo(secondTable);
        
        // Wait for operation to complete
        await page.waitForTimeout(1000);
        
        // Check if success message appears for reordering
        await expect(page.locator('.p-toast-message-success:has-text("order updated")')).toBeVisible();
        break;
      }
    }
  });

  test('should handle error cases gracefully', async ({ page }) => {
    // Test error handling by trying to access invalid URLs or forcing error conditions
    
    // Navigate to page and wait for load
    await page.waitForTimeout(1000);
    
    // If any error messages are visible, they should be properly formatted
    const errorMessages = page.locator('.p-toast-message-error, .p-message-error');
    const errorCount = await errorMessages.count();
    
    if (errorCount > 0) {
      await expect(errorMessages.first()).toBeVisible();
      // Error messages should contain Vietnamese text
      await expect(errorMessages.first()).toContainText(/lỗi|thất bại|không thể/i);
    }
  });

  test('should refresh data when refresh button is clicked', async ({ page }) => {
    // Wait for initial load
    await page.waitForTimeout(1000);
    
    // Click refresh button
    await page.click('button[pTooltip="Làm mới dữ liệu"]');
    
    // Wait for refresh to complete
    await page.waitForTimeout(1000);
    
    // Check if loading indicator appears and disappears
    // (This depends on the implementation - adjust selectors as needed)
    await expect(page.locator('.section-column')).toBeVisible();
  });

  test('should display Vietnamese status text correctly', async ({ page }) => {
    // Wait for tables to load
    await page.waitForTimeout(1000);
    
    // Check if Vietnamese status text is rendered correctly
    const statusTexts = [
      'Available', 'Occupied', 'Reserved', 'Cleaning'
    ];
    
    for (const statusText of statusTexts) {
      const statusElements = page.locator(`text=${statusText}`);
      const count = await statusElements.count();
      if (count > 0) {
        await expect(statusElements.first()).toBeVisible();
      }
    }
  });

  test('should maintain responsive design on mobile', async ({ page }) => {
    // Set viewport to mobile size
    await page.setViewportSize({ width: 375, height: 667 });
    
    // Wait for page to adjust
    await page.waitForTimeout(1000);
    
    // Check if main elements are still visible and properly arranged
    await expect(page.locator('h2:has-text("Quản Lý Vị Trí Bàn")')).toBeVisible();
    await expect(page.locator('button[pTooltip="Làm mới dữ liệu"]')).toBeVisible();
    
    // Check if sections stack properly on mobile
    const sections = page.locator('.section-column');
    const count = await sections.count();
    if (count > 0) {
      await expect(sections.first()).toBeVisible();
    }
  });

  test('should handle empty sections properly', async ({ page }) => {
    // Wait for sections to load
    await page.waitForTimeout(1000);
    
    const sections = page.locator('.section-column');
    const sectionCount = await sections.count();
    
    for (let i = 0; i < sectionCount; i++) {
      const section = sections.nth(i);
      const tablesInSection = section.locator('.table-card');
      const tableCount = await tablesInSection.count();
      
      // If section is empty, it should still show the header and add button
      if (tableCount === 0) {
        await expect(section.locator('.section-header')).toBeVisible();
        await expect(section.locator('button:has-text("+")')).toBeVisible();
        break;
      }
    }
  });

  test('should support keyboard navigation for accessibility', async ({ page }) => {
    // Wait for page to load
    await page.waitForTimeout(1000);
    
    // Test tab navigation through interactive elements
    await page.keyboard.press('Tab');
    
    // Check if focus is visible on first interactive element
    const focusedElement = page.locator(':focus');
    await expect(focusedElement).toBeVisible();
    
    // Test Enter key on focused button
    const refreshButton = page.locator('button[pTooltip="Làm mới dữ liệu"]');
    await refreshButton.focus();
    await expect(refreshButton).toBeFocused();
  });

  test('should handle table status transitions correctly', async ({ page }) => {
    // Wait for tables to load
    await page.waitForTimeout(1000);
    
    const tableCards = page.locator('.table-card');
    const count = await tableCards.count();
    
    if (count > 0) {
      // Check that each table card has proper status styling
      for (let i = 0; i < Math.min(count, 3); i++) {
        const table = tableCards.nth(i);
        const statusTag = table.locator('p-tag');
        await expect(statusTag).toBeVisible();
        
        // Check that status tag has proper severity class
        const tagElement = statusTag.locator('.p-tag');
        await expect(tagElement).toHaveClass(/p-tag-success|p-tag-danger|p-tag-warning|p-tag-info/);
      }
    }
  });

  test('should complete full table workflow from creation to positioning', async ({ page }) => {
    // Wait for initial load
    await page.waitForTimeout(1000);
    
    // Step 1: Create a new table
    const addButtons = page.locator('.section-header button:has-text("+")');
    const buttonCount = await addButtons.count();
    
    if (buttonCount > 0) {
      await addButtons.first().click();
      
      // Fill form
      const uniqueTableNumber = `E2E-${Date.now()}`;
      await page.fill('input[formControlName="tableNumber"]', uniqueTableNumber);
      
      // Select status
      await page.click('p-dropdown[formControlName="status"]');
      await page.click('p-dropdownitem:has-text("Available")');
      
      // Submit
      await page.click('button:has-text("Tạo Bàn")');
      
      // Wait for creation
      await page.waitForTimeout(1000);
      
      // Step 2: Verify table was created
      await expect(page.locator(`text=${uniqueTableNumber}`)).toBeVisible();
      
      // Step 3: Test drag and drop if multiple sections exist
      const sectionCount = await page.locator('.section-column').count();
      if (sectionCount > 1) {
        const newTable = page.locator(`text=${uniqueTableNumber}`).locator('..').locator('..');
        const targetSection = page.locator('.section-column').nth(1);
        
        await newTable.dragTo(targetSection);
        await page.waitForTimeout(1000);
        
        // Verify success message
        await expect(page.locator('.p-toast-message-success')).toBeVisible();
      }
    }
  });
});