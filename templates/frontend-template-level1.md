# Level 1: Simple List + Form UI Template

## 📋 Khi nào sử dụng Level 1
- **Simple master data management**: Quản lý dữ liệu chủ đạo đơn giản
- **Basic CRUD operations**: Các thao tác CRUD cơ bản
- **Phù hợp cho**: RoleList, UserList, LayoutSectionList, MenuCategoryList...

## 🎯 UI Pattern: PrimeNG Table + Dialog Form
- Basic search và filtering
- Standard CRUD operations (Create, Read, Update, Delete)  
- Simple form validation
- Confirmation dialogs

## Cấu trúc Angular Frontend

### 1. List Component Template - Dựa trên MenuCategoryListComponent

```typescript
// File: angular/src/app/features/{module}/{entity-name}s/{entity-name}-list/{entity-name}-list.component.ts
import { Component, OnInit, signal, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ButtonModule } from 'primeng/button';
import { TableModule, Table } from 'primeng/table';
import { InputTextModule } from 'primeng/inputtext';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { TagModule } from 'primeng/tag';
import { InputIconModule } from 'primeng/inputicon';
import { IconFieldModule } from 'primeng/iconfield';
import { ToolbarModule } from 'primeng/toolbar';
import { RippleModule } from 'primeng/ripple';
import { TooltipModule } from 'primeng/tooltip';
import { {EntityName}Dto } from '../../../../proxy/{module}/{entity-name}s/dto';
import { {EntityName}Service } from '../../../../proxy/{module}/{entity-name}s';
import { {EntityName}FormDialogService } from '../services/{entity-name}-form-dialog.service';
import { PagedAndSortedResultRequestDto } from '@abp/ng.core';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { finalize } from 'rxjs/operators';

@Component({
  selector: 'app-{entity-name}-list',
  standalone: true,
  // Import các module PrimeNG cần thiết cho table, form controls và dialog
  imports: [
    CommonModule,
    TableModule, // PrimeNG Table với pagination, sorting, filtering
    ButtonModule, // PrimeNG Button với các variant (primary, outlined, text)
    RippleModule, // Material Design ripple effect
    ToolbarModule, // Header toolbar cho các actions
    InputTextModule, // Text input với icon support
    TagModule, // Badge/Tag cho status display
    InputIconModule, // Icon inside input field
    IconFieldModule, // Wrapper cho input với icon
    ConfirmDialogModule, // Modal confirmation dialogs
    TooltipModule, // Hover tooltips
  ],
  providers: [],
  templateUrl: './{entity-name}-list.component.html',
  styleUrls: ['./{entity-name}-list.component.scss'],
})
export class {EntityName}ListComponent extends ComponentBase implements OnInit {
  // Quyền truy cập - Kiểm soát hiển thị các nút theo quyền user
  readonly permissions = {
    create: PERMISSIONS.RESTAURANT.{MODULE}.{ENTITY_UPPER}.CREATE,
    edit: PERMISSIONS.RESTAURANT.{MODULE}.{ENTITY_UPPER}.EDIT,
    delete: PERMISSIONS.RESTAURANT.{MODULE}.{ENTITY_UPPER}.DELETE,
  };

  // Cấu hình bảng - Các field được search khi user nhập tìm kiếm
  filterFields: string[] = ['name', 'description'];

  // Dữ liệu hiển thị
  {entityName}s = signal<{EntityName}Dto[]>([]); // Danh sách entities (client-side filtering)
  selected{EntityName}s: {EntityName}Dto[] = []; // Các entity được chọn để xóa bulk
  loading = false; // Trạng thái loading khi gọi API

  // Hằng số
  private readonly ENTITY_NAME = '{entity-display-name}'; // Tên entity dùng trong thông báo

  // Các service được inject
  private {entityName}Service = inject({EntityName}Service); // Service gọi API
  private {entityName}FormDialogService = inject({EntityName}FormDialogService); // Service mở dialog form

  constructor() {
    // ComponentBase cung cấp các method utility: showSuccess, handleApiError, confirmDelete, etc.
    super();
  }

  ngOnInit() {
    // Khởi tạo component: Load danh sách từ server
    this.load{EntityName}s();
  }

  // Thao tác bảng dữ liệu - PrimeNG tự xử lý client-side
  onGlobalFilter(table: Table, event: Event): void {
    // Tìm kiếm global trên tất cả các field được định nghĩa trong filterFields
    table.filterGlobal((event.target as HTMLInputElement).value, 'contains');
  }

  // Các thao tác với dialog form
  openFormDialog({entityName}Id?: string) {
    // Mở dialog form - tạo mới nếu không có ID, chỉnh sửa nếu có ID
    const dialog$ = {entityName}Id
      ? this.{entityName}FormDialogService.openEditDialog({entityName}Id)
      : this.{entityName}FormDialogService.openCreateDialog();

    dialog$.subscribe(success => {
      if (success) {
        this.load{EntityName}s(); // Reload danh sách sau khi thành công

        // Hiển thị thông báo tương ứng với thao tác
        if ({entityName}Id) {
          this.showUpdateSuccess(this.ENTITY_NAME);
        } else {
          this.showCreateSuccess(this.ENTITY_NAME);
        }
      }
    });
  }

  deleteSelected{EntityName}s() {
    // Xóa nhiều entity được chọn (bulk delete)
    if (!this.selected{EntityName}s?.length) return;

    // Sử dụng method từ ComponentBase với message đơn giản
    this.confirmBulkDelete(() => {
      this.performDeleteSelected{EntityName}s(); // Thực hiện xóa khi user confirm
    });
  }

  delete{EntityName}({entityName}: {EntityName}Dto) {
    // Xóa một entity cụ thể - sử dụng method từ ComponentBase
    this.confirmDelete({entityName}.name!, () => {
      this.performDelete{EntityName}({entityName}); // Thực hiện xóa khi user confirm
    });
  }

  // Các phương thức private
  private load{EntityName}s() {
    // Load tất cả entities từ server (client-side pagination)
    this.loading = true;

    const request: PagedAndSortedResultRequestDto = {
      maxResultCount: 1000, // Lấy hết tất cả entities (vì ít dữ liệu)
      skipCount: 0,
      sorting: 'displayOrder', // Sắp xếp theo thứ tự hiển thị
    };

    this.{entityName}Service
      .getList(request)
      .pipe(
        finalize(() => (this.loading = false)), // Luôn set loading = false khi hoàn thành hoặc lỗi
      )
      .subscribe({
        next: result => {
          this.{entityName}s.set(result.items || []); // Set dữ liệu vào signal
        },
        error: error => {
          console.error('Error loading {entityName}s:', error);
          this.{entityName}s.set([]); // Reset về mảng rỗng khi có lỗi
        },
      });
  }

  private performDelete{EntityName}({entityName}: {EntityName}Dto) {
    // Thực hiện xóa một entity cụ thể
    this.{entityName}Service.delete({entityName}.id).subscribe({
      next: () => {
        this.load{EntityName}s(); // Reload danh sách sau khi xóa
        this.showDeleteSuccess(this.ENTITY_NAME); // Hiển thị thông báo xóa thành công
      },
      error: error => {
        this.handleApiError(error, 'Không thể xóa {entity-display-name}'); // Xử lý lỗi API
      },
    });
  }

  private performDeleteSelected{EntityName}s() {
    // Thực hiện xóa nhiều entities được chọn
    if (!this.selected{EntityName}s?.length) return;

    // Lấy danh sách ID các entities được chọn
    const ids = this.selected{EntityName}s.map({entityName} => {entityName}.id!);

    this.{entityName}Service.deleteMany(ids).subscribe({
      next: () => {
        this.load{EntityName}s(); // Reload danh sách sau khi xóa
        this.selected{EntityName}s = []; // Clear selection
        this.showBulkDeleteSuccess(ids.length, this.ENTITY_NAME); // Hiển thị thông báo xóa bulk thành công
      },
      error: error => {
        this.handleApiError(error, 'Có lỗi xảy ra khi xóa {entity-display-name}'); // Xử lý lỗi API
      },
    });
  }
}
```

