# SmartRestaurant Testing Template

## Cấu trúc Testing cho từng layer

### 1. Backend Testing (.NET)

#### Unit Test Template cho Application Service

```csharp
// File: aspnet-core/test/SmartRestaurant.Application.Tests/{Module}/{EntityName}AppServiceTests.cs
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Extensions.DependencyInjection;
using NSubstitute;
using Shouldly;
using SmartRestaurant.Entities.{Module};
using SmartRestaurant.{Module}.{EntityName}s;
using SmartRestaurant.{Module}.{EntityName}s.Dto;
using SmartRestaurant.Repositories;
using Volo.Abp.Application.Dtos;
using Volo.Abp.Domain.Repositories;
using Volo.Abp.Validation;
using Xunit;

namespace SmartRestaurant.{Module}
{
    public class {EntityName}AppServiceTests : SmartRestaurantApplicationTestBase
    {
        private readonly I{EntityName}AppService _{entityName}AppService;
        private readonly I{EntityName}Repository _{entityName}Repository;

        public {EntityName}AppServiceTests()
        {
            _{entityName}AppService = GetRequiredService<I{EntityName}AppService>();
            _{entityName}Repository = GetRequiredService<I{EntityName}Repository>();
        }

        [Fact]
        public async Task GetListAsync_Should_Return_All_{EntityName}s_Ordered_By_DisplayOrder()
        {
            // Arrange
            var {entityName}1 = new {EntityName}(Guid.NewGuid(), "Test {EntityName} B", "Description B", 2, true);
            var {entityName}2 = new {EntityName}(Guid.NewGuid(), "Test {EntityName} A", "Description A", 1, true);
            
            await _{entityName}Repository.InsertAsync({entityName}1);
            await _{entityName}Repository.InsertAsync({entityName}2);

            // Act
            var result = await _{entityName}AppService.GetListAsync();

            // Assert
            result.ShouldNotBeNull();
            result.Count.ShouldBeGreaterThanOrEqualTo(2);
            
            var orderedResult = result.ToList();
            orderedResult[0].DisplayOrder.ShouldBeLessThanOrEqualTo(orderedResult[1].DisplayOrder);
        }

        [Fact]
        public async Task GetAsync_Should_Return_Correct_{EntityName}()
        {
            // Arrange
            var {entityName} = new {EntityName}(Guid.NewGuid(), "Test {EntityName}", "Test Description", 1, true);
            await _{entityName}Repository.InsertAsync({entityName});

            // Act
            var result = await _{entityName}AppService.GetAsync({entityName}.Id);

            // Assert
            result.ShouldNotBeNull();
            result.Id.ShouldBe({entityName}.Id);
            result.{PropertyName}.ShouldBe("Test {EntityName}");
            result.Description.ShouldBe("Test Description");
            result.DisplayOrder.ShouldBe(1);
            result.IsActive.ShouldBe(true);
        }

        [Fact]
        public async Task CreateAsync_Should_Create_New_{EntityName}()
        {
            // Arrange
            var createDto = new Create{EntityName}Dto
            {
                {PropertyName} = "New Test {EntityName}",
                Description = "New Test Description",
                DisplayOrder = 5,
                IsActive = true
            };

            // Act
            var result = await _{entityName}AppService.CreateAsync(createDto);

            // Assert
            result.ShouldNotBeNull();
            result.{PropertyName}.ShouldBe(createDto.{PropertyName});
            result.Description.ShouldBe(createDto.Description);
            result.DisplayOrder.ShouldBe(createDto.DisplayOrder);
            result.IsActive.ShouldBe(createDto.IsActive);

            // Verify in database
            var {entityName}InDb = await _{entityName}Repository.GetAsync(result.Id);
            {entityName}InDb.ShouldNotBeNull();
            {entityName}InDb.{PropertyName}.ShouldBe(createDto.{PropertyName});
        }

        [Fact]
        public async Task CreateAsync_Should_Throw_ValidationException_When_{PropertyName}_Is_Empty()
        {
            // Arrange
            var createDto = new Create{EntityName}Dto
            {
                {PropertyName} = "", // Empty name should fail validation
                Description = "Test Description",
                DisplayOrder = 1,
                IsActive = true
            };

            // Act & Assert
            await Should.ThrowAsync<AbpValidationException>(
                async () => await _{entityName}AppService.CreateAsync(createDto)
            );
        }

        [Fact]
        public async Task UpdateAsync_Should_Update_Existing_{EntityName}()
        {
            // Arrange
            var {entityName} = new {EntityName}(Guid.NewGuid(), "Original Name", "Original Description", 1, true);
            await _{entityName}Repository.InsertAsync({entityName});

            var updateDto = new Update{EntityName}Dto
            {
                {PropertyName} = "Updated Name",
                Description = "Updated Description",
                DisplayOrder = 2,
                IsActive = false
            };

            // Act
            var result = await _{entityName}AppService.UpdateAsync({entityName}.Id, updateDto);

            // Assert
            result.ShouldNotBeNull();
            result.{PropertyName}.ShouldBe(updateDto.{PropertyName});
            result.Description.ShouldBe(updateDto.Description);
            result.DisplayOrder.ShouldBe(updateDto.DisplayOrder);
            result.IsActive.ShouldBe(updateDto.IsActive);

            // Verify in database
            var {entityName}InDb = await _{entityName}Repository.GetAsync({entityName}.Id);
            {entityName}InDb.{PropertyName}.ShouldBe(updateDto.{PropertyName});
            {entityName}InDb.Description.ShouldBe(updateDto.Description);
        }

        [Fact]
        public async Task DeleteAsync_Should_Remove_{EntityName}()
        {
            // Arrange
            var {entityName} = new {EntityName}(Guid.NewGuid(), "Test {EntityName}", "Test Description", 1, true);
            await _{entityName}Repository.InsertAsync({entityName});

            // Act
            await _{entityName}AppService.DeleteAsync({entityName}.Id);

            // Assert
            var {entityName}InDb = await _{entityName}Repository.FindAsync({entityName}.Id);
            {entityName}InDb.ShouldBeNull();
        }

        [Fact]
        public async Task GetNextDisplayOrderAsync_Should_Return_Correct_Next_Order()
        {
            // Arrange
            var {entityName}1 = new {EntityName}(Guid.NewGuid(), "Test 1", "Description 1", 5, true);
            var {entityName}2 = new {EntityName}(Guid.NewGuid(), "Test 2", "Description 2", 10, true);
            
            await _{entityName}Repository.InsertAsync({entityName}1);
            await _{entityName}Repository.InsertAsync({entityName}2);

            // Act
            var result = await _{entityName}AppService.GetNextDisplayOrderAsync();

            // Assert
            result.ShouldBe(11); // Max display order (10) + 1
        }

        [Fact]
        public async Task GetActiveListAsync_Should_Return_Only_Active_{EntityName}s()
        {
            // Arrange
            var active{EntityName} = new {EntityName}(Guid.NewGuid(), "Active {EntityName}", "Active Description", 1, true);
            var inactive{EntityName} = new {EntityName}(Guid.NewGuid(), "Inactive {EntityName}", "Inactive Description", 2, false);
            
            await _{entityName}Repository.InsertAsync(active{EntityName});
            await _{entityName}Repository.InsertAsync(inactive{EntityName});

            // Act
            var result = await _{entityName}AppService.GetActiveListAsync();

            // Assert
            result.ShouldNotBeNull();
            result.All(x => x.IsActive).ShouldBe(true);
            result.Any(x => x.Id == active{EntityName}.Id).ShouldBe(true);
            result.Any(x => x.Id == inactive{EntityName}.Id).ShouldBe(false);
        }
    }
}
```

