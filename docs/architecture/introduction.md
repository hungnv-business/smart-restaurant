# Introduction (Giới thiệu)

This document outlines the complete fullstack architecture for Smart Restaurant Management System, including backend systems, frontend implementation, and their integration. It serves as the single source of truth for AI-driven development, ensuring consistency across the entire technology stack (Tài liệu này mô tả kiến trúc fullstack hoàn chỉnh cho Hệ thống Quản lý Nhà hàng Thông minh, bao gồm hệ thống backend, triển khai frontend và việc tích hợp chúng. Đây là nguồn thông tin duy nhất cho việc phát triển hướng dẫn bởi AI, đảm bảo tính nhất quán trên toàn bộ ngăn xếp công nghệ).

This unified approach combines what would traditionally be separate backend and frontend architecture documents, streamlining the development process for modern fullstack applications where these concerns are increasingly intertwined (Cách tiếp cận thống nhất này kết hợp những gì truyền thống sẽ là các tài liệu kiến trúc backend và frontend riêng biệt, tối ưu hóa quy trình phát triển cho các ứng dụng fullstack hiện đại).

## Starter Template or Existing Project (Template Khởi đầu hoặc Dự án Hiện có)

**Existing Project** - System has been established with specific architecture (Dự án hiện có - Hệ thống đã được thiết lập với kiến trúc cụ thể):
- **Backend**: ABP Framework (.NET 8) with modular monolith pattern and Domain-Driven Design (ABP Framework (.NET 8) với mô hình modular monolith và thiết kế hướng miền)
- **Frontend**: Angular 19 with PrimeNG and Poseidon template (Angular 19 với PrimeNG và template Poseidon)
- **Mobile**: Flutter app for staff and customers (Ứng dụng Flutter cho nhân viên và khách hàng)
- **Database**: PostgreSQL with Vietnamese text search support (PostgreSQL với hỗ trợ tìm kiếm văn bản tiếng Việt)
- **Real-time**: SignalR for kitchen coordination (SignalR cho phối hợp bếp)
- **Deployment**: Docker containers, VPS deployment target (Containers Docker, mục tiêu triển khai VPS)

## Change Log (Nhật ký Thay đổi)

| Date (Ngày) | Version (Phiên bản) | Description (Mô tả) | Author (Tác giả) |
|-------------|---------------------|---------------------|------------------|
| 2025-08-17 | 1.0 | Initial fullstack architecture for Smart Restaurant Management System (Kiến trúc fullstack ban đầu cho Hệ thống Quản lý Nhà hàng Thông minh) | Winston - Architect |
