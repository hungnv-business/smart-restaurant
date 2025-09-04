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
import {
  CreateTableDto,
  UpdateTableDto,
  TableDto,
} from '../../../../proxy/table-management/tables/dto/models';
import { TableStatus } from '../../../../proxy/table-status.enum';
import { TableFormDialogData } from './table-form-dialog.service';
import { IntLookupItemDto } from '@proxy/common/dto';

/**
 * Component quản lý form tạo/chỉnh sửa bàn ăn trong hệ thống nhà hàng
 * Chức năng chính:
 * - Tạo mới bàn ăn với số bàn và khu vực
 * - Chỉnh sửa thông tin bàn hiện có
 * - Quản lý trạng thái bàn (trống, đang dùng, đã đặt, dọn dẹp)
 * - Tự động tính toán thứ tự hiển thị tiếp theo
 * - Validation dữ liệu đầu vào
 */
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
    FormFooterActionsComponent,
  ],
  templateUrl: './table-form-dialog.component.html',
  styleUrls: ['./table-form-dialog.component.scss'],
})
export class TableFormDialogComponent extends ComponentBase implements OnInit {
  /** Trạng thái loading khi thực hiện các thao tác async */
  loading = false;
  /** ID khu vực mà bàn thuộc về */
  sectionId = '';
  /** ID của bàn đang chỉnh sửa (nếu có) */
  currentTableId?: string;
  /** Form quản lý thông tin bàn ăn */
  tableForm!: FormGroup;
  /** Danh sách các tùy chọn trạng thái bàn */
  tableStatusOptions: IntLookupItemDto[] = [];

  /** Các service được inject */
  private tableService = inject(TableService);
  private globalService = inject(GlobalService);

  private ref = inject(DynamicDialogRef);
  private config = inject(DynamicDialogConfig<TableFormDialogData>);
  private fb = inject(FormBuilder);

  /**
   * Khởi tạo component với cấu hình dialog
   */
  constructor() {
    super();
  }

  /**
   * Khởi tạo dữ liệu khi component được load
   */
  ngOnInit(): void {
    this.buildForm();
    this.loadInitialData();
  }

  /**
   * Xử lý submit form - tạo mới hoặc cập nhật bàn
   */
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

  /**
   * Hủy thao tác và đóng dialog
   */
  onCancel(): void {
    this.ref.close({ success: false });
  }

  /**
   * Đóng dialog (gọi onCancel)
   */
  onClose(): void {
    this.onCancel();
  }

  /**
   * Tải dữ liệu ban đầu cho form (trạng thái bàn, thông tin bàn, thứ tự hiển thị)
   */
  private loadInitialData(): void {
    // Khởi tạo dữ liệu dialog trước
    if (this.config.data) {
      this.sectionId = this.config.data.sectionId;
      this.currentTableId = this.config.data.tableId;
    }

    // Xây dựng các observable dựa trên chế độ (tạo mới / chỉnh sửa)
    const observables: {
      statuses: Observable<IntLookupItemDto[]>;
      tableData?: Observable<TableDto>;
      nextDisplayOrder?: Observable<number>;
    } = {
      statuses: this.globalService.getTableStatusLookup(),
    };

    // Thêm các observable cụ thể dựa trên chế độ
    if (this.currentTableId) {
      // Chế độ chỉnh sửa: tải thông tin bàn
      observables.tableData = this.tableService.get(this.currentTableId);
    } else if (!this.currentTableId && this.sectionId) {
      // Chế độ tạo mới: lấy thứ tự hiển thị tiếp theo
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
          // Ánh xạ các trạng thái bàn
          this.tableStatusOptions = results.statuses;

          // Xử lý dữ liệu bàn cho chế độ chỉnh sửa
          if (this.currentTableId && results.tableData) {
            this.sectionId = results.tableData.layoutSectionId;
            this.tableForm.patchValue({
              tableNumber: results.tableData.tableNumber,
              displayOrder: results.tableData.displayOrder,
              status: results.tableData.status,
              isActive: results.tableData.isActive,
            });
          }
          // Xử lý thứ tự hiển thị cho chế độ tạo mới
          else if (!this.currentTableId && results.nextDisplayOrder) {
            this.tableForm.patchValue({
              displayOrder: results.nextDisplayOrder,
            });
          }
        },
        error: error => {
          this.handleApiError(error, 'Có lỗi xảy ra khi tải dữ liệu form');
        },
      });
  }

  /**
   * Khởi tạo form với các validation rules
   */
  private buildForm(): void {
    this.tableForm = this.fb.group({
      tableNumber: ['', [Validators.required, Validators.maxLength(50)]],
      displayOrder: [1, [Validators.required, Validators.min(1)]],
      status: [TableStatus.Available, [Validators.required]],
      isActive: [true],
    });
  }

  /**
   * Tạo bàn ăn mới
   * @param formValue Dữ liệu từ form
   */
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
      layoutSectionId: this.sectionId,
    };

    this.tableService
      .create(createData)
      .pipe(
        takeUntil(this.destroyed$),
        catchError(error => {
          this.handleApiError(error, 'Có lỗi xảy ra khi tạo bàn');
          this.loading = false;
          return EMPTY;
        }),
      )
      .subscribe(() => {
        this.loading = false;
        // Hiển thị thông báo thành công và đóng dialog
        this.showSuccess('Thành công', 'Đã thêm bàn mới thành công');

        this.ref.close({ success: true });
      });
  }

  /**
   * Cập nhật thông tin bàn ăn
   * @param formValue Dữ liệu từ form
   */
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
      layoutSectionId: this.sectionId,
    };

    this.tableService
      .update(this.currentTableId!, updateData)
      .pipe(
        takeUntil(this.destroyed$),
        catchError(error => {
          this.handleApiError(error, 'Có lỗi xảy ra khi cập nhật bàn');
          this.loading = false;
          return EMPTY;
        }),
      )
      .subscribe(() => {
        this.loading = false;
        // Hiển thị thông báo cập nhật thành công và đóng dialog
        this.showSuccess('Thành công', 'Cập nhật thông tin bàn thành công');

        this.ref.close({ success: true });
      });
  }
}
