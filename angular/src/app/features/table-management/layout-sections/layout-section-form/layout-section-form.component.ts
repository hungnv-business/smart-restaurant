import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { InputTextModule } from 'primeng/inputtext';
import { InputNumber } from 'primeng/inputnumber';
import { InputSwitch } from 'primeng/inputswitch';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { LayoutSectionService } from '../../../../proxy/table-management/layout-sections/layout-section.service';
import {
  LayoutSectionDto,
  CreateLayoutSectionDto,
  UpdateLayoutSectionDto,
} from '../../../../proxy/table-management/layout-sections/dto/models';
import { LayoutSectionFormDialogData } from './layout-section-form-dialog.service';
import { takeUntil } from 'rxjs/operators';

/**
 * Component quản lý form tạo/chỉnh sửa khu vực bố cục nhà hàng
 * Chức năng chính:
 * - Tạo mới khu vực bố cục với tên tiếng Việt
 * - Chỉnh sửa thông tin khu vực hiện có
 * - Quản lý thứ tự hiển thị khu vực
 * - Gợi ý tên khu vực phổ biến trong nhà hàng Việt Nam
 * - Validation dữ liệu đầu vào
 * - Tự động tính toán thứ tự hiển thị tiếp theo
 */
@Component({
  selector: 'app-layout-section-form',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    InputNumber,
    InputSwitch,
    ValidationErrorComponent,
    FormFooterActionsComponent,
  ],
  templateUrl: './layout-section-form.component.html',
  styleUrls: ['./layout-section-form.component.scss'],
})
export class LayoutSectionFormComponent extends ComponentBase implements OnInit {
  /** Form quản lý thông tin khu vực bố cục */
  sectionForm!: FormGroup;
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** Thông tin chi tiết của khu vực đang chỉnh sửa */
  section: LayoutSectionDto | null = null;
  /** ID của khu vực đang chỉnh sửa (nếu có) */
  sectionId?: string;

  /** Gợi ý tên khu vực phổ biến trong nhà hàng Việt Nam */
  sectionNameSuggestions = [
    'Dãy 1',
    'Dãy 2',
    'Dãy 3',
    'Dãy 4',
    'Dãy 5',
    'Khu VIP',
    'Khu VIP 1',
    'Khu VIP 2',
    'Phòng riêng',
    'Phòng riêng A',
    'Phòng riêng B',
    'Sân vườn',
    'Khu ngoài trời',
    'Ban công',
    'Tầng 1',
    'Tầng 2',
    'Tầng trệt',
    'Khu gia đình',
    'Khu trẻ em',
    'Quầy bar',
    'Khu bar',
    'Quầy café',
    'Hành lang',
    'Khu tiệc',
    'Phòng họp',
  ];

  /** Các service được inject */
  private layoutSectionService = inject(LayoutSectionService);
  private fb = inject(FormBuilder);
  private dialogRef = inject(DynamicDialogRef);
  private config = inject(DynamicDialogConfig);

  /**
   * Khởi tạo component với cấu hình dialog
   */
  constructor() {
    super();
    const data = this.config.data as LayoutSectionFormDialogData;
    this.sectionId = data?.sectionId;
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit(): void {
    this.buildForm();
    if (this.sectionId) {
      this.loadSection(this.sectionId);
    } else {
      // Đối với khu vực mới, tự động lấy thứ tự hiển thị tiếp theo
      this.loadNextDisplayOrder();
    }
  }

  /**
   * Xử lý submit form - tạo mới hoặc cập nhật khu vực
   */
  onSubmit(): void {
    if (!this.validateForm(this.sectionForm)) {
      return;
    }

    this.loading = true;
    const formValue = this.sectionForm.value;

    if (this.sectionId) {
      this.updateSection(formValue);
    } else {
      this.createSection(formValue);
    }
  }

  /**
   * Hủy thao tác và đóng dialog
   */
  onCancel(): void {
    this.dialogRef.close(false);
  }

  /**
   * Xử lý khi click vào gợi ý tên khu vực
   * @param suggestion Tên khu vực được gợi ý
   */
  onSectionNameSuggestionClick(suggestion: string): void {
    this.sectionForm.patchValue({ sectionName: suggestion });
    this.sectionForm.get('sectionName')?.markAsTouched();
  }

  /**
   * Khởi tạo form với các validation rules
   */
  private buildForm(): void {
    this.sectionForm = this.fb.group({
      sectionName: ['', [Validators.required, Validators.maxLength(128)]],
      description: ['', [Validators.maxLength(512)]],
      displayOrder: [1, [Validators.required, Validators.min(1), Validators.max(999)]],
      isActive: [true],
    });
  }

  /**
   * Tải thông tin chi tiết của khu vực theo ID
   * @param sectionId ID của khu vực cần tải
   */
  private loadSection(sectionId: string): void {
    this.loading = true;

    this.layoutSectionService
      .get(sectionId)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: section => {
          this.section = section;
          this.populateForm();
          this.loading = false;
        },
        error: error => {
          this.loading = false;
          this.handleApiError(error, 'Không thể tải thông tin khu vực');
          this.dialogRef.close(false);
        },
      });
  }

  /**
   * Điền dữ liệu khu vực vào form
   */
  private populateForm(): void {
    if (this.section) {
      this.sectionForm.patchValue({
        sectionName: this.section.sectionName,
        description: this.section.description || '',
        displayOrder: this.section.displayOrder,
        isActive: this.section.isActive,
      });
    }
  }

  /**
   * Tải thứ tự hiển thị tiếp theo cho khu vực mới
   */
  private loadNextDisplayOrder(): void {
    this.layoutSectionService
      .getNextDisplayOrder()
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: maxOrder => {
          this.sectionForm.patchValue({
            displayOrder: maxOrder,
          });
        },
        error: error => {
          console.warn('Could not load next display order:', error);
        },
      });
  }

  /**
   * Tạo khu vực mới
   * @param formValue Dữ liệu từ form
   */
  private createSection(formValue: {
    sectionName: string;
    description?: string;
    displayOrder: number;
    isActive: boolean;
  }): void {
    const createDto: CreateLayoutSectionDto = {
      sectionName: formValue.sectionName?.trim(),
      description: formValue.description?.trim() || undefined,
      displayOrder: formValue.displayOrder,
      isActive: formValue.isActive ?? true,
    };

    this.layoutSectionService
      .create(createDto)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: response => {
          this.loading = false;
          this.showSuccess(
            'Tạo mới thành công',
            `Khu vực "${response.sectionName}" đã được tạo thành công`,
          );
          this.dialogRef.close(true);
        },
        error: error => {
          this.loading = false;
          this.handleApiError(error, 'Không thể tạo khu vực mới');
        },
      });
  }

  /**
   * Cập nhật thông tin khu vực
   * @param formValue Dữ liệu từ form
   */
  private updateSection(formValue: {
    sectionName: string;
    description?: string;
    displayOrder: number;
    isActive: boolean;
  }): void {
    const updateDto: UpdateLayoutSectionDto = {
      sectionName: formValue.sectionName?.trim(),
      description: formValue.description?.trim() || undefined,
      displayOrder: formValue.displayOrder,
      isActive: formValue.isActive ?? true,
    };

    this.layoutSectionService
      .update(this.sectionId!, updateDto)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: response => {
          this.loading = false;
          this.showSuccess(
            'Cập nhật thành công',
            `Thông tin khu vực "${response.sectionName}" đã được cập nhật`,
          );
          this.dialogRef.close(true);
        },
        error: error => {
          this.loading = false;
          this.handleApiError(error, 'Không thể cập nhật thông tin khu vực');
        },
      });
  }
}