#### Integration Test Template cho Domain Entity

```csharp
// File: aspnet-core/test/SmartRestaurant.Domain.Tests/{Module}/{EntityName}Tests.cs
using System;
using Shouldly;
using SmartRestaurant.Entities.{Module};
using Xunit;

namespace SmartRestaurant.{Module}
{
    public class {EntityName}Tests : SmartRestaurantDomainTestBase
    {
        [Fact]
        public void Constructor_Should_Set_Properties_Correctly()
        {
            // Arrange
            var id = Guid.NewGuid();
            var {propertyName} = "Test {EntityName}";
            var description = "Test Description";
            var displayOrder = 5;
            var isActive = true;

            // Act
            var {entityName} = new {EntityName}(id, {propertyName}, description, displayOrder, isActive);

            // Assert
            {entityName}.Id.ShouldBe(id);
            {entityName}.{PropertyName}.ShouldBe({propertyName});
            {entityName}.Description.ShouldBe(description);
            {entityName}.DisplayOrder.ShouldBe(displayOrder);
            {entityName}.IsActive.ShouldBe(isActive);
        }

        [Theory]
        [InlineData(null)]
        [InlineData("")]
        [InlineData("   ")]
        public void Constructor_Should_Throw_Exception_When_{PropertyName}_Is_Invalid(string invalid{PropertyName})
        {
            // Arrange & Act & Assert
            Should.Throw<ArgumentException>(
                () => new {EntityName}(Guid.NewGuid(), invalid{PropertyName}, "Description", 1, true)
            );
        }

        [Fact]
        public void Constructor_Should_Allow_Null_Description()
        {
            // Arrange & Act
            var {entityName} = new {EntityName}(Guid.NewGuid(), "Test {EntityName}", null, 1, true);

            // Assert
            {entityName}.Description.ShouldBeNull();
        }

        [Fact]
        public void Constructor_Should_Initialize_{RelatedEntities}_Collection()
        {
            // Arrange & Act
            var {entityName} = new {EntityName}(Guid.NewGuid(), "Test {EntityName}", "Description", 1, true);

            // Assert
            {entityName}.{RelatedEntities}.ShouldNotBeNull();
            {entityName}.{RelatedEntities}.ShouldBeEmpty();
        }

        [Fact]
        public void Default_Constructor_Should_Initialize_{RelatedEntities}_Collection()
        {
            // Arrange & Act
            var {entityName} = new {EntityName}();

            // Assert
            {entityName}.{RelatedEntities}.ShouldNotBeNull();
            {entityName}.{RelatedEntities}.ShouldBeEmpty();
        }
    }
}
```

