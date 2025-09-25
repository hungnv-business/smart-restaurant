# SmartRestaurant Development Environment Guide

## Rule Markdown file
QUAN TRỌNG: Tất cả phản hồi của Claude phải bằng tiếng Việt. Chỉ sử dụng tiếng Anh khi cần thiết cho code hoặc tên kỹ thuật.

## Language Requirements
- Ngôn ngữ chính: Tiếng Việt
- Ngôn ngữ phụ: Tiếng Anh (chỉ khi cần thiết cho tài liệu kỹ thuật)

## Project Overview
Vietnamese restaurant management system built with ABP Framework 8.0, .NET 8, Angular 19, Flutter Mobile, and PostgreSQL.

## Quick Start Commands

### Development Environment Setup
```bash
# Start development environment with Docker
cd infrastructure/docker
docker-compose up -d

# Or run locally (requires PostgreSQL running)
npm run dev

# Start mobile development
npm run dev:mobile
```

### ABP Framework Specific Commands

#### Backend (.NET 8)
```bash
# Navigate to backend
cd aspnet-core

# Run database migrations
dotnet run --project src/SmartRestaurant.DbMigrator

# Start API development server
dotnet run --project src/SmartRestaurant.HttpApi.Host

# Run backend tests
dotnet test SmartRestaurant.sln

# Build for production
dotnet publish src/SmartRestaurant.HttpApi.Host -c Release -o publish
```

#### Frontend (Angular 19)
```bash
# Navigate to frontend
cd angular

# Install ABP libraries (run after backend changes)
abp install-libs

# Generate ABP service proxies (run after backend API changes)
abp generate-proxy -t ng -u https://localhost:44346

# Start development server
npm start

# Run tests
npm test

# Build for production
npm run build:prod
```

#### Mobile App (Flutter 3.35.1)
```bash
# Navigate to mobile app
cd flutter_mobile

# Get Flutter dependencies
flutter pub get

# Start development on connected device/emulator
flutter run

# Run unit tests
flutter test

# Run widget tests
flutter test test/widgets/

# Run integration tests
flutter test integration_test/

# Build APK for Android
flutter build apk

# Build IPA for iOS (requires Xcode)
flutter build ios
```

### Root Package.json Scripts
```bash
# Start both API and Web in development mode
npm run dev

# Start mobile development with Flutter
npm run dev:mobile

# Generate Angular proxies after backend changes
npm run generate-proxy

# Install ABP frontend libraries
npm run install-libs

# Run database migrator
npm run migrate

# Run all tests (backend + frontend + mobile)
npm run test

# Run mobile tests specifically
npm run test:mobile

# Build everything for production
npm run build:prod

# Build mobile apps for production
npm run build:mobile
```

## Project Structure

### Backend (ABP Framework)
```
aspnet-core/
├── src/
│   ├── SmartRestaurant.Domain/           # Domain entities and business logic
│   ├── SmartRestaurant.Application/      # Application services and DTOs
│   ├── SmartRestaurant.EntityFrameworkCore/ # EF Core implementation
│   ├── SmartRestaurant.HttpApi/          # Auto-generated controllers
│   └── SmartRestaurant.HttpApi.Host/     # Web host application
├── test/                                 # Test projects
└── SmartRestaurant.sln                   # Solution file
```

