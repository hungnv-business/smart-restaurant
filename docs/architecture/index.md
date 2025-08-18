# Smart Restaurant Management System - Fullstack Architecture Document (Hệ thống Quản lý Nhà hàng Thông minh - Tài liệu Kiến trúc Fullstack)

## Table of Contents

### Core Architecture (Kiến trúc Cốt lõi)

- [Introduction (Giới thiệu)](./introduction.md) - Project overview and architectural foundations
- [High Level Architecture (Kiến trúc Tổng quan)](./high-level-architecture.md) - ABP Framework modular monolith with Vietnamese restaurant workflows  
- [Tech Stack (Ngăn xếp Công nghệ)](./tech-stack.md) - .NET 8, Angular 19, PostgreSQL, Docker deployment stack
- [Unified Project Structure (Cấu trúc Dự án Thống nhất)](./unified-project-structure.md) - Repository organization and development structure

### Data & API Design (Thiết kế Dữ liệu & API)

- [Data Models (Các Mô hình Dữ liệu)](./data-models.md) - Core business entities for Vietnamese restaurant operations
- [Database Management (Quản lý Cơ sở Dữ liệu)](./database-management.md) - EF Core Code-First with Vietnamese text search
- [API Specification (Thông số kỹ thuật API)](./api-specification.md) - REST APIs and SignalR real-time communication
- [External APIs (API Bên ngoài)](./external-apis.md) - Vietnamese banking QR payments and kitchen printer integration

### Application Architecture (Kiến trúc Ứng dụng)

- [Frontend Architecture (Kiến trúc Frontend)](./frontend-architecture.md) - Angular 19 with PrimeNG Poseidon template and ABP integration
- [Backend Architecture (Kiến trúc Backend)](./backend-architecture.md) - ABP Framework layered architecture with Vietnamese localization
- [Components (Các Thành phần)](./components.md) - Frontend components and backend services for restaurant operations
- [Core Workflows (Quy trình Cốt lõi)](./core-workflows.md) - Order processing, payment, and kitchen coordination workflows

### Development & Operations (Phát triển & Vận hành)

- [Development Workflow (Quy trình Phát triển)](./development-workflow.md) - Local setup, environment configuration, and development commands
- [Deployment Architecture (Kiến trúc Triển khai)](./deployment-architecture.md) - CI/CD pipeline, VPS deployment, and environment management
- [Testing Strategy (Chiến lược Kiểm thử)](./testing-strategy.md) - Comprehensive testing approach with Vietnamese test data
- [Security and Performance (Bảo mật và Hiệu suất)](./security-and-performance.md) - Security requirements and performance optimization

### Quality & Standards (Chất lượng & Tiêu chuẩn)

- [Coding Standards (Tiêu chuẩn Lập trình)](./coding-standards.md) - Fullstack coding conventions and Vietnamese naming standards
- [Error Handling Strategy (Chiến lược Xử lý Lỗi)](./error-handling-strategy.md) - Error flow and handling patterns across the stack
- [Monitoring and Observability (Giám sát và Quan sát Hệ thống)](./monitoring-and-observability.md) - Application monitoring and performance dashboards

### Project Management (Quản lý Dự án)

- [Cross-Epic Dependencies Documentation (Tài liệu Phụ thuộc Liên Epic)](./cross-epic-dependencies-documentation.md) - Epic dependency matrix and integration criteria
- [Checklist Results Report (Báo cáo Kết quả Kiểm tra)](./checklist-results-report.md) - Architecture validation and compliance results