### 2. Frontend Testing (Angular)

#### Component Unit Test Template

```typescript
// File: angular/src/app/features/{module}/{entity-name}/{entity-name}-list/{entity-name}-list.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { HttpClientTestingModule } from '@angular/common/http/testing';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { ConfirmationService } from 'primeng/api';
import { DialogService } from 'primeng/dynamicdialog';
import { of, throwError } from 'rxjs';

import { {EntityName}ListComponent } from './{entity-name}-list.component';
import { {EntityName}Service } from '../../../../proxy/{module}/{entity-name}s/{entity-name}.service';
import { {EntityName}FormDialogService } from '../{entity-name}-form/{entity-name}-form-dialog.service';
import { {EntityName}Dto } from '../../../../proxy/{module}/{entity-name}s/dto/models';
import { ToastService } from '../../../../shared/services/toast.service';

describe('{EntityName}ListComponent', () => {
  let component: {EntityName}ListComponent;
  let fixture: ComponentFixture<{EntityName}ListComponent>;
  let {entityName}Service: jasmine.SpyObj<{EntityName}Service>;
  let {entityName}FormDialogService: jasmine.SpyObj<{EntityName}FormDialogService>;
  let confirmationService: jasmine.SpyObj<ConfirmationService>;
  let toastService: jasmine.SpyObj<ToastService>;

  const mock{EntityName}s: {EntityName}Dto[] = [
    {
      id: '1',
      {propertyName}: 'Test {Entity Name} 1',
      description: 'Test description 1',
      displayOrder: 1,
      isActive: true,
      creationTime: new Date('2024-01-01'),
      lastModificationTime: null
    },
    {
      id: '2',
      {propertyName}: 'Test {Entity Name} 2',
      description: 'Test description 2',
      displayOrder: 2,
      isActive: false,
      creationTime: new Date('2024-01-02'),
      lastModificationTime: new Date('2024-01-03')
    }
  ];

  beforeEach(async () => {
    const {entityName}ServiceSpy = jasmine.createSpyObj('{EntityName}Service', ['getList', 'delete']);
    const {entityName}FormDialogServiceSpy = jasmine.createSpyObj('{EntityName}FormDialogService', ['openCreateDialog', 'openEditDialog']);
    const confirmationServiceSpy = jasmine.createSpyObj('ConfirmationService', ['confirm']);
    const toastServiceSpy = jasmine.createSpyObj('ToastService', ['showSuccess', 'showError']);

    await TestBed.configureTestingModule({
      imports: [
        {EntityName}ListComponent,
        HttpClientTestingModule,
        BrowserAnimationsModule
      ],
      providers: [
        { provide: {EntityName}Service, useValue: {entityName}ServiceSpy },
        { provide: {EntityName}FormDialogService, useValue: {entityName}FormDialogServiceSpy },
        { provide: ConfirmationService, useValue: confirmationServiceSpy },
        { provide: ToastService, useValue: toastServiceSpy },
        DialogService
      ]
    }).compileComponents();

    fixture = TestBed.createComponent({EntityName}ListComponent);
    component = fixture.componentInstance;
    {entityName}Service = TestBed.inject({EntityName}Service) as jasmine.SpyObj<{EntityName}Service>;
    {entityName}FormDialogService = TestBed.inject({EntityName}FormDialogService) as jasmine.SpyObj<{EntityName}FormDialogService>;
    confirmationService = TestBed.inject(ConfirmationService) as jasmine.SpyObj<ConfirmationService>;
    toastService = TestBed.inject(ToastService) as jasmine.SpyObj<ToastService>;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('ngOnInit', () => {
    it('should load {entity-name}s on initialization', () => {
      // Arrange
      {entityName}Service.getList.and.returnValue(of(mock{EntityName}s));

      // Act
      fixture.detectChanges();

      // Assert
      expect({entityName}Service.getList).toHaveBeenCalled();
      expect(component.{entityName}s).toEqual(mock{EntityName}s);
      expect(component.loading).toBe(false);
    });

    it('should handle error when loading {entity-name}s fails', () => {
      // Arrange
      const error = new Error('API Error');
      {entityName}Service.getList.and.returnValue(throwError(() => error));
      spyOn(component, 'handleApiError');

      // Act
      fixture.detectChanges();

      // Assert
      expect(component.loading).toBe(false);
      expect(component.handleApiError).toHaveBeenCalledWith(error, 'Không thể tải danh sách {entity-display-name}');
    });
  });

  describe('onCreate', () => {
    it('should open create dialog and refresh list on success', () => {
      // Arrange
      {entityName}FormDialogService.openCreateDialog.and.returnValue(of(true));
      spyOn(component, 'load{EntityName}s');

      // Act
      component.onCreate();

      // Assert
      expect({entityName}FormDialogService.openCreateDialog).toHaveBeenCalled();
      expect(component.load{EntityName}s).toHaveBeenCalled();
    });

    it('should not refresh list when create dialog is cancelled', () => {
      // Arrange
      {entityName}FormDialogService.openCreateDialog.and.returnValue(of(false));
      spyOn(component, 'load{EntityName}s');

      // Act
      component.onCreate();

      // Assert
      expect({entityName}FormDialogService.openCreateDialog).toHaveBeenCalled();
      expect(component.load{EntityName}s).not.toHaveBeenCalled();
    });
  });

  describe('onEdit', () => {
    it('should open edit dialog with correct {entity-name} id and refresh list on success', () => {
      // Arrange
      const {entityName} = mock{EntityName}s[0];
      {entityName}FormDialogService.openEditDialog.and.returnValue(of(true));
      spyOn(component, 'load{EntityName}s');

      // Act
      component.onEdit({entityName});

      // Assert
      expect({entityName}FormDialogService.openEditDialog).toHaveBeenCalledWith({entityName}.id);
      expect(component.load{EntityName}s).toHaveBeenCalled();
    });
  });

  describe('onDelete', () => {
    it('should show confirmation dialog and delete {entity-name} on confirm', () => {
      // Arrange
      const {entityName} = mock{EntityName}s[0];
      {entityName}Service.delete.and.returnValue(of(void 0));
      confirmationService.confirm.and.callFake((config: any) => {
        config.accept();
      });
      spyOn(component, 'load{EntityName}s');

      // Act
      component.onDelete({entityName});

      // Assert
      expect(confirmationService.confirm).toHaveBeenCalled();
      expect({entityName}Service.delete).toHaveBeenCalledWith({entityName}.id);
      expect(component.load{EntityName}s).toHaveBeenCalled();
    });

    it('should not delete {entity-name} when confirmation is rejected', () => {
      // Arrange
      const {entityName} = mock{EntityName}s[0];
      confirmationService.confirm.and.callFake((config: any) => {
        config.reject();
      });

      // Act
      component.onDelete({entityName});

      // Assert
      expect(confirmationService.confirm).toHaveBeenCalled();
      expect({entityName}Service.delete).not.toHaveBeenCalled();
    });
  });

  describe('onGlobalFilter', () => {
    it('should update global filter value and filter table', () => {
      // Arrange
      component.table = { filterGlobal: jasmine.createSpy('filterGlobal') } as any;
      const event = { target: { value: 'test filter' } } as any;

      // Act
      component.onGlobalFilter(event);

      // Assert
      expect(component.globalFilterValue).toBe('test filter');
      expect(component.table.filterGlobal).toHaveBeenCalledWith('test filter', 'contains');
    });
  });

  describe('clearGlobalFilter', () => {
    it('should clear global filter value and table filter', () => {
      // Arrange
      component.globalFilterValue = 'test filter';
      component.table = { clear: jasmine.createSpy('clear') } as any;

      // Act
      component.clearGlobalFilter();

      // Assert
      expect(component.globalFilterValue).toBe('');
      expect(component.table.clear).toHaveBeenCalled();
    });
  });
});
```

