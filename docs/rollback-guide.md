# SmartRestaurant Rollback Guide

## 🔄 Automatic Rollback Mechanism

SmartRestaurant deployment workflow có tích hợp automatic rollback mechanism để đảm bảo zero-downtime deployment và nhanh chóng khôi phục khi có lỗi.

## 🏗️ Cách hoạt động

### 1. **Backup Phase**
Trước mỗi deployment, hệ thống tự động tạo:
- ✅ Backup toàn bộ application files
- ✅ Backup database (PostgreSQL dump)
- ✅ Backup Docker images hiện tại
- ✅ Backup configuration files

### 2. **Health Check Phase**
Sau khi deploy version mới, hệ thống kiểm tra:
- ✅ Container startup status
- ✅ Nginx health endpoint
- ✅ API health endpoint
- ✅ Database connectivity

### 3. **Automatic Rollback Triggers**
Rollback sẽ được kích hoạt khi:
- ❌ Containers không start được
- ❌ Nginx health check fail
- ❌ API health check fail (timeout 60s)
- ❌ Database connection error

### 4. **Rollback Process**
Khi có lỗi, hệ thống tự động:
1. 🛑 Stop các services mới
2. 📦 Restore application files từ backup
3. 🐳 Restore Docker images
4. 🗄️ Restore database từ backup
5. 🚀 Start lại services với version cũ
6. 🔍 Verify health checks
7. 📢 Send notification về kết quả

## 🎯 Các trường hợp Rollback

| Trường hợp | Rollback Result | Downtime |
|------------|-----------------|----------|
| ✅ Rollback thành công | Previous version restored | ~2-5 phút |
| ❌ Rollback thất bại | Manual intervention required | Tùy thuộc admin |
| 🔄 External health check fail | Rollback + alert | ~3-7 phút |

## 🛠️ Manual Rollback

### Sử dụng script tự động
```bash
# List available backups
./scripts/rollback.sh list

# Rollback to latest backup
./scripts/rollback.sh latest

# Rollback to specific backup
./scripts/rollback.sh rollback /opt/smartrestaurant.backup.20231201_140530
```

### Manual rollback steps
```bash
# 1. SSH vào VPS
ssh user@your-vps

# 2. Stop current services
cd /opt/smartrestaurant
sudo docker-compose -f docker-compose.prod.yml down

# 3. Find available backups
sudo find /opt -name "smartrestaurant.backup.*" -type d | sort -r

# 4. Restore from backup
sudo rm -rf /opt/smartrestaurant
sudo cp -r /opt/smartrestaurant.backup.YYYYMMDD_HHMMSS /opt/smartrestaurant
cd /opt/smartrestaurant

# 5. Restore Docker images (if available)
sudo docker load < api_image_backup.tar

# 6. Restore database (if available)
sudo docker-compose -f docker-compose.prod.yml up postgres -d
sleep 10
sudo docker exec smartrestaurant-postgres-1 psql -U postgres -d SmartRestaurant < database_backup.sql

# 7. Start all services
sudo docker-compose -f docker-compose.prod.yml up -d

# 8. Verify health
curl -f https://chodocquan.site/health
curl -f https://chodocquan.site/api/health
```

## 🧪 Testing Rollback Mechanism

### Automated Testing
Sử dụng workflow `test-rollback.yml`:
```bash
# Từ GitHub Actions, trigger workflow:
# - test-rollback.yml
# - Chọn test scenario: api_failure, nginx_failure, container_failure, database_failure
# - Environment: development (bắt buộc cho safety)
```

### Manual Testing (Development only)
```bash
# 1. Backup current state
sudo cp -r /opt/smartrestaurant /opt/smartrestaurant.test.backup

# 2. Break something intentionally
# For API failure:
sed -i 's/smartrestaurant\/api:latest/nonexistent\/api:broken/g' docker-compose.prod.yml

# For nginx failure:
echo "invalid_config" >> nginx.conf

# For database failure:
sed -i 's/DB_PASSWORD=.*/DB_PASSWORD=wrong/g' .env

# 3. Try deployment
sudo docker-compose -f docker-compose.prod.yml up -d

# 4. Should trigger rollback automatically

# 5. Cleanup
sudo rm -rf /opt/smartrestaurant
sudo mv /opt/smartrestaurant.test.backup /opt/smartrestaurant
```

## 📊 Monitoring & Alerts

### GitHub Actions Notifications
- ✅ **Success**: "🎉 Deployment successful! All services healthy."
- 🔄 **Rollback**: "🔄 Deployment failed but rollback successful."
- ❌ **Failed**: "❌ Both deployment and rollback failed. Manual intervention required!"

### Log Monitoring
```bash
# Check deployment logs
sudo docker-compose -f docker-compose.prod.yml logs

# Check backup status
ls -la /opt/smartrestaurant.backup.*

# Check health endpoints
curl -f https://chodocquan.site/health
curl -f https://chodocquan.site/api/health
```

## 🚨 Emergency Procedures

### Khi Rollback tự động thất bại
1. **Immediate Response**:
   ```bash
   # Connect to VPS
   ssh user@your-vps
   
   # Check container status
   sudo docker ps -a
   
   # Check available backups
   sudo ls -la /opt/smartrestaurant.backup.*
   ```

2. **Manual Recovery**:
   ```bash
   # Use rollback script
   ./scripts/rollback.sh latest
   
   # Or manual restore (see manual rollback steps above)
   ```

3. **If all fails**:
   - Contact system administrator
   - Check database integrity
   - Consider restoring from external backup
   - Communicate with stakeholders

### Backup Retention Policy
- 🗂️ **Local backups**: Keep last 5 deployment backups
- 📅 **Cleanup**: Old backups auto-deleted during deployment
- 💾 **External backups**: Consider regular DB dumps to external storage

## 🔧 Configuration

### Required Environment Variables
```bash
# Production VPS
VPS_HOST=your-production-server
VPS_USER=deployment-user
VPS_SSH_KEY=your-ssh-private-key
VPS_PORT=22 (optional)

# Database
DB_PASSWORD=your-db-password
JWT_SECRET=your-jwt-secret
```

### Health Check Endpoints
- **Main site**: `https://chodocquan.site/health`
- **API**: `https://chodocquan.site/api/health`
- **Local checks**: `http://localhost/health`, `http://localhost/api/health`

## 📝 Best Practices

### Before Deployment
- ✅ Ensure CI tests pass
- ✅ Test in development environment first
- ✅ Check backup disk space
- ✅ Verify external dependencies

### During Deployment
- 👀 Monitor GitHub Actions logs
- 📱 Be ready for manual intervention if needed
- 🕐 Deploy during low-traffic hours when possible

### After Deployment
- ✅ Verify external health checks
- 📊 Monitor application metrics
- 🗂️ Confirm backup created successfully
- 📢 Communicate deployment status to team

## 🆘 Support

### When to Use Manual Rollback
- ❌ Automatic rollback failed
- 🐛 Issues discovered after deployment
- 📈 Performance degradation detected
- 🚨 Security incidents

### Getting Help
- 📖 Check this documentation
- 🔍 Review GitHub Actions logs
- 📞 Contact development team
- 🛠️ Use manual rollback script

---

**⚠️ Important**: Always test rollback procedures in development environment before production deployment.

**🔒 Security Note**: Ensure SSH keys and secrets are properly secured and rotated regularly.