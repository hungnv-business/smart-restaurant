import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { MessageService, ConfirmationService } from 'primeng/api';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { PermissionService } from '@abp/ng.core';
import { CORE_OPTIONS } from '@abp/ng.core';
import { of } from 'rxjs';
import { PurchaseInvoiceFormComponent } from './purchase-invoice-form.component';
import { ComponentBase } from '../../../../shared/base/component-base';
import { GlobalService } from '../../../../proxy/common/global.service';
import { PurchaseInvoiceService } from '../../../../proxy/inventory-management/purchase-invoices/purchase-invoice.service';

describe('PurchaseInvoiceFormComponent', () => {
  let component: PurchaseInvoiceFormComponent;
  let fixture: ComponentFixture<PurchaseInvoiceFormComponent>;
  let mockDialogRef: jasmine.SpyObj<DynamicDialogRef>;
  let mockConfig: DynamicDialogConfig;

  // Mock services
  const mockGlobalService = {
    getIngredientCategoriesLookup: jasmine.createSpy('getIngredientCategoriesLookup').and.returnValue(of({ items: [] }))
  };

  const mockPurchaseInvoiceService = {
    create: jasmine.createSpy('create').and.returnValue(of({})),
    update: jasmine.createSpy('update').and.returnValue(of({})),
    get: jasmine.createSpy('get').and.returnValue(of({}))
  };

  beforeEach(async () => {
    mockDialogRef = jasmine.createSpyObj('DynamicDialogRef', ['close']);
    mockConfig = { data: null };

    await TestBed.configureTestingModule({
      imports: [PurchaseInvoiceFormComponent, ReactiveFormsModule, NoopAnimationsModule],
      providers: [
        FormBuilder,
        provideHttpClient(),
        provideHttpClientTesting(),
        MessageService,
        ConfirmationService,
        DialogService,
        { provide: DynamicDialogRef, useValue: mockDialogRef },
        { provide: DynamicDialogConfig, useValue: mockConfig },
        { provide: PermissionService, useValue: { getGrantedPolicy: () => true } },
        { provide: GlobalService, useValue: mockGlobalService },
        { provide: PurchaseInvoiceService, useValue: mockPurchaseInvoiceService },
        {
          provide: CORE_OPTIONS,
          useValue: { environment: { production: false }, skipGetAppConfiguration: true },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(PurchaseInvoiceFormComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should extend ComponentBase', () => {
    expect(component instanceof ComponentBase).toBeTruthy();
  });

  it('should initialize form with required validators', () => {
    expect(component.form).toBeDefined();
    
    // invoiceNumber không có required validator (được tự động sinh)
    expect(component.form.get('invoiceNumber')).toBeDefined();
    expect(component.form.get('invoiceNumber')?.value).toBeTruthy();
    
    // invoiceDate có required validator và có default value
    expect(component.form.get('invoiceDate')).toBeDefined();
    expect(component.form.get('invoiceDate')?.hasError('required')).toBeFalsy(); // Có default value nên không có lỗi
    
    // Kiểm tra khi xóa giá trị invoiceDate
    component.form.get('invoiceDate')?.setValue(null);
    expect(component.form.get('invoiceDate')?.hasError('required')).toBeTruthy();
  });

  it('should add default item on init', async () => {
    await component.ngOnInit();
    expect(component.itemsFormArray.length).toBeGreaterThan(0);
  });

  it('should add and remove items correctly', () => {
    const initialLength = component.itemsFormArray.length;

    component.addItem();
    expect(component.itemsFormArray.length).toBe(initialLength + 1);

    component.removeItem(0);
    if (initialLength > 1) {
      expect(component.itemsFormArray.length).toBe(initialLength);
    }
  });

  it('should calculate total amount correctly', () => {
    component.addItem();
    component.addItem();

    // Set some test values
    component.itemsFormArray.at(0).patchValue({ totalPrice: 100000 });
    component.itemsFormArray.at(1).patchValue({ totalPrice: 200000 });

    expect(component.getTotalAmount()).toBe(300000);
  });

  it('should auto-calculate total price when quantity and unit price change', () => {
    component.addItem();
    const itemForm = component.itemsFormArray.at(0);

    itemForm.patchValue({ quantity: 5, unitPrice: 20000 });
    component.onQuantityOrPriceChange(0);

    expect(itemForm.get('totalPrice')?.value).toBe(100000);
  });
});