#### Form Component Test Template

```typescript
// File: angular/src/app/features/{module}/{entity-name}/{entity-name}-form/{entity-name}-form.component.spec.ts
import { ComponentFixture, TestBed } from '@angular/core/testing';
import { ReactiveFormsModule } from '@angular/forms';
import { DynamicDialogRef, DynamicDialogConfig } from 'primeng/dynamicdialog';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { of, throwError } from 'rxjs';

import { {EntityName}FormComponent } from './{entity-name}-form.component';
import { {EntityName}Service } from '../../../../proxy/{module}/{entity-name}s/{entity-name}.service';
import { {EntityName}Dto } from '../../../../proxy/{module}/{entity-name}s/dto/models';
import { ToastService } from '../../../../shared/services/toast.service';

describe('{EntityName}FormComponent', () => {
  let component: {EntityName}FormComponent;
  let fixture: ComponentFixture<{EntityName}FormComponent>;
  let {entityName}Service: jasmine.SpyObj<{EntityName}Service>;
  let dialogRef: jasmine.SpyObj<DynamicDialogRef>;
  let toastService: jasmine.SpyObj<ToastService>;

  const mock{EntityName}: {EntityName}Dto = {
    id: '1',
    {propertyName}: 'Test {Entity Name}',
    description: 'Test description',
    displayOrder: 1,
    isActive: true,
    creationTime: new Date('2024-01-01'),
    lastModificationTime: null
  };

  beforeEach(async () => {
    const {entityName}ServiceSpy = jasmine.createSpyObj('{EntityName}Service', ['get', 'create', 'update', 'getNextDisplayOrder']);
    const dialogRefSpy = jasmine.createSpyObj('DynamicDialogRef', ['close']);
    const toastServiceSpy = jasmine.createSpyObj('ToastService', ['showSuccess', 'showError']);

    await TestBed.configureTestingModule({
      imports: [
        {EntityName}FormComponent,
        ReactiveFormsModule,
        BrowserAnimationsModule
      ],
      providers: [
        { provide: {EntityName}Service, useValue: {entityName}ServiceSpy },
        { provide: DynamicDialogRef, useValue: dialogRefSpy },
        { provide: DynamicDialogConfig, useValue: { data: {} } },
        { provide: ToastService, useValue: toastServiceSpy }
      ]
    }).compileComponents();

    fixture = TestBed.createComponent({EntityName}FormComponent);
    component = fixture.componentInstance;
    {entityName}Service = TestBed.inject({EntityName}Service) as jasmine.SpyObj<{EntityName}Service>;
    dialogRef = TestBed.inject(DynamicDialogRef) as jasmine.SpyObj<DynamicDialogRef>;
    toastService = TestBed.inject(ToastService) as jasmine.SpyObj<ToastService>;
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });

  describe('ngOnInit', () => {
    it('should build form and load next display order for new {entity-name}', () => {
      // Arrange
      {entityName}Service.getNextDisplayOrder.and.returnValue(of(5));

      // Act
      fixture.detectChanges();

      // Assert
      expect(component.{entityName}Form).toBeDefined();
      expect({entityName}Service.getNextDisplayOrder).toHaveBeenCalled();
      expect(component.{entityName}Form.get('displayOrder')?.value).toBe(5);
    });

    it('should load existing {entity-name} for edit mode', () => {
      // Arrange
      component.{entityName}Id = '1';
      {entityName}Service.get.and.returnValue(of(mock{EntityName}));

      // Act
      fixture.detectChanges();

      // Assert
      expect({entityName}Service.get).toHaveBeenCalledWith('1');
      expect(component.{entityName}).toEqual(mock{EntityName});
      expect(component.{entityName}Form.get('{propertyName}')?.value).toBe(mock{EntityName}.{propertyName});
    });
  });

  describe('onSubmit', () => {
    beforeEach(() => {
      fixture.detectChanges();
      component.{entityName}Form.patchValue({
        {propertyName}: 'Test {Entity Name}',
        description: 'Test description',
        displayOrder: 1,
        isActive: true
      });
    });

    it('should not submit when form is invalid', () => {
      // Arrange
      component.{entityName}Form.patchValue({ {propertyName}: '' }); // Invalid form

      // Act
      component.onSubmit();

      // Assert
      expect({entityName}Service.create).not.toHaveBeenCalled();
      expect({entityName}Service.update).not.toHaveBeenCalled();
    });

    it('should create new {entity-name} when no {entityName}Id', () => {
      // Arrange
      const createResponse = { ...mock{EntityName} };
      {entityName}Service.create.and.returnValue(of(createResponse));

      // Act
      component.onSubmit();

      // Assert
      expect({entityName}Service.create).toHaveBeenCalledWith(
        jasmine.objectContaining({
          {propertyName}: 'Test {Entity Name}',
          description: 'Test description',
          displayOrder: 1,
          isActive: true
        })
      );
      expect(dialogRef.close).toHaveBeenCalledWith(true);
    });

    it('should update existing {entity-name} when {entityName}Id exists', () => {
      // Arrange
      component.{entityName}Id = '1';
      const updateResponse = { ...mock{EntityName} };
      {entityName}Service.update.and.returnValue(of(updateResponse));

      // Act
      component.onSubmit();

      // Assert
      expect({entityName}Service.update).toHaveBeenCalledWith(
        '1',
        jasmine.objectContaining({
          {propertyName}: 'Test {Entity Name}',
          description: 'Test description',
          displayOrder: 1,
          isActive: true
        })
      );
      expect(dialogRef.close).toHaveBeenCalledWith(true);
    });

    it('should handle create error', () => {
      // Arrange
      const error = new Error('Create failed');
      {entityName}Service.create.and.returnValue(throwError(() => error));
      spyOn(component, 'handleApiError');

      // Act
      component.onSubmit();

      // Assert
      expect(component.loading).toBe(false);
      expect(component.handleApiError).toHaveBeenCalledWith(error, 'Không thể tạo {entity-display-name} mới');
    });
  });

  describe('onCancel', () => {
    it('should close dialog with false result', () => {
      // Act
      component.onCancel();

      // Assert
      expect(dialogRef.close).toHaveBeenCalledWith(false);
    });
  });

  describe('Form Validation', () => {
    beforeEach(() => {
      fixture.detectChanges();
    });

    it('should require {propertyName}', () => {
      // Arrange
      const {propertyName}Control = component.{entityName}Form.get('{propertyName}');

      // Act
      {propertyName}Control?.setValue('');
      {propertyName}Control?.markAsTouched();

      // Assert
      expect({propertyName}Control?.hasError('required')).toBe(true);
      expect({propertyName}Control?.valid).toBe(false);
    });

    it('should validate {propertyName} max length', () => {
      // Arrange
      const {propertyName}Control = component.{entityName}Form.get('{propertyName}');
      const longName = 'a'.repeat(129); // 129 characters

      // Act
      {propertyName}Control?.setValue(longName);
      {propertyName}Control?.markAsTouched();

      // Assert
      expect({propertyName}Control?.hasError('maxlength')).toBe(true);
      expect({propertyName}Control?.valid).toBe(false);
    });

    it('should validate description max length', () => {
      // Arrange
      const descriptionControl = component.{entityName}Form.get('description');
      const longDescription = 'a'.repeat(513); // 513 characters

      // Act
      descriptionControl?.setValue(longDescription);
      descriptionControl?.markAsTouched();

      // Assert
      expect(descriptionControl?.hasError('maxlength')).toBe(true);
      expect(descriptionControl?.valid).toBe(false);
    });

    it('should validate display order range', () => {
      // Arrange
      const displayOrderControl = component.{entityName}Form.get('displayOrder');

      // Act - Test minimum
      displayOrderControl?.setValue(0);
      displayOrderControl?.markAsTouched();

      // Assert
      expect(displayOrderControl?.hasError('min')).toBe(true);
      expect(displayOrderControl?.valid).toBe(false);

      // Act - Test maximum
      displayOrderControl?.setValue(1000);
      displayOrderControl?.markAsTouched();

      // Assert
      expect(displayOrderControl?.hasError('max')).toBe(true);
      expect(displayOrderControl?.valid).toBe(false);
    });
  });
});
```

