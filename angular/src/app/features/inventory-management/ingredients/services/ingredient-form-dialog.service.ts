import { Injectable, inject } from '@angular/core';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { IngredientFormComponent } from '../ingredient-form/ingredient-form.component';
import { IngredientService } from '../../../../proxy/inventory-management/ingredients';
import { IngredientDto } from '../../../../proxy/inventory-management/ingredients/dto';

export interface IngredientFormData {
  ingredientId?: string;
  ingredient?: IngredientDto;
  title?: string;
}

@Injectable({
  providedIn: 'root',
})
export class IngredientFormDialogService {
  private dialogService = inject(DialogService);
  private ingredientService = inject(IngredientService);

  openCreateDialog(): Observable<boolean> {
    const dialogData: IngredientFormData = {
      title: 'Thêm nguyên liệu',
    };

    return this.openDialog(dialogData);
  }

  openEditDialog(ingredientId: string): Observable<boolean> {
    const dialogData: IngredientFormData = {
      ingredientId,
      title: 'Cập nhật nguyên liệu',
    };

    return this.openDialog(dialogData);
  }

  private openDialog(data: IngredientFormData): Observable<boolean> {
    return new Observable<boolean>(observer => {
      if (data.ingredientId) {
        // Edit mode: load entity data
        this.ingredientService.get(data.ingredientId).subscribe({
          next: (ingredient: IngredientDto) => {
            data.ingredient = ingredient;
            this.createDialog(data, observer);
          },
          error: error => {
            console.error('Error loading ingredient:', error);
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
    data: IngredientFormData,
    observer: {
      next: (value: boolean) => void;
      complete: () => void;
      error: (error: unknown) => void;
    },
  ): void {
    const config: DynamicDialogConfig<IngredientFormData> = {
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

    const ref: DynamicDialogRef = this.dialogService.open(IngredientFormComponent, config);
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