import { Component, OnInit, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, FormArray, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { CalendarModule } from 'primeng/calendar';
import { DropdownModule } from 'primeng/dropdown';
import { ButtonModule } from 'primeng/button';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import { InputTextarea } from 'primeng/inputtextarea';
import { ComponentBase } from '../../../../shared/base/component-base';
import { VndCurrencyPipe } from '../../../../shared/pipes';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { PurchaseInvoiceItemComponent } from '../purchase-invoice-item/purchase-invoice-item.component';
import { PurchaseInvoiceFormData } from '../services/purchase-invoice-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { take, finalize } from 'rxjs';
import { DateTimeHelper } from '../../../../shared/helpers';

// Import proxy DTOs and services
import { 
  CreateUpdatePurchaseInvoiceDto, 
  PurchaseInvoiceDto} from '../../../../proxy/inventory-management/purchase-invoices/dto';
import { PurchaseInvoiceService } from '../../../../proxy/inventory-management/purchase-invoices/purchase-invoice.service';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';

interface IngredientLookupDto {
  id: string;
  name: string;
  unitId: string;
  unitName: string;
  costPerUnit: number;
  supplierInfo: string;
}

@Component({
  selector: 'app-purchase-invoice-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    CalendarModule,
    DropdownModule,
    ButtonModule,
    ProgressSpinnerModule,
    InputTextarea,
    VndCurrencyPipe,
    FormFooterActionsComponent,
    ValidationErrorComponent,
    PurchaseInvoiceItemComponent,
  ],
  templateUrl: './purchase-invoice-form.component.html',
  styleUrls: ['./purchase-invoice-form.component.scss'],
})
export class PurchaseInvoiceFormComponent extends ComponentBase implements OnInit {
  form: FormGroup;
  loading = false;
  isEdit = false;
  isViewOnly = false;
  purchaseInvoice?: PurchaseInvoiceDto;
  ingredients = signal<IngredientLookupDto[]>([]);

  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<PurchaseInvoiceFormData>);

  private fb = inject(FormBuilder);
  private purchaseInvoiceService = inject(PurchaseInvoiceService);
  private ingredientService = inject(IngredientService);

  constructor() {
    super();
    this.form = this.createForm();
  }

  ngOnInit() {
    this.loadIngredients();

    const data = this.config.data;
    if (data) {
      this.isViewOnly = data.mode === 'view';
      this.isEdit = data.mode === 'edit';

      if (data.purchaseInvoiceId) {
        this.loadPurchaseInvoice(data.purchaseInvoiceId);
      }
    }

    // Thêm một item mặc định nếu không có và không phải chế độ view
    if (this.itemsFormArray.length === 0 && !this.isViewOnly) {
      this.addItem();
    }
  }

  get itemsFormArray(): FormArray {
    return this.form.get('items') as FormArray;
  }

  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    const formValue = this.form.value;
    const invoiceDate = new Date(formValue.invoiceDate);
    const invoiceDateId = DateTimeHelper.getDateId(invoiceDate);
    
    const dto: CreateUpdatePurchaseInvoiceDto = {
      invoiceNumber: formValue.invoiceNumber,
      invoiceDateId: invoiceDateId,
      notes: formValue.notes || '',
      items: formValue.items,
    };

    this.loading = true;
    this.savePurchaseInvoice(dto);
  }

  onCancel() {
    this.ref.close(false);
  }

  // Tính tổng tiền toàn bộ hóa đơn
  getTotalAmount(): number {
    return this.itemsFormArray.controls.reduce((total, control) => {
      const itemTotal = control.get('totalPrice')?.value || 0;
      return total + itemTotal;
    }, 0);
  }

  // Thêm item mới (thêm vào đầu danh sách)
  addItem() {
    const newItem = this.createItemFormGroup();
    this.itemsFormArray.insert(0, newItem);
  }

  // Xóa item
  removeItem(index: number) {
    if (this.itemsFormArray.length > 1) {
      this.itemsFormArray.removeAt(index);
    }
  }


  // Tính total price khi thay đổi quantity hoặc unit price
  onQuantityOrPriceChange(index: number) {
    const itemForm = this.itemsFormArray.at(index);
    const quantity = itemForm.get('quantity')?.value || 0;
    const unitPrice = itemForm.get('unitPrice')?.value;
    
    if (quantity && unitPrice) {
      const totalPrice = quantity * unitPrice;
      itemForm.patchValue({ totalPrice });
    }
  }

  private loadIngredients() {
    const request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000,
      sorting: 'name',
    };

    this.ingredientService.getList(request).subscribe({
      next: result => {
        const ingredients = result?.items?.filter(i => i.isActive) || [];
        this.ingredients.set(ingredients.map(i => ({
          id: i.id!,
          name: i.name!,
          unitId: i.unitId!,
          unitName: i.unitName!,
          costPerUnit: i.costPerUnit || 0,
          supplierInfo: i.supplierInfo || ''
        })));
      },
      error: error => {
        console.error('Error loading ingredients:', error);
        this.ingredients.set([]);
      },
    });
  }

  private loadPurchaseInvoice(id: string) {
    this.purchaseInvoiceService.get(id).subscribe({
      next: result => {
        this.purchaseInvoice = result;
        console.log('Loaded purchase invoice:', result);
        
        
        this.populateForm(result);
      },
      error: error => {
        this.handleApiError(error, 'Không thể tải thông tin hóa đơn');
      },
    });
  }

  private savePurchaseInvoice(dto: CreateUpdatePurchaseInvoiceDto) {
    const operation = this.isEdit && this.purchaseInvoice
      ? this.purchaseInvoiceService.update(this.purchaseInvoice.id!, dto)
      : this.purchaseInvoiceService.create(dto);

    const errorMessage = this.isEdit
      ? 'Không thể cập nhật hóa đơn mua'
      : 'Không thể tạo hóa đơn mua';

    operation
      .pipe(
        take(1),
        finalize(() => (this.loading = false)),
      )
      .subscribe({
        next: () => {
          this.ref.close(true);
        },
        error: err => this.handleApiError(err, errorMessage),
      });
  }

  private createForm(): FormGroup {
    return this.fb.group({
      invoiceNumber: [this.generateInvoiceNumber()],
      invoiceDate: [new Date(), [Validators.required]],
      notes: ['', [Validators.maxLength(500)]],
      items: this.fb.array([])
    });
  }

  private generateInvoiceNumber(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const time = String(now.getHours()).padStart(2, '0') + String(now.getMinutes()).padStart(2, '0');
    return `HD-${year}${month}${day}-${time}`;
  }

  private createItemFormGroup(): FormGroup {
    return this.fb.group({
      ingredientId: [null, [Validators.required]],
      quantity: [1, [Validators.required, Validators.min(1)]],
      unitId: [null],
      unitName: ['', [Validators.required, Validators.maxLength(50)]],
      unitPrice: [null],
      totalPrice: [null, [Validators.required, Validators.min(0)]],
      supplierInfo: [''],
      notes: ['', [Validators.maxLength(500)]],
      categoryId: [null]
    });
  }

  private populateForm(purchaseInvoice: PurchaseInvoiceDto) {
    // Convert InvoiceDateId back to Date for form binding
    const invoiceDate = purchaseInvoice.invoiceDateId 
      ? DateTimeHelper.getDateFromId(purchaseInvoice.invoiceDateId)
      : new Date();

    this.form.patchValue({
      invoiceNumber: purchaseInvoice.invoiceNumber ?? '',
      invoiceDate: invoiceDate || new Date(),
      notes: purchaseInvoice.notes ?? '',
    });

    // Clear existing items and populate with loaded items
    while (this.itemsFormArray.length !== 0) {
      this.itemsFormArray.removeAt(0);
    }

    purchaseInvoice.items?.forEach(item => {
      const itemFormGroup = this.createItemFormGroup();
      itemFormGroup.patchValue({
        ingredientId: item.ingredientId ?? null,
        quantity: item.quantity ?? 1,
        unitId: item.unitId ?? null,
        unitName: item.unitName ?? '',
        unitPrice: item.unitPrice ?? null,
        totalPrice: item.totalPrice ?? 0,
        supplierInfo: item.supplierInfo ?? '',
        notes: item.notes ?? '',
        categoryId: item.categoryId ?? null,
      });
      this.itemsFormArray.push(itemFormGroup);
    });

    // Set form readonly nếu ở chế độ view only
    if (this.isViewOnly) {
      this.setFormReadonly(this.form);
    }

    this.form.markAsPristine();
  }


  private setFormReadonly(formGroup: FormGroup) {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      if (control instanceof FormGroup) {
        this.setFormReadonly(control);
      } else if (control instanceof FormArray) {
        control.controls.forEach(arrayControl => {
          if (arrayControl instanceof FormGroup) {
            this.setFormReadonly(arrayControl);
          }
        });
      }
    });
  }
}