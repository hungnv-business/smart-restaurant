import { TestBed } from '@angular/core/testing';
import { provideHttpClient } from '@angular/common/http';
import { provideHttpClientTesting } from '@angular/common/http/testing';
import { MenuItemFormDialogService } from './menu-item-form-dialog.service';
import { DialogService } from 'primeng/dynamicdialog';
import { CORE_OPTIONS } from '@abp/ng.core';

describe('MenuItemFormDialogService', () => {
  let service: MenuItemFormDialogService;

  beforeEach(() => {
    TestBed.configureTestingModule({
      providers: [
        provideHttpClient(),
        provideHttpClientTesting(),
        DialogService,
        {
          provide: CORE_OPTIONS,
          useValue: { environment: { production: false }, skipGetAppConfiguration: true },
        },
      ],
    });
    service = TestBed.inject(MenuItemFormDialogService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
