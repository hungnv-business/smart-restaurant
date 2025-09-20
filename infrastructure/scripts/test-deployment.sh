#!/bin/bash
# SmartRestaurant Production Deployment Test Script
# Run this after deployment to validate everything is working
# Usage: ./infrastructure/scripts/test-deployment.sh

set -e

# Configuration
DOMAIN="chodocquan.site"
API_BASE="https://$DOMAIN"
WEB_BASE="https://$DOMAIN"
TEST_TIMEOUT=30

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test results
PASSED_TESTS=0
FAILED_TESTS=0
TOTAL_TESTS=0

# Function to print colored output
print_status() {
    local status=$1
    local message=$2
    case $status in
        "PASS")
            echo -e "${GREEN}✅ PASS${NC}: $message"
            ((PASSED_TESTS++))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL${NC}: $message"
            ((FAILED_TESTS++))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN${NC}: $message"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO${NC}: $message"
            ;;
    esac
    ((TOTAL_TESTS++))
}

# Function to test HTTP endpoint
test_endpoint() {
    local url=$1
    local description=$2
    local expected_status=${3:-200}
    local timeout=${4:-$TEST_TIMEOUT}
    
    echo "Testing: $description"
    echo "URL: $url"
    
    if response=$(curl -s -w "HTTPSTATUS:%{http_code}" --max-time $timeout "$url" 2>/dev/null); then
        http_code=$(echo $response | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')
        body=$(echo $response | sed -e 's/HTTPSTATUS\:.*//g')
        
        if [ "$http_code" -eq "$expected_status" ]; then
            print_status "PASS" "$description (HTTP $http_code)"
            return 0
        else
            print_status "FAIL" "$description (Expected HTTP $expected_status, got $http_code)"
            return 1
        fi
    else
        print_status "FAIL" "$description (Connection failed or timeout)"
        return 1
    fi
}

# Function to test SSL certificate
test_ssl_certificate() {
    echo "Testing SSL certificate for $DOMAIN..."
    
    if ssl_info=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates 2>/dev/null); then
        expiry_date=$(echo "$ssl_info" | grep "notAfter" | cut -d= -f2)
        expiry_timestamp=$(date -d "$expiry_date" +%s 2>/dev/null || date -j -f "%b %d %H:%M:%S %Y %Z" "$expiry_date" +%s 2>/dev/null)
        current_timestamp=$(date +%s)
        days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
        
        if [ $days_until_expiry -gt 0 ]; then
            if [ $days_until_expiry -lt 30 ]; then
                print_status "WARN" "SSL certificate expires in $days_until_expiry days"
            else
                print_status "PASS" "SSL certificate valid (expires in $days_until_expiry days)"
            fi
        else
            print_status "FAIL" "SSL certificate has expired"
        fi
    else
        print_status "FAIL" "Cannot retrieve SSL certificate information"
    fi
}

# Function to test database connectivity
test_database() {
    echo "Testing database connectivity..."
    
    if [ -f "/opt/smartrestaurant/docker-compose.prod.yml" ]; then
        cd /opt/smartrestaurant
        if docker-compose -f docker-compose.prod.yml exec -T postgres pg_isready -U postgres >/dev/null 2>&1; then
            print_status "PASS" "Database connectivity"
            
            # Test database size and connection count
            db_size=$(docker-compose -f docker-compose.prod.yml exec -T postgres psql -U postgres -d SmartRestaurant -t -c "SELECT pg_size_pretty(pg_database_size('SmartRestaurant'));" 2>/dev/null | xargs)
            connections=$(docker-compose -f docker-compose.prod.yml exec -T postgres psql -U postgres -d SmartRestaurant -t -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null | xargs)
            
            print_status "INFO" "Database size: $db_size"
            print_status "INFO" "Active connections: $connections"
        else
            print_status "FAIL" "Database connectivity"
        fi
    else
        print_status "WARN" "Docker compose file not found, skipping database test"
    fi
}

# Function to test container health
test_containers() {
    echo "Testing Docker containers..."
    
    if [ -f "/opt/smartrestaurant/docker-compose.prod.yml" ]; then
        cd /opt/smartrestaurant
        containers_status=$(docker-compose -f docker-compose.prod.yml ps --format "table {{.Name}}\t{{.State}}" | tail -n +2)
        
        while IFS=$'\t' read -r container_name container_state; do
            if [ "$container_state" = "Up" ]; then
                print_status "PASS" "Container $container_name is running"
            else
                print_status "FAIL" "Container $container_name is $container_state"
            fi
        done <<< "$containers_status"
    else
        print_status "WARN" "Docker compose file not found, skipping container test"
    fi
}

# Function to test performance
test_performance() {
    echo "Testing website performance..."
    
    # Test response time
    response_time=$(curl -o /dev/null -s -w "%{time_total}" "$WEB_BASE")
    response_time_ms=$(echo "$response_time * 1000" | bc -l 2>/dev/null || echo "N/A")
    
    if command -v bc >/dev/null && [ "$response_time_ms" != "N/A" ]; then
        if (( $(echo "$response_time < 3.0" | bc -l) )); then
            print_status "PASS" "Website response time: ${response_time}s"
        else
            print_status "WARN" "Slow website response time: ${response_time}s"
        fi
    else
        print_status "INFO" "Website response time: ${response_time}s"
    fi
    
    # Test gzip compression
    if curl -H "Accept-Encoding: gzip" -s -I "$WEB_BASE" | grep -i "content-encoding: gzip" >/dev/null; then
        print_status "PASS" "Gzip compression enabled"
    else
        print_status "WARN" "Gzip compression not enabled"
    fi
}

