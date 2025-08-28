import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { MenuItemFormComponent } from '../menu-item-form/menu-item-form.component';
import { MenuItemService } from '../../../../proxy/menu-management/menu-items';
import { MenuItemDto } from '../../../../proxy/menu-management/menu-items/dto';

export interface MenuItemFormData {
  menuItemId?: string;
  menuItem?: MenuItemDto;
  title?: string;
}

@Injectable({
  providedIn: 'root',
})
export class MenuItemFormDialogService {
  private dialogService = inject(DialogService);
  private menuItemService = inject(MenuItemService);

  openCreateDialog(): Observable<boolean> {
    const dialogData: MenuItemFormData = {
      title: 'Thêm món ăn',
    };

    return this.openDialog(dialogData);
  }

  openEditDialog(menuItemId: string): Observable<boolean> {
    const dialogData: MenuItemFormData = {
      menuItemId,
      title: 'Cập nhật món ăn',
    };

    return this.openDialog(dialogData);
  }

  private openDialog(data: MenuItemFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.menuItemId) {
        // Edit mode: load entity data
        this.menuItemService.get(data.menuItemId).subscribe({
          next: (menuItem: MenuItemDto) => {
            data.menuItem = menuItem;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error loading menu item:', error);
            observer.error(error);
          },
        });
      } else {
        // Create mode: no additional data needed
        this.createDialog(data, observer);
      }
    });
  }

  private createDialog(
    data: MenuItemFormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    const config: DynamicDialogConfig<MenuItemFormData> = {
      header: data.title,
      width: '700px',
      modal: true,
      closable: true,
      draggable: false,
      resizable: false,
      data: data,
      maximizable: false,
      dismissableMask: false,
      closeOnEscape: true,
      breakpoints: {
        '960px': '80vw',
        '640px': '95vw',
      },
    };

    const ref: DynamicDialogRef = this.dialogService.open(MenuItemFormComponent, config);
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
