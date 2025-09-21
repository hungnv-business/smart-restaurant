#!/bin/bash
# SmartRestaurant Server Upgrade Script
# Run this after upgrading VPS specifications
# Usage: ./infrastructure/scripts/upgrade-server.sh

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 SmartRestaurant Server Upgrade Optimizer${NC}"
echo "=================================================="

# Detect current system specs
TOTAL_RAM_MB=$(free -m | awk 'NR==2{print $2}')
TOTAL_RAM_GB=$((TOTAL_RAM_MB / 1024))
CPU_CORES=$(nproc)
DISK_SPACE_GB=$(df / | awk 'NR==2 {print int($2/1024/1024)}')

echo -e "${YELLOW}📊 Current System Specifications:${NC}"
echo "  RAM: ${TOTAL_RAM_GB}GB (${TOTAL_RAM_MB}MB)"
echo "  CPU Cores: ${CPU_CORES}"
echo "  Disk Space: ${DISK_SPACE_GB}GB"
echo ""

# Determine optimal configuration
determine_config() {
    if [ $TOTAL_RAM_GB -ge 8 ]; then
        CONFIG_PROFILE="high-performance"
        API_MEMORY="2G"
        API_CPU="2.0"
        POSTGRES_MEMORY="2G"
        POSTGRES_CPU="1.5"
        SHARED_BUFFERS="512MB"
        EFFECTIVE_CACHE="6GB"
        MAX_CONNECTIONS="200"
        WORKER_CONNECTIONS="2048"
        GC_HEAP_LIMIT="1600000000"
    elif [ $TOTAL_RAM_GB -ge 4 ]; then
        CONFIG_PROFILE="medium-performance"
        API_MEMORY="1G"
        API_CPU="1.5"
        POSTGRES_MEMORY="1G"
        POSTGRES_CPU="1.0"
        SHARED_BUFFERS="256MB"
        EFFECTIVE_CACHE="3GB"
        MAX_CONNECTIONS="100"
        WORKER_CONNECTIONS="1024"
        GC_HEAP_LIMIT="800000000"
    else
        CONFIG_PROFILE="basic"
        API_MEMORY="450M"
        API_CPU="0.7"
        POSTGRES_MEMORY="350M"
        POSTGRES_CPU="0.5"
        SHARED_BUFFERS="80MB"
        EFFECTIVE_CACHE="200MB"
        MAX_CONNECTIONS="40"
        WORKER_CONNECTIONS="1024"
        GC_HEAP_LIMIT="400000000"
    fi
    
    echo -e "${GREEN}✅ Selected Profile: ${CONFIG_PROFILE}${NC}"
    echo ""
}

# Update Docker Compose configuration
update_docker_compose() {
    echo -e "${YELLOW}🐳 Updating Docker Compose configuration...${NC}"
    
    COMPOSE_FILE="/opt/smartrestaurant/docker-compose.prod.yml"
    BACKUP_FILE="/opt/smartrestaurant/docker-compose.prod.yml.backup.$(date +%Y%m%d_%H%M%S)"
    
    # Backup current config
    cp "$COMPOSE_FILE" "$BACKUP_FILE"
    echo "  📦 Backup created: $BACKUP_FILE"
    
    # Update API service
    sed -i "s/memory: [0-9]*[MG]/memory: $API_MEMORY/g" "$COMPOSE_FILE"
    sed -i "s/cpus: '[0-9.]*'/cpus: '$API_CPU'/g" "$COMPOSE_FILE"
    
    # Update PostgreSQL service  
    sed -i "/postgres:/,/^  [a-z]/ s/memory: [0-9]*[MG]/memory: $POSTGRES_MEMORY/" "$COMPOSE_FILE"
    sed -i "/postgres:/,/^  [a-z]/ s/cpus: '[0-9.]*'/cpus: '$POSTGRES_CPU'/" "$COMPOSE_FILE"
    
    # Update PostgreSQL command parameters
    sed -i "s/shared_buffers=[0-9]*MB/shared_buffers=$SHARED_BUFFERS/g" "$COMPOSE_FILE"
    sed -i "s/effective_cache_size=[0-9]*[MG]B/effective_cache_size=$EFFECTIVE_CACHE/g" "$COMPOSE_FILE"
    sed -i "s/max_connections=[0-9]*/max_connections=$MAX_CONNECTIONS/g" "$COMPOSE_FILE"
    
    
    echo -e "${GREEN}  ✅ Docker Compose updated${NC}"
}

# Update Nginx configuration
update_nginx_config() {
    echo -e "${YELLOW}🌐 Updating Nginx configuration...${NC}"
    
    NGINX_FILE="/opt/smartrestaurant/nginx.prod.conf"
    
    # Update worker connections
    sed -i "s/worker_connections [0-9]*/worker_connections $WORKER_CONNECTIONS/g" "$NGINX_FILE"
    
    echo -e "${GREEN}  ✅ Nginx configuration updated${NC}"
}