### 2. Component HTML Template

```html
<!-- File: angular/src/app/features/{module}/{entity-name}/{entity-name}-list/{entity-name}-list.component.html -->
<div class="bg-white rounded-lg shadow-sm border">
  <!-- Header -->
  <div class="p-6 border-b">
    <div class="flex justify-between items-center">
      <h3 class="text-xl font-semibold text-gray-900">Danh sách {Entity Display Name}</h3>
      <button
        pButton
        type="button"
        icon="pi pi-plus"
        class="p-button p-button-primary"
        label="Thêm mới"
        (click)="onCreate()"
      ></button>
    </div>
  </div>

  <!-- Search and filters -->
  <div class="p-6">
    <div class="flex justify-between items-center mb-6">
      <div class="relative">
        <span class="p-input-icon-left">
          <i class="pi pi-search"></i>
          <input
            pInputText
            type="text"
            [placeholder]="searchPlaceholder"
            [value]="globalFilterValue"
            (input)="onGlobalFilter($event)"
            class="w-80"
          />
        </span>
        <button
          *ngIf="globalFilterValue"
          pButton
          type="button"
          icon="pi pi-times"
          class="p-button-text p-button-rounded p-button-plain absolute right-2 top-1/2 transform -translate-y-1/2"
          (click)="clearGlobalFilter()"
        ></button>
      </div>
    </div>

    <!-- Data table -->
    <p-table
      #dt
      [value]="{entityName}s"
      [loading]="loading"
      [paginator]="true"
      [rows]="10"
      [rowsPerPageOptions]="[10, 25, 50]"
      [showCurrentPageReport]="true"
      currentPageReportTemplate="Hiển thị {first} đến {last} của {totalRecords} kết quả"
      [globalFilterFields]="['{propertyName}', 'description']"
      responsiveLayout="stack"
      styleClass="p-datatable-sm"
    >
      <ng-template pTemplate="header">
        <tr>
          <th pSortableColumn="{propertyName}">
            {Property Display Name}
            <p-sortIcon field="{propertyName}"></p-sortIcon>
          </th>
          <th pSortableColumn="description">
            Mô tả
            <p-sortIcon field="description"></p-sortIcon>
          </th>
          <th pSortableColumn="displayOrder">
            Thứ tự
            <p-sortIcon field="displayOrder"></p-sortIcon>
          </th>
          <th pSortableColumn="isActive">
            Trạng thái
            <p-sortIcon field="isActive"></p-sortIcon>
          </th>
          <th pSortableColumn="creationTime">
            Ngày tạo
            <p-sortIcon field="creationTime"></p-sortIcon>
          </th>
          <th style="width: 150px">Thao tác</th>
        </tr>
      </ng-template>
      
      <ng-template pTemplate="body" let-{entityName}>
        <tr>
          <td>
            <span class="font-semibold text-gray-900">{{ {entityName}.{propertyName} }}</span>
          </td>
          <td>
            <span class="text-gray-500">{{ {entityName}.description || 'Không có mô tả' }}</span>
          </td>
          <td>
            <span class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium bg-blue-100 text-blue-800">{{ {entityName}.displayOrder }}</span>
          </td>
          <td>
            <span 
              class="inline-flex items-center px-2 py-1 rounded-full text-xs font-medium"
              [class]="{entityName}.isActive ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'"
            >
              {{ {entityName}.isActive ? 'Hoạt động' : 'Không hoạt động' }}
            </span>
          </td>
          <td>
            <span class="text-sm text-gray-500">{{ {entityName}.creationTime | date: 'dd/MM/yyyy HH:mm' }}</span>
          </td>
          <td>
            <div class="flex gap-2">
              <button
                pButton
                type="button"
                icon="pi pi-pencil"
                class="p-button-outlined p-button-sm p-button-info"
                pTooltip="Chỉnh sửa"
                (click)="onEdit({entityName})"
              ></button>
              <button
                pButton
                type="button"
                icon="pi pi-trash"
                class="p-button-outlined p-button-sm p-button-danger"
                pTooltip="Xóa"
                (click)="onDelete({entityName})"
              ></button>
            </div>
          </td>
        </tr>
      </ng-template>
      
      <ng-template pTemplate="emptymessage">
        <tr>
          <td colspan="6" class="text-center py-8">
            <div class="flex flex-col items-center">
              <i class="pi pi-search text-gray-400 text-5xl mb-3"></i>
              <p class="text-gray-500 text-sm">Không tìm thấy dữ liệu</p>
            </div>
          </td>
        </tr>
      </ng-template>
    </p-table>
  </div>
</div>

<p-confirmDialog></p-confirmDialog>
```

