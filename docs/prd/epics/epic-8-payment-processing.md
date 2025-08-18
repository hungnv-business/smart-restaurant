# Epic 8: Payment Processing (Thanh toán)

**Integrated Goal:** Implement integrated payment processing within order management interface supporting Vietnamese payment methods (cash, QR bank transfer) with payment buttons directly accessible from order lists for seamless workflow (Triển khai xử lý thanh toán tích hợp trong giao diện quản lý đơn hàng hỗ trợ phương thức thanh toán Việt Nam - tiền mặt, chuyển khoản QR - với nút thanh toán truy cập trực tiếp từ danh sách đơn hàng để quy trình mượt mà).

## Story 8.1: Integrated Payment Processing (Xử lý Thanh toán Tích hợp)
**As a** waitstaff (nhân viên phục vụ),  
**I want** to process customer payments with a simple one-step workflow that automatically prints invoices (tôi muốn xử lý thanh toán khách hàng với quy trình một bước đơn giản tự động in hóa đơn),  
**so that** I can quickly complete payment processing and reset table availability (để tôi có thể nhanh chóng hoàn thành xử lý thanh toán và đặt lại trạng thái bàn khả dụng).

**Acceptance Criteria:**
1. **Auto-Print Payment Invoice**: Click "Payment" button automatically prints detailed invoice with restaurant info, itemized order details, total amount, and restaurant QR code for customer payment (Tự động in hóa đơn thanh toán: Bấm nút "Thanh toán" tự động in hóa đơn chi tiết với thông tin quán, chi tiết đơn hàng từng món, tổng tiền và QR code thanh toán của quán)
2. **Payment Confirmation Button**: Single "Payment Completed" button appears after invoice printing for staff to confirm when customer has paid (cash or bank transfer) (Nút xác nhận thanh toán: Nút "Đã thanh toán" xuất hiện sau khi in hóa đơn để nhân viên xác nhận khi khách đã thanh toán - tiền mặt hoặc chuyển khoản)
3. **Automatic Table Reset**: After clicking "Payment Completed", system automatically resets table status to "Available" and clears order data for next customers (Tự động đặt lại bàn: Sau khi bấm "Đã thanh toán", hệ thống tự động đặt lại trạng thái bàn thành "Khả dụng" và xóa dữ liệu đơn hàng cho khách tiếp theo)
4. **Invoice Content Requirements**: Printed invoice must include restaurant name, contact info, itemized dishes with prices, total amount, timestamp, and restaurant payment QR code (Yêu cầu nội dung hóa đơn: Hóa đơn in phải bao gồm tên quán, thông tin liên hệ, chi tiết món ăn với giá, tổng tiền, thời gian và QR code thanh toán của quán)

## Story 8.2: Financial Reconciliation & Reporting (Đối soát Tài chính & Báo cáo)
**As a** restaurant owner (chủ nhà hàng),  
**I want** to track all payment transactions with detailed reporting (tôi muốn theo dõi tất cả giao dịch thanh toán với báo cáo chi tiết),  
**so that** financial records are accurate and auditable (để hồ sơ tài chính chính xác và có thể kiểm toán).

**Acceptance Criteria:**
1. **Daily Payment Reconciliation**: Cash counting and payment method reconciliation with daily totals (Đối soát thanh toán hàng ngày: Kiểm đếm tiền mặt và đối soát phương thức thanh toán với tổng số hàng ngày)
2. **Payment Analytics**: Payment method breakdown analysis and daily/weekly/monthly trends (Phân tích thanh toán: Phân tích phương thức thanh toán và xu hướng hàng ngày/tuần/tháng)
3. **Financial Reporting**: Export capabilities for accounting software with Vietnamese tax compliance (Báo cáo tài chính: Khả năng xuất cho phần mềm kế toán với tuân thủ thuế Việt Nam)
4. **Transaction History**: Complete payment transaction history with search and filter capabilities (Lịch sử giao dịch: Lịch sử giao dịch thanh toán đầy đủ với khả năng tìm kiếm và lọc)
5. **Backend Integration**: Database integration to track all payments processed through the integrated interface (Tích hợp backend: Tích hợp cơ sở dữ liệu để theo dõi tất cả thanh toán được xử lý qua giao diện tích hợp)

---