### 3. Mobile Testing (Flutter)

#### Widget Test Template

```dart
// File: flutter_mobile/test/features/{module}/{entity_name}_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_restaurant_mobile/features/{module}/{entity_name}_screen.dart';
import 'package:smart_restaurant_mobile/shared/models/{entity_name}_model.dart';
import 'package:smart_restaurant_mobile/shared/constants/vietnamese_constants.dart';

void main() {
  late List<{EntityName}Model> mock{EntityName}s;

  setUpAll(() async {
    await ScreenUtil.ensureScreenSize();
  });

  setUp(() {
    mock{EntityName}s = [
      {EntityName}Model(
        id: '1',
        {propertyName}: 'Test {Entity Name} 1',
        description: 'Test description 1',
        displayOrder: 1,
        isActive: true,
        creationTime: DateTime.now().subtract(Duration(days: 7)),
        lastModificationTime: null,
      ),
      {EntityName}Model(
        id: '2',
        {propertyName}: 'Test {Entity Name} 2',
        description: 'Test description 2',
        displayOrder: 2,
        isActive: false,
        creationTime: DateTime.now().subtract(Duration(days: 5)),
        lastModificationTime: DateTime.now().subtract(Duration(days: 1)),
      ),
    ];
  });

  group('{EntityName}Screen Widget Tests', () => {
    testWidgets('should display correct title in list mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      expect(find.text(VietnameseConstants.{entityName}Title), findsOneWidget);
    });

    testWidgets('should display correct title in new mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'new'),
        ),
      );

      expect(find.text(VietnameseConstants.new{EntityName}), findsOneWidget);
    });

    testWidgets('should display correct title in edit mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'edit', {entityName}Id: '1'),
        ),
      );

      expect(find.text('Sửa {entity-display-name} #1'), findsOneWidget);
    });

    testWidgets('should display correct title in detail mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'detail', {entityName}Id: '1'),
        ),
      );

      expect(find.text('Chi tiết {entity-display-name} #1'), findsOneWidget);
    });

    testWidgets('should display add button only in list mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should not display add button in non-list modes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'new'),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsNothing);
    });

    testWidgets('should display search field in list mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.text(VietnameseConstants.search), findsOneWidget);
    });

    testWidgets('should display loading indicator when loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should filter search results correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find search field and enter text
      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Test {Entity Name} 1');
      await tester.pump();

      // Should filter results (implementation depends on actual filtering logic)
    });

    testWidgets('should display empty state when no data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty state message
      expect(find.text('Không tìm thấy dữ liệu'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });
  });

  group('{EntityName}Screen Navigation Tests', () => {
    testWidgets('should navigate to new form when add button pressed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(),
        ),
      );

      await tester.pumpAndSettle();

      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      // Should navigate to new form (implementation depends on navigation logic)
    });
  });

  group('{EntityName}Screen Form Tests', () => {
    testWidgets('should display form fields in new mode', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'new'),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tạo mới {Entity Display Name}'), findsOneWidget);
      expect(find.text(VietnameseConstants.create), findsOneWidget);
      expect(find.text(VietnameseConstants.cancel), findsOneWidget);
    });

    testWidgets('should validate form fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'new'),
        ),
      );

      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text(VietnameseConstants.create));
      await tester.pump();

      // Should show validation errors
      expect(find.text('{Property Display Name} không được để trống'), findsOneWidget);
    });

    testWidgets('should submit valid form', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'new'),
        ),
      );

      await tester.pumpAndSettle();

      // Fill form fields
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nhập {property-display-name}...'),
        'Test {Entity Name}',
      );

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nhập mô tả (tùy chọn)...'),
        'Test description',
      );

      // Submit form
      await tester.tap(find.text(VietnameseConstants.create));
      await tester.pump();

      // Should show loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('{EntityName}Screen Detail Tests', () => {
    testWidgets('should display {entity-name} details correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: {EntityName}Screen(mode: 'detail', {entityName}Id: '1'),
        ),
      );

      await tester.pumpAndSettle();

      // Should display detail fields (implementation depends on actual detail view)
      expect(find.text('{Property Display Name}'), findsOneWidget);
      expect(find.text('Mô tả'), findsOneWidget);
      expect(find.text('Thứ tự hiển thị'), findsOneWidget);
      expect(find.text('Trạng thái'), findsOneWidget);
      expect(find.text('Ngày tạo'), findsOneWidget);
    });
  });
});
```