### 3. Form Component Template - Dựa trên MenuCategoryFormComponent

```typescript
// File: angular/src/app/features/{module}/{entity-name}s/{entity-name}-form/{entity-name}-form.component.ts
import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule, Validators } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { InputTextModule } from 'primeng/inputtext';
import { TextareaModule } from 'primeng/textarea';
import { InputNumberModule } from 'primeng/inputnumber';
import { ProgressSpinnerModule } from 'primeng/progressspinner';
import {
  {EntityName}Dto,
  CreateUpdate{EntityName}Dto,
} from '../../../../proxy/{module}/{entity-name}s/dto';
import { {EntityName}Service } from '../../../../proxy/{module}/{entity-name}s';
import { ComponentBase } from '../../../../shared/base/component-base';
import { ValidationErrorComponent } from '../../../../shared/components/validation-error/validation-error.component';
import { FormFooterActionsComponent } from '../../../../shared/components/form-footer-actions/form-footer-actions.component';
import { {EntityName}FormData } from '../services/{entity-name}-form-dialog.service';
import { CustomValidators } from '../../../../shared/validators/custom-validators';
import { take, finalize } from 'rxjs';

@Component({
  selector: 'app-{entity-name}-form',
  standalone: true,
  // Import các module cần thiết cho reactive form và validation
  imports: [
    CommonModule,
    ReactiveFormsModule, // Angular reactive forms với FormBuilder, FormGroup
    InputTextModule, // PrimeNG text input với validation styling
    TextareaModule, // PrimeNG textarea cho description field
    InputNumberModule, // PrimeNG number input với spinner controls
    ProgressSpinnerModule, // Loading spinner khi submit form
    ValidationErrorComponent, // Custom component hiển thị validation errors
    FormFooterActionsComponent, // Custom component với Save/Cancel buttons
  ],
  templateUrl: './{entity-name}-form.component.html',
  styleUrls: ['./{entity-name}-form.component.scss'],
})
export class {EntityName}FormComponent extends ComponentBase implements OnInit {
  // Form state và data
  form: FormGroup; // Reactive form với validation rules
  loading = false; // Loading state khi submit form
  isEdit = false; // Phân biệt mode Create vs Edit
  {entityName}?: {EntityName}Dto; // Entity data khi ở Edit mode

  // Dynamic Dialog integration - PrimeNG dialog system
  public ref = inject(DynamicDialogRef); // Reference để close dialog và return result
  public config = inject(DynamicDialogConfig<{EntityName}FormData>); // Dialog config và data

  // Injected services
  private fb = inject(FormBuilder); // Angular FormBuilder để tạo reactive form
  private {entityName}Service = inject({EntityName}Service); // API service

  constructor() {
    // ComponentBase cung cấp: validateForm, handleApiError, showSuccess, etc.
    super();
    this.form = this.createForm();
  }

  ngOnInit() {
    // Xử lý data được truyền từ dialog service
    const data = this.config.data;
    if (data) {
      this.isEdit = !!data.{entityName}Id; // Có ID = Edit mode
      this.{entityName} = data.{entityName}; // Pre-loaded entity data

      if (this.isEdit && this.{entityName}) {
        // Edit mode: populate form với data hiện tại
        this.populateForm(this.{entityName});
      } else if (data.nextDisplayOrder) {
        // Create mode: set default display order tự động từ server
        this.form.patchValue({
          displayOrder: data.nextDisplayOrder,
        });
      }
    }
  }

  onSubmit() {
    // Validate form trước khi submit - method từ ComponentBase
    if (!this.validateForm(this.form)) {
      return;
    }

    // Map form values thành DTO để gửi lên server
    const formValue = this.form.value;
    const dto: CreateUpdate{EntityName}Dto = {
      name: formValue.name,
      description: formValue.description || '',
      displayOrder: formValue.displayOrder,
      isEnabled: formValue.isEnabled,
      imageUrl: formValue.imageUrl || '',
    };

    this.loading = true; // Bật loading state

    this.save{EntityName}(dto);
  }

  onCancel() {
    // Đóng dialog với result = false (không có thay đổi)
    this.ref.close(false);
  }

  private save{EntityName}(dto: CreateUpdate{EntityName}Dto) {
    // Chọn operation dựa trên mode: Create vs Edit
    const operation =
      this.isEdit && this.{entityName}
        ? this.{entityName}Service.update(this.{entityName}.id, dto)
        : this.{entityName}Service.create(dto);

    const errorMessage = this.isEdit ? 'Không thể cập nhật {entity-display-name}' : 'Không thể tạo {entity-display-name}';

    operation
      .pipe(
        take(1), // Chỉ lấy 1 result duy nhất
        finalize(() => (this.loading = false)), // Luôn tắt loading khi hoàn thành
      )
      .subscribe({
        next: () => {
          // Đóng dialog với result = true (có thay đổi) để parent component reload data
          this.ref.close(true);
        },
        error: err => this.handleApiError(err, errorMessage), // Error handling từ ComponentBase
      });
  }

  /** ---------------- Form Configuration ---------------- */
  private createForm(): FormGroup {
    // Tạo reactive form với validation rules tương ứng với backend constraints
    return this.fb.group({
      name: ['', [Validators.required, Validators.maxLength(128)]], // Required field, max 128 chars
      description: ['', [Validators.maxLength(512)]], // Optional field, max 512 chars
      displayOrder: [1, [Validators.required, Validators.min(1)]], // Số thứ tự >= 1
      isEnabled: [true], // Mặc định enabled
      imageUrl: ['', [Validators.maxLength(2048), CustomValidators.url()]], // Optional URL field
    });
  }

  private populateForm({entityName}: {EntityName}Dto) {
    this.form.patchValue({
      name: {entityName}.name ?? '',
      description: {entityName}.description ?? '',
      displayOrder: {entityName}.displayOrder ?? 1,
      isEnabled: {entityName}.isEnabled ?? true,
      imageUrl: {entityName}.imageUrl ?? '',
    });

    this.form.markAsPristine();
  }
}
```

