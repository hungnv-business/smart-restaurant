import {
  Component,
  Input,
  Output,
  EventEmitter,
  inject,
  OnInit,
  OnChanges,
  SimpleChanges,
} from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormGroup, ReactiveFormsModule } from '@angular/forms';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumber } from 'primeng/inputnumber';
import { SelectModule } from 'primeng/select';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PurchaseInvoiceService } from '../../../../proxy/inventory-management/purchase-invoices/purchase-invoice.service';
import { GuidLookupItemDto } from '../../../../proxy/common/dto/models';
import { GlobalService } from '../../../../proxy/common/global.service';
import { IngredientPurchaseUnitDto } from '../../../../proxy/inventory-management/ingredients/dto';
import { FluidModule } from 'primeng/fluid';
import { TextareaModule } from 'primeng/textarea';

/**
 * Component quản lý một mặt hàng trong hóa đơn mua nguyên liệu
 *
 * Chức năng chính:
 * - Hiển thị form nhập thông tin một mặt hàng trong hóa đơn mua
 * - Chọn danh mục → nguyên liệu → đơn vị mua → số lượng
 * - Tự động tính toán đơn giá dựa trên cost per unit và conversion ratio
 * - Tự động tính toán thành tiền (quantity × unit price)
 * - Hiển thị preview số lượng quy đổi về đơn vị cơ bản
 * - Validate dữ liệu nhập vào
 * - Hỗ trợ mode chỉ xem (view only)
 * - Load thông tin nhà cung cấp từ master data
 *
 * @example
 * // Sử dụng trong purchase invoice form:
 * <app-purchase-invoice-item
 *   [itemForm]="getItemForm(i)"
 *   [index]="i"
 *   [isViewOnly]="isViewOnly"
 *   [categories]="categories"
 *   (remove)="removeItem(i)">
 * </app-purchase-invoice-item>
 */
@Component({
  selector: 'app-purchase-invoice-item',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    InputNumber,
    SelectModule,
    ButtonModule,
    TooltipModule,
    ValidationErrorComponent,
    FluidModule,
    TextareaModule,
  ],
  templateUrl: './purchase-invoice-item.component.html',
  styleUrl: './purchase-invoice-item.component.scss',
})
export class PurchaseInvoiceItemComponent extends ComponentBase implements OnInit, OnChanges {
  /** Form của mặt hàng cụ thể (được truyền từ parent FormArray) */
  @Input({ required: true }) itemForm!: FormGroup;
  /** Vị trí của mặt hàng trong danh sách (để hiển thị số thứ tự) */
  @Input({ required: true }) index!: number;
  /** Chế độ chỉ xem (không cho chỉnh sửa) */
  @Input() isViewOnly = false;
  /** Danh sách các danh mục nguyên liệu */
  @Input() categories: GuidLookupItemDto[] = [];
  /** Event khi click nút xóa mặt hàng */
  @Output() remove = new EventEmitter<void>();

  /** Danh sách nguyên liệu thuộc danh mục đã chọn */
  ingredients: GuidLookupItemDto[] = [];
  /** Danh sách các đơn vị mua hàng của nguyên liệu đã chọn */
  purchaseUnits: IngredientPurchaseUnitDto[] = [];
  /** ID danh mục hiện tại đang chọn */
  currentCategoryId: string | null = null;
  /** ID nguyên liệu hiện tại đang chọn */
  currentIngredientId: string | null = null;
  /** Giá cơ bản trên đơn vị của nguyên liệu hiện tại */
  currentIngredientCostPerUnit: number | null = null;

  /** Service để lấy thông tin nguyên liệu cho purchase */
  private purchaseInvoiceService = inject(PurchaseInvoiceService);
  /** Service để lấy lookup data */
  private globalService = inject(GlobalService);

