import { Component, OnInit, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ButtonModule } from 'primeng/button';
import { TableModule } from 'primeng/table';
import { InputSwitchModule } from 'primeng/inputswitch';
import { ToolbarModule } from 'primeng/toolbar';
import { DynamicDialogModule } from 'primeng/dynamicdialog';
import { ConfirmDialogModule } from 'primeng/confirmdialog';
import { ToastModule } from 'primeng/toast';
import { ConfirmationService } from 'primeng/api';
import { DragDropModule } from '@angular/cdk/drag-drop';
import { CdkDragDrop, moveItemInArray } from '@angular/cdk/drag-drop';
import { ComponentBase } from '../../../../shared/base/component-base';
import { LayoutSectionFormDialogService } from '../layout-section-form/layout-section-form-dialog.service';
import { LayoutSectionService } from '../../../../proxy/table-management/layout-sections/layout-section.service';
import { LayoutSectionDto, UpdateLayoutSectionDto } from '../../../../proxy/table-management/layout-sections/dto/models';
import { takeUntil } from 'rxjs/operators';
import { forkJoin } from 'rxjs';

@Component({
  selector: 'app-layout-section-list',
  standalone: true,
  imports: [
    CommonModule,
    FormsModule,
    TableModule,
    ButtonModule,
    InputSwitchModule,
    ToolbarModule,
    DynamicDialogModule,
    ConfirmDialogModule,
    ToastModule,
    DragDropModule
  ],
  providers: [ConfirmationService],
  templateUrl: './layout-section-list.component.html',
  styleUrls: ['./layout-section-list.component.scss']
})
export class LayoutSectionListComponent extends ComponentBase implements OnInit {
  layoutSections: LayoutSectionDto[] = [];
  loading = false;

  private confirmationService = inject(ConfirmationService);
  private layoutSectionService = inject(LayoutSectionService);
  private layoutSectionFormDialogService = inject(LayoutSectionFormDialogService);

  constructor() {
    super();
  }

  ngOnInit(): void {
    this.loadLayoutSections();
  }

  loadLayoutSections(): void {
    this.loading = true;
    
    this.layoutSectionService.getList()
    .pipe(takeUntil(this.destroyed$))
    .subscribe({
      next: (sections) => {
        this.layoutSections = sections || [];
        this.loading = false;
      },
      error: (error) => {
        this.loading = false;
        this.handleApiError(error, 'Không thể tải danh sách khu vực bố cục');
      }
    });
  }

  openNew(): void {
    this.layoutSectionFormDialogService.openCreateSectionDialog().subscribe((success) => {
      if (success) {
        this.loadLayoutSections();
      }
    });
  }

  editSection(section: LayoutSectionDto): void {
    this.layoutSectionFormDialogService.openEditSectionDialog(section.id!).subscribe((success) => {
      if (success) {
        this.loadLayoutSections();
      }
    });
  }

  deleteSection(section: LayoutSectionDto): void {
    this.confirmationService.confirm({
      message: `Bạn có chắc chắn muốn xóa khu vực "${section.sectionName}"?\n\nLưu ý: Việc xóa khu vực có thể ảnh hưởng đến các bàn ăn đã được gán vào khu vực này.`,
      header: 'Xác nhận Xóa Khu vực',
      icon: 'pi pi-exclamation-triangle',
      acceptIcon: 'pi pi-trash',
      rejectIcon: 'pi pi-times',
      acceptLabel: 'Xác nhận xóa',
      rejectLabel: 'Hủy bỏ',
      acceptButtonStyleClass: 'p-button-danger p-button-sm',
      rejectButtonStyleClass: 'p-button-text p-button-sm',
      accept: () => {
        this.layoutSectionService.delete(section.id!)
          .pipe(takeUntil(this.destroyed$))
          .subscribe({
            next: () => {
              this.layoutSections = this.layoutSections.filter(s => s.id !== section.id);
              this.showSuccess(
                'Đã xóa thành công',
                `Khu vực "${section.sectionName}" đã được xóa khỏi hệ thống`
              );
            },
            error: (error) => {
              this.handleApiError(error, 'Không thể xóa khu vực này');
            }
          });
      },
      reject: () => {
        // Optional: Show cancel message
        this.showInfo(
          'Đã hủy',
          'Không có thay đổi nào được thực hiện'
        );
      }
    });
  }

