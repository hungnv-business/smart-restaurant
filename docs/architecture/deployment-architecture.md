# Deployment Architecture

## Deployment Strategy (Chiến lược Triển khai)

**Frontend Deployment:**
- **Platform:** Nginx static file serving on VPS
- **Build Command:** `cd angular && npm run build:prod`
- **Output Directory:** `angular/dist/`
- **CDN/Edge:** Nginx with gzip compression and caching headers

**Backend Deployment:**
- **Platform:** Docker container on VPS
- **Build Command:** `cd aspnet-core && dotnet publish -c Release`
- **Deployment Method:** Docker container with health checks

## CI/CD Pipeline (Đường ống CI/CD)

**Comprehensive GitHub Actions Workflow for ABP Framework Deployment (Quy trình GitHub Actions toàn diện cho triển khai ABP Framework)**

The CI/CD pipeline is designed specifically for ABP Framework applications with automated testing, multi-environment configuration, and VPS deployment automation (Đường ống CI/CD được thiết kế đặc biệt cho ứng dụng ABP Framework với kiểm thử tự động, cấu hình đa môi trường và tự động hóa triển khai VPS).

### Main Deployment Workflow (Quy trình Triển khai Chính)

```yaml
# .github/workflows/deploy.yaml
name: Deploy Smart Restaurant to VPS

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  DOTNET_VERSION: '8.0.x'
  NODE_VERSION: '18'
  REGISTRY: ghcr.io
  IMAGE_NAME: smart-restaurant

jobs:
  test:
    name: Run Tests
    runs-on: ubuntu-latest
    
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: SmartRestaurant_Test
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432
          
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}
        
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: angular/package-lock.json
        
    - name: Cache .NET packages
      uses: actions/cache@v3
      with:
        path: ~/.nuget/packages
        key: ${{ runner.os }}-nuget-${{ hashFiles('**/*.csproj') }}
        restore-keys: |
          ${{ runner.os }}-nuget-
        
    - name: Restore .NET dependencies
      run: |
        dotnet restore SmartRestaurant.sln
        
    - name: Install npm dependencies
      run: |
        cd angular
        npm ci
        
    - name: Run Backend Unit Tests
      run: |
        dotnet test test/SmartRestaurant.Domain.Tests/ --no-restore --logger trx --results-directory TestResults/
        dotnet test test/SmartRestaurant.Application.Tests/ --no-restore --logger trx --results-directory TestResults/
        
    - name: Run Backend Integration Tests
      env:
        ConnectionStrings__Default: "Host=localhost;Database=SmartRestaurant_Test;Username=postgres;Password=postgres;"
      run: |
        dotnet test test/SmartRestaurant.EntityFrameworkCore.Tests/ --no-restore --logger trx --results-directory TestResults/
        
    - name: Run Frontend Unit Tests
      run: |
        cd angular
        npm run test:ci
        
    - name: Run Frontend E2E Tests
      run: |
        cd angular
        npm run e2e:ci
        
    - name: Upload Test Results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: TestResults/

  build:
    name: Build and Push Images
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main' || github.ref == 'refs/heads/develop'
    
    permissions:
      contents: read
      packages: write
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v4
      
    - name: Setup .NET
      uses: actions/setup-dotnet@v4
      with:
        dotnet-version: ${{ env.DOTNET_VERSION }}
        
    - name: Setup Node.js
      uses: actions/setup-node@v4
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        cache-dependency-path: angular/package-lock.json
        
    - name: Restore and Build Backend
      run: |
        dotnet restore SmartRestaurant.sln
        dotnet publish aspnet-core/src/SmartRestaurant.HttpApi.Host/SmartRestaurant.HttpApi.Host.csproj \
          -c Release -o ./publish --no-restore
          
    - name: Build Frontend
      run: |
        cd angular
        npm ci
        npm run build:prod
        
    - name: Log in to Container Registry
      uses: docker/login-action@v3
      with:
        registry: ${{ env.REGISTRY }}
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
        
    - name: Extract metadata
      id: meta
      uses: docker/metadata-action@v5
      with:
        images: ${{ env.REGISTRY }}/${{ github.repository }}
        tags: |
          type=ref,event=branch
          type=sha
          
    - name: Build and push API image
      uses: docker/build-push-action@v5
      with:
        context: .
        file: infrastructure/docker/Dockerfile.api
        push: true
        tags: ${{ steps.meta.outputs.tags }}-api
        labels: ${{ steps.meta.outputs.labels }}
        
    - name: Build and push Web image
      uses: docker/build-push-action@v5
      with:
        context: .
        file: infrastructure/docker/Dockerfile.web
        push: true
        tags: ${{ steps.meta.outputs.tags }}-web
        labels: ${{ steps.meta.outputs.labels }}

  deploy-staging:
    name: Deploy to Staging
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/develop'
    environment: staging
    
    steps:
    - name: Deploy to Staging VPS
      uses: appleboy/ssh-action@v0.1.7
      with:
        host: ${{ secrets.STAGING_VPS_HOST }}
        username: ${{ secrets.VPS_USERNAME }}
        key: ${{ secrets.VPS_SSH_KEY }}
        script: |
          cd /opt/smart-restaurant-staging
          docker-compose down
          docker pull ${{ env.REGISTRY }}/${{ github.repository }}:develop-api
          docker pull ${{ env.REGISTRY }}/${{ github.repository }}:develop-web
          export API_IMAGE=${{ env.REGISTRY }}/${{ github.repository }}:develop-api
          export WEB_IMAGE=${{ env.REGISTRY }}/${{ github.repository }}:develop-web
          docker-compose -f docker-compose.staging.yml up -d
          docker system prune -f

  deploy-production:
    name: Deploy to Production
    runs-on: ubuntu-latest
    needs: build
    if: github.ref == 'refs/heads/main'
    environment: production
    
    steps:
    - name: Deploy to Production VPS
      uses: appleboy/ssh-action@v0.1.7
      with:
        host: ${{ secrets.PROD_VPS_HOST }}
        username: ${{ secrets.VPS_USERNAME }}
        key: ${{ secrets.VPS_SSH_KEY }}
        script: |
          cd /opt/smart-restaurant
          docker-compose down
          docker pull ${{ env.REGISTRY }}/${{ github.repository }}:main-api
          docker pull ${{ env.REGISTRY }}/${{ github.repository }}:main-web
          export API_IMAGE=${{ env.REGISTRY }}/${{ github.repository }}:main-api
          export WEB_IMAGE=${{ env.REGISTRY }}/${{ github.repository }}:main-web
          docker-compose -f docker-compose.prod.yml up -d
          docker system prune -f
          
    - name: Run Health Checks
      run: |
        sleep 30
        curl -f ${{ secrets.PROD_API_URL }}/health || exit 1
        curl -f ${{ secrets.PROD_WEB_URL }}/health || exit 1
```