### 4. Form HTML Template

```html
<!-- File: angular/src/app/features/{module}/{entity-name}/{entity-name}-form/{entity-name}-form.component.html -->
<form [formGroup]="{entityName}Form" (ngSubmit)="onSubmit()" class="space-y-6">
  <div class="grid grid-cols-1 gap-6">
    <!-- {Property Display Name} Field -->
    <div class="space-y-2">
      <label class="block text-sm font-medium text-gray-700 required" for="{propertyName}">
        {Property Display Name}
      </label>
      <input
        pInputText
        id="{propertyName}"
        formControlName="{propertyName}"
        class="w-full"
        placeholder="Nhập {property-display-name}..."
        [class.p-invalid]="{entityName}Form.get('{propertyName}')?.invalid && {entityName}Form.get('{propertyName}')?.touched"
      />
      <app-validation-error 
        [control]="{entityName}Form.get('{propertyName}')" 
        [fieldName]="'{Property Display Name}'"
      ></app-validation-error>
    </div>

    <!-- Description Field -->
    <div class="space-y-2">
      <label class="block text-sm font-medium text-gray-700" for="description">Mô tả</label>
      <textarea
        pInputTextarea
        id="description"
        formControlName="description"
        class="w-full"
        placeholder="Nhập mô tả (tùy chọn)..."
        rows="3"
        [class.p-invalid]="{entityName}Form.get('description')?.invalid && {entityName}Form.get('description')?.touched"
      ></textarea>
      <app-validation-error 
        [control]="{entityName}Form.get('description')" 
        fieldName="Mô tả"
      ></app-validation-error>
    </div>

    <!-- Display Order and Active Status Fields -->
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <!-- Display Order Field -->
      <div class="space-y-2">
        <label class="block text-sm font-medium text-gray-700 required" for="displayOrder">Thứ tự hiển thị</label>
        <p-inputNumber
          inputId="displayOrder"
          formControlName="displayOrder"
          class="w-full"
          [min]="1"
          [max]="999"
          [showButtons]="true"
          buttonLayout="horizontal"
          spinnerMode="horizontal"
          decrementButtonClass="p-button-secondary"
          incrementButtonClass="p-button-secondary"
        ></p-inputNumber>
        <app-validation-error 
          [control]="{entityName}Form.get('displayOrder')" 
          fieldName="Thứ tự hiển thị"
        ></app-validation-error>
      </div>

      <!-- Active Status Field -->
      <div class="space-y-2">
        <label class="block text-sm font-medium text-gray-700" for="isActive">Trạng thái</label>
        <div class="flex items-center mt-2">
          <p-inputSwitch
            inputId="isActive"
            formControlName="isActive"
          ></p-inputSwitch>
          <span class="ml-3 text-sm text-gray-500">
            {{ {entityName}Form.get('isActive')?.value ? 'Hoạt động' : 'Không hoạt động' }}
          </span>
        </div>
      </div>
    </div>
  </div>

  <!-- Form Actions -->
  <app-form-footer-actions
    [loading]="loading"
    [saveText]="{entityName}Id ? 'Cập nhật' : 'Tạo mới'"
    cancelText="Hủy"
    (save)="onSubmit()"
    (cancel)="onCancel()"
  ></app-form-footer-actions>
</form>
```

