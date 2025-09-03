import { Component, OnInit, signal, inject, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { TableModule, Table, TableLazyLoadEvent } from 'primeng/table';
import { InputTextModule } from 'primeng/inputtext';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { TagModule } from 'primeng/tag';
import { InputIconModule } from 'primeng/inputicon';
import { IconFieldModule } from 'primeng/iconfield';
import { ToolbarModule } from 'primeng/toolbar';
import { RippleModule } from 'primeng/ripple';
import { TooltipModule } from 'primeng/tooltip';
import { DatePickerModule } from 'primeng/datepicker';
import { VndCurrencyPipe } from '../../../../shared/pipes';
import { GetPurchaseInvoiceListDto } from '../../../../proxy/inventory-management/purchase-invoices/dto';
import { ComponentBase } from '../../../../shared/base/component-base';
import { PERMISSIONS } from '../../../../shared/constants/permissions';
import { PurchaseInvoiceFormDialogService } from '../services/purchase-invoice-form-dialog.service';
import { finalize, debounceTime, distinctUntilChanged } from 'rxjs/operators';
import { Subject } from 'rxjs';
import { DateTimeHelper } from '../../../../shared/helpers';

// Import proxy DTOs and services
import { PurchaseInvoiceDto } from '../../../../proxy/inventory-management/purchase-invoices/dto';
import { PurchaseInvoiceService } from '../../../../proxy/inventory-management/purchase-invoices/purchase-invoice.service';

/**
 * Component quản lý danh sách hóa đơn mua hàng trong hệ thống nhà hàng
 * Chức năng chính:
 * - Hiển thị danh sách hóa đơn mua nguyên liệu với phân trang server-side
 * - Tìm kiếm theo số hóa đơn và lọc theo khoảng thời gian
 * - Tạo mới, chỉnh sửa, xem chi tiết và xóa hóa đơn mua
 * - Hiển thị tổng tiền theo định dạng tiền Việt (VND)
 * - Kiểm soát quyền truy cập theo role (chỉ nhân viên kho)
 */
@Component({
  selector: 'app-purchase-invoice-list',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    TableModule,
    ButtonModule,
    RippleModule,
    ToolbarModule,
    InputTextModule,
    TagModule,
    InputIconModule,
    IconFieldModule,
    ConfirmDialogModule,
    TooltipModule,
    DatePickerModule,
    VndCurrencyPipe,
  ],
  providers: [],
  templateUrl: './purchase-invoice-list.component.html',
  styleUrls: ['./purchase-invoice-list.component.scss'],
})
export class PurchaseInvoiceListComponent extends ComponentBase implements OnInit {
  /** Quyền truy cập - Kiểm soát hiển thị các nút theo quyền user */
  readonly permissions = {
    create: PERMISSIONS.RESTAURANT.INVENTORY.PURCHASE_INVOICES.CREATE, // Quyền tạo hóa đơn
    edit: PERMISSIONS.RESTAURANT.INVENTORY.PURCHASE_INVOICES.EDIT, // Quyền sửa hóa đơn
    delete: PERMISSIONS.RESTAURANT.INVENTORY.PURCHASE_INVOICES.DELETE, // Quyền xóa hóa đơn
  };

  /** Các field được search khi user nhập tìm kiếm */
  filterFields: string[] = ['invoiceNumber', 'totalAmount'];

  /** Dữ liệu hiển thị trên bảng */
  purchaseInvoices = signal<PurchaseInvoiceDto[]>([]); // Danh sách hóa đơn mua (server-side paging)
  dateRange: Date[] | null = null; // Khoảng thời gian lọc (từ ngày - đến ngày)
  searchText = ''; // Văn bản tìm kiếm theo số hóa đơn
  totalRecords = 0; // Tổng số record cho phân trang
  loading = false; // Trạng thái loading khi gọi API

  /** Xử lý debounce cho tìm kiếm */
  private searchSubject = new Subject<string>();

