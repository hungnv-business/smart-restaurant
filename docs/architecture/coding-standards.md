# Coding Standards

## Critical Fullstack Rules (Quy tắc Fullstack Quan trọng)

**ABP Code-First Development Rules (Quy tắc Phát triển ABP Code-First):**
- **Entity Definition:** Always define entities in Domain layer using ABP base classes (FullAuditedEntity, etc.) - never create POCOs (Luôn định nghĩa entity trong Domain layer sử dụng ABP base classes)
- **Type Generation:** Use ABP proxy generation for frontend types - never manually create TypeScript interfaces that duplicate backend DTOs (Sử dụng ABP proxy generation cho frontend types)
- **API Calls:** Always use auto-generated ABP service proxies - never make direct HTTP calls or manually create API clients (Luôn sử dụng ABP service proxy tự động tạo)
- **Database Access:** Use ABP repositories and Entity Framework Core - never write raw SQL in application services (Sử dụng ABP repositories và Entity Framework Core)
- **Application Services:** Implement IApplicationService for auto-API generation - never create manual controllers (Implement IApplicationService để tự động tạo API)
- **DTOs:** Define DTOs in Application layer for auto-proxy generation - never use entities directly in frontend (Định nghĩa DTO trong Application layer để tự động tạo proxy)
- **Validation:** Use ABP/DataAnnotations validation - never implement custom validation without ABP integration (Sử dụng ABP/DataAnnotations validation)
- **Authorization:** Use ABP authorization attributes and permission system - never implement custom authorization (Sử dụng ABP authorization attributes và permission system)
- **Localization:** Use ABP localization system for Vietnamese text - never hardcode Vietnamese strings (Sử dụng ABP localization system cho tiếng Việt)
- **Configuration:** Access settings through ABP configuration system - never use process.env directly in backend (Truy cập setting qua ABP configuration system)

**Frontend Integration Rules (Quy tắc Tích hợp Frontend):**
- **State Updates:** Never mutate NgRx state directly - use proper actions and reducers (Không bao giờ mutate NgRx state trực tiếp)
- **SignalR Connections:** Always use centralized SignalRService - never create direct hub connections in components (Luôn sử dụng SignalRService tập trung)
- **Error Handling:** Use ABP's built-in error handling and localization (Sử dụng error handling tích hợp của ABP)
- **Proxy Regeneration:** Always regenerate proxies after backend changes - never manually update frontend types (Luôn tạo lại proxy sau khi thay đổi backend)

## Naming Conventions (Quy ước Đặt tên)

| Element (Phần tử) | Frontend | Backend | Example (Ví dụ) |
|---------|----------|---------|---------|
| Components | PascalCase | - | `OrderProcessingComponent` |
| Services | PascalCase with Service | PascalCase with AppService | `OrderService` / `OrderAppService` |
| API Routes | - | kebab-case | `/api/app/menu-items` |
| Database Tables | - | PascalCase (ABP convention) | `Orders`, `MenuItems` |
| Domain Events | - | PascalCase with Event suffix | `OrderStatusChangedEvent` |
| NgRx Actions | PascalCase with Action suffix | - | `LoadOrdersAction` |
| SignalR Methods | camelCase | PascalCase | `orderStatusChanged` / `OrderStatusChanged` |