  /**
   * Khởi tạo component
   */
  constructor() {
    super();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit() {
    // Categories được nhận từ parent component qua @Input
    this.loadPurchaseUnits();
  }

  /**
   * Xử lý khi có thay đổi Input properties
   * Load dữ liệu cần thiết khi form được populate (mode chỉnh sửa/xem)
   * @param changes - Các thay đổi của Input properties
   */
  ngOnChanges(changes: SimpleChanges) {
    // Khi itemForm thay đổi (được populate với data có sẵn)
    if (changes['itemForm'] && this.itemForm) {
      const categoryId = this.itemForm.get('categoryId')?.value;
      const ingredientId = this.itemForm.get('ingredientId')?.value;

      // Load danh sách nguyên liệu nếu đã chọn danh mục
      if (categoryId) {
        this.currentCategoryId = categoryId;
        this.loadIngredientsByCategory(categoryId);
      }

      // Load các đơn vị mua hàng nếu đã chọn nguyên liệu (quan trọng cho view mode)
      if (ingredientId) {
        this.currentIngredientId = ingredientId;
        this.loadPurchaseUnits(ingredientId);
      }
    }
  }

  /**
   * Xử lý sự kiện click nút xóa mặt hàng
   */
  onRemove() {
    this.remove.emit();
  }

  /**
   * Xử lý khi thay đổi nguyên liệu được chọn
   * Load các đơn vị mua hàng và reset form các field liên quan
   * @param ingredientId - ID nguyên liệu mới được chọn
   */
  onIngredientChange(ingredientId: string | null) {
    this.currentIngredientId = ingredientId;

    if (ingredientId) {
      // Load các đơn vị mua hàng của nguyên liệu
      this.loadPurchaseUnits(ingredientId);

      // Reset các field phụ thuộc vào nguyên liệu
      this.itemForm.patchValue({
        purchaseUnitId: null,
        unitPrice: null,
        quantity: null,
        totalPrice: null,
      });
    } else {
      this.purchaseUnits = [];
      this.currentIngredientCostPerUnit = null;
    }
  }

  /**
   * Xử lý khi thay đổi đơn vị mua hàng
   * Tự động điền giá theo đơn vị và tính lại thành tiền
   * @param purchaseUnitId - ID đơn vị mua hàng được chọn
   */
  onPurchaseUnitChange(purchaseUnitId: string | null) {
    if (purchaseUnitId) {
      const selectedUnit = this.purchaseUnits.find(u => u.id === purchaseUnitId);
      if (selectedUnit) {
        // Tự động điền giá từ purchase unit (nếu có)
        const unitPrice = selectedUnit.purchasePrice || null;
        this.itemForm.patchValue({ unitPrice });

        // Tính lại thành tiền nếu đã có số lượng
        const quantity = this.itemForm.get('quantity')?.value;
        if (quantity && unitPrice) {
          this.onCalculateTotal();
        }
      }
    }
  }

  /**
   * Lấy tên hiển thị của đơn vị mua hàng (bao gồm tỷ lệ quy đổi)
   * @param purchaseUnit - Đơn vị mua hàng cần hiển thị
   * @returns Chuỗi mô tả đơn vị (VD: "Thùng (24 chai)")
   */
  getPurchaseUnitDisplayName(purchaseUnit: IngredientPurchaseUnitDto): string {
    const unitName = purchaseUnit.unit?.displayName || 'N/A';
    if (purchaseUnit.isBaseUnit) {
      return `${unitName} (đơn vị cơ sở)`;
    }
    return `${unitName} (${purchaseUnit.conversionRatio} ${purchaseUnit.baseUnit?.displayName || ''})`;
  }

  /**
   * Tính toán tự động thành tiền khi thay đổi số lượng hoặc đơn giá
   * Công thức: Thành tiền = Số lượng × Đơn giá
   */
  onCalculateTotal() {
    const quantity = this.itemForm.get('quantity')?.value;
    const unitPrice = this.itemForm.get('unitPrice')?.value;

    if (quantity && unitPrice) {
      const totalPrice = quantity * unitPrice;
      this.itemForm.patchValue({ totalPrice }, { emitEvent: false });
    } else {
      this.itemForm.patchValue({ totalPrice: null }, { emitEvent: false });
    }
  }

  /**
   * Xử lý khi thay đổi danh mục nguyên liệu
   * Load danh sách nguyên liệu thuộc danh mục và reset các field liên quan
   * @param categoryId - ID của danh mục được chọn
   */
  onCategoryChange(categoryId: string | null) {
    this.currentCategoryId = categoryId;

    if (categoryId) {
      this.loadIngredientsByCategory(categoryId);
    } else {
      // Xóa danh sách nguyên liệu và reset form khi bỏ chọn danh mục
      this.ingredients = [];
      this.itemForm.patchValue({
        ingredientId: null,
        purchaseUnitId: null,
        unitPrice: null,
        supplierInfo: null,
        totalPrice: null,
        notes: null,
      });
      this.purchaseUnits = [];
    }
  }

  /**
   * Tải danh sách nguyên liệu thuộc danh mục đã chọn
   * @param categoryId - ID của danh mục nguyên liệu
   * @private
   */
  private loadIngredientsByCategory(categoryId: string) {
    this.globalService.getIngredientsByCategoryLookup(categoryId).subscribe({
      next: ingredients => {
        this.ingredients = ingredients;
      },
      error: error => {
        console.error('Lỗi khi tải danh sách nguyên liệu:', error);
      },
    });
  }

  /**
   * Xử lý sự kiện xóa mặt hàng
   * Emit event để parent component xử lý
   */
  onRemove() {
    this.remove.emit();
  }

  onIngredientChange(ingredientId: string | null) {
    this.currentIngredientId = ingredientId;

    if (ingredientId) {
      this.loadPurchaseUnits(ingredientId, true); // true = reset form fields
    } else {
      this.purchaseUnits = [];
      this.itemForm.patchValue({
        purchaseUnitId: null,
        unitPrice: null,
        totalPrice: null,
        supplierInfo: '',
      });
    }
  }

  loadPurchaseUnits(ingredientId: string, resetFormFields: boolean = false) {
    this.purchaseInvoiceService.getIngredientForPurchase(ingredientId).subscribe({
      next: ingredientInfo => {
        this.purchaseUnits = ingredientInfo.purchaseUnits || [];
        this.currentIngredientCostPerUnit = ingredientInfo.costPerUnit || null;

        if (resetFormFields && !this.isViewOnly) {
          this.itemForm.patchValue({
            supplierInfo: ingredientInfo.supplierInfo || '',
            purchaseUnitId: null,
            unitPrice: null,
            totalPrice: null,
          });
        }
      },
      error: error => {
        console.error('Error loading ingredient for purchase:', error);
        this.purchaseUnits = [];
      },
    });
  }

  onPurchaseUnitChange(purchaseUnitId: string | null) {
    if (purchaseUnitId) {
      // Tìm purchase unit được chọn để lấy giá
      const selectedPurchaseUnit = this.purchaseUnits.find(pu => pu.id === purchaseUnitId);
      if (selectedPurchaseUnit) {
        let unitPrice = 0;

        // Nếu có giá riêng cho đơn vị mua này thì sử dụng
        if (selectedPurchaseUnit.purchasePrice) {
          unitPrice = selectedPurchaseUnit.purchasePrice;
        } else if (this.currentIngredientCostPerUnit) {
          // Nếu không có giá riêng, tính từ giá cơ sở * conversion ratio
          unitPrice = this.currentIngredientCostPerUnit * selectedPurchaseUnit.conversionRatio;
        }

        this.itemForm.patchValue({
          unitPrice: unitPrice,
        });
        this.onCalculateTotal();
      }
    } else {
      this.itemForm.patchValue({
        unitPrice: null,
        totalPrice: null,
      });
    }
  }

  getPurchaseUnitDisplayName(purchaseUnit: IngredientPurchaseUnitDto): string {
    const ratioText = purchaseUnit.isBaseUnit
      ? ''
      : ` (1 = ${purchaseUnit.conversionRatio} ${this.getBaseUnitName()})`;
    return `${purchaseUnit.unitName}${ratioText}`;
  }

  private getBaseUnitName(): string {
    const baseUnit = this.purchaseUnits.find(u => u.isBaseUnit);
    return baseUnit?.unitName || '';
  }

  onCalculateTotal() {
    const quantity = this.itemForm.get('quantity')?.value || 0;
    const unitPrice = this.itemForm.get('unitPrice')?.value;

    if (quantity && unitPrice) {
      const totalPrice = quantity * unitPrice;
      this.itemForm.patchValue({ totalPrice });
    }
  }

  getPurchaseUnitName(): string {
    const purchaseUnitId = this.itemForm.get('purchaseUnitId')?.value;
    if (!purchaseUnitId) return '';

    const purchaseUnit = this.purchaseUnits.find(u => u.id === purchaseUnitId);
    return purchaseUnit?.unitName || '';
  }

  getConvertedBaseQuantity(): number {
    const quantity = this.itemForm.get('quantity')?.value || 0;
    const purchaseUnitId = this.itemForm.get('purchaseUnitId')?.value;

    if (!quantity || !purchaseUnitId) return 0;

    const purchaseUnit = this.purchaseUnits.find(u => u.id === purchaseUnitId);
    if (!purchaseUnit) return 0;

    return quantity * purchaseUnit.conversionRatio;
  }
}
