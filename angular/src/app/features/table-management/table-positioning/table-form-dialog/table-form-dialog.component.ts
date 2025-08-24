import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, Validators } from '@angular/forms';
import { takeUntil, catchError } from 'rxjs/operators';
import { forkJoin, EMPTY, Observable } from 'rxjs';

// PrimeNG imports
import { InputTextModule } from 'primeng/inputtext';
import { DropdownModule } from 'primeng/dropdown';
import { ButtonModule } from 'primeng/button';
import { InputNumber } from 'primeng/inputnumber';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';

// Application imports
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { TableService } from '../../../../proxy/table-management/tables/table.service';
import { GlobalService } from '../../../../proxy/common/global.service';
import { CreateTableDto, UpdateTableDto, TableDto } from '../../../../proxy/table-management/tables/dto/models';
import { TableStatus } from '../../../../proxy/table-status.enum';
import { TableFormDialogData } from './table-form-dialog.service';
import { IntLookupItemDto } from '@proxy/common/dto';

@Component({
  selector: 'app-table-form-dialog',
  standalone: true,
  imports: [
    CommonModule,
    ReactiveFormsModule,
    InputTextModule,
    DropdownModule,
    ButtonModule,
    InputNumber,
    ValidationErrorComponent,
    FormFooterActionsComponent
  ],
  templateUrl: './table-form-dialog.component.html',
  styleUrls: ['./table-form-dialog.component.scss']
})
export class TableFormDialogComponent extends ComponentBase implements OnInit {
  loading = false;
  sectionId = '';
  currentTableId?: string;
  tableForm!: FormGroup;
  tableStatusOptions: IntLookupItemDto[] = [];

  private tableService = inject(TableService);
  private globalService = inject(GlobalService);

  private ref = inject(DynamicDialogRef);
  private config = inject(DynamicDialogConfig<TableFormDialogData>);
  private fb = inject(FormBuilder);

  constructor() {
    super();
  }

  ngOnInit(): void {
    this.buildForm();
    this.loadInitialData();
  }

  private loadInitialData(): void {
    // Initialize dialog data first
    if (this.config.data) {
      this.sectionId = this.config.data.sectionId;
      this.currentTableId = this.config.data.tableId;
    }

    // Build observables based on mode
    const observables: {
      statuses: Observable<IntLookupItemDto[]>;
      tableData?: Observable<TableDto>;
      nextDisplayOrder?: Observable<number>;
    } = {
      statuses: this.globalService.getTableStatuses()
    };

    // Add specific observables based on mode
    if (this.currentTableId) {
      observables.tableData = this.tableService.get(this.currentTableId);
    } else if (!this.currentTableId && this.sectionId) {
      observables.nextDisplayOrder = this.tableService.getNextDisplayOrder(this.sectionId);
    }

    forkJoin(observables)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: (results: {
          statuses: IntLookupItemDto[];
          tableData?: TableDto;
          nextDisplayOrder?: number;
        }) => {
          // Map table statuses  
          this.tableStatusOptions = results.statuses;

          // Handle table data for edit mode
          if (this.currentTableId && results.tableData) {
            this.sectionId = results.tableData.layoutSectionId;
            this.tableForm.patchValue({
              tableNumber: results.tableData.tableNumber,
              displayOrder: results.tableData.displayOrder,
              status: results.tableData.status,
              isActive: results.tableData.isActive
            });
          } 
          // Handle display order for create mode
          else if (!this.currentTableId && results.nextDisplayOrder) {
            this.tableForm.patchValue({
              displayOrder: results.nextDisplayOrder
            });
          }
        },
        error: (error) => {
          this.handleApiError(error, 'Có lỗi xảy ra khi tải dữ liệu form');
        }
      });
  }

  private buildForm(): void {
    this.tableForm = this.fb.group({
      tableNumber: ['', [Validators.required, Validators.maxLength(50)]],
      displayOrder: [1, [Validators.required, Validators.min(1)]],
      status: [TableStatus.Available, [Validators.required]],
      isActive: [true]
    });
  }



  onSubmit(): void {
    if (!this.validateForm(this.tableForm)) {
      return;
    }

    this.loading = true;
    const formValue = this.tableForm.value;

    if (this.currentTableId) {
      this.updateTable(formValue);
    } else {
      this.createTable(formValue);
    }
  }

  private createTable(formValue: {
    tableNumber: string;
    displayOrder: number;
    status: TableStatus;
    isActive: boolean;
  }): void {
    const createData: CreateTableDto = {
      tableNumber: formValue.tableNumber?.trim(),
      displayOrder: formValue.displayOrder,
      status: formValue.status,
      isActive: formValue.isActive,
      layoutSectionId: this.sectionId
    };

    this.tableService.create(createData).pipe(
      takeUntil(this.destroyed$),
      catchError(error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi tạo bàn');
        this.loading = false;
        return EMPTY;
      })
    ).subscribe(() => {
      this.loading = false;
      this.showSuccess('Thành công', 'Đã thêm bàn mới thành công');
      
      this.ref.close({ success: true });
    });
  }

  private updateTable(formValue: {
    tableNumber: string;
    displayOrder: number;
    status: TableStatus;
    isActive: boolean;
  }): void {
    const updateData: UpdateTableDto = {
      tableNumber: formValue.tableNumber?.trim(),
      displayOrder: formValue.displayOrder,
      status: formValue.status,
      isActive: formValue.isActive,
      layoutSectionId: this.sectionId
    };

    this.tableService.update(this.currentTableId!, updateData).pipe(
      takeUntil(this.destroyed$),
      catchError(error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi cập nhật bàn');
        this.loading = false;
        return EMPTY;
      })
    ).subscribe(() => {
      this.loading = false;
      this.showSuccess('Thành công', 'Cập nhật thông tin bàn thành công');
      
      this.ref.close({ success: true });
    });
  }

  onCancel(): void {
    this.ref.close({ success: false });
  }

  onClose(): void {
    this.onCancel();
  }
}