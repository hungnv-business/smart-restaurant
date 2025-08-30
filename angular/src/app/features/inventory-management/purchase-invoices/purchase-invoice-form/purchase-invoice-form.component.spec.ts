import { ComponentFixture, TestBed } from '@angular/core/testing';
import { FormBuilder, ReactiveFormsModule } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { PurchaseInvoiceFormComponent } from './purchase-invoice-form.component';
import { ComponentBase } from '../../../../shared/base/component-base';

describe('PurchaseInvoiceFormComponent', () => {
  let component: PurchaseInvoiceFormComponent;
  let fixture: ComponentFixture<PurchaseInvoiceFormComponent>;
  let mockDialogRef: jasmine.SpyObj<DynamicDialogRef>;
  let mockConfig: DynamicDialogConfig;

  beforeEach(async () => {
    mockDialogRef = jasmine.createSpyObj('DynamicDialogRef', ['close']);
    mockConfig = { data: null };

    await TestBed.configureTestingModule({
      imports: [PurchaseInvoiceFormComponent, ReactiveFormsModule],
      providers: [
        FormBuilder,
        { provide: DynamicDialogRef, useValue: mockDialogRef },
        { provide: DynamicDialogConfig, useValue: mockConfig },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(PurchaseInvoiceFormComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should extend ComponentBase', () => {
    expect(component instanceof ComponentBase).toBeTruthy();
  });

  it('should initialize form with required validators', () => {
    expect(component.form).toBeDefined();
    expect(component.form.get('invoiceNumber')?.hasError('required')).toBeTruthy();
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