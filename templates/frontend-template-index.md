# SmartRestaurant Frontend Template - Navigation

## 🎯 Template Selection Guide

### Quick Decision Tree
```
┌─ Simple list/form cho master data? ────────────────────────────────► Level 1
│
├─ Có workflow, multi-step, status tracking? ───────────────────────► Level 2
│
├─ Cần drag & drop, real-time, visual editors? ─────────────────────► Level 3
│
└─ Không chắc? ────────────────────────────────────────────────────── Start với Level 1, sau đó migrate lên
```

## 📄 Template Files

### 📋 [Level 1: Simple List + Form UI](./frontend-template-level1.md)
**Khi nào dùng**: Simple master data management, basic CRUD operations
**Phù hợp cho**: RoleList, UserList, LayoutSectionList, MenuCategoryList...
**UI Pattern**: PrimeNG Table + Dialog Form
**Đặc điểm**: 
- Basic search và filtering
- Standard CRUD operations (Create, Read, Update, Delete)
- Simple form validation
- Confirmation dialogs

### 🔧 [Level 2: Business Logic UI](./frontend-template-level2.md)
**Khi nào dùng**: Business processes có workflow, multi-step operations
**Phù hợp cho**: Order Management, Reservation Flow, Payment Process, Inventory...
**UI Pattern**: Stepper, Status badges, Workflow buttons, Tabs
**Đặc điểm**:
- Multi-step forms và wizards
- Status tracking với badges
- Business rule validations
- Conditional UI elements
- Progress indicators

### 🚀 [Level 3: Interactive UI](./frontend-template-level3.md)
**Khi nào dùng**: Complex user interactions, real-time updates, visual editors
**Phù hợp cho**: Table Layout Kanban, Kitchen Dashboard, Menu Builder, Real-time Reporting...
**UI Pattern**: Drag & Drop, Canvas, Real-time widgets, Interactive dashboards
**Đặc điểm**:
- CDK Drag & Drop functionality
- Real-time updates (WebSocket/SignalR)
- Visual editors và builders
- Advanced UX interactions
- Performance-optimized components

## Frontend-Backend Template Mapping

```
Backend Level 1 (Basic CRUD) ←→ Frontend Level 1 (Simple List + Form)
Backend Level 2 (Business Logic) ←→ Frontend Level 2 (Workflow UI)  
Backend Level 3 (Complex Business) ←→ Frontend Level 3 (Interactive UI)
```

## 🔄 Migration Path

1. **Bắt đầu với Level 1** cho UI components mới
2. **Migrate lên Level 2** khi cần workflow và business logic
3. **Migrate lên Level 3** khi cần interactive features và real-time

## 📖 Common Resources

Tất cả các level đều sử dụng chung:
- Angular 19 với standalone components
- PrimeNG UI component library
- Tailwind CSS cho styling
- ComponentBase cho error handling
- Vietnamese localization patterns
- Responsive design principles