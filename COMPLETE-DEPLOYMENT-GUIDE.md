# 🚀 HƯỚNG DẪN DEPLOYMENT HOÀN CHỈNH - SmartRestaurant

## 📋 TỔNG QUAN DỰ ÁN
**SmartRestaurant** - Hệ thống quản lý nhà hàng Việt Nam với:
- **Backend**: ABP Framework 8.0 + .NET 8 + PostgreSQL
- **Frontend**: Angular 19 với PrimeNG
- **Mobile**: Flutter 3.35.1 
- **Infrastructure**: Docker + Nginx + Let's Encrypt SSL
- **Domain**: chodocquan.site
- **VPS**: Ubuntu 20.04 - 2GB RAM - IP: 103.245.236.236

---

## 🛠️ BƯỚC 1: SETUP VPS UBUNTU

### 1.1 Yêu cầu VPS:
- **OS**: Ubuntu 20.04/22.04 LTS
- **RAM**: 2GB minimum
- **Storage**: 20GB SSD
- **Network**: Public IP
- **Domain**: chodocquan.site

### 1.2 Kết nối VPS và chạy setup script:

```bash
# Kết nối SSH tới VPS
ssh root@103.245.236.236

# Upload script setup từ máy local (chạy trên máy local)
scp infrastructure/vps-setup.sh root@103.245.236.236:/root/

# Quay lại VPS và chạy script
ssh root@103.245.236.236
chmod +x /root/vps-setup.sh
sudo ./vps-setup.sh
```

**📝 Trong quá trình setup:**
- Script sẽ hỏi về openssh-server config → Chọn **"keep the local version currently installed"**
- Email cho SSL certificate → Nhập: `admin@chodocquan.site`
- Quá trình setup mất ~5-10 phút

### 1.3 Kiểm tra sau khi setup:

```bash
# Kiểm tra Docker
docker --version
docker-compose --version

# Kiểm tra Nginx
nginx -v
systemctl status nginx

# Kiểm tra firewall
ufw status

# Kiểm tra thư mục đã tạo
ls -la /opt/smartrestaurant/
```

---

## 🌐 BƯỚC 2: SETUP DOMAIN VÀ DNS

### 2.1 Cấu hình DNS Records:

Vào trang quản lý domain và thêm:

```
Type: A
Name: @ (hoặc chodocquan.site)  
Value: 103.245.236.236
TTL: 300

Type: A
Name: www
Value: 103.245.236.236
TTL: 300
```

### 2.2 Đợi DNS propagate và kiểm tra:

```bash
# Kiểm tra DNS từ VPS
nslookup chodocquan.site
nslookup www.chodocquan.site

# Kết quả mong đợi:
# chodocquan.site has address 103.245.236.236
# www.chodocquan.site has address 103.245.236.236
```

**⏱️ DNS thường mất 5-15 phút để propagate**

---

## 🔐 BƯỚC 3: TẠO SSL CERTIFICATE

### 3.1 Sau khi DNS hoạt động, tạo SSL:

```bash
# Trên VPS, tạo SSL certificate
certbot --nginx -d chodocquan.site -d www.chodocquan.site --email admin@chodocquan.site --agree-tos --non-interactive
```

### 3.2 Kiểm tra SSL đã tạo thành công:

```bash
# Kiểm tra certificates
certbot certificates

# Test SSL
curl -I https://chodocquan.site
openssl s_client -connect chodocquan.site:443 -servername chodocquan.site </dev/null
```

**Kết quả mong đợi:** SSL certificate valid, website accessible via HTTPS

---

## 🔑 BƯỚC 4: TẠO SSH KEYS CHO GITHUB ACTIONS

### 4.1 Tạo SSH key pair:

```bash
# Trên VPS, tạo SSH key cho GitHub Actions
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github-actions -N ""

# Kiểm tra key đã tạo
ls -la ~/.ssh/github-actions*
```

### 4.2 Thêm public key vào authorized_keys:

```bash
# Thêm public key để GitHub Actions có thể SSH vào
cat ~/.ssh/github-actions.pub >> ~/.ssh/authorized_keys

# Kiểm tra
tail -2 ~/.ssh/authorized_keys
```

### 4.3 Test SSH key hoạt động:

```bash
# Test SSH connection
ssh -i ~/.ssh/github-actions -o StrictHostKeyChecking=no root@localhost "echo 'GitHub Actions SSH key working!'"
```

### 4.4 Lấy private key để copy vào GitHub:

```bash
# Hiển thị private key và copy toàn bộ
cat ~/.ssh/github-actions
```

