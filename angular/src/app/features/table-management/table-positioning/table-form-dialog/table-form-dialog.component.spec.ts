import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormsModule } from '@angular/forms';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';

import { DialogModule } from 'primeng/dialog';
import { InputTextModule } from 'primeng/inputtext';
import { DropdownModule } from 'primeng/dropdown';
import { ButtonModule } from 'primeng/button';

import { TableFormDialogComponent } from './table-form-dialog.component';
import { TableStatus } from '../../../../proxy/table-status.enum';
import { CreateTableDto } from '../../../../proxy/table-management/tables/dto/models';

describe('TableFormDialogComponent', () => {
  let component: TableFormDialogComponent;
  let fixture: ComponentFixture<TableFormDialogComponent>;

  const mockTableStatusOptions = [
    { label: 'Có sẵn', value: TableStatus.Available },
    { label: 'Đang sử dụng', value: TableStatus.Occupied },
    { label: 'Đã đặt trước', value: TableStatus.Reserved },
    { label: 'Đang dọn dẹp', value: TableStatus.Cleaning }
  ];

  const mockNewTable: CreateTableDto = {
    tableNumber: 'B01',
    displayOrder: 1,
    status: TableStatus.Available,
    isActive: true,
    layoutSectionId: 'section1'
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [
        TableFormDialogComponent,
        FormsModule,
        NoopAnimationsModule,
        DialogModule,
        InputTextModule,
        DropdownModule,
        ButtonModule
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(TableFormDialogComponent);
    component = fixture.componentInstance;
    
    // Set up component inputs
    component.tableStatusOptions = mockTableStatusOptions;
    component.newTable = { ...mockNewTable };
    component.selectedSectionId = 'section1';
    
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should display dialog when visible is true', () => {
    component.visible = true;
    fixture.detectChanges();

    const dialog = fixture.debugElement.nativeElement.querySelector('p-dialog');
    expect(dialog).toBeTruthy();
  });

  it('should hide dialog when visible is false', () => {
    component.visible = false;
    fixture.detectChanges();

    const dialog = fixture.debugElement.nativeElement.querySelector('p-dialog[visible="true"]');
    expect(dialog).toBeFalsy();
  });

  it('should emit visibleChange when dialog visibility changes', () => {
    spyOn(component.visibleChange, 'emit');
    
    component.dialogVisible = true;
    
    expect(component.visibleChange.emit).toHaveBeenCalledWith(true);
  });

  describe('Form Validation', () => {
    it('should validate table number correctly', () => {
      // Empty table number
      component.newTable.tableNumber = '';
      expect(component.isTableNumberValid()).toBe(false);

      // Whitespace only
      component.newTable.tableNumber = '   ';
      expect(component.isTableNumberValid()).toBe(false);

      // Valid table number
      component.newTable.tableNumber = 'B01';
      expect(component.isTableNumberValid()).toBe(true);
    });

    it('should validate form correctly', () => {
      // Invalid form (empty table number)
      component.newTable.tableNumber = '';
      expect(component.isFormValid()).toBe(false);

      // Valid form
      component.newTable.tableNumber = 'B01';
      expect(component.isFormValid()).toBe(true);
    });

    it('should disable create button when form is invalid', () => {
      component.newTable.tableNumber = '';
      fixture.detectChanges();

      const createButton = fixture.debugElement.nativeElement.querySelector('p-button[label="Tạo Bàn"] button');
      expect(createButton.disabled).toBe(true);
    });

    it('should enable create button when form is valid', () => {
      component.newTable.tableNumber = 'B01';
      fixture.detectChanges();

      const createButton = fixture.debugElement.nativeElement.querySelector('p-button[label="Tạo Bàn"] button');
      expect(createButton.disabled).toBe(false);
    });
  });

  describe('Event Handling', () => {
    it('should emit createTable when create button is clicked with valid form', () => {
      spyOn(component.createTable, 'emit');
      component.newTable.tableNumber = 'B01';

      component.onCreateTable();

      expect(component.createTable.emit).toHaveBeenCalled();
    });

    it('should not emit createTable when form is invalid', () => {
      spyOn(component.createTable, 'emit');
      component.newTable.tableNumber = '';

      component.onCreateTable();

      expect(component.createTable.emit).not.toHaveBeenCalled();
    });

    it('should emit closeDialog when cancel button is clicked', () => {
      spyOn(component.closeDialog, 'emit');

      component.onCloseDialog();

      expect(component.closeDialog.emit).toHaveBeenCalled();
    });

    it('should emit closeDialog when close button is clicked', () => {
      spyOn(component.closeDialog, 'emit');
      component.visible = true;
      fixture.detectChanges();

      const cancelButton = fixture.debugElement.nativeElement.querySelector('p-button[label="Hủy"] button');
      cancelButton.click();

      expect(component.closeDialog.emit).toHaveBeenCalled();
    });
  });

  describe('Loading State', () => {
    it('should show loading state on create button when loading is true', () => {
      component.loading = true;
      component.newTable.tableNumber = 'B01';
      fixture.detectChanges();

      const createButton = fixture.debugElement.nativeElement.querySelector('p-button[label="Tạo Bàn"]');
      expect(createButton.getAttribute('ng-reflect-loading')).toBe('true');
    });

    it('should not show loading state when loading is false', () => {
      component.loading = false;
      component.newTable.tableNumber = 'B01';
      fixture.detectChanges();

      const createButton = fixture.debugElement.nativeElement.querySelector('p-button[label="Tạo Bàn"]');
      expect(createButton.getAttribute('ng-reflect-loading')).toBe('false');
    });
  });

  describe('Status Dropdown', () => {
    it('should display all table status options', () => {
      expect(component.tableStatusOptions).toEqual(mockTableStatusOptions);
      expect(component.tableStatusOptions.length).toBe(4);
    });

    it('should have default status as Available', () => {
      expect(component.newTable.status).toBe(TableStatus.Available);
    });
  });

  describe('Form Fields', () => {
    it('should display required field indicator for table number', () => {
      component.visible = true;
      fixture.detectChanges();

      const requiredIndicator = fixture.debugElement.nativeElement.querySelector('label[for="tableNumber"] .text-red-500');
      expect(requiredIndicator).toBeTruthy();
      expect(requiredIndicator.textContent.trim()).toBe('*');
    });

    it('should show validation error when table number is empty and touched', () => {
      component.visible = true;
      component.newTable.tableNumber = 'test';
      fixture.detectChanges();

      // Simulate user interaction by setting empty value
      component.newTable.tableNumber = '';
      fixture.detectChanges();

      const errorMessage = fixture.debugElement.nativeElement.querySelector('.text-red-500 small');
      expect(errorMessage?.textContent.trim()).toBe('Số bàn không được để trống');
    });

    it('should update newTable properties when form fields change', () => {
      component.visible = true;
      fixture.detectChanges();

      // Test table number input
      const tableNumberInput = fixture.debugElement.nativeElement.querySelector('#tableNumber');
      tableNumberInput.value = 'B02';
      tableNumberInput.dispatchEvent(new Event('input'));
      fixture.detectChanges();

      expect(component.newTable.tableNumber).toBe('B02');
    });
  });

  describe('Accessibility', () => {
    it('should have proper label associations', () => {
      component.visible = true;
      fixture.detectChanges();

      const tableNumberLabel = fixture.debugElement.nativeElement.querySelector('label[for="tableNumber"]');
      const tableNumberInput = fixture.debugElement.nativeElement.querySelector('#tableNumber');
      
      expect(tableNumberLabel).toBeTruthy();
      expect(tableNumberInput).toBeTruthy();
      expect(tableNumberLabel.getAttribute('for')).toBe(tableNumberInput.getAttribute('id'));
    });

    it('should have proper placeholder text', () => {
      component.visible = true;
      fixture.detectChanges();

      const tableNumberInput = fixture.debugElement.nativeElement.querySelector('#tableNumber');
      expect(tableNumberInput.getAttribute('placeholder')).toBe('Ví dụ: B01, VIP1');
    });
  });
});