### Frontend (Angular 19)
```
angular/
├── src/app/
│   ├── app.component.ts                  # Root application component
│   ├── app.config.ts                     # Application configuration
│   ├── app.routes.ts                     # Routing configuration
│   ├── home/                             # Home feature module
│   │   ├── home.component.ts             # Home component
│   │   ├── home.component.html           # Home template
│   │   ├── home.component.scss           # Home styles
│   │   ├── home.component.spec.ts        # Home tests
│   │   └── home.routes.ts                # Home routing
│   └── layout/                           # Poseidon theme layout components
│       ├── components/                   # Layout UI components
│       │   ├── app.breadcrumb.ts         # Breadcrumb navigation
│       │   ├── app.configurator.ts       # Theme settings panel
│       │   ├── app.footer.ts             # Footer component
│       │   ├── app.menu.ts               # Main navigation menu
│       │   ├── app.menuitem.ts           # Menu item component
│       │   ├── app.rightmenu.ts          # Right sidebar menu
│       │   ├── app.search.ts             # Search functionality
│       │   ├── app.sidebar.ts            # Left sidebar
│       │   ├── app.topbar.ts             # Top navigation bar
│       │   └── restaurant.layout.ts      # Main restaurant layout wrapper
│       └── service/                      # Layout services
│           └── layout.service.ts         # Layout state management
├── src/assets/                           # Static assets and themes
│   ├── demo/                             # Poseidon theme demo assets
│   │   ├── data/                         # Sample JSON data
│   │   └── images/                       # Demo images and illustrations
│   └── layout/                           # Core layout styles and assets
│       ├── images/                       # Layout-specific images
│       ├── sidebar/                      # Sidebar theme styles
│       ├── topbar/                       # Topbar theme styles
│       └── variables/                    # SCSS theme variables
├── angular.json                          # Angular workspace configuration
├── karma.conf.js                         # Test runner configuration
├── package.json                          # Dependencies and scripts
├── package-lock.json                     # NPM dependency lock file
├── tailwind.config.js                    # Tailwind CSS configuration
├── tsconfig.json                         # TypeScript configuration
├── tsconfig.app.json                     # App-specific TypeScript config
└── tsconfig.spec.json                    # Test TypeScript config
```

**Note**: Restaurant feature modules (dashboard, orders, menu, etc.) will be implemented in future development under `features/` directory.

### Mobile App (Flutter 3.35.1)
```
flutter_mobile/
├── lib/
│   ├── main.dart                         # App entry point
│   ├── features/                         # Feature modules
│   │   ├── orders/                       # Gọi món (Orders)
│   │   ├── reservations/                 # Đặt bàn (Reservations)
│   │   └── takeaway/                     # Mang về (Takeaway)
│   └── shared/                           # Shared components and services
│       ├── constants/                    # Vietnamese text constants
│       ├── models/                       # Data models
│       ├── services/                     # API client, auth service
│       ├── utils/                        # Vietnamese formatters
│       └── widgets/                      # Reusable widgets
├── test/                                 # Unit and widget tests
├── integration_test/                     # Integration tests
└── pubspec.yaml                          # Dependencies and scripts
```

### Infrastructure
```
infrastructure/
├── DEPLOYMENT-GUIDE.md                  # Deployment documentation
├── docker/                              # Docker configuration
│   ├── docker-compose.yml               # Docker compose configuration
│   ├── Dockerfile.api                   # Backend container
│   ├── Dockerfile.web                   # Frontend container
│   ├── nginx.conf                       # Nginx reverse proxy config
│   └── init-scripts/                    # Database initialization
│       └── 01-vietnamese-collation.sql  # Vietnamese text support
├── scripts/                             # Deployment and maintenance scripts
│   ├── backup-database.sh               # Database backup script
│   ├── health-monitor.sh                # Health monitoring script
│   ├── test-deployment.sh               # Deployment testing script
│   └── upgrade-server.sh                # Server upgrade script
└── vps-setup.sh                         # VPS initial setup script
```

## Development Workflow

### 1. Making Backend Changes
```bash
# 1. Make changes to Domain/Application layers
cd aspnet-core

# 2. Add new migration if entities changed
dotnet ef migrations add YourMigrationName -p src/SmartRestaurant.EntityFrameworkCore

# 3. Update database
dotnet run --project src/SmartRestaurant.DbMigrator

# 4. Regenerate Angular proxies if APIs changed
cd ../angular
abp generate-proxy -t ng -u https://localhost:44346

# 5. Install ABP libs if needed
abp install-libs
```