**📋 Copy từ `-----BEGIN OPENSSH PRIVATE KEY-----` đến `-----END OPENSSH PRIVATE KEY-----`**

---

## 🔐 BƯỚC 5: SETUP GITHUB SECRETS

### 5.1 Truy cập GitHub Repository Secrets:

```
GitHub Repository → Settings → Secrets and variables → Actions → New repository secret
```

### 5.2 Thêm các secrets sau:

| Secret Name | Value | Mô tả |
|-------------|-------|-------|
| `VPS_HOST` | `103.245.236.236` | IP address VPS |
| `VPS_USER` | `root` | Username VPS |
| `VPS_SSH_KEY` | *(private key content từ bước 4.4)* | SSH private key |
| `VPS_PORT` | `22` | SSH port |
| `DB_PASSWORD` | `5yIV0jLRwo8qocfw8jc6EhMd75G3j9Hr` | Database password |
| `JWT_SECRET` | `Y7S32BVJonnM02PPC5NfUQ8OEDrKA0QuQXK4L0sf5EU=` | JWT secret key |

**📝 Lưu ý:** 
- `VPS_SSH_KEY` paste toàn bộ nội dung private key
- Passwords đã được generated strong và secure

---

## 📁 BƯỚC 6: COPY PRODUCTION FILES

### 6.1 Copy files từ máy local lên VPS:

```bash
# Từ máy local, đảm bảo đang ở thư mục dự án
cd /Volumes/Work/my-data/source-code/smart-restaurant

# Copy environment configuration
scp infrastructure/.env root@103.245.236.236:/opt/smartrestaurant/.env

# Copy docker compose
scp infrastructure/docker/docker-compose.yml root@103.245.236.236:/opt/smartrestaurant/

# Copy nginx configuration  
scp infrastructure/docker/nginx.conf root@103.245.236.236:/opt/smartrestaurant/

# Copy backup và monitoring scripts
scp -r infrastructure/scripts/ root@103.245.236.236:/opt/smartrestaurant/
```

### 6.2 Set permissions cho scripts:

```bash
# Set executable permissions
ssh root@103.245.236.236 "chmod +x /opt/smartrestaurant/scripts/*.sh"
```

### 6.3 Kiểm tra files đã copy:

```bash
# SSH vào VPS và kiểm tra
ssh root@103.245.236.236

# Kiểm tra file structure
ls -la /opt/smartrestaurant/
cat /opt/smartrestaurant/.env | head -10

# Kiểm tra scripts executable
ls -la /opt/smartrestaurant/scripts/
```

---

## 🚀 BƯỚC 7: TRIGGER DEPLOYMENT

### 7.1 Commit và push code:

```bash
# Từ máy local, ở thư mục smart-restaurant
cd /Volumes/Work/my-data/source-code/smart-restaurant

# Add tất cả changes
git add .

# Commit với message đầy đủ
git commit -m "🚀 Production deployment ready

✅ VPS Ubuntu + Docker + Nginx configured
✅ Domain chodocquan.site với SSL certificate  
✅ GitHub Actions SSH keys configured
✅ Production environment files copied
✅ Database secrets generated
🎯 Ready to deploy to https://chodocquan.site"

# Push để trigger deployment
git push origin main
```

### 7.2 GitHub Actions sẽ tự động chạy:

**Workflow stages:**
1. **Build Backend**: .NET API + Docker image (~5-8 phút)
2. **Build Frontend**: Angular build + tests (~3-5 phút)
3. **Test Mobile**: Flutter analyze + tests (~2-3 phút)  
4. **Deploy Production**: Deploy lên VPS (~3-5 phút)
5. **Post-deploy Check**: Health verification (~1-2 phút)

---

## 📊 BƯỚC 8: THEO DÕI DEPLOYMENT

### 8.1 GitHub Actions Monitoring:

```
GitHub Repository → Actions tab → "Deploy SmartRestaurant to Production"
```

Theo dõi từng step và xem logs nếu có lỗi.

### 8.2 VPS Real-time Monitoring:

```bash
# SSH vào VPS để theo dõi
ssh root@103.245.236.236

# Theo dõi containers status
cd /opt/smartrestaurant
watch "docker-compose -f docker-compose.prod.yml ps"

# Theo dõi logs real-time khi deployment chạy
docker-compose -f docker-compose.prod.yml logs -f

# Theo dõi nginx logs
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

### 8.3 Resource monitoring:

```bash
# Memory usage
free -h
docker stats

# Disk space
df -h