  toggleActive(section: LayoutSectionDto): void {
    const previousState = section.isActive;
    const updateDto: UpdateLayoutSectionDto = {
      sectionName: section.sectionName!,
      description: section.description,
      displayOrder: section.displayOrder,
      isActive: !section.isActive
    };

    this.layoutSectionService.update(section.id!, updateDto)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: (updatedSection) => {
          section.isActive = updatedSection.isActive;
          
          if (section.isActive) {
            this.showSuccess(
              'Đã kích hoạt',
              `Khu vực "${section.sectionName}" hiện có thể được sử dụng để bố trí bàn ăn`
            );
          } else {
            this.showWarning(
              'Đã vô hiệu hóa',
              `Khu vực "${section.sectionName}" tạm thời không khả dụng cho việc bố trí bàn ăn`
            );
          }
        },
        error: (error) => {
          // Revert on error
          section.isActive = previousState;
          this.handleApiError(error, 'Không thể thay đổi trạng thái khu vực');
        }
      });
  }


  moveUp(section: LayoutSectionDto): void {
    const currentIndex = this.layoutSections.findIndex(s => s.id === section.id);
    if (currentIndex > 0) {
      // Swap items in array
      const temp = this.layoutSections[currentIndex];
      this.layoutSections[currentIndex] = this.layoutSections[currentIndex - 1];
      this.layoutSections[currentIndex - 1] = temp;
      
      // Update display order and save to backend
      this.updateDisplayOrderAfterMove();
    }
  }

  moveDown(section: LayoutSectionDto): void {
    const currentIndex = this.layoutSections.findIndex(s => s.id === section.id);
    if (currentIndex < this.layoutSections.length - 1) {
      // Swap items in array
      const temp = this.layoutSections[currentIndex];
      this.layoutSections[currentIndex] = this.layoutSections[currentIndex + 1];
      this.layoutSections[currentIndex + 1] = temp;
      
      // Update display order and save to backend
      this.updateDisplayOrderAfterMove();
    }
  }

  // Drag and drop functionality
  onSectionDrop(event: CdkDragDrop<LayoutSectionDto[]>): void {
    if (event.previousIndex !== event.currentIndex) {
      moveItemInArray(this.layoutSections, event.previousIndex, event.currentIndex);
      
      // Update display order for all affected items and save to backend
      this.updateDisplayOrderAfterDrop();
    }
  }

  private updateDisplayOrderAfterDrop(): void {
    this.layoutSections.forEach((section, index) => {
      section.displayOrder = index + 1;
    });
    this.saveSectionOrder();
  }

  private updateDisplayOrderAfterMove(): void {
    this.layoutSections.forEach((section, index) => {
      section.displayOrder = index + 1;
    });
    this.saveSectionOrder();
  }

  private saveSectionOrder(): void {
    // Update all sections with new display order
    const updateObservables = this.layoutSections.map((section, index) => {
      const updateDto: UpdateLayoutSectionDto = {
        sectionName: section.sectionName!,
        description: section.description,
        displayOrder: index + 1,
        isActive: section.isActive
      };
      return this.layoutSectionService.update(section.id!, updateDto);
    });

    forkJoin(updateObservables)
      .pipe(takeUntil(this.destroyed$))
      .subscribe({
        next: () => {
          this.showSuccess(
            'Đã thay đổi thứ tự',
            'Thứ tự các khu vực đã được cập nhật thành công'
          );
        },
        error: (error) => {
          this.handleApiError(error, 'Không thể cập nhật thứ tự khu vực');
          // Reload to get correct order from server
          this.loadLayoutSections();
        }
      });
  }
}