#### Model Unit Test Template

```dart
// File: flutter_mobile/test/shared/models/{entity_name}_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_restaurant_mobile/shared/models/{entity_name}_model.dart';

void main() {
  late {EntityName}Model test{EntityName};
  late Map<String, dynamic> testJson;

  setUp(() {
    test{EntityName} = {EntityName}Model(
      id: '1',
      {propertyName}: 'Test {Entity Name}',
      description: 'Test description',
      displayOrder: 1,
      isActive: true,
      creationTime: DateTime(2024, 1, 1, 10, 0, 0),
      lastModificationTime: DateTime(2024, 1, 2, 10, 0, 0),
    );

    testJson = {
      'id': '1',
      '{propertyName}': 'Test {Entity Name}',
      'description': 'Test description',
      'displayOrder': 1,
      'isActive': true,
      'creationTime': '2024-01-01T10:00:00.000',
      'lastModificationTime': '2024-01-02T10:00:00.000',
    };
  });

  group('{EntityName}Model Tests', () => {
    test('should create {EntityName}Model with all properties', () {
      expect(test{EntityName}.id, '1');
      expect(test{EntityName}.{propertyName}, 'Test {Entity Name}');
      expect(test{EntityName}.description, 'Test description');
      expect(test{EntityName}.displayOrder, 1);
      expect(test{EntityName}.isActive, true);
      expect(test{EntityName}.creationTime, DateTime(2024, 1, 1, 10, 0, 0));
      expect(test{EntityName}.lastModificationTime, DateTime(2024, 1, 2, 10, 0, 0));
    });

    test('should create {EntityName}Model with null description', () {
      final {entityName} = {EntityName}Model(
        id: '1',
        {propertyName}: 'Test {Entity Name}',
        description: null,
        displayOrder: 1,
        isActive: true,
        creationTime: DateTime.now(),
        lastModificationTime: null,
      );

      expect({entityName}.description, isNull);
      expect({entityName}.lastModificationTime, isNull);
    });

    test('should create {EntityName}Model from JSON', () {
      final {entityName} = {EntityName}Model.fromJson(testJson);

      expect({entityName}.id, '1');
      expect({entityName}.{propertyName}, 'Test {Entity Name}');
      expect({entityName}.description, 'Test description');
      expect({entityName}.displayOrder, 1);
      expect({entityName}.isActive, true);
      expect({entityName}.creationTime, DateTime(2024, 1, 1, 10, 0, 0));
      expect({entityName}.lastModificationTime, DateTime(2024, 1, 2, 10, 0, 0));
    });

    test('should convert {EntityName}Model to JSON', () {
      final json = test{EntityName}.toJson();

      expect(json['id'], '1');
      expect(json['{propertyName}'], 'Test {Entity Name}');
      expect(json['description'], 'Test description');
      expect(json['displayOrder'], 1);
      expect(json['isActive'], true);
      expect(json['creationTime'], '2024-01-01T10:00:00.000');
      expect(json['lastModificationTime'], '2024-01-02T10:00:00.000');
    });

    test('should create copy with modified properties', () {
      final copied = test{EntityName}.copyWith(
        {propertyName}: 'Modified Name',
        isActive: false,
      );

      expect(copied.id, test{EntityName}.id);
      expect(copied.{propertyName}, 'Modified Name');
      expect(copied.description, test{EntityName}.description);
      expect(copied.displayOrder, test{EntityName}.displayOrder);
      expect(copied.isActive, false);
      expect(copied.creationTime, test{EntityName}.creationTime);
      expect(copied.lastModificationTime, test{EntityName}.lastModificationTime);
    });

    test('should maintain original properties when copying with null values', () {
      final copied = test{EntityName}.copyWith();

      expect(copied.id, test{EntityName}.id);
      expect(copied.{propertyName}, test{EntityName}.{propertyName});
      expect(copied.description, test{EntityName}.description);
      expect(copied.displayOrder, test{EntityName}.displayOrder);
      expect(copied.isActive, test{EntityName}.isActive);
      expect(copied.creationTime, test{EntityName}.creationTime);
      expect(copied.lastModificationTime, test{EntityName}.lastModificationTime);
    });

    test('should compare equality correctly', () {
      final another{EntityName} = {EntityName}Model(
        id: '1',
        {propertyName}: 'Test {Entity Name}',
        description: 'Test description',
        displayOrder: 1,
        isActive: true,
        creationTime: DateTime(2024, 1, 1, 10, 0, 0),
        lastModificationTime: DateTime(2024, 1, 2, 10, 0, 0),
      );

      expect(test{EntityName}, another{EntityName});
      expect(test{EntityName}.hashCode, another{EntityName}.hashCode);
    });

    test('should not be equal with different properties', () {
      final different{EntityName} = test{EntityName}.copyWith({propertyName}: 'Different Name');

      expect(test{EntityName}, isNot(different{EntityName}));
      expect(test{EntityName}.hashCode, isNot(different{EntityName}.hashCode));
    });

    test('should generate proper toString', () {
      final string = test{EntityName}.toString();

      expect(string, contains('{EntityName}Model'));
      expect(string, contains('id: 1'));
      expect(string, contains('{propertyName}: Test {Entity Name}'));
      expect(string, contains('description: Test description'));
      expect(string, contains('displayOrder: 1'));
      expect(string, contains('isActive: true'));
    });
  });

  group('Create{EntityName}Request Tests', () => {
    test('should create request with all properties', () {
      final request = Create{EntityName}Request(
        {propertyName}: 'New {Entity Name}',
        description: 'New description',
        displayOrder: 5,
        isActive: true,
      );

      expect(request.{propertyName}, 'New {Entity Name}');
      expect(request.description, 'New description');
      expect(request.displayOrder, 5);
      expect(request.isActive, true);
    });

    test('should create request with default isActive', () {
      final request = Create{EntityName}Request(
        {propertyName}: 'New {Entity Name}',
        displayOrder: 1,
      );

      expect(request.isActive, true);
      expect(request.description, isNull);
    });

    test('should serialize to JSON correctly', () {
      final request = Create{EntityName}Request(
        {propertyName}: 'New {Entity Name}',
        description: 'New description',
        displayOrder: 5,
        isActive: false,
      );

      final json = request.toJson();

      expect(json['{propertyName}'], 'New {Entity Name}');
      expect(json['description'], 'New description');
      expect(json['displayOrder'], 5);
      expect(json['isActive'], false);
    });
  });

  group('Update{EntityName}Request Tests', () => {
    test('should create update request with all properties', () {
      final request = Update{EntityName}Request(
        {propertyName}: 'Updated {Entity Name}',
        description: 'Updated description',
        displayOrder: 10,
        isActive: false,
      );

      expect(request.{propertyName}, 'Updated {Entity Name}');
      expect(request.description, 'Updated description');
      expect(request.displayOrder, 10);
      expect(request.isActive, false);
    });

    test('should serialize to JSON correctly', () {
      final request = Update{EntityName}Request(
        {propertyName}: 'Updated {Entity Name}',
        description: 'Updated description',
        displayOrder: 10,
        isActive: false,
      );

      final json = request.toJson();

      expect(json['{propertyName}'], 'Updated {Entity Name}');
      expect(json['description'], 'Updated description');
      expect(json['displayOrder'], 10);
      expect(json['isActive'], false);
    });
  });
});
```

