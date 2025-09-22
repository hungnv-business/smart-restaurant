#!/bin/bash

# SmartRestaurant Manual Rollback Script
# Sử dụng khi cần rollback manual hoặc emergency rollback

set -e

echo "🚨 SmartRestaurant Emergency Rollback Script"
echo "============================================"

# Check if running as root or with sudo access
if [[ $EUID -eq 0 ]]; then
    SUDO=""
else
    SUDO="sudo"
fi

# Function to list available backups
list_backups() {
    echo "📋 Available backups:"
    if [ -d "/opt" ]; then
        $SUDO find /opt -maxdepth 1 -name "smartrestaurant.backup.*" -type d | sort -r | head -10
    else
        echo "❌ No backup directory found"
        exit 1
    fi
}

# Function to rollback to specific backup
rollback_to_backup() {
    local backup_dir="$1"
    
    if [ ! -d "$backup_dir" ]; then
        echo "❌ Backup directory not found: $backup_dir"
        exit 1
    fi
    
    echo "🔄 Rolling back to: $backup_dir"
    
    # Stop current services
    echo "⏹️ Stopping current services..."
    cd /opt/smartrestaurant
    $SUDO docker-compose -f docker-compose.prod.yml down --timeout 30 2>/dev/null || true
    
    # Backup current state (in case we need to rollback the rollback)
    current_backup="/opt/smartrestaurant.rollback.$(date +%Y%m%d_%H%M%S)"
    if [ -d "/opt/smartrestaurant" ]; then
        echo "💾 Creating emergency backup of current state..."
        $SUDO cp -r /opt/smartrestaurant "$current_backup"
        echo "📁 Current state backed up to: $current_backup"
    fi
    
    # Restore from backup
    echo "📥 Restoring application from backup..."
    $SUDO rm -rf /opt/smartrestaurant
    $SUDO cp -r "$backup_dir" /opt/smartrestaurant
    cd /opt/smartrestaurant
    
    # Restore Docker images
    if [ -f "api_image_backup.tar" ]; then
        echo "🐳 Restoring Docker images..."
        $SUDO docker load < api_image_backup.tar
    fi
    
    # Restore database
    if [ -f "database_backup.sql" ]; then
        echo "🗄️ Restoring database..."
        
        # Start only postgres for database restore
        $SUDO docker-compose -f docker-compose.prod.yml up postgres -d
        sleep 15
        
        # Restore database
        $SUDO docker exec smartrestaurant-postgres-1 dropdb -U postgres SmartRestaurant --if-exists
        $SUDO docker exec smartrestaurant-postgres-1 createdb -U postgres SmartRestaurant
        $SUDO docker exec -i smartrestaurant-postgres-1 psql -U postgres -d SmartRestaurant < database_backup.sql
        
        echo "✅ Database restored successfully"
    fi
    
    # Start all services
    echo "🚀 Starting restored services..."
    $SUDO docker-compose -f docker-compose.prod.yml up -d
    
    # Wait for services
    echo "⏳ Waiting for services to start..."
    sleep 30
    
    # Health check
    echo "🔍 Performing health checks..."
    
    # Check containers
    if ! $SUDO docker-compose -f docker-compose.prod.yml ps | grep -q "Up"; then
        echo "❌ Some containers failed to start"
        $SUDO docker-compose -f docker-compose.prod.yml logs
        return 1
    fi
    
    # Check nginx
    if ! curl -f http://localhost/health 2>/dev/null; then
        echo "❌ Nginx health check failed"
        return 1
    fi
    
    # Check API
    if ! timeout 60 bash -c 'until curl -f http://localhost/api/health 2>/dev/null; do sleep 5; done'; then
        echo "❌ API health check failed"
        return 1
    fi
    
    echo "✅ Rollback completed successfully!"
    echo "🌐 SmartRestaurant is available at: https://chodocquan.site"
    
    # Show final status
    echo "📊 Service status:"
    $SUDO docker-compose -f docker-compose.prod.yml ps
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [COMMAND] [OPTIONS]"
    echo ""
    echo "Commands:"
    echo "  list                    - List available backups"
    echo "  rollback [backup_path]  - Rollback to specific backup"
    echo "  latest                  - Rollback to latest backup"
    echo "  help                    - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 list"
    echo "  $0 latest"
    echo "  $0 rollback /opt/smartrestaurant.backup.20231201_140530"
}

# Main execution
case "${1:-help}" in
    "list")
        list_backups
        ;;
    "latest")
        latest_backup=$($SUDO find /opt -maxdepth 1 -name "smartrestaurant.backup.*" -type d | sort -r | head -1)
        if [ -n "$latest_backup" ]; then
            echo "🔄 Rolling back to latest backup: $latest_backup"
            rollback_to_backup "$latest_backup"
        else
            echo "❌ No backups found"
            exit 1
        fi
        ;;
    "rollback")
        if [ -z "$2" ]; then
            echo "❌ Backup path required"
            echo "Use '$0 list' to see available backups"
            exit 1
        fi
        rollback_to_backup "$2"
        ;;
    "help"|*)
        show_usage
        ;;
esac