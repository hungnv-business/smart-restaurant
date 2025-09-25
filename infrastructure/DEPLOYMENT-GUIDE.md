# SmartRestaurant Production Deployment Guide

Hướng dẫn triển khai production cho hệ thống SmartRestaurant trên VPS với domain **chodocquan.site**.

## 📋 Yêu Cầu Hệ Thống

### VPS Specifications
- **CPU**: 1 core
- **RAM**: 2GB 
- **Storage**: 20GB SSD
- **OS**: Ubuntu 20.04/22.04 LTS
- **Network**: 100 Mbps unlimited bandwidth

### Domain & DNS
- Domain: `chodocquan.site`
- DNS A record pointing to VPS IP
- SSL certificate (auto-generated với Let's Encrypt)

## 🚀 Bước 1: Setup VPS

### 1.1 Chạy VPS Setup Script

```bash
# Upload và chạy script setup
chmod +x infrastructure/vps-setup.sh
sudo ./infrastructure/vps-setup.sh
```

### 1.2 Kiểm tra sau khi setup
```bash
# Kiểm tra Docker
docker --version
docker-compose --version

# Kiểm tra Nginx
nginx -v
systemctl status nginx

# Kiểm tra SSL
certbot certificates
```

## 🐳 Bước 2: Chuẩn bị Production Files

### 2.1 Copy các file cần thiết lên VPS

```bash
# Tạo thư mục
sudo mkdir -p /opt/smartrestaurant
sudo chown -R $USER:$USER /opt/smartrestaurant

# Copy Docker Compose và configs
scp infrastructure/docker/docker-compose.yml root@103.245.236.236:/opt/smartrestaurant/
scp infrastructure/docker/nginx.conf root@103.245.236.236:/opt/smartrestaurant/
scp infrastructure/.env root@103.245.236.236:/opt/smartrestaurant/.env

# Copy scripts
scp -r infrastructure/scripts/ root@103.245.236.236:/opt/smartrestaurant/
chmod +x /opt/smartrestaurant/scripts/*.sh
```

### 2.2 Cấu hình Environment Variables

```bash
# Edit .env file trên VPS
nano /opt/smartrestaurant/.env
```

**Cập nhật các giá trị sau:**
```env
DB_PASSWORD=your_very_secure_password_here
JWT_SECRET=your_32_char_jwt_secret_key_here
NOTIFICATION_EMAIL=admin@chodocquan.site
```

## 🔧 Bước 3: Setup GitHub Actions

### 3.1 Cấu hình GitHub Secrets

Vào GitHub Repository → Settings → Secrets → Add:

```
VPS_HOST=your-vps-ip-address
VPS_USER=your-vps-username  
VPS_SSH_KEY=your-private-ssh-key
VPS_PORT=22
DB_PASSWORD=same-as-in-env-file
JWT_SECRET=same-as-in-env-file
```

### 3.2 Generate SSH Key cho GitHub Actions

```bash
# Trên VPS
ssh-keygen -t rsa -b 4096 -C "github-actions"
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Copy private key (id_rsa) content vào GitHub Secret VPS_SSH_KEY
cat ~/.ssh/id_rsa
```

## 🗄️ Bước 4: Setup Database

### 4.1 Tạo database trước khi deploy

```bash
cd /opt/smartrestaurant

# Khởi động chỉ PostgreSQL
docker-compose -f docker-compose.yml up -d postgres

# Đợi database sẵn sàng
sleep 30

# Tạo database (nếu chưa có)
docker exec smartrestaurant_postgres psql -U postgres -c "CREATE DATABASE \"SmartRestaurant\";"
```

### 4.2 Import database (nếu có)

```bash
# Nếu có database backup từ development
docker exec -i smartrestaurant_postgres psql -U postgres -d SmartRestaurant < your-database-dump.sql
```

## 📱 Bước 5: Build và Deploy

### 5.1 Push code lên GitHub

```bash
# Commit và push code
git add .
git commit -m "Add production deployment configuration"
git push origin main
```

### 5.2 Manual deploy (lần đầu)

```bash
# Trên VPS - build images manually cho lần đầu
cd /opt/smartrestaurant

# Pull và build API image
docker build -t smartrestaurant/api:latest -f ../infrastructure/docker/Dockerfile.api ../

# Hoặc pull từ GitHub Container Registry nếu đã setup
# docker pull ghcr.io/your-username/smart-restaurant/api:latest
# docker tag ghcr.io/your-username/smart-restaurant/api:latest smartrestaurant/api:latest
```

### 5.3 Deploy Angular frontend

```bash
# Build Angular trên local machine hoặc CI
cd angular
npm install
npm run build:prod

# Copy static files lên VPS
scp -r dist/* user@your-vps:/var/www/html/
```

### 5.4 Start production services

```bash
# Trên VPS
cd /opt/smartrestaurant
docker-compose -f docker-compose.yml up -d

# Kiểm tra logs
docker-compose -f docker-compose.yml logs -f
```

## 🔍 Bước 6: Verification & Testing

### 6.1 Health Checks

```bash
# Kiểm tra containers
docker-compose -f docker-compose.yml ps

# Kiểm tra health endpoints
curl http://localhost/health
curl http://localhost/api/health

# Kiểm tra public site
curl https://chodocquan.site
```

### 6.2 Database Connectivity

```bash
# Test database connection
docker exec smartrestaurant_postgres psql -U postgres -d SmartRestaurant -c "SELECT version();"
```

### 6.3 SSL Certificate

```bash
# Kiểm tra SSL
curl -I https://chodocquan.site
openssl s_client -connect chodocquan.site:443 -servername chodocquan.site
```

## 📊 Bước 7: Setup Monitoring & Backup

### 7.1 Setup Backup Cron Job

```bash
# Cron job đã được setup trong vps-setup.sh, kiểm tra:
crontab -l

# Manual test backup
sudo /opt/smartrestaurant/scripts/backup-database.sh
```

### 7.2 Setup Health Monitoring

```bash
# Health monitor cron job (chạy mỗi 5 phút)
crontab -l

# Manual test monitoring
sudo /opt/smartrestaurant/scripts/health-monitor.sh
```

### 7.3 Check Log Files

```bash
# Kiểm tra logs
tail -f /opt/smartrestaurant/logs/backup.log
tail -f /opt/smartrestaurant/logs/health-monitor.log
tail -f /var/log/nginx/access.log
tail -f /var/log/nginx/error.log
```

## 📱 Bước 8: Flutter Mobile Setup (Optional)

### 8.1 Build APK cho production

```bash
cd flutter_mobile

# Update API endpoint trong code
# lib/core/constants/api_constants.dart
# const String baseUrl = 'https://chodocquan.site/api';

# Build APK
flutter build apk --release

# File APK sẽ được tạo tại:
# build/app/outputs/flutter-apk/app-release.apk
```

## 🔧 Bước 9: Troubleshooting

### 9.1 Common Issues

#### Container không start được:
```bash
# Kiểm tra logs chi tiết
docker-compose -f docker-compose.yml logs nginx
docker-compose -f docker-compose.yml logs api
docker-compose -f docker-compose.yml logs postgres

# Restart services
docker-compose -f docker-compose.yml restart
```

#### SSL certificate issues:
```bash
# Renew SSL certificate manually
sudo certbot renew --nginx

# Test automatic renewal
sudo certbot renew --dry-run
```

#### Database connection issues:
```bash
# Check PostgreSQL container
docker exec smartrestaurant_postgres pg_isready -U postgres

# Check database logs
docker-compose -f docker-compose.prod.yml logs postgres
```

#### Memory issues:
```bash
# Check memory usage
free -h
docker stats

# Restart containers nếu cần
docker-compose -f docker-compose.yml restart
```

### 9.2 Performance Optimization

#### Nếu gặp vấn đề về memory:
```bash
# Giảm PostgreSQL memory settings trong docker-compose.yml
# Giảm .NET heap limit trong environment variables
# Restart containers
```

#### Tối ưu Nginx:
```bash
# Edit nginx.prod.conf để tune cache settings
# Reload Nginx config
docker-compose -f docker-compose.yml exec nginx nginx -s reload
```

## 🚀 Bước 10: Go Live Checklist

### Pre-launch Checklist:
- [ ] VPS setup completed
- [ ] SSL certificate working
- [ ] Database created and accessible
- [ ] All containers running healthy
- [ ] GitHub Actions workflow working
- [ ] Backup system functional
- [ ] Health monitoring active
- [ ] Performance tests passed
- [ ] Security checks completed

### Post-launch Monitoring:
- [ ] Website accessible at https://chodocquan.site
- [ ] API endpoints responding
- [ ] Mobile app connecting successfully
- [ ] Backup logs showing success
- [ ] No critical alerts in monitoring
- [ ] SSL certificate valid
- [ ] Performance metrics acceptable

## 📞 Support & Maintenance

### Daily Tasks:
- Kiểm tra health monitor logs
- Kiểm tra backup completion
- Review application logs

### Weekly Tasks:
- Update system packages
- Review performance metrics
- Check backup retention

### Monthly Tasks:
- SSL certificate renewal check
- Security updates
- Performance optimization review

---

## 🎉 Deployment Complete!

Sau khi hoàn thành tất cả các bước, SmartRestaurant sẽ có sẵn tại:

**🌐 Website**: https://chodocquan.site
**📱 Mobile**: APK file for distribution
**🔧 Admin**: https://chodocquan.site/admin

**Monitoring URLs**:
- Health Check: https://chodocquan.site/health
- API Health: https://chodocquan.site/api/health

**Files quan trọng trên VPS**:
- Application: `/opt/smartrestaurant/`
- Logs: `/opt/smartrestaurant/logs/`
- Backups: `/opt/smartrestaurant/backups/`
- Static Files: `/var/www/html/`
- SSL Certs: `/etc/letsencrypt/live/chodocquan.site/`