#### Environment-Specific Configuration Management (Quản lý Cấu hình theo Môi trường)

**Development Environment Configuration (Cấu hình Môi trường Phát triển):**
```yaml
# .github/workflows/dev-environment.yaml
name: Development Environment Setup

on:
  workflow_dispatch:
  
jobs:
  setup-dev:
    runs-on: ubuntu-latest
    steps:
    - name: Setup Development Environment
      uses: appleboy/ssh-action@v0.1.7
      with:
        host: ${{ secrets.DEV_VPS_HOST }}
        username: ${{ secrets.VPS_USERNAME }}
        key: ${{ secrets.VPS_SSH_KEY }}
        script: |
          cd /opt/smart-restaurant-dev
          docker-compose -f docker-compose.dev.yml down
          docker-compose -f docker-compose.dev.yml pull
          docker-compose -f docker-compose.dev.yml up -d
          
          # Seed Vietnamese test data
          docker exec smart-restaurant-api dotnet SmartRestaurant.DbMigrator.dll --seed-vietnamese-data
```

**Configuration Files per Environment (File Cấu hình theo Môi trường):**
```bash
# Development
export ASPNETCORE_ENVIRONMENT=Development
export ConnectionStrings__Default="Host=postgres-dev;Database=SmartRestaurant_Dev;Username=dev_user;Password=${DEV_DB_PASSWORD};"
export App__SelfUrl="https://dev-api.restaurant.local"
export App__CorsOrigins="https://dev.restaurant.local"

# Staging
export ASPNETCORE_ENVIRONMENT=Staging
export ConnectionStrings__Default="Host=postgres-staging;Database=SmartRestaurant_Staging;Username=staging_user;Password=${STAGING_DB_PASSWORD};"
export App__SelfUrl="https://staging-api.restaurant.com"
export App__CorsOrigins="https://staging.restaurant.com"

# Production
export ASPNETCORE_ENVIRONMENT=Production
export ConnectionStrings__Default="Host=postgres-prod;Database=SmartRestaurant_Prod;Username=prod_user;Password=${PROD_DB_PASSWORD};"
export App__SelfUrl="https://api.restaurant.com"
export App__CorsOrigins="https://restaurant.com"
```

