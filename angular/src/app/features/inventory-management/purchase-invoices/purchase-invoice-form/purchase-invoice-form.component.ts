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
import { GetIngredientListRequestDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { take, finalize } from 'rxjs';
import { DateTimeHelper } from '../../../../shared/helpers';

// Import proxy DTOs and services
import {
  CreateUpdatePurchaseInvoiceDto,
  PurchaseInvoiceDto,
} from '../../../../proxy/inventory-management/purchase-invoices/dto';
import { PurchaseInvoiceService } from '../../../../proxy/inventory-management/purchase-invoices/purchase-invoice.service';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { GlobalService } from '../../../../proxy/common/global.service';
import { GuidLookupItemDto } from '../../../../proxy/common/dto/models';

/**
 * Interface định nghĩa thông tin lookup của nguyên liệu
 */
interface IngredientLookupDto {
  id: string;
  name: string;
  costPerUnit: number;
  supplierInfo: string;
}

/**
 * Component quản lý form tạo/chỉnh sửa hóa đơn mua nguyên liệu
 * Chức năng chính:
 * - Tạo mới hóa đơn mua hàng cho nhà hàng
 * - Chỉnh sửa hóa đơn mua hiện có
 * - Xem chi tiết hóa đơn (chế độ chỉ đọc)
 * - Quản lý danh sách mặt hàng trong hóa đơn
 * - Tự động tính toán thành tiền và tổng tiền
 * - Quản lý thông tin nhà cung cấp
 * - Validation dữ liệu đầu vào
 * - Tự động sinh mã hóa đơn
 */
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
  /** Form quản lý thông tin hóa đơn mua */
  form: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** Chế độ chỉnh sửa (true) hay tạo mới (false) */
  isEdit = false;
  /** Chế độ chỉ xem (không chỉnh sửa được) */
  isViewOnly = false;
  /** Thông tin hóa đơn mua đang được chỉnh sửa */
  purchaseInvoice?: PurchaseInvoiceDto;
  /** Danh sách các danh mục nguyên liệu */
  categories: GuidLookupItemDto[] = [];

  /** Tham chiếu dialog và cấu hình */
  public ref = inject(DynamicDialogRef);
  public config = inject(DynamicDialogConfig<PurchaseInvoiceFormData>);

  /** Các service được inject */
  private fb = inject(FormBuilder);
  private purchaseInvoiceService = inject(PurchaseInvoiceService);
  private globalService = inject(GlobalService);

  /**
   * Khởi tạo component và tạo form
   */
  constructor() {
    super();
    this.form = this.createForm();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit() {
    this.loadCategories();

    const data = this.config.data;
    if (data) {
      this.isViewOnly = data.mode === 'view';
      this.isEdit = data.mode === 'edit';

      if (data.purchaseInvoiceId) {
        this.loadPurchaseInvoice(data.purchaseInvoiceId);
      }
    }

    // Thêm một item mặc định nếu không có và không phải chế độ chỉ xem
    if (this.itemsFormArray.length === 0 && !this.isViewOnly) {
      this.addItem();
    }
  }

  /**
   * Lấy FormArray của các item trong hóa đơn
   * @returns FormArray chứa các mặt hàng
   */
  get itemsFormArray(): FormArray {
    return this.form.get('items') as FormArray;
  }

  /**
   * Xử lý submit form - validate và lưu hóa đơn mua
   */
  onSubmit() {
    if (!this.validateForm(this.form)) {
      return;
    }

    // Chuyển đổi dữ liệu form sang DTO
    const formValue = this.form.value;
    const invoiceDate = new Date(formValue.invoiceDate);
    const invoiceDateId = DateTimeHelper.getDateId(invoiceDate);

    const dto: CreateUpdatePurchaseInvoiceDto = {
      invoiceNumber: formValue.invoiceNumber, // Mã hóa đơn
      invoiceDateId: invoiceDateId, // Ngày hóa đơn (dạng ID)
      notes: formValue.notes || '', // Ghi chú
      items: formValue.items, // Danh sách mặt hàng
    };

    this.loading = true;
    this.savePurchaseInvoice(dto);
  }

  /**
   * Hủy thao tác và đóng dialog
   */
  onCancel() {
    this.ref.close(false);
  }

  /**
   * Tính tổng tiền toàn bộ hóa đơn
   * @returns Tổng tiền VND
   */
  getTotalAmount(): number {
    return this.itemsFormArray.controls.reduce((total, control) => {
      const itemTotal = control.get('totalPrice')?.value || 0;
      return total + itemTotal;
    }, 0);
  }

  /**
   * Thêm mặt hàng mới vào đầu danh sách
   */
  addItem() {
    const newItem = this.createItemFormGroup();
    this.itemsFormArray.insert(0, newItem);
  }

  /**
   * Xóa mặt hàng tại vị trí chỉ định
   * @param index Vị trí của item cần xóa
   */
  removeItem(index: number) {
    if (this.itemsFormArray.length > 1) {
      this.itemsFormArray.removeAt(index);
    }
  }

  /**
   * Tính lại thành tiền khi thay đổi số lượng hoặc đơn giá
   * @param index Vị trí của item cần tính lại
   */
  onQuantityOrPriceChange(index: number) {
    const itemForm = this.itemsFormArray.at(index);
    const quantity = itemForm.get('quantity')?.value || 0;
    const unitPrice = itemForm.get('unitPrice')?.value;

    if (quantity && unitPrice) {
      const totalPrice = quantity * unitPrice;
      itemForm.patchValue({ totalPrice });
    }
  }

  /**
   * Tải thông tin hóa đơn mua từ server (mode chỉnh sửa/xem)
   * @param id - ID của hóa đơn mua cần tải
   * @private
   */
  private loadPurchaseInvoice(id: string) {
    this.purchaseInvoiceService.get(id).subscribe({
      next: result => {
        this.purchaseInvoice = result;
        console.log('Đã tải thông tin hóa đơn mua:', result);

        this.populateForm(result);
      },
      error: error => {
        this.handleApiError(error, 'Không thể tải thông tin hóa đơn');
      },
    });
  }

  /**
   * Lưu thông tin hóa đơn mua (tạo mới hoặc cập nhật)
   * Bao gồm thông tin hóa đơn và danh sách các mặt hàng
   * @param dto - Dữ liệu hóa đơn mua cần lưu
   * @private
   */
  private savePurchaseInvoice(dto: CreateUpdatePurchaseInvoiceDto) {
    // Chọn operation phù hợp dựa vào mode (create/edit)
    const operation =
      this.isEdit && this.purchaseInvoice
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
          // Đóng dialog với kết quả thành công
          this.ref.close(true);
        },
        error: err => this.handleApiError(err, errorMessage),
      });
  }

  /**
   * Tạo reactive form với các validation rules
   * @private
   * @returns FormGroup với các control và validator
   */
  private createForm(): FormGroup {
    return this.fb.group({
      invoiceNumber: [this.generateInvoiceNumber()], // Mã hóa đơn tự động sinh
      invoiceDate: [new Date(), [Validators.required]], // Ngày hóa đơn bắt buộc
      notes: ['', [Validators.maxLength(500)]], // Ghi chú tối đa 500 ký tự
      items: this.fb.array([]), // Danh sách mặt hàng (FormArray)
    });
  }

  /**
   * Tự động sinh mã hóa đơn theo format HD-YYYYMMDD-HHMM
   * @private
   * @returns Mã hóa đơn duy nhất
   */
  private generateInvoiceNumber(): string {
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const day = String(now.getDate()).padStart(2, '0');
    const time =
      String(now.getHours()).padStart(2, '0') + String(now.getMinutes()).padStart(2, '0');
    return `HD-${year}${month}${day}-${time}`;
  }

  /**
   * Tạo FormGroup cho một mặt hàng trong hóa đơn
   * @private
   * @returns FormGroup chứa thông tin một mặt hàng
   */
  private createItemFormGroup(): FormGroup {
    return this.fb.group({
      id: [null], // ID để tracking khi update
      ingredientId: [null, [Validators.required]], // Bắt buộc chọn nguyên liệu
      quantity: [1, [Validators.required, Validators.min(1)]], // Số lượng >= 1
      purchaseUnitId: [null, [Validators.required]], // Bắt buộc chọn đơn vị mua
      unitPrice: [null], // Đơn giá (có thể để trống)
      totalPrice: [null, [Validators.required, Validators.min(0)]], // Thành tiền >= 0
      supplierInfo: [''], // Thông tin nhà cung cấp
      notes: ['', [Validators.maxLength(500)]], // Ghi chú tối đa 500 ký tự
      categoryId: [null], // Danh mục nguyên liệu
      displayOrder: [1], // Thứ tự hiển thị
    });
  }

  /**
   * Điền dữ liệu hóa đơn vào form (mode chỉnh sửa/xem)
   * @param purchaseInvoice - Dữ liệu hóa đơn cần hiển thị
   * @private
   */
  private populateForm(purchaseInvoice: PurchaseInvoiceDto) {
    // Chuyển đổi InvoiceDateId thành Date để bind vào form
    const invoiceDate = purchaseInvoice.invoiceDateId
      ? DateTimeHelper.getDateFromId(purchaseInvoice.invoiceDateId)
      : new Date();

    this.form.patchValue({
      invoiceNumber: purchaseInvoice.invoiceNumber ?? '',
      invoiceDate: invoiceDate || new Date(),
      notes: purchaseInvoice.notes ?? '',
    });

    // Xóa tất cả items cũ và populate với items mới
    while (this.itemsFormArray.length !== 0) {
      this.itemsFormArray.removeAt(0);
    }

    purchaseInvoice.items?.forEach((item, index) => {
      const itemFormGroup = this.createItemFormGroup();
      itemFormGroup.patchValue({
        id: item.id ?? null, // ID quan trọng để tracking khi update
        ingredientId: item.ingredientId ?? null,
        quantity: item.quantity ?? 1,
        purchaseUnitId: item.purchaseUnitId ?? null,
        unitPrice: item.unitPrice ?? null,
        totalPrice: item.totalPrice ?? 0,
        supplierInfo: item.supplierInfo ?? '',
        notes: item.notes ?? '',
        categoryId: item.categoryId ?? null,
        displayOrder: item.displayOrder ?? (index + 1),
      });
      this.itemsFormArray.push(itemFormGroup);
    });

    // Đặt form chỉ đọc nếu ở chế độ view only
    if (this.isViewOnly) {
      this.setFormReadonly(this.form);
    }

    // Đánh dấu form là chưa thay đổi (pristine)
    this.form.markAsPristine();
  }

  /**
   * Tải danh sách các danh mục nguyên liệu để hiển thị trong dropdown
   * @private
   */
  private loadCategories() {
    this.globalService.getIngredientCategoriesLookup().subscribe({
      next: categories => {
        this.categories = categories;
      },
      error: error => {
        console.error('Lỗi khi tải danh sách danh mục:', error);
      }
    });
  }

  /**
   * Đặt form và tất cả sub-form thành chế độ chỉ đọc
   * Sử dụng recursive để xử lý FormGroup và FormArray lồng nhau
   * @param formGroup - Form cần đặt readonly
   * @private
   */
  private setFormReadonly(formGroup: FormGroup) {
    Object.keys(formGroup.controls).forEach(key => {
      const control = formGroup.get(key);
      if (control instanceof FormGroup) {
        // Xử lý FormGroup lồng nhau
        this.setFormReadonly(control);
      } else if (control instanceof FormArray) {
        // Xử lý FormArray (như danh sách items)
        control.controls.forEach(arrayControl => {
          if (arrayControl instanceof FormGroup) {
            this.setFormReadonly(arrayControl);
          }
        });
      }
      // Disable control để không thể chỉnh sửa
      control?.disable();
    });
  }
}