  /** Tên entity dùng trong thông báo */
  readonly ENTITY_NAME = 'hóa đơn mua';

  /** Các service được inject */
  private purchaseInvoiceFormDialogService = inject(PurchaseInvoiceFormDialogService);
  private purchaseInvoiceService = inject(PurchaseInvoiceService);

  /** Tham chiếu đến PrimeNG Table */
  @ViewChild('dt') dt!: Table;

  /**
   * Constructor - khởi tạo component
   */
  constructor() {
    super();
  }

  /**
   * Khởi tạo component - thiết lập debounce search
   */
  ngOnInit() {
    // Thiết lập tìm kiếm debounce để giảm tải API calls
    this.searchSubject.pipe(
      debounceTime(1000), // Chờ 1s sau ký tự cuối (lâu hơn vì search hóa đơn)
      distinctUntilChanged() // Chỉ gọi nếu giá trị thay đổi
    ).subscribe(() => {
      this.resetPagination(this.dt); // Reset về trang đầu và tải lại
    });
  }

  // Xử lý tìm kiếm với debounce
  onFilterChange(): void {
    this.searchSubject.next(this.searchText);
  }

  // Xử lý lọc theo khoảng ngày
  onDateRangeFilter(): void {
    this.resetPagination(this.dt);
  }

  // Mở dialog form
  openFormDialog(purchaseInvoiceId?: string) {
    const dialog$ = purchaseInvoiceId
      ? this.purchaseInvoiceFormDialogService.openEditDialog(purchaseInvoiceId)
      : this.purchaseInvoiceFormDialogService.openCreateDialog();

    dialog$.subscribe(success => {
      if (success) {
        this.loadPurchaseInvoices();

        if (purchaseInvoiceId) {
          this.showUpdateSuccess(this.ENTITY_NAME);
        } else {
          this.showCreateSuccess(this.ENTITY_NAME);
        }
      }
    });
  }

  // Mở dialog xem chi tiết
  openViewDialog(purchaseInvoiceId: string) {
    this.purchaseInvoiceFormDialogService.openViewDialog(purchaseInvoiceId).subscribe();
  }

  // Xóa một hóa đơn
  deletePurchaseInvoice(invoice: PurchaseInvoiceDto) {
    this.confirmDelete(invoice.invoiceNumber!, () => {
      this.performDeletePurchaseInvoice(invoice);
    });
  }

  // Load danh sách hóa đơn mua
  loadPurchaseInvoices(event?: TableLazyLoadEvent) {
    this.loading = true;

    const { fromDateId, toDateId } = DateTimeHelper.getDateIdsFromRange(this.dateRange);

    const request: GetPurchaseInvoiceListDto = {
      maxResultCount: this.getMaxResultCount(event),
      skipCount: this.getSkipCount(event),
      sorting: this.getSorting(event, 'invoiceDate desc'),
      filter: this.searchText?.trim() || undefined,
      fromDateId,
      toDateId,
    };

    this.purchaseInvoiceService
      .getList(request)
      .pipe(finalize(() => (this.loading = false)))
      .subscribe({
        next: result => {
          const invoices = result.items || [];
          this.purchaseInvoices.set(invoices);
          this.totalRecords = result.totalCount || 0;
        },
        error: error => {
          console.error('Error loading purchase invoices:', error);
          this.purchaseInvoices.set([]);
          this.totalRecords = 0;
          this.handleApiError(error, 'Không thể tải danh sách hóa đơn mua');
        },
      });
  }

  // Thực hiện xóa một hóa đơn
  private performDeletePurchaseInvoice(invoice: PurchaseInvoiceDto) {
    this.purchaseInvoiceService.delete(invoice.id!).subscribe({
      next: () => {
        this.loadPurchaseInvoices();
        this.showDeleteSuccess(this.ENTITY_NAME);
      },
      error: error => {
        this.handleApiError(error, 'Không thể xóa hóa đơn mua');
      },
    });
  }
}