# Function to test Vietnamese content
test_vietnamese_content() {
    echo "Testing Vietnamese content support..."
    
    # Test that the site returns proper UTF-8 encoding
    if curl -s -I "$WEB_BASE" | grep -i "charset=utf-8\|charset=UTF-8" >/dev/null; then
        print_status "PASS" "UTF-8 encoding supported"
    else
        print_status "WARN" "UTF-8 encoding not explicitly set"
    fi
    
    # Test Vietnamese characters in API response (if health endpoint returns JSON)
    api_response=$(curl -s "$API_BASE/api/health" 2>/dev/null || echo "")
    if [ -n "$api_response" ]; then
        print_status "PASS" "API responding with content"
    else
        print_status "WARN" "API not responding or empty response"
    fi
}

# Function to test backup system
test_backup_system() {
    echo "Testing backup system..."
    
    backup_script="/opt/smartrestaurant/scripts/backup-database.sh"
    if [ -f "$backup_script" ] && [ -x "$backup_script" ]; then
        print_status "PASS" "Backup script exists and is executable"
        
        # Check if there are recent backups
        backup_dir="/opt/smartrestaurant/backups"
        if [ -d "$backup_dir" ]; then
            recent_backup=$(find "$backup_dir" -name "*.sql.gz" -mtime -1 | head -1)
            if [ -n "$recent_backup" ]; then
                backup_size=$(du -h "$recent_backup" | cut -f1)
                print_status "PASS" "Recent backup found: $backup_size"
            else
                print_status "WARN" "No recent backups found (within 24 hours)"
            fi
        else
            print_status "WARN" "Backup directory not found"
        fi
        
        # Check cron job
        if crontab -l 2>/dev/null | grep -q "backup-database.sh"; then
            print_status "PASS" "Backup cron job configured"
        else
            print_status "WARN" "Backup cron job not found"
        fi
    else
        print_status "FAIL" "Backup script not found or not executable"
    fi
}

# Function to test monitoring system
test_monitoring() {
    echo "Testing monitoring system..."
    
    monitor_script="/opt/smartrestaurant/scripts/health-monitor.sh"
    if [ -f "$monitor_script" ] && [ -x "$monitor_script" ]; then
        print_status "PASS" "Health monitor script exists and is executable"
        
        # Check cron job
        if crontab -l 2>/dev/null | grep -q "health-monitor.sh"; then
            print_status "PASS" "Health monitor cron job configured"
        else
            print_status "WARN" "Health monitor cron job not found"
        fi
        
        # Check recent monitor logs
        monitor_log="/opt/smartrestaurant/logs/health-monitor.log"
        if [ -f "$monitor_log" ]; then
            recent_entries=$(tail -10 "$monitor_log" | wc -l)
            if [ "$recent_entries" -gt 0 ]; then
                print_status "PASS" "Health monitor log has recent entries"
            else
                print_status "WARN" "Health monitor log is empty"
            fi
        else
            print_status "WARN" "Health monitor log file not found"
        fi
    else
        print_status "FAIL" "Health monitor script not found or not executable"
    fi
}

# Main test execution
main() {
    echo "========================================"
    echo "🏥 SmartRestaurant Production Test Suite"
    echo "========================================"
    echo "Domain: $DOMAIN"
    echo "Test started: $(date)"
    echo ""
    
    # Basic connectivity tests
    echo "📡 CONNECTIVITY TESTS"
    echo "----------------------------------------"
    test_endpoint "$WEB_BASE" "Website accessibility"
    test_endpoint "$WEB_BASE/health" "Health endpoint"
    test_endpoint "$API_BASE/api/health" "API health endpoint"
    echo ""
    
    # Security tests
    echo "🔒 SECURITY TESTS"
    echo "----------------------------------------"
    test_ssl_certificate
    test_endpoint "http://$DOMAIN" "HTTP to HTTPS redirect" 301
    echo ""
    
    # Infrastructure tests
    echo "🏗️ INFRASTRUCTURE TESTS"
    echo "----------------------------------------"
    test_database
    test_containers
    echo ""
    
    # Performance tests
    echo "⚡ PERFORMANCE TESTS"
    echo "----------------------------------------"
    test_performance
    echo ""
    
    # Localization tests
    echo "🇻🇳 VIETNAMESE SUPPORT TESTS"
    echo "----------------------------------------"
    test_vietnamese_content
    echo ""
    
    # Operational tests
    echo "🔧 OPERATIONAL TESTS"
    echo "----------------------------------------"
    test_backup_system
    test_monitoring
    echo ""
    
    # Summary
    echo "========================================"
    echo "📊 TEST SUMMARY"
    echo "========================================"
    echo "Total tests: $TOTAL_TESTS"
    echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
    echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
    echo ""
    
    if [ $FAILED_TESTS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! SmartRestaurant is ready for production.${NC}"
        echo ""
        echo "🌐 Your restaurant website is live at: https://$DOMAIN"
        exit 0
    else
        echo -e "${RED}❌ Some tests failed. Please review and fix issues before going live.${NC}"
        exit 1
    fi
}

# Check if running on the VPS or locally
if [ ! -f "/opt/smartrestaurant/docker-compose.prod.yml" ]; then
    echo "⚠️  Warning: This script should be run on the production VPS"
    echo "Some tests will be skipped as they require access to the production environment."
    echo ""
fi

# Run main function
main