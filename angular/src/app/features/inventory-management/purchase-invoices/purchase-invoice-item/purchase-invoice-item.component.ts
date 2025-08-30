import { Component, Input, Output, EventEmitter, inject, OnInit, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormGroup, ReactiveFormsModule } from '@angular/forms';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumber } from 'primeng/inputnumber';
import { DropdownModule } from 'primeng/dropdown';
import { ButtonModule } from 'primeng/button';
import { TooltipModule } from 'primeng/tooltip';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { PurchaseInvoiceService } from '../../../../proxy/inventory-management/purchase-invoices/purchase-invoice.service';
import { GuidLookupItemDto } from '../../../../proxy/common/dto/models';
import { GlobalService } from '../../../../proxy/common/global.service';

@Component({
  selector: 'app-purchase-invoice-item',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    InputNumber,
    DropdownModule,
    ButtonModule,
    TooltipModule,
    ValidationErrorComponent,
  ],
  templateUrl: './purchase-invoice-item.component.html',
})
export class PurchaseInvoiceItemComponent implements OnInit, OnChanges {
  @Input({ required: true }) itemForm!: FormGroup;
  @Input({ required: true }) index!: number;
  @Input() isViewOnly = false;
  @Output() remove = new EventEmitter<void>();

  private purchaseInvoiceService = inject(PurchaseInvoiceService);
  private globalService = inject(GlobalService);

  categories: GuidLookupItemDto[] = [];
  ingredients: GuidLookupItemDto[] = [];
  currentCategoryId: string | null = null;

  ngOnInit() {
    this.loadCategories();
  }

  ngOnChanges(changes: SimpleChanges) {
    // Khi form được populate với data có sẵn, load category và ingredients
    if (changes['itemForm'] && this.itemForm) {
      const categoryId = this.itemForm.get('categoryId')?.value;
      if (categoryId) {
        this.currentCategoryId = categoryId;
        this.loadIngredientsByCategory(categoryId);
      }
    }
  }

  loadCategories() {
    this.globalService.getCategories().subscribe({
      next: (categories) => {
        this.categories = categories;
      },
      error: (error) => {
        console.error('Error loading categories:', error);
      }
    });
  }

  onCategoryChange(categoryId: string | null) {
    this.currentCategoryId = categoryId;
    this.itemForm.patchValue({ categoryId });
    
    if (categoryId) {
      this.loadIngredientsByCategory(categoryId);
    } else {
      // Clear ingredients và reset form khi clear category
      this.ingredients = [];
      this.itemForm.patchValue({
        ingredientId: null,
        ingredientName: null,
        unitId: null,
        unitName: null,
        unitPrice: null,
        supplierInfo: null,
        totalPrice: null,
      });
    }
  }

  private loadIngredientsByCategory(categoryId: string) {
    this.globalService.getIngredientsByCategory(categoryId).subscribe({
      next: (ingredients) => {
        this.ingredients = ingredients;
      },
      error: (error) => {
        console.error('Error loading ingredients:', error);
      }
    });
  }

  onRemove() {
    this.remove.emit();
  }

  onIngredientNameChange(ingredientName: string | null) {
    // Tìm ingredient match với tên đã nhập
    const matchedIngredient = this.ingredients.find(ing => ing.displayName === ingredientName);
    
    if (matchedIngredient && matchedIngredient.id) {
      // Gọi API để lấy thông tin chi tiết và auto-fill
      this.purchaseInvoiceService.getIngredientLookup(matchedIngredient.id).subscribe({
        next: (ingredientLookup) => {
          if (ingredientLookup) {
            this.itemForm.patchValue({
              ingredientId: ingredientLookup.id,
              ingredientName: ingredientLookup.name,
              unitId: ingredientLookup.unitId,
              unitName: ingredientLookup.unitName,
              unitPrice: ingredientLookup.costPerUnit,
              supplierInfo: ingredientLookup.supplierInfo
            });
            
            // Tự động tính thành tiền nếu có quantity
            this.onCalculateTotal();
          }
        },
        error: (error) => {
          console.error('Error loading ingredient lookup:', error);
        }
      });
    } else {
      // Nếu nhập tự do → clear ID và thông tin auto-fill
      this.itemForm.patchValue({
        ingredientId: null,
        unitId: null,
        unitPrice: null,
        supplierInfo: null
      });
      // Không clear unitName - để user tự nhập
    }
  }

  onCalculateTotal() {
    const quantity = this.itemForm.get('quantity')?.value || 0;
    const unitPrice = this.itemForm.get('unitPrice')?.value;
    
    if (quantity && unitPrice) {
      const totalPrice = quantity * unitPrice;
      this.itemForm.patchValue({ totalPrice });
    }
  }
}