### 5. Dialog Service Template - Dựa trên MenuCategoryFormDialogService

```typescript
// File: angular/src/app/features/{module}/{entity-name}s/services/{entity-name}-form-dialog.service.ts
import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { {EntityName}FormComponent } from '../{entity-name}-form/{entity-name}-form.component';
import { {EntityName}Service } from '../../../../proxy/{module}/{entity-name}s';
import { {EntityName}Dto } from '../../../../proxy/{module}/{entity-name}s/dto';

// Interface định nghĩa data truyền vào dialog form
export interface {EntityName}FormData {
  {entityName}Id?: string; // ID entity (có trong Edit mode)
  {entityName}?: {EntityName}Dto; // Entity data đã load từ server (Edit mode)
  title?: string; // Tiêu đề dialog
  nextDisplayOrder?: number; // Thứ tự hiển thị tiếp theo (Create mode)
}

@Injectable({
  providedIn: 'root',
})
export class {EntityName}FormDialogService {
  private dialogService = inject(DialogService);
  private {entityName}Service = inject({EntityName}Service);

  /**
   * Mở dialog thêm mới - tự động load nextDisplayOrder từ server
   */
  openCreateDialog(): Observable<boolean> {
    const dialogData: {EntityName}FormData = {
      title: 'Thêm mới',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Mở dialog chỉnh sửa - tự động load entity data từ server
   */
  openEditDialog({entityName}Id: string): Observable<boolean> {
    const dialogData: {EntityName}FormData = {
      {entityName}Id,
      title: 'Cập nhật',
    };

    return this.openDialog(dialogData);
  }

  /**
   * Method dùng chung để mở dialog - tự động load dữ liệu cần thiết trước khi mở
   */
  private openDialog(data: {EntityName}FormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.{entityName}Id) {
        // Edit mode: load entity data trước
        this.{entityName}Service.get(data.{entityName}Id).subscribe({
          next: ({entityName}: {EntityName}Dto) => {
            data.{entityName} = {entityName};
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error loading {entity-name}:', error);
            observer.error(error);
          },
        });
      } else {
        // Create mode: load next display order trước
        this.{entityName}Service.getNextDisplayOrder().subscribe({
          next: (nextDisplayOrder: number) => {
            data.nextDisplayOrder = nextDisplayOrder;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error getting next display order:', error);
            observer.error(error);
          },
        });
      }
    });
  }

  private createDialog(
    data: {EntityName}FormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    const config: DynamicDialogConfig<{EntityName}FormData> = {
      header: data.title,
      width: '600px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      maximizable: false,
      dismissableMask: false,
      closeOnEscape: true,
      breakpoints: {
        '960px': '75vw',
        '640px': '90vw',
      },
    };

    const ref: DynamicDialogRef = this.dialogService.open({EntityName}FormComponent, config);
    ref.onClose.pipe(map(result => result || false)).subscribe({
      next: result => {
        observer.next(result);
        observer.complete();
      },
      error: error => {
        observer.error(error);
      },
    });
  }
}
```

