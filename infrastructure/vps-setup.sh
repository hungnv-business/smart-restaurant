#!/bin/bash
# VPS Production Setup Script for chodocquan.site
# Run this script on your VPS as root or with sudo

set -e

echo "🚀 Starting VPS Setup for SmartRestaurant Production..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Install required packages
echo "🔧 Installing Docker, Nginx, Certbot..."
apt install -y \
    docker.io \
    docker-compose \
    nginx \
    certbot \
    python3-certbot-nginx \
    curl \
    wget \
    unzip \
    htop \
    ufw

# Enable services
echo "⚙️ Enabling services..."
systemctl enable docker
systemctl enable nginx
systemctl start docker
systemctl start nginx

# Add user to docker group
echo "👤 Configuring Docker permissions..."
usermod -aG docker $USER

# Configure firewall
echo "🔒 Configuring firewall..."
ufw --force enable
ufw allow ssh
ufw allow 'Nginx Full'
ufw allow 80
ufw allow 443

# Create application directory
echo "📁 Creating application directories..."
mkdir -p /opt/smartrestaurant
mkdir -p /opt/smartrestaurant/backups
mkdir -p /opt/smartrestaurant/logs
mkdir -p /var/www/html

# Set permissions
chown -R $USER:$USER /opt/smartrestaurant
chmod -R 755 /opt/smartrestaurant

# Setup SSL certificate for chodocquan.site
echo "🔐 Setting up SSL certificate..."
certbot --nginx -d chodocquan.site --non-interactive --agree-tos --email admin@chodocquan.site

# Setup automatic SSL renewal
echo "🔄 Setting up SSL auto-renewal..."
echo "0 12 * * * /usr/bin/certbot renew --quiet" | crontab -

# Create backup directory and script
echo "💾 Setting up backup system..."
cat > /opt/smartrestaurant/backup.sh << 'EOF'
#!/bin/bash
# Automated backup script for SmartRestaurant
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/smartrestaurant/backups"
DB_NAME="SmartRestaurant"

# Create backup directory if not exists
mkdir -p $BACKUP_DIR

# Database backup
echo "$(date): Starting database backup..." >> /opt/smartrestaurant/logs/backup.log
docker exec smartrestaurant_postgres_1 pg_dump -U postgres $DB_NAME > $BACKUP_DIR/db_backup_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/db_backup_$DATE.sql

# Keep only 7 days of backups
find $BACKUP_DIR -name "db_backup_*.sql.gz" -mtime +7 -delete

# Log completion
echo "$(date): Backup completed - db_backup_$DATE.sql.gz" >> /opt/smartrestaurant/logs/backup.log
EOF

chmod +x /opt/smartrestaurant/backup.sh

# Setup backup cron job (2AM daily)
echo "⏰ Setting up backup cron job..."
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/smartrestaurant/backup.sh") | crontab -

# Create monitoring script
cat > /opt/smartrestaurant/health-check.sh << 'EOF'
#!/bin/bash
# Health check script
LOG_FILE="/opt/smartrestaurant/logs/health.log"

# Check if containers are running
if docker-compose -f /opt/smartrestaurant/docker-compose.prod.yml ps | grep -q "Up"; then
    echo "$(date): Services are healthy" >> $LOG_FILE
else
    echo "$(date): WARNING - Some services are down" >> $LOG_FILE
    # Restart services
    cd /opt/smartrestaurant
    docker-compose -f docker-compose.prod.yml restart
fi

# Check disk space
DISK_USAGE=$(df /opt | tail -1 | awk '{print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 90 ]; then
    echo "$(date): WARNING - Disk usage is $DISK_USAGE%" >> $LOG_FILE
fi
EOF

chmod +x /opt/smartrestaurant/health-check.sh

# Setup health check cron (every 5 minutes)
(crontab -l 2>/dev/null; echo "*/5 * * * * /opt/smartrestaurant/health-check.sh") | crontab -

echo "✅ VPS Setup completed!"
echo "📍 Next steps:"
echo "1. Copy docker-compose.yml to /opt/smartrestaurant/"
echo "2. Copy nginx.conf to /etc/nginx/"
echo "3. Copy .env to /opt/smartrestaurant/.env"
echo "4. Run: cd /opt/smartrestaurant && docker-compose up -d"
echo ""
echo "🌐 Your site will be available at: https://chodocquan.site"