#!/bin/bash
# SmartRestaurant Database Backup Script
# Schedule: Daily at 2AM Vietnam time
# Usage: /opt/smartrestaurant/scripts/backup-database.sh

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="/opt/smartrestaurant"
BACKUP_DIR="$PROJECT_DIR/backups"
LOG_DIR="$PROJECT_DIR/logs"
LOG_FILE="$LOG_DIR/backup.log"

# Database configuration
DB_CONTAINER="smartrestaurant_postgres"
DB_NAME="SmartRestaurant"
DB_USER="postgres"

# Backup retention
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/smartrestaurant_backup_$DATE.sql"

# Vietnamese time
export TZ=Asia/Ho_Chi_Minh

# Function to log messages
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send notification (if configured)
send_notification() {
    local message="$1"
    local status="$2"
    
    # Log the message
    log_message "$message"
    
    # Send email notification if configured
    if command -v mail &> /dev/null && [ -n "$NOTIFICATION_EMAIL" ]; then
        echo "$message" | mail -s "SmartRestaurant Backup $status" "$NOTIFICATION_EMAIL"
    fi
}

# Create directories if they don't exist
mkdir -p "$BACKUP_DIR" "$LOG_DIR"

log_message "=== Starting SmartRestaurant database backup ==="

# Check if Docker container is running
if ! docker ps | grep -q "$DB_CONTAINER"; then
    send_notification "ERROR: PostgreSQL container $DB_CONTAINER is not running" "FAILED"
    exit 1
fi

# Check available disk space (warn if less than 1GB)
AVAILABLE_SPACE=$(df "$BACKUP_DIR" | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_SPACE" -lt 1048576 ]; then  # Less than 1GB in KB
    send_notification "WARNING: Low disk space. Available: ${AVAILABLE_SPACE}KB" "WARNING"
fi

# Perform database backup
log_message "Creating database backup: $BACKUP_FILE"

if docker exec "$DB_CONTAINER" pg_dump -U "$DB_USER" -d "$DB_NAME" --no-owner --no-privileges > "$BACKUP_FILE"; then
    # Compress the backup
    log_message "Compressing backup file..."
    gzip "$BACKUP_FILE"
    COMPRESSED_BACKUP="$BACKUP_FILE.gz"
    
    # Check backup file size
    BACKUP_SIZE=$(du -h "$COMPRESSED_BACKUP" | cut -f1)
    log_message "Backup completed successfully. Size: $BACKUP_SIZE"
    
    # Verify backup integrity
    log_message "Verifying backup integrity..."
    if gunzip -t "$COMPRESSED_BACKUP" 2>/dev/null; then
        log_message "Backup integrity verified successfully"
        
        # Create a quick restore test (optional)
        log_message "Performing quick restore test..."
        TEST_DB="smartrestaurant_test_$(date +%s)"
        
        if docker exec "$DB_CONTAINER" createdb -U "$DB_USER" "$TEST_DB" 2>/dev/null && \
           gunzip -c "$COMPRESSED_BACKUP" | docker exec -i "$DB_CONTAINER" psql -U "$DB_USER" -d "$TEST_DB" >/dev/null 2>&1; then
            log_message "Restore test successful"
            docker exec "$DB_CONTAINER" dropdb -U "$DB_USER" "$TEST_DB" 2>/dev/null || true
        else
            log_message "WARNING: Restore test failed, but backup file is valid"
            docker exec "$DB_CONTAINER" dropdb -U "$DB_USER" "$TEST_DB" 2>/dev/null || true
        fi
        
        send_notification "Database backup completed successfully. Size: $BACKUP_SIZE, File: $(basename $COMPRESSED_BACKUP)" "SUCCESS"
    else
        send_notification "ERROR: Backup file is corrupted" "FAILED"
        rm -f "$COMPRESSED_BACKUP"
        exit 1
    fi
else
    send_notification "ERROR: Database backup failed" "FAILED"
    rm -f "$BACKUP_FILE" 2>/dev/null || true
    exit 1
fi

# Clean up old backups
log_message "Cleaning up backups older than $RETENTION_DAYS days..."
DELETED_COUNT=$(find "$BACKUP_DIR" -name "smartrestaurant_backup_*.sql.gz" -mtime +$RETENTION_DAYS -delete -print | wc -l)
if [ "$DELETED_COUNT" -gt 0 ]; then
    log_message "Deleted $DELETED_COUNT old backup files"
else
    log_message "No old backup files to delete"
fi

# Display current backup files
log_message "Current backup files:"
ls -lh "$BACKUP_DIR"/smartrestaurant_backup_*.sql.gz 2>/dev/null | while read line; do
    log_message "  $line"
done

# Calculate total backup size
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
log_message "Total backup directory size: $TOTAL_SIZE"

log_message "=== Backup process completed ==="

# Optional: Upload to cloud storage (uncomment if needed)
# upload_to_cloud() {
#     log_message "Uploading backup to cloud storage..."
#     # Example for AWS S3:
#     # aws s3 cp "$COMPRESSED_BACKUP" s3://your-backup-bucket/smartrestaurant/
#     # Example for Google Cloud:
#     # gsutil cp "$COMPRESSED_BACKUP" gs://your-backup-bucket/smartrestaurant/
# }
# upload_to_cloud

exit 0