import { ComponentFixture, TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { NoopAnimationsModule } from '@angular/platform-browser/animations';
import { MessageService, ConfirmationService } from 'primeng/api';
import { DialogService, DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { PermissionService } from '@abp/ng.core';
import { CORE_OPTIONS } from '@abp/ng.core';
import { PermissionsService } from '@abp/ng.permission-management/proxy';
import { IdentityRoleService } from '@abp/ng.identity/proxy';
import { of } from 'rxjs';

import { RoleFormComponent } from './role-form.component';
import { PermissionTreeService } from '../../services/permission-tree.service';

describe('RoleFormComponent', () => {
  let component: RoleFormComponent;
  let fixture: ComponentFixture<RoleFormComponent>;

  // Mock services
  const mockPermissionsService = {
    get: jasmine.createSpy('get').and.returnValue(of({ groups: [] })),
    update: jasmine.createSpy('update').and.returnValue(of({}))
  };

  const mockIdentityRoleService = {
    get: jasmine.createSpy('get').and.returnValue(of({ name: 'TestRole', isPublic: false })),
    create: jasmine.createSpy('create').and.returnValue(of({})),
    update: jasmine.createSpy('update').and.returnValue(of({}))
  };

  const mockPermissionTreeService = {
    buildPermissionTree: jasmine.createSpy('buildPermissionTree').and.returnValue([]),
    getSelectedPermissions: jasmine.createSpy('getSelectedPermissions').and.returnValue([])
  };

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [RoleFormComponent, NoopAnimationsModule],
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        MessageService,
        ConfirmationService,
        DialogService,
        { provide: DynamicDialogRef, useValue: { close: jasmine.createSpy('close') } },
        { provide: DynamicDialogConfig, useValue: { data: null } },
        { provide: PermissionService, useValue: { getGrantedPolicy: () => true } },
        { provide: PermissionsService, useValue: mockPermissionsService },
        { provide: IdentityRoleService, useValue: mockIdentityRoleService },
        { provide: PermissionTreeService, useValue: mockPermissionTreeService },
        {
          provide: CORE_OPTIONS,
          useValue: { environment: { production: false }, skipGetAppConfiguration: true },
        },
      ],
    }).compileComponents();

    fixture = TestBed.createComponent(RoleFormComponent);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
