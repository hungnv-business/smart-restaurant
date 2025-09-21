# Story Planning Guide - Template-based Task Creation

## 🎯 Quy trình Planning Story với Templates

### Step 1: Phân tích và chọn Level Template

```markdown
## Requirements Analysis Checklist

### Entity Complexity Assessment
- [ ] **Simple Properties Only**: Chỉ có basic fields (name, description, isActive) → **Level 1**
- [ ] **Has Calculations/Status**: Có tính toán, thay đổi trạng thái → **Level 2**  
- [ ] **Controls Core Workflow**: Điều khiển business workflow chính → **Level 3**

### UI Complexity Assessment
- [ ] **Basic List + Form**: Chỉ cần hiển thị list và form → **Level 1**
- [ ] **Multi-step Workflow**: Có stepper, workflow, status tracking → **Level 2**
- [ ] **Interactive Features**: Cần drag&drop, real-time, visual editors → **Level 3**

### Technical Requirements
- [ ] **Standard CRUD**: ICrudAppService đủ dùng → **Level 1**
- [ ] **Business Logic**: Cần custom methods, validations → **Level 2**
- [ ] **Real-time + Advanced**: SignalR, complex interactions → **Level 3**
```

### Step 2: Template-based Task Generation

## 📋 **Level 1 Tasks Template** (Simple CRUD)

```markdown
## Epic: [Entity Name] Management

### 🏗️ **Backend Tasks (Level 1)**
- [ ] **Task 1**: Create [Entity] Domain Entity
  - [ ] Subtask 1.1: Define entity properties and relationships
  - [ ] Subtask 1.2: Add entity to DbContext
  - [ ] Subtask 1.3: Create database migration

- [ ] **Task 2**: Implement [Entity] Application Layer  
  - [ ] Subtask 2.1: Create [Entity]AppService using ICrudAppService
  - [ ] Subtask 2.2: Define Create/Update DTOs
  - [ ] Subtask 2.3: Add AutoMapper profiles

- [ ] **Task 3**: Add [Entity] API Endpoints
  - [ ] Subtask 3.1: Auto-generated controller via ICrudAppService
  - [ ] Subtask 3.2: Configure API permissions
  - [ ] Subtask 3.3: Add API documentation

- [ ] **Task 4**: Create Integration Tests
  - [ ] Subtask 4.1: CRUD operation tests
  - [ ] Subtask 4.2: Validation tests
  - [ ] Subtask 4.3: Permission tests

### 🎨 **Frontend Tasks (Level 1)**
- [ ] **Task 5**: Generate Angular Service Proxies
  - [ ] Subtask 5.1: Run ABP generate-proxy command
  - [ ] Subtask 5.2: Verify generated DTOs and services

- [ ] **Task 6**: Create [Entity] List Component
  - [ ] Subtask 6.1: Implement list component with PrimeNG Table
  - [ ] Subtask 6.2: Add search and filtering
  - [ ] Subtask 6.3: Add CRUD action buttons

- [ ] **Task 7**: Create [Entity] Form Component
  - [ ] Subtask 7.1: Build reactive form with validation
  - [ ] Subtask 7.2: Implement create/edit dialog
  - [ ] Subtask 7.3: Add form submission logic

- [ ] **Task 8**: Implement Dialog Service
  - [ ] Subtask 8.1: Create form dialog service
  - [ ] Subtask 8.2: Add dialog opening methods
  - [ ] Subtask 8.3: Handle dialog result callbacks

- [ ] **Task 9**: Add Route Configuration
  - [ ] Subtask 9.1: Define feature routes
  - [ ] Subtask 9.2: Add to main routing module
  - [ ] Subtask 9.3: Configure breadcrumbs

- [ ] **Task 10**: Create Integration Tests
  - [ ] Subtask 10.1: Component rendering tests
  - [ ] Subtask 10.2: User interaction tests
  - [ ] Subtask 10.3: Service integration tests

### 📚 **Documentation & Deployment**
- [ ] **Task 11**: Update Documentation
- [ ] **Task 12**: Deploy to Dev Environment
```

## 📋 **Level 2 Tasks Template** (Business Logic)