# Update environment variables
update_environment() {
    echo -e "${YELLOW}⚙️ Updating environment variables...${NC}"
    
    ENV_FILE="/opt/smartrestaurant/.env"
    
    # Update .NET GC settings
    if grep -q "DOTNET_GCHeapHardLimit" "$ENV_FILE"; then
        sed -i "s/DOTNET_GCHeapHardLimit=[0-9]*/DOTNET_GCHeapHardLimit=$GC_HEAP_LIMIT/g" "$ENV_FILE"
    else
        echo "DOTNET_GCHeapHardLimit=$GC_HEAP_LIMIT" >> "$ENV_FILE"
    fi
    
    echo -e "${GREEN}  ✅ Environment variables updated${NC}"
}

# Update monitoring thresholds
update_monitoring() {
    echo -e "${YELLOW}📊 Updating monitoring thresholds...${NC}"
    
    MONITOR_SCRIPT="/opt/smartrestaurant/scripts/health-monitor.sh"
    
    # Calculate dynamic thresholds
    if [ $TOTAL_RAM_GB -ge 8 ]; then
        MEMORY_THRESHOLD=90
        CPU_THRESHOLD=85
    elif [ $TOTAL_RAM_GB -ge 4 ]; then
        MEMORY_THRESHOLD=85
        CPU_THRESHOLD=80
    else
        MEMORY_THRESHOLD=85
        CPU_THRESHOLD=80
    fi
    
    # Update thresholds in monitoring script
    sed -i "s/MEMORY_THRESHOLD=[0-9]*/MEMORY_THRESHOLD=$MEMORY_THRESHOLD/g" "$MONITOR_SCRIPT"
    sed -i "s/CPU_THRESHOLD=[0-9]*/CPU_THRESHOLD=$CPU_THRESHOLD/g" "$MONITOR_SCRIPT"
    
    echo -e "${GREEN}  ✅ Monitoring thresholds updated${NC}"
}

# Gracefully restart services
restart_services() {
    echo -e "${YELLOW}🔄 Restarting services with new configuration...${NC}"
    
    cd /opt/smartrestaurant
    
    # Create backup before restart
    echo "  📦 Creating database backup before restart..."
    ./scripts/backup-database.sh
    
    # Graceful restart
    echo "  ⏹️ Stopping services..."
    docker-compose -f docker-compose.prod.yml down --timeout 30
    
    echo "  🚀 Starting services with new configuration..."
    docker-compose -f docker-compose.prod.yml up -d
    
    # Wait for services to be ready
    echo "  ⏳ Waiting for services to start..."
    sleep 30
    
    # Health check
    echo "  🔍 Running health checks..."
    if ./scripts/test-deployment.sh; then
        echo -e "${GREEN}  ✅ Services restarted successfully${NC}"
    else
        echo -e "⚠️ Some health checks failed. Check logs for details."
    fi
}

# Performance recommendations
show_recommendations() {
    echo ""
    echo -e "${BLUE}📋 Performance Recommendations for ${CONFIG_PROFILE}:${NC}"
    echo "=================================================="
    
    if [ "$CONFIG_PROFILE" = "high-performance" ]; then
        echo "🎯 Consider implementing:"
        echo "  • Load balancing with multiple API instances"
        echo "  • Database connection pooling"
        echo "  • CDN for static assets"
        echo "  • Read replicas for database"
    elif [ "$CONFIG_PROFILE" = "medium-performance" ]; then
        echo "🎯 Consider implementing:"
        echo "  • API response caching"
        echo "  • Database query optimization"
        echo "  • Static file compression"
    else
        echo "🎯 Current configuration is optimal for this server size"
    fi
    
    echo ""
    echo "📊 New Resource Allocation:"
    echo "  • API Service: $API_MEMORY (CPU: $API_CPU cores)"
    echo "  • PostgreSQL: $POSTGRES_MEMORY (CPU: $POSTGRES_CPU cores)"
    echo "  • Nginx: 64MB (CPU: 0.2 cores)"
    echo ""
}

# Check if we're on the production server
check_environment() {
    if [ ! -f "/opt/smartrestaurant/docker-compose.prod.yml" ]; then
        echo "❌ This script must be run on the production server"
        echo "Expected location: /opt/smartrestaurant/"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Production environment detected${NC}"
}

# Main execution
main() {
    check_environment
    determine_config
    
    echo -e "${YELLOW}🔧 Starting server upgrade optimization...${NC}"
    echo ""
    
    update_docker_compose
    update_nginx_config
    update_environment
    update_monitoring
    
    echo ""
    echo -e "${YELLOW}Ready to restart services with new configuration?${NC}"
    read -p "Continue? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        restart_services
        show_recommendations
        
        echo ""
        echo -e "${GREEN}🎉 Server upgrade optimization completed!${NC}"
        echo "Your SmartRestaurant is now optimized for the new server specs."
        echo ""
        echo "Monitor the system for the next 24 hours and check:"
        echo "  • /opt/smartrestaurant/logs/health-monitor.log"
        echo "  • docker stats"
        echo "  • Performance at https://chodocquan.site"
    else
        echo "Upgrade cancelled. No changes were applied to running services."
    fi
}

# Run main function
main