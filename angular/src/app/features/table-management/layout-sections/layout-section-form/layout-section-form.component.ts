import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  ReactiveFormsModule,
  FormBuilder,
  FormGroup,
  Validators,
} from '@angular/forms';
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
  sectionForm!: FormGroup;
  loading = false;
  section: LayoutSectionDto | null = null;
  sectionId?: string;

  // Vietnamese restaurant section name suggestions
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

  private layoutSectionService = inject(LayoutSectionService);
  private fb = inject(FormBuilder);
  private dialogRef = inject(DynamicDialogRef);
  private config = inject(DynamicDialogConfig);

  constructor() {
    super();
    const data = this.config.data as LayoutSectionFormDialogData;
    this.sectionId = data?.sectionId;
  }

  ngOnInit(): void {
    this.buildForm();
    if (this.sectionId) {
      this.loadSection(this.sectionId);
    } else {
      // For new sections, get the next display order
      this.loadNextDisplayOrder();
    }
  }

  private buildForm(): void {
    this.sectionForm = this.fb.group({
      sectionName: ['', [Validators.required, Validators.maxLength(128)]],
      description: ['', [Validators.maxLength(512)]],
      displayOrder: [1, [Validators.required, Validators.min(1), Validators.max(999)]],
      isActive: [true],
    });
  }

  private loadSection(sectionId: string): void {
    this.loading = true;
    
    this.layoutSectionService.get(sectionId)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: (section) => {
          this.section = section;
          this.populateForm();
          this.loading = false;
        },
        error: (error) => {
          this.loading = false;
          this.handleApiError(error, 'Không thể tải thông tin khu vực');
          this.dialogRef.close(false);
        }
      });
  }

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

  private createSection(formValue: { sectionName: string; description?: string; displayOrder: number; isActive: boolean }): void {
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
            `Khu vực "${response.sectionName}" đã được tạo thành công`
          );
          this.dialogRef.close(true);
        },
        error: error => {
          this.loading = false;
          this.handleApiError(error, 'Không thể tạo khu vực mới');
        },
      });
  }

  private updateSection(formValue: { sectionName: string; description?: string; displayOrder: number; isActive: boolean }): void {
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
            `Thông tin khu vực "${response.sectionName}" đã được cập nhật`
          );
          this.dialogRef.close(true);
        },
        error: error => {
          this.loading = false;
          this.handleApiError(error, 'Không thể cập nhật thông tin khu vực');
        },
      });
  }

  onCancel(): void {
    this.dialogRef.close(false);
  }

  onSectionNameSuggestionClick(suggestion: string): void {
    this.sectionForm.patchValue({ sectionName: suggestion });
    this.sectionForm.get('sectionName')?.markAsTouched();
  }
}
