# GitHub Secrets và Variables Setup

## Repository Secrets (Settings → Secrets and variables → Actions → Secrets)

### 🔒 Database & Security Secrets
```
DB_PASSWORD=your_strong_database_password
ENCRYPTION_PASSPHRASE=your_encryption_passphrase_32chars
```

### 🔒 VPS Deployment Secrets
```
VPS_HOST=your_vps_ip
VPS_USER=root
VPS_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
[your-private-key-content]
-----END OPENSSH PRIVATE KEY-----
VPS_PORT=22
```

## Repository Variables (Settings → Secrets and variables → Actions → Variables)

### 🌐 Domain Configuration
```
FRONTEND_BASE_URL=https://chodocquan.site
BACKEND_BASE_URL=https://chodocquan.site/api
```

### 🔐 Client IDs & Settings
```
SWAGGER_CLIENT_ID=SmartRestaurant_Swagger
WEB_CLIENT_ID=SmartRestaurant_Angular
AUTH_REQUIRE_HTTPS=false
```

## Environment-specific Variables (Optional)

### Production Environment
- Tạo environment "production" trong Settings → Environments
- Thêm protection rules nếu cần

### Staging Environment (Optional)
- Tạo environment "staging" với các variables riêng:
```
FRONTEND_BASE_URL=https://staging.chodocquan.site
BACKEND_BASE_URL=https://staging.chodocquan.site/api
```

## Cách setup trên GitHub:

1. **Repository Secrets:**
   - Go to: Repository → Settings → Secrets and variables → Actions
   - Click "New repository secret"
   - Thêm từng secret một theo list trên

2. **Repository Variables:**
   - Same page, tab "Variables"
   - Click "New repository variable"
   - Thêm từng variable một

3. **Environment-specific (Optional):**
   - Go to: Repository → Settings → Environments
   - Create "production" environment
   - Add environment-specific variables/secrets

## Lưu ý bảo mật:
- ✅ Secrets được encrypt và không hiển thị trong logs
- ✅ Variables có thể nhìn thấy trong logs (dùng cho URLs, configs)
- ⚠️ SSH Key phải là private key có quyền truy cập VPS
- ⚠️ DB_PASSWORD phải trùng với password trong VPS PostgreSQL

## Tóm tắt đơn giản hóa:
- **Giảm từ 10+ variables xuống còn 5 variables**
- **Chỉ cần 2 URLs chính:** `FRONTEND_BASE_URL` và `BACKEND_BASE_URL`
- **Dễ thay đổi domain:** chỉ cần sửa 2 biến thay vì nhiều biến
- **Tránh lỗi typo** do trùng lặp URLs