#### VPS Deployment Automation Setup (Thiết lập Tự động hóa Triển khai VPS)

**VPS Server Preparation Script (Script Chuẩn bị Máy chủ VPS):**
```bash
#!/bin/bash
# infrastructure/scripts/vps-setup.sh

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Setup application directories
sudo mkdir -p /opt/smart-restaurant
sudo mkdir -p /opt/smart-restaurant/data
sudo mkdir -p /opt/smart-restaurant/logs
sudo chown -R $USER:$USER /opt/smart-restaurant

# Setup Nginx for reverse proxy
sudo apt install nginx -y
sudo systemctl enable nginx

# Configure firewall
sudo ufw allow ssh
sudo ufw allow 80
sudo ufw allow 443
sudo ufw --force enable

# Install Vietnamese locale support
sudo locale-gen vi_VN.UTF-8
sudo update-locale LC_ALL=vi_VN.UTF-8 LANG=vi_VN.UTF-8

echo "VPS setup completed for Smart Restaurant deployment"
```

**Automated Testing Pipeline Integration (Tích hợp Đường ống Kiểm thử Tự động):**
```yaml
# .github/workflows/test-pipeline.yaml
name: Comprehensive Test Pipeline

on:
  pull_request:
    branches: [main, develop]

jobs:
  unit-tests:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        test-type: [domain, application, frontend]
    steps:
    - uses: actions/checkout@v4
    - name: Run ${{ matrix.test-type }} tests
      run: |
        case ${{ matrix.test-type }} in
          domain)
            dotnet test test/SmartRestaurant.Domain.Tests/ --logger trx
            ;;
          application)
            dotnet test test/SmartRestaurant.Application.Tests/ --logger trx
            ;;
          frontend)
            cd angular && npm ci && npm run test:ci
            ;;
        esac

  integration-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
          POSTGRES_DB: SmartRestaurant_Test
        options: --health-cmd pg_isready --health-interval 10s --health-timeout 5s --health-retries 5
        ports:
          - 5432:5432
    steps:
    - uses: actions/checkout@v4
    - name: Run Integration Tests with Vietnamese Data
      env:
        ConnectionStrings__Default: "Host=localhost;Database=SmartRestaurant_Test;Username=postgres;Password=postgres;"
      run: |
        dotnet test test/SmartRestaurant.EntityFrameworkCore.Tests/ --logger trx
        
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Run E2E Tests
      run: |
        docker-compose -f docker-compose.test.yml up -d
        cd angular
        npm ci
        npm run e2e:ci
        docker-compose -f docker-compose.test.yml down
```

### Test Environment Setup (Thiết lập Môi trường Kiểm thử)

**Vietnamese Test Data Seeding Procedures (Quy trình Tạo Dữ liệu Kiểm thử Tiếng Việt)**

The test environment requires Vietnamese-specific data for accurate testing of restaurant operations (Môi trường kiểm thử yêu cầu dữ liệu đặc thù Việt Nam để kiểm thử chính xác các hoạt động nhà hàng).

