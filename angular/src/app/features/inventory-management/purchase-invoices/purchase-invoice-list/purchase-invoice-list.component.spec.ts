import { ComponentFixture, TestBed } from '@angular/core/testing';
import { PurchaseInvoiceListComponent } from './purchase-invoice-list.component';
import { ComponentBase } from '../../../../shared/base/component-base';

describe('PurchaseInvoiceListComponent', () => {
  let component: PurchaseInvoiceListComponent;
  let fixture: ComponentFixture<PurchaseInvoiceListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PurchaseInvoiceListComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PurchaseInvoiceListComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should extend ComponentBase', () => {
    expect(component instanceof ComponentBase).toBeTruthy();
  });

  it('should have correct permissions configuration', () => {
    expect(component.permissions.create).toBeDefined();
    expect(component.permissions.edit).toBeDefined();
    expect(component.permissions.delete).toBeDefined();
  });

  it('should initialize with empty purchase invoices', () => {
    expect(component.purchaseInvoices()).toEqual([]);
    expect(component.selectedPurchaseInvoices).toEqual([]);
  });

  it('should have correct filter fields', () => {
    expect(component.filterFields).toContain('invoiceNumber');
    expect(component.filterFields).toContain('totalAmount');
  });
});