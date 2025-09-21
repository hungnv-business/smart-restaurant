# 🚀 HƯỚNG DẪN DEPLOYMENT TIẾP THEO - SmartRestaurant

## ✅ ĐÃ HOÀN THÀNH:
- [x] VPS setup với Ubuntu + Docker + Nginx
- [x] Domain chodocquan.site trỏ về IP 103.245.236.236
- [x] SSL certificate từ Let's Encrypt (HTTPS working)
- [x] SSH keys cho GitHub Actions
- [x] Production files đã copy lên VPS

## 🔐 BƯỚC TIẾP THEO: SETUP GITHUB SECRETS

### 1. Truy cập GitHub Repository Secrets:
```
GitHub Repository → Settings → Secrets and variables → Actions → New repository secret
```

### 2. Thêm các secrets sau:

| Secret Name | Value | Mô tả |
|-------------|-------|-------|
| `VPS_HOST` | `103.245.236.236` | IP address VPS |
| `VPS_USER` | `root` | Username VPS |
| `VPS_SSH_KEY` | *(private key content)* | SSH private key để GitHub Actions kết nối VPS |
| `VPS_PORT` | `22` | SSH port |
| `DB_PASSWORD` | `5yIV0jLRwo8qocfw8jc6EhMd75G3j9Hr` | Database password |
| `JWT_SECRET` | `Y7S32BVJonnM02PPC5NfUQ8OEDrKA0QuQXK4L0sf5EU=` | JWT secret key |

### 3. Để lấy SSH Private Key:
```bash
# Trên VPS, chạy lệnh này và copy toàn bộ output:
cat ~/.ssh/github-actions
```

Copy từ `-----BEGIN OPENSSH PRIVATE KEY-----` đến `-----END OPENSSH PRIVATE KEY-----` vào secret `VPS_SSH_KEY`.

## 🚀 BƯỚC TIẾP THEO: TRIGGER DEPLOYMENT

### 1. Kiểm tra files production trên VPS:
```bash
# SSH vào VPS
ssh root@103.245.236.236

# Kiểm tra files
ls -la /opt/smartrestaurant/
cat /opt/smartrestaurant/.env | head -5
```

### 2. Commit và Push để trigger GitHub Actions:
```bash
# Từ máy local, ở thư mục smart-restaurant
cd /Volumes/Work/my-data/source-code/smart-restaurant

# Add và commit
git add .
git commit -m "🚀 Production deployment ready

✅ SSL certificate configured (chodocquan.site)
✅ VPS environment setup complete  
✅ GitHub Actions SSH keys configured
🎯 Ready to deploy to production"

# Push để trigger deployment
git push origin main
```

## 📊 THEO DÕI DEPLOYMENT

### 1. GitHub Actions:
- Vào GitHub repo → **Actions** tab
- Xem workflow **"Deploy SmartRestaurant to Production"**
- Theo dõi progress: Build Backend → Build Frontend → Deploy

### 2. VPS Monitoring:
```bash
# SSH vào VPS
ssh root@103.245.236.236

# Theo dõi deployment logs
cd /opt/smartrestaurant
watch "docker-compose -f docker-compose.prod.yml ps"

# Xem logs chi tiết
docker-compose -f docker-compose.prod.yml logs -f
```

## ⏱️ TIMELINE DỰ KIẾN:
- **Build Backend**: ~5-8 phút
- **Build Frontend**: ~3-5 phút  
- **Deploy to VPS**: ~3-5 phút
- **Total**: ~15-20 phút

## 🎯 KẾT QUẢ SAU DEPLOYMENT:

### Website URLs:
- **🌐 Main Site**: https://chodocquan.site
- **🔧 API Health**: https://chodocquan.site/api/health
- **📱 API Endpoints**: https://chodocquan.site/api/*

### Verification Commands:
```bash
# Kiểm tra website
curl -I https://chodocquan.site

# Kiểm tra API
curl https://chodocquan.site/api/health

# Kiểm tra containers
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml ps
```

## 🔧 TROUBLESHOOTING

### Nếu GitHub Actions fail:
1. Kiểm tra GitHub Secrets đã đúng chưa
2. Xem logs chi tiết trong Actions tab
3. SSH vào VPS kiểm tra disk space: `df -h`

### Nếu website không load:
```bash
# Kiểm tra containers
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml ps

# Restart nếu cần
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml restart

# Xem logs
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml logs nginx
docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml logs api
```

### Nếu SSL lỗi:
```bash
# Renew SSL
sudo certbot renew --nginx
sudo systemctl reload nginx
```

## 📈 SAU KHI DEPLOYMENT THÀNH CÔNG:

### 1. Setup Monitoring:
```bash
# Test backup system
sudo /opt/smartrestaurant/scripts/backup-database.sh

# Test health monitoring
sudo /opt/smartrestaurant/scripts/health-monitor.sh
```

### 2. Mobile App Integration:
- Update Flutter app API endpoint: `https://chodocquan.site/api`
- Test mobile app với production API

### 3. Performance Optimization:
- Setup CDN cho static files
- Database query optimization
- Cache strategies

---

## 🎊 DEPLOYMENT FLOW SUMMARY:

1. ✅ **Setup GitHub Secrets** (hiện tại)
2. 🚀 **Push code trigger deployment** 
3. 📊 **Monitor deployment progress**
4. 🎯 **Verify website live**
5. 📱 **Test mobile integration**

**Next Action**: Setup GitHub Secrets và push code! 🚀