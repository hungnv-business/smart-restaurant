import { ComponentFixture, TestBed } from '@angular/core/testing';
import { Component } from '@angular/core';
import { ComponentBase } from './component-base';
import { MessageService, ConfirmationService } from 'primeng/api';
import { PermissionService } from '@abp/ng.core';

@Component({
  template: '',
  standalone: true
})
class TestComponentBase extends ComponentBase {
  loading = false;
}

describe('ComponentBase', () => {
  let component: TestComponentBase;
  let fixture: ComponentFixture<TestComponentBase>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [TestComponentBase],
      providers: [
        MessageService,
        ConfirmationService,
        { provide: PermissionService, useValue: { getGrantedPolicy: () => true } }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent(TestComponentBase);
    component = fixture.componentInstance;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