```markdown
## Epic: [Entity Name] Management with Workflow

### 🏗️ **Backend Tasks (Level 2)**
- [ ] **Task 1**: Design [Entity] Domain Model
  - [ ] Subtask 1.1: Define entity with status/workflow properties
  - [ ] Subtask 1.2: Create related entities and relationships  
  - [ ] Subtask 1.3: Add business rule validations
  - [ ] Subtask 1.4: Implement domain events

- [ ] **Task 2**: Create [Entity] Domain Service
  - [ ] Subtask 2.1: Implement business logic methods
  - [ ] Subtask 2.2: Add status transition logic
  - [ ] Subtask 2.3: Create calculation methods
  - [ ] Subtask 2.4: Add domain event handlers

- [ ] **Task 3**: Implement [Entity] Application Service
  - [ ] Subtask 3.1: Create custom application service (not ICrudAppService)
  - [ ] Subtask 3.2: Implement CRUD methods with business logic
  - [ ] Subtask 3.3: Add workflow management methods
  - [ ] Subtask 3.4: Create specialized DTOs for different scenarios

- [ ] **Task 4**: Add Database Configuration
  - [ ] Subtask 4.1: Configure entity relationships
  - [ ] Subtask 4.2: Add database migrations
  - [ ] Subtask 4.3: Configure indexes for performance

- [ ] **Task 5**: Create Custom API Controllers
  - [ ] Subtask 5.1: Implement CRUD endpoints
  - [ ] Subtask 5.2: Add business logic endpoints
  - [ ] Subtask 5.3: Add workflow transition endpoints

### 🎨 **Frontend Tasks (Level 2)**  
- [ ] **Task 6**: Create Multi-step Workflow Component
  - [ ] Subtask 6.1: Implement stepper UI with PrimeNG Steps
  - [ ] Subtask 6.2: Create step navigation logic
  - [ ] Subtask 6.3: Add progress tracking

- [ ] **Task 7**: Build Business Logic Forms
  - [ ] Subtask 7.1: Create multi-step form components
  - [ ] Subtask 7.2: Add conditional validation rules
  - [ ] Subtask 7.3: Implement business rule checks

- [ ] **Task 8**: Add Status Management UI
  - [ ] Subtask 8.1: Create status badge components
  - [ ] Subtask 8.2: Add status transition buttons
  - [ ] Subtask 8.3: Implement status history timeline

- [ ] **Task 9**: Implement Dashboard/Summary Views
  - [ ] Subtask 9.1: Create summary statistics
  - [ ] Subtask 9.2: Add filtering by status
  - [ ] Subtask 9.3: Build reporting views

### 🧪 **Advanced Testing**
- [ ] **Task 10**: Business Logic Testing
  - [ ] Subtask 10.1: Domain service unit tests
  - [ ] Subtask 10.2: Workflow integration tests
  - [ ] Subtask 10.3: End-to-end workflow tests
```

## 📋 **Level 3 Tasks Template** (Interactive UI)