### 6. Route Configuration Template

```typescript
// File: angular/src/app/features/{module}/{entity-name}s/{entity-name}s.routes.ts
import { Routes } from '@angular/router';

export const {ENTITY_NAME}S_ROUTES: Routes = [
  {
    path: '',
    loadComponent: () => 
      import('./{entity-name}-list/{entity-name}-list.component').then(c => c.{EntityName}ListComponent),
    data: {
      breadcrumb: 'Danh sách {Entity Display Name}'
    }
  }
];
```

### 7. Integration Test Template

```typescript
// File: angular/src/app/features/{module}/{entity-name}s/{entity-name}.integration.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { of } from 'rxjs';
import { {EntityName}ListComponent } from './{entity-name}-list/{entity-name}-list.component';
import { {EntityName}Service } from '../../../proxy/{module}/{entity-name}s/{entity-name}.service';
import { {EntityName}Dto } from '../../../proxy/{module}/{entity-name}s/dto/models';

describe('{EntityName}ListComponent Integration', () => {
  let component: {EntityName}ListComponent;
  let fixture: ComponentFixture<{EntityName}ListComponent>;
  let {entityName}Service: jasmine.SpyObj<{EntityName}Service>;

  const mock{EntityName}s: {EntityName}Dto[] = [
    {
      id: '1',
      {propertyName}: 'Test {Entity Name} 1',
      description: 'Test description 1',
      displayOrder: 1,
      isActive: true,
      creationTime: new Date('2024-01-01'),
      lastModificationTime: null
    },
    {
      id: '2',
      {propertyName}: 'Test {Entity Name} 2', 
      description: 'Test description 2',
      displayOrder: 2,
      isActive: false,
      creationTime: new Date('2024-01-02'),
      lastModificationTime: new Date('2024-01-03')
    }
  ];

  beforeEach(async () => {
    const {entityName}ServiceSpy = jasmine.createSpyObj('{EntityName}Service', [
      'getList',
      'delete'
    ]);

    await TestBed.configureTestingModule({
      imports: [
        {EntityName}ListComponent,
        HttpClientTestingModule,
        BrowserAnimationsModule
      ],
      providers: [
        { provide: {EntityName}Service, useValue: {entityName}ServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent({EntityName}ListComponent);
    component = fixture.componentInstance;
    {entityName}Service = TestBed.inject({EntityName}Service) as jasmine.SpyObj<{EntityName}Service>;
    
    {entityName}Service.getList.and.returnValue(of(mock{EntityName}s));
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should load {entity-name}s on init', () => {
    fixture.detectChanges();
    
    expect({entityName}Service.getList).toHaveBeenCalled();
    expect(component.{entityName}s).toEqual(mock{EntityName}s);
  });

  it('should filter {entity-name}s by search term', () => {
    fixture.detectChanges();
    
    const searchInput = fixture.nativeElement.querySelector('input[type="text"]');
    searchInput.value = 'Test {Entity Name} 1';
    searchInput.dispatchEvent(new Event('input'));
    
    fixture.detectChanges();
    
    expect(component.globalFilterValue).toBe('Test {Entity Name} 1');
  });
});
```

