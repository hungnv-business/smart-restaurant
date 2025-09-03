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
  @Input({ required: true }) itemForm!: FormGroup;
  @Input({ required: true }) index!: number;
  @Input() isViewOnly = false;
  @Input() categories: GuidLookupItemDto[] = [];
  @Output() remove = new EventEmitter<void>();

  private purchaseInvoiceService = inject(PurchaseInvoiceService);
  private globalService = inject(GlobalService);

  constructor() {
    super();
  }

  ingredients: GuidLookupItemDto[] = [];
  purchaseUnits: IngredientPurchaseUnitDto[] = [];
  currentCategoryId: string | null = null;
  currentIngredientId: string | null = null;
  currentIngredientCostPerUnit: number | null = null;

  ngOnInit() {
    // Categories được nhận từ parent component
  }

  ngOnChanges(changes: SimpleChanges) {
    // Khi form được populate với data có sẵn, load category và ingredients
    if (changes['itemForm'] && this.itemForm) {
      const categoryId = this.itemForm.get('categoryId')?.value;
      const ingredientId = this.itemForm.get('ingredientId')?.value;
      
      if (categoryId) {
        this.currentCategoryId = categoryId;
        this.loadIngredientsByCategory(categoryId);
      }
      
      // Load purchase units khi có ingredientId (cho view mode)
      if (ingredientId) {
        this.currentIngredientId = ingredientId;
        this.loadPurchaseUnits(ingredientId);
      }
    }
  }


  onCategoryChange(categoryId: string | null) {
    this.currentCategoryId = categoryId;

    if (categoryId) {
      this.loadIngredientsByCategory(categoryId);
    } else {
      // Clear ingredients và reset form khi clear category
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

  private loadIngredientsByCategory(categoryId: string) {
    this.globalService.getIngredientsByCategory(categoryId).subscribe({
      next: ingredients => {
        this.ingredients = ingredients;
      },
      error: error => {
        console.error('Error loading ingredients:', error);
      },
    });
  }

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
        supplierInfo: ''
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
      }
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
    const ratioText = purchaseUnit.isBaseUnit ? '' : ` (1 = ${purchaseUnit.conversionRatio} ${this.getBaseUnitName()})`;
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
