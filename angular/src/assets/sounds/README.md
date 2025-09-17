# Kitchen Notification Sounds

Thư mục này chứa file âm thanh cho thông báo kitchen dashboard.

## File âm thanh cần có:

- `new-order.mp3` - Âm thanh chung cho tất cả thông báo từ mobile

## Đơn giản hóa:
- **Tất cả thông báo** đều dùng cùng 1 âm thanh `new-order.mp3`
- Bao gồm: đơn hàng mới, thêm món, xóa món, cập nhật số lượng
- Text-to-speech sẽ phân biệt các loại thông báo bằng message

## Ghi chú:
- File âm thanh nên ngắn (0.5-2 giây)  
- Format khuyến nghị: MP3, WAV
- Âm lượng vừa phải, không quá lớn
- Nếu không có file, service sẽ tự tạo âm thanh beep 800Hz

## Cài đặt file âm thanh:
1. Thêm file `new-order.mp3` vào thư mục này
2. Service sẽ tự động load và dùng cho tất cả thông báo
3. Không cần file khác - hệ thống đã đơn giản hóa