#### Vietnamese Test Data Seeder (Bộ tạo Dữ liệu Kiểm thử Tiếng Việt)

```csharp
// aspnet-core/src/SmartRestaurant.DbMigrator/VietnameseTestDataSeeder.cs
public class VietnameseTestDataSeeder : IDataSeedContributor, ITransientDependency
{
    private readonly IRepository<MenuCategory, Guid> _categoryRepository;
    private readonly IRepository<MenuItem, Guid> _menuItemRepository;
    private readonly IRepository<Table, Guid> _tableRepository;
    
    public async Task SeedAsync(DataSeedContext context)
    {
        if (await _categoryRepository.GetCountAsync() > 0)
            return; // Already seeded
            
        await SeedVietnameseMenuCategories();
        await SeedVietnameseMenuItems();
        await SeedRestaurantTables();
    }
    
    private async Task SeedVietnameseMenuCategories()
    {
        var categories = new[]
        {
            new MenuCategory { Name = "Khai vị", Description = "Các món khai vị truyền thống Việt Nam", IsActive = true },
            new MenuCategory { Name = "Món chính", Description = "Các món ăn chính phong phú", IsActive = true },
            new MenuCategory { Name = "Lẩu", Description = "Các loại lẩu cho 2-6 người", IsActive = true },
            new MenuCategory { Name = "Nướng", Description = "Đồ nướng BBQ theo kg", IsActive = true },
            new MenuCategory { Name = "Đồ uống", Description = "Bia, nước ngọt, nước suối", IsActive = true },
            new MenuCategory { Name = "Tráng miệng", Description = "Chè, bánh flan, trái cây", IsActive = false } // Seasonal
        };
        
        await _categoryRepository.InsertManyAsync(categories);
    }
    
    private async Task SeedVietnameseMenuItems()
    {
        var menuItems = new[]
        {
            // Khai vị
            new MenuItem { Name = "Gỏi cuốn tôm thịt", Price = 45000, Description = "2 cuốn với tôm tươi và thịt ba chỉ", PreparationTime = 10 },
            new MenuItem { Name = "Chả cá Lá Vọng", Price = 85000, Description = "Đặc sản Hà Nội với bún và rau thơm", PreparationTime = 15 },
            
            // Món chính  
            new MenuItem { Name = "Phở bò tái", Price = 65000, Description = "Phở bò truyền thống với tái chín", PreparationTime = 8 },
            new MenuItem { Name = "Cơm tấm sườn nướng", Price = 75000, Description = "Cơm tấm với sườn nướng và chả trứng", PreparationTime = 12 },
            new MenuItem { Name = "Bún chả Hà Nội", Price = 70000, Description = "Bún chả với thịt nướng than hoa", PreparationTime = 15 },
            
            // Lẩu
            new MenuItem { Name = "Lẩu thái chua cay", Price = 350000, Description = "Lẩu thái cho 4-6 người", PreparationTime = 20 },
            new MenuItem { Name = "Lẩu cá kèo lá giang", Price = 320000, Description = "Đặc sản miền Tây cho 4 người", PreparationTime = 25 },
            
            // Nướng
            new MenuItem { Name = "Thịt ba chỉ nướng", Price = 180000, Description = "500g thịt ba chỉ nướng than hoa", PreparationTime = 18 },
            new MenuItem { Name = "Tôm sú nướng", Price = 280000, Description = "6 con tôm sú nướng muối ớt", PreparationTime = 12 },
            
            // Đồ uống
            new MenuItem { Name = "Bia Saigon Special", Price = 25000, Description = "Lon 330ml", PreparationTime = 2 },
            new MenuItem { Name = "Nước dừa tươi", Price = 35000, Description = "Trái dừa tươi nguyên vỏ", PreparationTime = 3 },
            new MenuItem { Name = "Trà đá", Price = 8000, Description = "Trà đá truyền thống", PreparationTime = 1 }
        };
        
        await _menuItemRepository.InsertManyAsync(menuItems);
    }
    
    private async Task SeedRestaurantTables()
    {
        var tables = new[]
        {
            // Tầng trệt
            new Table { TableNumber = "B01", Capacity = 4, Location = "Tầng trệt", Status = TableStatus.Available },
            new Table { TableNumber = "B02", Capacity = 6, Location = "Tầng trệt", Status = TableStatus.Available },
            new Table { TableNumber = "B03", Capacity = 2, Location = "Tầng trệt", Status = TableStatus.Available },
            
            // Khu VIP
            new Table { TableNumber = "VIP1", Capacity = 8, Location = "Khu VIP tầng 2", Status = TableStatus.Available },
            new Table { TableNumber = "VIP2", Capacity = 10, Location = "Khu VIP tầng 2", Status = TableStatus.Available },
            
            // Sân vườn
            new Table { TableNumber = "SV01", Capacity = 6, Location = "Sân vườn", Status = TableStatus.Available },
            new Table { TableNumber = "SV02", Capacity = 4, Location = "Sân vườn", Status = TableStatus.Available }
        };
        
        await _tableRepository.InsertManyAsync(tables);
    }
}
```

