#!/bin/bash
# SmartRestaurant Health Monitoring Script
# Runs every 5 minutes to check system health
# Usage: /opt/smartrestaurant/scripts/health-monitor.sh

set -e

# Configuration
PROJECT_DIR="/opt/smartrestaurant"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/health-monitor.log"
COMPOSE_FILE="$PROJECT_DIR/docker-compose.prod.yml"

# Vietnamese time
export TZ=Asia/Ho_Chi_Minh

# Health check URLs
API_HEALTH_URL="http://localhost/api/health"
WEB_HEALTH_URL="http://localhost/health"
SITE_URL="https://chodocquan.site"

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send alert
send_alert() {
    local message="$1"
    local severity="$2"
    
    log_message "ALERT [$severity]: $message"
    
    # Send notification if configured
    if [ -n "$NOTIFICATION_EMAIL" ] && command -v mail &> /dev/null; then
        echo "$message" | mail -s "SmartRestaurant Alert [$severity]" "$NOTIFICATION_EMAIL"
    fi
    
    # Log to system log
    logger -t "smartrestaurant-health" "[$severity] $message"
}

# Create log directory
mkdir -p "$LOG_DIR"

# Check system resources
check_system_resources() {
    log_message "=== System Resources Check ==="
    
    # CPU Usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | awk -F'%' '{print $1}')
    CPU_USAGE=${CPU_USAGE%.*}  # Remove decimal part
    
    if [ "$CPU_USAGE" -gt "$CPU_THRESHOLD" ]; then
        send_alert "High CPU usage: ${CPU_USAGE}%" "WARNING"
    else
        log_message "CPU usage: ${CPU_USAGE}% (OK)"
    fi
    
    # Memory Usage
    MEMORY_INFO=$(free | grep Mem)
    MEMORY_TOTAL=$(echo $MEMORY_INFO | awk '{print $2}')
    MEMORY_USED=$(echo $MEMORY_INFO | awk '{print $3}')
    MEMORY_USAGE=$((MEMORY_USED * 100 / MEMORY_TOTAL))
    
    if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
        send_alert "High memory usage: ${MEMORY_USAGE}% (${MEMORY_USED}KB/${MEMORY_TOTAL}KB)" "WARNING"
    else
        log_message "Memory usage: ${MEMORY_USAGE}% (OK)"
    fi
    
    # Disk Usage
    DISK_USAGE=$(df /opt | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
        send_alert "High disk usage: ${DISK_USAGE}%" "CRITICAL"
    else
        log_message "Disk usage: ${DISK_USAGE}% (OK)"
    fi
}

# Check Docker containers
check_containers() {
    log_message "=== Docker Containers Check ==="
    
    cd "$PROJECT_DIR"
    
    # Check if docker-compose file exists
    if [ ! -f "$COMPOSE_FILE" ]; then
        send_alert "Docker compose file not found: $COMPOSE_FILE" "CRITICAL"
        return 1
    fi
    
    # Get container status
    CONTAINERS_STATUS=$(docker-compose -f "$COMPOSE_FILE" ps --format "table {{.Name}}\t{{.State}}" | tail -n +2)
    
    # Check each container
    while IFS=$'\t' read -r container_name container_state; do
        if [ "$container_state" != "Up" ]; then
            send_alert "Container $container_name is $container_state" "CRITICAL"
            
            # Try to restart the container
            log_message "Attempting to restart $container_name..."
            if docker-compose -f "$COMPOSE_FILE" restart "$container_name"; then
                log_message "Successfully restarted $container_name"
            else
                send_alert "Failed to restart $container_name" "CRITICAL"
            fi
        else
            log_message "Container $container_name: $container_state (OK)"
        fi
    done <<< "$CONTAINERS_STATUS"
}

# Check application health endpoints
check_application_health() {
    log_message "=== Application Health Check ==="
    
    # Check Web Health
    if curl -f -s "$WEB_HEALTH_URL" >/dev/null; then
        log_message "Web health endpoint: OK"
    else
        send_alert "Web health endpoint failed: $WEB_HEALTH_URL" "CRITICAL"
    fi
    
    # Check API Health
    if curl -f -s "$API_HEALTH_URL" >/dev/null; then
        log_message "API health endpoint: OK"
    else
        send_alert "API health endpoint failed: $API_HEALTH_URL" "CRITICAL"
    fi
    
    # Check public site
    if curl -f -s "$SITE_URL" >/dev/null; then
        log_message "Public site: OK"
    else
        send_alert "Public site is down: $SITE_URL" "CRITICAL"
    fi
}

# Check database connectivity
check_database() {
    log_message "=== Database Health Check ==="
    
    DB_CONTAINER="smartrestaurant_postgres"
    
    if docker exec "$DB_CONTAINER" pg_isready -U postgres >/dev/null 2>&1; then
        log_message "Database connectivity: OK"
        
        # Check database size
        DB_SIZE=$(docker exec "$DB_CONTAINER" psql -U postgres -d SmartRestaurant -t -c "SELECT pg_size_pretty(pg_database_size('SmartRestaurant'));" | xargs)
        log_message "Database size: $DB_SIZE"
        
        # Check active connections
        ACTIVE_CONNECTIONS=$(docker exec "$DB_CONTAINER" psql -U postgres -d SmartRestaurant -t -c "SELECT count(*) FROM pg_stat_activity WHERE state = 'active';" | xargs)
        log_message "Active database connections: $ACTIVE_CONNECTIONS"
        
        if [ "$ACTIVE_CONNECTIONS" -gt 30 ]; then
            send_alert "High number of active database connections: $ACTIVE_CONNECTIONS" "WARNING"
        fi
    else
        send_alert "Database connectivity failed" "CRITICAL"
    fi
}

# Check SSL certificate expiration
check_ssl_certificate() {
    log_message "=== SSL Certificate Check ==="
    
    CERT_FILE="/etc/letsencrypt/live/chodocquan.site/fullchain.pem"
    
    if [ -f "$CERT_FILE" ]; then
        EXPIRY_DATE=$(openssl x509 -enddate -noout -in "$CERT_FILE" | cut -d= -f2)
        EXPIRY_TIMESTAMP=$(date -d "$EXPIRY_DATE" +%s)
        CURRENT_TIMESTAMP=$(date +%s)
        DAYS_UNTIL_EXPIRY=$(( (EXPIRY_TIMESTAMP - CURRENT_TIMESTAMP) / 86400 ))
        
        if [ "$DAYS_UNTIL_EXPIRY" -lt 30 ]; then
            send_alert "SSL certificate expires in $DAYS_UNTIL_EXPIRY days" "WARNING"
        else
            log_message "SSL certificate expires in $DAYS_UNTIL_EXPIRY days (OK)"
        fi
    else
        send_alert "SSL certificate file not found: $CERT_FILE" "WARNING"
    fi
}

# Check log file sizes
check_log_sizes() {
    log_message "=== Log Files Check ==="
    
    # Check if any log file is too large (>100MB)
    find "$LOG_DIR" -name "*.log" -size +100M | while read large_log; do
        SIZE=$(du -h "$large_log" | cut -f1)
        send_alert "Large log file detected: $large_log ($SIZE)" "WARNING"
        
        # Rotate log file
        log_message "Rotating large log file: $large_log"
        cp "$large_log" "${large_log}.old"
        > "$large_log"
    done
}

# Check backup status
check_backup_status() {
    log_message "=== Backup Status Check ==="
    
    BACKUP_DIR="$PROJECT_DIR/backups"
    LATEST_BACKUP=$(ls -t "$BACKUP_DIR"/smartrestaurant_backup_*.sql.gz 2>/dev/null | head -1)
    
    if [ -n "$LATEST_BACKUP" ]; then
        BACKUP_AGE_HOURS=$(( ($(date +%s) - $(stat -c %Y "$LATEST_BACKUP")) / 3600 ))
        
        if [ "$BACKUP_AGE_HOURS" -gt 25 ]; then  # More than 25 hours
            send_alert "Latest backup is $BACKUP_AGE_HOURS hours old" "WARNING"
        else
            log_message "Latest backup age: $BACKUP_AGE_HOURS hours (OK)"
        fi
        
        BACKUP_SIZE=$(du -h "$LATEST_BACKUP" | cut -f1)
        log_message "Latest backup size: $BACKUP_SIZE"
    else
        send_alert "No backup files found in $BACKUP_DIR" "WARNING"
    fi
}

# Main execution
main() {
    log_message "=== SmartRestaurant Health Monitor Started ==="
    
    check_system_resources
    check_containers
    check_application_health
    check_database
    check_ssl_certificate
    check_log_sizes
    check_backup_status
    
    log_message "=== Health Monitor Completed ==="
    
    # Clean up old log entries (keep last 1000 lines)
    if [ -f "$LOG_FILE" ]; then
        tail -1000 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
}

# Run the main function
main