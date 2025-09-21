import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { MessageService, ConfirmationService } from 'primeng/api';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { PermissionService } from '@abp/ng.core';
import { CORE_OPTIONS } from '@abp/ng.core';

import { TableLayoutKanbanComponent } from './table-layout-kanban/table-layout-kanban.component';
import { TableFormDialogComponent } from './table-form-dialog/table-form-dialog.component';

describe('TablePositioning Integration Tests', () => {
  it('should create kanban component', async () => {
    await TestBed.configureTestingModule({
      imports: [TableLayoutKanbanComponent, NoopAnimationsModule],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        MessageService,
        ConfirmationService,
        DialogService,
        { provide: DynamicDialogRef, useValue: {} },
        { provide: DynamicDialogConfig, useValue: {} },
        { provide: PermissionService, useValue: { getGrantedPolicy: () => true } },
        {
          provide: CORE_OPTIONS,
          useValue: { environment: { production: false }, skipGetAppConfiguration: true },
        },
      ],
    }).compileComponents();

    const fixture = TestBed.createComponent(TableLayoutKanbanComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('should create form dialog component', async () => {
    await TestBed.configureTestingModule({
      imports: [TableFormDialogComponent, NoopAnimationsModule],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        MessageService,
        ConfirmationService,
        DialogService,
        { provide: DynamicDialogRef, useValue: {} },
        { provide: DynamicDialogConfig, useValue: {} },
        { provide: PermissionService, useValue: { getGrantedPolicy: () => true } },
        {
          provide: CORE_OPTIONS,
          useValue: { environment: { production: false }, skipGetAppConfiguration: true },
        },
      ],
    }).compileComponents();

    const fixture = TestBed.createComponent(TableFormDialogComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });
});