#### Mock Services Configuration for External APIs (Cấu hình Mock Services cho API Bên ngoài)

```csharp
// test/SmartRestaurant.TestBase/MockServices/MockVietnameseBankingService.cs
public class MockVietnameseBankingService : IVietnameseBankingService
{
    public async Task<QrPaymentResult> GenerateQrCodeAsync(decimal amount, string orderNumber)
    {
        // Mock Vietnamese banking QR code generation
        return new QrPaymentResult
        {
            QrCodeBase64 = "iVBORw0KGgoAAAANSUhEUgAA...", // Mock QR code
            TransactionId = $"VN{DateTime.Now:yyyyMMddHHmmss}",
            ExpiryTime = DateTime.Now.AddMinutes(15),
            Amount = amount,
            BankName = "Vietcombank",
            AccountNumber = "0123456789"
        };
    }
    
    public async Task<PaymentStatus> CheckPaymentStatusAsync(string transactionId)
    {
        // Mock payment verification
        await Task.Delay(500); // Simulate API call
        
        return new PaymentStatus
        {
            TransactionId = transactionId,
            Status = PaymentStatusEnum.Completed,
            PaidAmount = 150000,
            PaidAt = DateTime.Now,
            BankReference = $"REF{transactionId}"
        };
    }
}

// test/SmartRestaurant.TestBase/MockServices/MockKitchenPrinterService.cs
public class MockKitchenPrinterService : IKitchenPrinterService
{
    private readonly List<PrintedOrder> _printedOrders = new();
    
    public async Task PrintOrderToKitchenAsync(Order order, KitchenStation station)
    {
        // Mock kitchen printing
        _printedOrders.Add(new PrintedOrder
        {
            OrderId = order.Id,
            Station = station,
            PrintedAt = DateTime.Now,
            Items = order.OrderItems.Select(oi => $"{oi.Quantity}x {oi.MenuItem.Name}").ToList()
        });
        
        await Task.Delay(100); // Simulate printer delay
    }
    
    public List<PrintedOrder> GetPrintedOrders() => _printedOrders;
}
```

#### Test Database Setup with Vietnamese Collation (Thiết lập Cơ sở Dữ liệu Kiểm thử với Collation Tiếng Việt)

```sql
-- infrastructure/sql/test-db-setup.sql
CREATE DATABASE "SmartRestaurant_Test" 
WITH 
    ENCODING = 'UTF8'
    LC_COLLATE = 'vi_VN.UTF-8'
    LC_CTYPE = 'vi_VN.UTF-8'
    TEMPLATE = template0;

-- Connect to test database
\c SmartRestaurant_Test;

-- Create Vietnamese text search configuration
CREATE TEXT SEARCH CONFIGURATION vietnamese (COPY = simple);

-- Create function for Vietnamese text normalization
CREATE OR REPLACE FUNCTION normalize_vietnamese(text)
RETURNS text AS $$
BEGIN
    RETURN translate(
        lower($1),
        'àáảãạâầấẩẫậăằắẳẵặèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ',
        'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
    );
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create indexes for Vietnamese search
CREATE INDEX idx_menu_item_name_vietnamese 
ON menu_items USING gin(normalize_vietnamese(name) gin_trgm_ops);

CREATE INDEX idx_menu_item_description_vietnamese 
ON menu_items USING gin(normalize_vietnamese(description) gin_trgm_ops);
```