# CPU usage
htop
```

---

## 🎯 BƯỚC 9: VERIFICATION SAU DEPLOYMENT

### 9.1 Kiểm tra website URLs:

- **🌐 Main Site**: https://chodocquan.site
- **🔧 API Health**: https://chodocquan.site/api/health
- **📱 API Endpoints**: https://chodocquan.site/api/*

### 9.2 Verification commands từ bên ngoài:

```bash
# Kiểm tra website response
curl -I https://chodocquan.site

# Kiểm tra API health
curl https://chodocquan.site/api/health

# Kiểm tra SSL certificate
curl -vI https://chodocquan.site 2>&1 | grep -E "(SSL|TLS|Certificate)"

# Test redirect HTTP → HTTPS
curl -I http://chodocquan.site
```

### 9.3 Kiểm tra trên VPS:

```bash
# SSH vào VPS
ssh root@103.245.236.236

# Kiểm tra containers running
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml ps

# Kiểm tra container health
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml exec api curl -f http://localhost/health

# Kiểm tra database connectivity
docker exec smartrestaurant_postgres pg_isready -U postgres -d SmartRestaurant

# Kiểm tra backup system
sudo /opt/smartrestaurant/scripts/backup-database.sh

# Kiểm tra health monitoring
sudo /opt/smartrestaurant/scripts/health-monitor.sh
```

---

## 🔧 TROUBLESHOOTING

### Nếu GitHub Actions fail:

1. **Kiểm tra GitHub Secrets**: Đảm bảo tất cả 6 secrets đã được setup đúng
2. **Kiểm tra SSH key**: Test SSH connection từ VPS
3. **Kiểm tra disk space**: `df -h` trên VPS
4. **Xem logs chi tiết**: Trong GitHub Actions → Failed job → View logs

### Nếu website không load:

```bash
# Kiểm tra containers
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml ps

# Restart containers nếu cần
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml restart

# Xem logs containers
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml logs nginx
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml logs api
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml logs postgres
```

### Nếu SSL lỗi:

```bash
# Renew SSL certificate
sudo certbot renew --nginx
sudo systemctl reload nginx

# Check SSL status
certbot certificates
```

### Nếu memory issues:

```bash
# Check memory usage
free -h
docker stats

# Restart containers to free memory
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml restart
```

---

## 📈 BƯỚC 10: POST-DEPLOYMENT SETUP

### 10.1 Monitoring & Backup:

```bash
# Test automated backup
sudo /opt/smartrestaurant/scripts/backup-database.sh

# Check backup cron job
crontab -l

# Test health monitoring  
sudo /opt/smartrestaurant/scripts/health-monitor.sh

# Check monitoring logs
tail -f /opt/smartrestaurant/logs/health-monitor.log
tail -f /opt/smartrestaurant/logs/backup.log
```

### 10.2 Mobile App Integration:

```bash
# Update Flutter app API endpoint
# lib/core/constants/api_constants.dart
# const String baseUrl = 'https://chodocquan.site/api';

# Build production APK
cd flutter_mobile
flutter build apk --release
```

### 10.3 Performance Optimization:

- Setup CDN cho static files
- Database query optimization  
- Implement application-level caching
- Monitor và tune resource usage

---

## 🎊 DEPLOYMENT CHECKLIST

### Pre-deployment:
- [x] VPS setup với Ubuntu + Docker + Nginx
- [x] Domain DNS trỏ về VPS IP
- [x] SSL certificate từ Let's Encrypt
- [x] SSH keys cho GitHub Actions
- [x] GitHub Secrets configured
- [x] Production files copied

### Post-deployment:
- [ ] Website accessible tại https://chodocquan.site ✅
- [ ] API endpoints responding ✅
- [ ] SSL certificate valid ✅
- [ ] Database backup working ✅
- [ ] Health monitoring active ✅
- [ ] Mobile app integration tested ✅

---

## 🎯 SUMMARY

**🚀 DEPLOYMENT FLOW:**
1. ✅ Setup VPS Ubuntu + Docker + Nginx
2. ✅ Configure domain DNS + SSL
3. ✅ Create SSH keys cho GitHub Actions  
4. ✅ Setup GitHub Secrets
5. ✅ Copy production files
6. ✅ Trigger deployment via git push
7. ✅ Monitor deployment progress
8. ✅ Verify website live
9. ✅ Setup monitoring & backup
10. ✅ Mobile app integration

**🌐 WEBSITE LIVE TẠI:** https://chodocquan.site

**📱 API ENDPOINTS:** https://chodocquan.site/api/*

**🔒 SECURITY:** SSL certificate + firewall + secure passwords

**📊 MONITORING:** Automated backup + health checks + resource monitoring

**⏱️ TOTAL TIME:** ~30-45 phút (bao gồm DNS propagation)