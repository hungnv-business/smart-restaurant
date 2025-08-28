import { TestBed } from '@angular/core/testing';
import { PermissionTreeService } from './permission-tree.service';

describe('PermissionTreeService', () => {
  let service: PermissionTreeService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(PermissionTreeService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
