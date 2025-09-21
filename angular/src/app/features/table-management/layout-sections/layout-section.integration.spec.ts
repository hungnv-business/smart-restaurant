import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { MessageService, ConfirmationService } from 'primeng/api';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { PermissionService } from '@abp/ng.core';
import { CORE_OPTIONS } from '@abp/ng.core';

import { LayoutSectionListComponent } from './layout-section-list/layout-section-list.component';
import { LayoutSectionFormComponent } from './layout-section-form/layout-section-form.component';

describe('LayoutSection Integration Tests', () => {
  it('should create list component', async () => {
    await TestBed.configureTestingModule({
      imports: [LayoutSectionListComponent, NoopAnimationsModule],
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

    const fixture = TestBed.createComponent(LayoutSectionListComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });

  it('should create form component', async () => {
    await TestBed.configureTestingModule({
      imports: [LayoutSectionFormComponent, NoopAnimationsModule],
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

    const fixture = TestBed.createComponent(LayoutSectionFormComponent);
    expect(fixture.componentInstance).toBeTruthy();
  });
});