### 2. Making Frontend Changes
```bash
cd angular

# Make your changes to components/services

# Run tests
npm test

# Check for build errors
npm run build
```

### 3. Making Mobile Changes
```bash
cd flutter_mobile

# Make your changes to features/widgets/services

# Get dependencies if pubspec.yaml changed
flutter pub get

# Run tests
flutter test

# Check for build errors
flutter build apk --debug
```

### 4. Database Operations
```bash
# Create new migration
cd aspnet-core
dotnet ef migrations add MigrationName -p src/SmartRestaurant.EntityFrameworkCore

# Apply migrations to development database
dotnet run --project src/SmartRestaurant.DbMigrator

# Rollback migration (if needed)
dotnet ef database update PreviousMigrationName -p src/SmartRestaurant.EntityFrameworkCore

# Generate SQL script
dotnet ef migrations script -p src/SmartRestaurant.EntityFrameworkCore
```

## Configuration

### Database Connection (appsettings.json)
```json
{
  "ConnectionStrings": {
    "Default": "User ID=postgres;Password=postgres;Host=localhost;Port=5432;Database=SmartRestaurant;"
  }
}
```

### Environment Variables
Copy `.env.example` to `.env` and update values for production deployment.

## Troubleshooting

### Common ABP Framework Issues

#### 1. "ABP CLI not found" or "@volo/abp not found"
```bash
# ABP v8.2+ uses new CLI package
# Install new ABP CLI globally
dotnet tool install -g Volo.Abp.Studio.Cli

# Update ABP CLI
dotnet tool update -g Volo.Abp.Studio.Cli

# If new CLI fails, fallback to old CLI
dotnet tool install -g Volo.Abp.Cli

# Add dotnet tools to PATH if needed
export PATH="$PATH:$HOME/.dotnet/tools"
```

#### 2. "Proxy generation failed"
```bash
# Ensure API is running first
cd aspnet-core
dotnet run --project src/SmartRestaurant.HttpApi.Host

# Then regenerate proxies in another terminal
cd angular
abp generate-proxy -t ng -u https://localhost:44346
```

#### 3. "Database connection failed"
```bash
# Check PostgreSQL is running
docker ps | grep postgres

# Or start with Docker Compose
cd infrastructure/docker
docker-compose up postgres -d

# Check connection string in appsettings.json
```

#### 4. "ABP install-libs failed"
```bash
cd angular

# Clear npm cache
npm cache clean --force

# Remove node_modules and reinstall
rm -rf node_modules package-lock.json
npm install

# Try install-libs again
abp install-libs
```

### Flutter Mobile Issues

#### 1. "Flutter SDK not found"
```bash
# Install Flutter SDK
# Visit https://flutter.dev/docs/get-started/install

# Add to PATH (macOS/Linux) - replace with your Flutter SDK path
export PATH="$PATH:/path/to/flutter/bin"

# Verify installation
flutter doctor
```

#### 2. "No connected devices"
```bash
# List available devices
flutter devices

# For iOS Simulator (macOS only)
open -a Simulator

# For Android Emulator
flutter emulators
flutter emulators --launch <emulator_id>
```

#### 3. "Pub get failed"
```bash
cd flutter_mobile

# Clear pub cache
flutter clean
flutter pub cache clean

# Get dependencies
flutter pub get

# If dependencies conflict, check pubspec.yaml versions
```

#### 4. "Build failed on iOS"
```bash
# Clean iOS build
cd flutter_mobile/ios
rm -rf Pods/ Podfile.lock
cd ..
flutter clean
flutter pub get

# Install CocoaPods dependencies
cd ios
pod install
cd ..

# Try building again
flutter build ios
```

### PostgreSQL with Vietnamese Collation

#### Verify Vietnamese text search
```sql
-- Connect to SmartRestaurant database
\c SmartRestaurant

-- Test Vietnamese search function
SELECT vietnamese_search('pho', 'Phở Bò Tái');
-- Should return true

-- Test unaccent function
SELECT remove_vietnamese_accents('Phở Bò Tái Nạm');
-- Should return 'Pho Bo Tai Nam'
```