## Tailwind CSS Guidelines

### Layout Classes
- **Container**: `max-w-7xl mx-auto p-6`
- **Cards**: `bg-white rounded-lg shadow-sm border`
- **Grid**: `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6`
- **Flex**: `flex items-center justify-between`

### Typography Classes
- **Headings**: `text-xl font-semibold text-gray-900` (H3), `text-2xl font-bold text-gray-900` (H2)
- **Body Text**: `text-sm text-gray-600`, `text-base text-gray-800`
- **Labels**: `block text-sm font-medium text-gray-700`

### Color System
- **Primary**: `bg-blue-500 text-white` (buttons), `border-blue-500 bg-blue-50` (selected)
- **Success**: `bg-green-100 text-green-800` (badges), `bg-green-600` (success buttons)
- **Warning**: `bg-yellow-100 text-yellow-800` (badges), `bg-yellow-500` (warning buttons)
- **Danger**: `bg-red-100 text-red-800` (badges), `bg-red-600` (danger buttons)
- **Gray Tones**: `bg-gray-50` (backgrounds), `text-gray-500` (muted), `border-gray-200`

### Spacing System
- **Padding**: `p-4`, `p-6`, `px-4 py-2`
- **Margin**: `mb-4`, `mt-6`, `mx-auto`
- **Gap**: `gap-4`, `gap-6`, `space-y-4`, `space-x-2`

