# GitHub Secrets và Variables Setup

## Repository Secrets (Settings → Secrets and variables → Actions → Secrets)

### 🔒 Database & Security Secrets
```
DB_PASSWORD=5yIV0jLRwo8qocfw8jc6EhMd75G3j9Hr
ENCRYPTION_PASSPHRASE=froLqucNEUJgzTCL
```

### 🔒 VPS Deployment Secrets
```
VPS_HOST=103.245.236.236
VPS_USER=root
VPS_SSH_KEY=-----BEGIN OPENSSH PRIVATE KEY-----
[your-private-key-content]
-----END OPENSSH PRIVATE KEY-----
VPS_PORT=22
```

## Repository Variables (Settings → Secrets and variables → Actions → Variables)

### 🌐 Application URLs
```
APP_SELF_URL=https://chodocquan.site/api
APP_CLIENT_URL=https://chodocquan.site
APP_CORS_ORIGINS=https://*.SmartRestaurant.com,https://chodocquan.site
APP_REDIRECT_URLS=https://chodocquan.site
```

### 🔐 Auth Server Configuration
```
AUTH_SERVER_AUTHORITY=https://chodocquan.site/api
AUTH_REQUIRE_HTTPS=false
SWAGGER_CLIENT_ID=SmartRestaurant_Swagger
```

### 🎨 Frontend Configuration
```
WEB_API_URL=https://chodocquan.site/api
WEB_BASE_URL=https://chodocquan.site
WEB_CLIENT_ID=SmartRestaurant_Angular
```

## Environment-specific Variables (Optional)

### Production Environment
- Tạo environment "production" trong Settings → Environments
- Thêm protection rules nếu cần

### Staging Environment (Optional)
- Tạo environment "staging" với các variables riêng:
```
APP_SELF_URL=https://staging.chodocquan.site/api
WEB_API_URL=https://staging.chodocquan.site/api
WEB_BASE_URL=https://staging.chodocquan.site
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