## Test Commands và Configuration

### Backend Test Commands
```bash
# Run all tests
dotnet test aspnet-core/SmartRestaurant.sln

# Run specific test project
dotnet test aspnet-core/test/SmartRestaurant.Application.Tests

# Run with coverage
dotnet test aspnet-core/SmartRestaurant.sln --collect:"XPlat Code Coverage"

# Run specific test class
dotnet test aspnet-core/SmartRestaurant.sln --filter "ClassName={EntityName}AppServiceTests"

# Run specific test method
dotnet test aspnet-core/SmartRestaurant.sln --filter "MethodName=CreateAsync_Should_Create_New_{EntityName}"
```

### Frontend Test Commands
```bash
# Run all tests
cd angular && npm test

# Run tests with coverage
cd angular && npm run test:coverage

# Run specific test file
cd angular && npx ng test --include="**/{entity-name}*.spec.ts"

# Run in watch mode
cd angular && npx ng test --watch=true

# Run e2e tests
cd angular && npm run e2e
```

### Mobile Test Commands
```bash
# Run all tests
cd flutter_mobile && flutter test

# Run specific test file
cd flutter_mobile && flutter test test/features/{module}/{entity_name}_screen_test.dart

# Run with coverage
cd flutter_mobile && flutter test --coverage

# Run widget tests only
cd flutter_mobile && flutter test test/widgets/

# Run integration tests
cd flutter_mobile && flutter test integration_test/
```

## Notes quan trọng

1. **Test Coverage**: Đảm bảo coverage tối thiểu 80% cho mỗi layer
2. **Vietnamese Messages**: Test messages và validation phải bằng tiếng Việt
3. **Mock Data**: Sử dụng realistic Vietnamese data cho testing
4. **Error Scenarios**: Test cả success và error scenarios
5. **Integration Tests**: Test end-to-end workflows
6. **Performance Tests**: Test với large datasets khi cần thiết
7. **Accessibility Tests**: Test accessibility features cho mobile và web