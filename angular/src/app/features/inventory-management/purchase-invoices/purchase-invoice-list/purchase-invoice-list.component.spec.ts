import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { MessageService, ConfirmationService } from 'primeng/api';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { PermissionService } from '@abp/ng.core';
import { CORE_OPTIONS } from '@abp/ng.core';
import { PurchaseInvoiceListComponent } from './purchase-invoice-list.component';
import { ComponentBase } from '../../../../shared/base/component-base';

describe('PurchaseInvoiceListComponent', () => {
  let component: PurchaseInvoiceListComponent;
  let fixture: ComponentFixture<PurchaseInvoiceListComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [PurchaseInvoiceListComponent, NoopAnimationsModule],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        MessageService,
        ConfirmationService,
        DialogService,
        { provide: DynamicDialogRef, useValue: {} },
        { provide: DynamicDialogConfig, useValue: {} },
        { provide: PermissionService, useValue: { getGrantedPolicy: () => true } },
        { provide: CORE_OPTIONS, useValue: { environment: { production: false }, skipGetAppConfiguration: true } }
      ]
    })
    .compileComponents();

    fixture = TestBed.createComponent(PurchaseInvoiceListComponent);
    component = fixture.componentInstance;
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
  });

  it('should have correct filter fields', () => {
    expect(component.filterFields).toContain('invoiceNumber');
    expect(component.filterFields).toContain('totalAmount');
  });
});