```markdown
## Epic: [Entity Name] Interactive Management System

### 🏗️ **Backend Tasks (Level 3)**
- [ ] **Task 1**: Design Complex Domain Architecture
  - [ ] Subtask 1.1: Create aggregate roots and entities
  - [ ] Subtask 1.2: Design domain events for real-time
  - [ ] Subtask 1.3: Implement complex business rules
  - [ ] Subtask 1.4: Add caching strategies

- [ ] **Task 2**: Implement Advanced Application Services
  - [ ] Subtask 2.1: Create feature-rich application services
  - [ ] Subtask 2.2: Add batch operation methods
  - [ ] Subtask 2.3: Implement search and filtering
  - [ ] Subtask 2.4: Add export/import functionality

- [ ] **Task 3**: Setup Real-time Infrastructure
  - [ ] Subtask 3.1: Configure SignalR hubs
  - [ ] Subtask 3.2: Implement real-time event broadcasting
  - [ ] Subtask 3.3: Add connection management
  - [ ] Subtask 3.4: Create real-time authorization

- [ ] **Task 4**: Add Performance Optimization
  - [ ] Subtask 4.1: Implement caching with in-memory cache
  - [ ] Subtask 4.2: Add background job processing
  - [ ] Subtask 4.3: Configure database optimization
  - [ ] Subtask 4.4: Add monitoring and metrics

### 🎨 **Frontend Tasks (Level 3)**
- [ ] **Task 5**: Setup Advanced UI Infrastructure
  - [ ] Subtask 5.1: Configure Angular CDK for drag & drop
  - [ ] Subtask 5.2: Setup SignalR client connection
  - [ ] Subtask 5.3: Implement state management with signals
  - [ ] Subtask 5.4: Add performance monitoring

- [ ] **Task 6**: Build Interactive Components
  - [ ] Subtask 6.1: Create drag & drop kanban board
  - [ ] Subtask 6.2: Implement visual editors/builders
  - [ ] Subtask 6.3: Add interactive dashboards
  - [ ] Subtask 6.4: Create real-time charts/graphs

- [ ] **Task 7**: Implement Advanced UX Features
  - [ ] Subtask 7.1: Add context menus and shortcuts
  - [ ] Subtask 7.2: Implement keyboard navigation
  - [ ] Subtask 7.3: Create customizable layouts
  - [ ] Subtask 7.4: Add user preferences storage

- [ ] **Task 8**: Add Real-time Features
  - [ ] Subtask 8.1: Implement live data synchronization
  - [ ] Subtask 8.2: Add collaborative editing features
  - [ ] Subtask 8.3: Create real-time notifications
  - [ ] Subtask 8.4: Add connection status indicators

### ⚡ **Performance & Testing**
- [ ] **Task 9**: Performance Optimization
  - [ ] Subtask 9.1: Implement virtual scrolling
  - [ ] Subtask 9.2: Add lazy loading strategies
  - [ ] Subtask 9.3: Optimize change detection
  - [ ] Subtask 9.4: Add performance monitoring

- [ ] **Task 10**: Advanced Testing Strategy
  - [ ] Subtask 10.1: Unit tests for complex components
  - [ ] Subtask 10.2: Integration tests for real-time features
  - [ ] Subtask 10.3: E2E tests for user workflows
  - [ ] Subtask 10.4: Performance and load testing
```

## 🔧 Cách sử dụng Templates trong Practice

### Example: Story "Menu Category Management"

```markdown
## 1. Requirements Analysis
**Feature**: Menu Category Management
**Description**: Quản lý danh mục thực đơn - tạo, sửa, xóa, sắp xếp thứ tự

## 2. Level Assessment
- ✅ Simple properties: name, description, displayOrder, isActive
- ❌ No complex workflow or calculations  
- ❌ No real-time or drag & drop needed
- **→ LEVEL 1 TEMPLATE**

## 3. Apply Level 1 Tasks
- Replace [Entity] with "MenuCategory"
- Replace [entity] with "menuCategory"  
- Add specific business requirements
- Estimate story points based on template complexity
```

### Template Usage Commands

```bash
# Khi tạo story mới, copy template phù hợp
cp templates/story-planning-guide.md stories/new-story-tasks.md

# Edit và thay thế placeholders
# [Entity] → MenuCategory
# [entity] → menuCategory
# [Entity Display Name] → Danh mục thực đơn
```

## 📈 Benefits của Template-based Planning

1. **Consistency**: Tất cả stories cùng level có structure giống nhau
2. **Completeness**: Không bỏ sót tasks quan trọng
3. **Estimation**: Dễ estimate dựa trên template complexity
4. **Quality**: Follow best practices từ templates
5. **Speed**: Nhanh chóng generate tasks cho stories mới
6. **Maintainability**: Code structure consistent, dễ maintain

## ⚡ Quick Reference

| Entity Type | Template Level | Key Indicators |
|-------------|---------------|----------------|
| Master Data | Level 1 | Basic CRUD, simple properties |
| Business Data | Level 2 | Workflow, calculations, status |
| Core System | Level 3 | Real-time, drag&drop, complex UX |

**Lưu ý**: Có thể start với Level 1 và migrate lên Level cao hơn khi requirements thay đổi.