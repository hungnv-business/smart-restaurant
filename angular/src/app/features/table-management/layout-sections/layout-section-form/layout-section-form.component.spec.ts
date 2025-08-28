import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { MessageService, ConfirmationService } from 'primeng/api';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { PermissionService } from '@abp/ng.core';
import { CORE_OPTIONS } from '@abp/ng.core';

import { LayoutSectionFormComponent } from './layout-section-form.component';

describe('LayoutSectionFormComponent', () => {
  let component: LayoutSectionFormComponent;
  let fixture: ComponentFixture<LayoutSectionFormComponent>;

  beforeEach(async () => {
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
        { provide: CORE_OPTIONS, useValue: { environment: { production: false }, skipGetAppConfiguration: true } }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(LayoutSectionFormComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  it('should have loading property', () => {
    expect(component.loading).toBeDefined();
  });
});