#### Common Vietnamese Text Issues
```bash
# If Vietnamese characters don't display correctly:
# 1. Ensure database encoding is UTF8
# 2. Check application charset settings
# 3. Verify locale settings in PostgreSQL container
```

### Docker Issues

#### Container won't start
```bash
# Check logs
docker-compose -f infrastructure/docker/docker-compose.yml logs

# Rebuild containers
docker-compose -f infrastructure/docker/docker-compose.yml build --no-cache

# Clean up and restart
docker-compose -f infrastructure/docker/docker-compose.yml down
docker system prune -f
docker-compose -f infrastructure/docker/docker-compose.yml up -d
```

#### Port conflicts
```bash
# Check what's using the ports
lsof -i :5432  # PostgreSQL
lsof -i :44346 # API
lsof -i :4200  # Angular

# For Flutter mobile development
lsof -i :8080  # Flutter web (if using)

# Stop conflicting services or change ports in docker-compose files
```

### Performance Issues

#### Slow API responses
```bash
# Check database performance
# Enable query logging in PostgreSQL
# Monitor with Azure Application Insights (production)

# Check database connection
psql -h localhost -U postgres -d SmartRestaurant -c "SELECT 1;"
```

#### Large Angular bundle size
```bash
cd angular

# Analyze bundle
npm run build:prod -- --stats-json
npx webpack-bundle-analyzer dist/stats.json

# Check for lazy loading opportunities
```

#### Flutter app performance issues
```bash
cd flutter_mobile

# Profile app performance
flutter run --profile

# Check for jank (frame drops)
flutter run --trace-skia

# Build release version for performance testing
flutter build apk --release
flutter install
```

## Testing

### Backend Tests
```bash
cd aspnet-core

# Run all tests
dotnet test

# Run specific test project
dotnet test test/SmartRestaurant.Application.Tests

# Generate coverage report
dotnet test --collect:"XPlat Code Coverage"
```

### Frontend Tests
```bash
cd angular

# Unit tests
npm test

# E2E tests
npm run e2e

# Test coverage
npm run test:coverage
```

### Mobile Tests
```bash
cd flutter_mobile

# Unit tests
flutter test

# Widget tests
flutter test test/widgets/

# Integration tests
flutter test integration_test/

# Test coverage (requires lcov)
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Integration Tests
```bash
# Full stack test (requires running services)
cd angular
npm run test:integration
```

## Deployment

### Production Deployment
```bash
# Build and deploy with Docker Compose
cd infrastructure/docker
docker-compose up -d --build

# Or build separately
docker build -f Dockerfile.api -t smartrestaurant-api .
docker build -f Dockerfile.web -t smartrestaurant-web .
```

### Environment-specific Settings
- Development: `appsettings.Development.json`
- Production: `appsettings.json` + environment variables
- Secrets: `appsettings.secrets.json` (not in version control)

## Vietnamese Restaurant Specific Notes

### Menu Data Format
- Use Vietnamese dish names: "Phở Bò", "Cơm Tấm", etc.
- Price format: Vietnamese Dong (₫)
- Text search supports accented characters

### Localization
- Primary language: Vietnamese (vi)
- Fallback: English (en)
- Currency: VND (₫)
- Date format: dd/MM/yyyy

### Kitchen Integration
- Real-time order updates via SignalR
- Print integration for kitchen orders
- Vietnamese order status terms

## Useful Resources

- [ABP Framework Documentation](https://docs.abp.io)
- [Angular Documentation](https://angular.io/docs)
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Guide](https://dart.dev/guides)
- [PostgreSQL Vietnamese Collation](https://www.postgresql.org/docs/current/collation.html)
- [Docker Documentation](https://docs.docker.com)

## Support

For issues specific to this project:
1. Check this troubleshooting guide
2. Review ABP Framework documentation
3. Check project GitHub issues
4. Contact development team