### Form Classes
- **Input Groups**: `space-y-2` (label + input wrapper)
- **Grid Forms**: `grid grid-cols-1 md:grid-cols-2 gap-6`
- **Required Labels**: `required` class + `text-red-500` for asterisk
- **Validation**: Sử dụng PrimeNG `p-invalid` class

### Interactive States
- **Hover**: `hover:bg-gray-100`, `hover:shadow-md`
- **Focus**: `focus:ring-2 focus:ring-blue-500`
- **Active/Selected**: `bg-blue-50 border-blue-500`
- **Disabled**: `opacity-50 cursor-not-allowed`

## Quy tắc đặt tên

### Frontend (Angular/TypeScript)
- **Components**: `PascalCase` (VD: `LayoutSectionListComponent`)
- **Files**: `kebab-case` (VD: `layout-section-list.component.ts`)
- **Properties/Methods**: `camelCase` (VD: `sectionName`, `loadSections`)
- **Constants**: `UPPER_SNAKE_CASE` (VD: `LAYOUT_SECTIONS_ROUTES`)
- **Interfaces**: `PascalCase` với prefix `I` (VD: `ILayoutSectionFormData`)

### HTML Templates
- **Attributes**: `kebab-case` (VD: `[form-group]="sectionForm"`)
- **Tailwind Classes**: Sử dụng utility classes (VD: `flex items-center justify-between`)
- **Custom CSS Classes**: Chỉ khi cần thiết, ưu tiên Tailwind utilities

## Notes quan trọng

1. **Vietnamese Labels**: Tất cả labels và messages phải bằng tiếng Việt
2. **Tailwind CSS**: Ưu tiên sử dụng Tailwind utility classes thay vì custom CSS
3. **Responsive Design**: Sử dụng Tailwind responsive prefixes (sm:, md:, lg:, xl:)
4. **Color System**: Sử dụng Tailwind color palette (gray-50, blue-500, green-600, etc.)
5. **Spacing**: Sử dụng Tailwind spacing system (p-4, m-6, space-y-4, gap-6, etc.)
6. **Typography**: Sử dụng Tailwind typography classes (text-sm, font-medium, leading-6, etc.)
7. **Validation**: Client-side validation với PrimeNG p-invalid class
8. **Loading States**: Hiển thị loading indicators
9. **Error Handling**: Sử dụng centralized error handling từ `ComponentBase`
10. **Memory Management**: Sử dụng `takeUntil(destroyed$)` để avoid memory leaks
11. **Accessibility**: Đảm bảo proper ARIA labels và keyboard navigation