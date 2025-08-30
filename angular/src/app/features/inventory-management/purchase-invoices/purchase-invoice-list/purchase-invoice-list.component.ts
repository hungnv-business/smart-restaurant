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
  // Quyền truy cập
  readonly permissions = {
    create: PERMISSIONS.RESTAURANT.INVENTORY.PURCHASE_INVOICES.CREATE,
    edit: PERMISSIONS.RESTAURANT.INVENTORY.PURCHASE_INVOICES.EDIT,
    delete: PERMISSIONS.RESTAURANT.INVENTORY.PURCHASE_INVOICES.DELETE,
  };

  // Cấu hình bảng
  filterFields: string[] = ['invoiceNumber', 'totalAmount'];

  // Dữ liệu hiển thị
  purchaseInvoices = signal<PurchaseInvoiceDto[]>([]);
  dateRange: Date[] | null = null;
  searchText = '';
  totalRecords = 0;
  loading = false;

  // Debounce search
  private searchSubject = new Subject<string>();

  // Hằng số
  readonly ENTITY_NAME = 'hóa đơn mua';

  private purchaseInvoiceFormDialogService = inject(PurchaseInvoiceFormDialogService);
  private purchaseInvoiceService = inject(PurchaseInvoiceService);

  @ViewChild('dt') dt!: Table;

  constructor() {
    super();
  }

  ngOnInit() {
    // Setup debounced search
    this.searchSubject
      .pipe(
        debounceTime(1000),
        distinctUntilChanged()
      )
      .subscribe(() => {
        this.resetPagination(this.dt);
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