#### Automated Test Environment Provisioning (Tự động Cung cấp Môi trường Kiểm thử)

```yaml
# docker-compose.test.yml
version: '3.8'

services:
  postgres-test:
    image: postgres:14
    environment:
      POSTGRES_DB: SmartRestaurant_Test
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_INITDB_ARGS: "--encoding=UTF-8 --lc-collate=vi_VN.UTF-8 --lc-ctype=vi_VN.UTF-8"
    ports:
      - "5433:5432"
    volumes:
      - ./infrastructure/sql/test-db-setup.sql:/docker-entrypoint-initdb.d/01-setup.sql
      - postgres_test_data:/var/lib/postgresql/data
    command: [
      "postgres",
      "-c", "shared_preload_libraries=pg_trgm",
      "-c", "log_statement=all"
    ]
      
  api-test:
    build:
      context: .
      dockerfile: infrastructure/docker/Dockerfile.api.test
    environment:
      ASPNETCORE_ENVIRONMENT: Test
      ConnectionStrings__Default: "Host=postgres-test;Database=SmartRestaurant_Test;Username=postgres;Password=postgres;"
      App__SelfUrl: "http://localhost:5000"
    ports:
      - "5000:80"
    depends_on:
      - postgres-test
    volumes:
      - ./test-logs:/app/logs
      
  web-test:
    build:
      context: .
      dockerfile: infrastructure/docker/Dockerfile.web.test
    environment:
      NODE_ENV: test
      API_BASE_URL: "http://api-test"
    ports:
      - "4201:80"
    depends_on:
      - api-test

volumes:
  postgres_test_data:
```

**Test Environment Management Script (Script Quản lý Môi trường Kiểm thử):**
```bash
#!/bin/bash
# scripts/test-env.sh

set -e

command="$1"

case $command in
  "start")
    echo "Starting test environment with Vietnamese data..."
    docker-compose -f docker-compose.test.yml up -d
    
    echo "Waiting for services to be ready..."
    sleep 15
    
    echo "Seeding Vietnamese test data..."
    docker exec smart-restaurant-api-test dotnet SmartRestaurant.DbMigrator.dll --seed-vietnamese-data
    
    echo "Test environment ready at:"
    echo "  API: http://localhost:5000"
    echo "  Web: http://localhost:4201"
    echo "  DB: localhost:5433"
    ;;
    
  "stop")
    echo "Stopping test environment..."
    docker-compose -f docker-compose.test.yml down
    ;;
    
  "reset")
    echo "Resetting test environment..."
    docker-compose -f docker-compose.test.yml down -v
    docker-compose -f docker-compose.test.yml up -d
    sleep 15
    docker exec smart-restaurant-api-test dotnet SmartRestaurant.DbMigrator.dll --seed-vietnamese-data
    ;;
    
  "logs")
    docker-compose -f docker-compose.test.yml logs -f
    ;;
    
  *)
    echo "Usage: $0 {start|stop|reset|logs}"
    exit 1
    ;;
esac
```

### Environments (Môi trường)

| Environment (Môi trường) | Frontend URL | Backend URL | Database | Purpose (Mục đích) |
|-------------|--------------|-------------|----------|---------|  
| Development | http://localhost:4200 | https://localhost:44391 | SmartRestaurant_Dev | Local development with hot reload |
| Test | http://localhost:4201 | http://localhost:5000 | SmartRestaurant_Test | Automated testing with Vietnamese data |
| Staging | https://staging.restaurant.com | https://staging-api.restaurant.com | SmartRestaurant_Staging | Pre-production testing and UAT |
| Production | https://restaurant.com | https://api.restaurant.com | SmartRestaurant_Prod | Live environment for restaurant operations |