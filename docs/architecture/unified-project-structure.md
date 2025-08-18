# Unified Project Structure

```
smart-restaurant/
├── .github/                        # CI/CD workflows  
│   └── workflows/
│       ├── ci.yaml                 # Build and test pipeline
│       └── deploy.yaml             # VPS deployment pipeline
├── aspnet-core/                    # ABP Framework backend source projects
│   ├── src/
│   │   ├── SmartRestaurant.Domain.Shared/ # Shared domain constants and resources
│   │   ├── SmartRestaurant.Domain/     # Domain entities and business logic
│   │   │   ├── Data/               # Database schema migration
│   │   │   ├── OpenIddict/         # Authentication data seeding
│   │   │   └── Settings/           # Application settings
│   │   ├── SmartRestaurant.Application.Contracts/ # DTOs and interfaces
│   │   │   └── Permissions/        # Permission definitions
│   │   ├── SmartRestaurant.Application/ # Application services
│   │   │   ├── Orders/             # Order management services (future)
│   │   │   ├── Menu/               # Menu management services (future)
│   │   │   ├── Tables/             # Table management services (future)
│   │   │   ├── Payments/           # Payment processing services (future)
│   │   │   └── Kitchen/            # Kitchen coordination services (future)
│   │   ├── SmartRestaurant.EntityFrameworkCore/ # EF Core implementation
│   │   │   ├── EntityFrameworkCore/ # DbContext and configurations
│   │   │   └── Migrations/         # Database migrations
│   │   ├── SmartRestaurant.HttpApi/ # Auto-generated API controllers
│   │   │   └── Controllers/        # Manual controllers if needed
│   │   ├── SmartRestaurant.HttpApi.Client/ # HTTP client for APIs
│   │   └── SmartRestaurant.HttpApi.Host/ # Web host application
│   │       ├── appsettings.json    # Configuration
│   │       ├── Program.cs          # Application entry point
│   │       └── wwwroot/            # Static files and ABP resources
│   ├── test/                       # Backend test projects
│   │   ├── SmartRestaurant.Domain.Tests/
│   │   ├── SmartRestaurant.Application.Tests/
│   │   ├── SmartRestaurant.EntityFrameworkCore.Tests/
│   │   ├── SmartRestaurant.HttpApi.Client.ConsoleTestApp/
│   │   └── SmartRestaurant.TestBase/
│   └── SmartRestaurant.sln         # Solution file
├── angular/                        # Angular 19 frontend
│   ├── src/
│   │   ├── app/
│   │   │   ├── core/               # Singleton services
│   │   │   │   ├── auth/           # ABP authentication
│   │   │   │   ├── signalr/        # Real-time connections
│   │   │   │   └── interceptors/   # HTTP interceptors
│   │   │   ├── shared/             # Shared components
│   │   │   │   ├── components/     # Reusable UI components
│   │   │   │   ├── pipes/          # Vietnamese formatting pipes
│   │   │   │   ├── services/       # Shared services
│   │   │   │   └── models/         # TypeScript interfaces
│   │   │   ├── features/           # Feature modules
│   │   │   │   ├── dashboard/      # Restaurant dashboard
│   │   │   │   ├── orders/         # Order management
│   │   │   │   ├── menu/           # Menu management
│   │   │   │   ├── tables/         # Table management
│   │   │   │   ├── payments/       # Payment processing
│   │   │   │   ├── kitchen/        # Kitchen displays
│   │   │   │   └── reservations/   # Reservation management
│   │   │   ├── layout/             # App layout
│   │   │   └── store/              # NgRx state management
│   │   │       ├── orders/         # Order state
│   │   │       ├── menu/           # Menu state
│   │   │       └── tables/         # Table state
│   │   ├── assets/                 # Static assets
│   │   │   ├── images/             # Menu images, logos
│   │   │   └── i18n/               # Vietnamese translations
│   │   └── environments/           # Environment configurations
│   ├── tests/                      # Frontend tests
│   │   ├── unit/                   # Component unit tests
│   │   ├── integration/            # Service integration tests
│   │   └── e2e/                    # End-to-end tests
│   ├── angular.json                # Angular configuration
│   ├── package.json                # Dependencies
│   └── tsconfig.json               # TypeScript configuration
├── flutter/                        # Flutter mobile apps
│   ├── lib/
│   │   ├── features/               # Feature-based organization
│   │   │   ├── orders/             # Order management
│   │   │   ├── menu/               # Menu browsing
│   │   │   ├── tables/             # Table management
│   │   │   └── kitchen/            # Kitchen display
│   │   ├── shared/                 # Shared code
│   │   │   ├── models/             # Data models
│   │   │   ├── services/           # API services
│   │   │   ├── widgets/            # Reusable widgets
│   │   │   └── utils/              # Utilities
│   │   └── main.dart               # App entry point
│   ├── test/                       # Flutter tests
│   ├── pubspec.yaml                # Flutter dependencies
│   └── android/                    # Android-specific code
├── shared/                         # Shared TypeScript definitions
│   ├── src/
│   │   ├── types/                  # TypeScript interfaces
│   │   │   ├── order.types.ts      # Order-related types
│   │   │   ├── menu.types.ts       # Menu-related types
│   │   │   ├── table.types.ts      # Table-related types
│   │   │   └── payment.types.ts    # Payment-related types
│   │   ├── constants/              # Shared constants
│   │   │   ├── order-status.ts     # Order status enum
│   │   │   ├── payment-methods.ts  # Payment method enum
│   │   │   └── kitchen-stations.ts # Kitchen station enum
│   │   └── utils/                  # Shared utilities
│   │       ├── currency.ts         # Vietnamese currency formatting
│   │       ├── datetime.ts         # Date/time utilities
│   │       └── validation.ts       # Common validation rules
│   └── package.json                # Shared package definition
├── infrastructure/                 # Docker & deployment
│   ├── docker/
│   │   ├── docker-compose.dev.yml  # Development environment
│   │   ├── docker-compose.prod.yml # Production environment
│   │   ├── Dockerfile.api          # Backend container
│   │   ├── Dockerfile.web          # Frontend container
│   │   └── nginx.conf              # Nginx configuration
│   ├── scripts/
│   │   ├── deploy.sh               # Deployment script
│   │   ├── backup.sh               # Database backup script
│   │   └── restore.sh              # Database restore script
│   └── monitoring/
│       ├── prometheus.yml          # Metrics configuration
│       └── grafana/                # Dashboard configurations
├── docs/                           # Documentation
│   ├── prd.md                      # Product Requirements Document
│   ├── architecture.md             # This document
│   ├── deployment.md               # Deployment guide
│   ├── api-docs/                   # API documentation
│   └── user-guides/                # User manuals
├── .env.example                    # Environment template
├── package.json                    # Root package.json (npm workspaces)
├── nx.json                         # Nx workspace configuration  
├── tsconfig.base.json              # Base TypeScript configuration
└── README.md                       # Project overview
```

**Root Package.json Scripts for ABP Workflow (Script Package.json Gốc cho ABP Workflow):**
```json
{
  "scripts": {
    "dev": "concurrently \"npm run dev:api\" \"npm run dev:web\"",
    "dev:api": "cd aspnet-core && dotnet run --project src/SmartRestaurant.HttpApi.Host",
    "dev:web": "cd angular && npm start",
    "dev:mobile": "cd flutter && flutter run",
    "generate-proxy": "cd angular && abp generate-proxy -t ng -u https://localhost:44391",
    "install-libs": "cd angular && abp install-libs",
    "migrate": "cd aspnet-core && dotnet run --project src/SmartRestaurant.DbMigrator",
    "test": "npm run test:backend && npm run test:frontend",
    "test:backend": "cd aspnet-core && dotnet test SmartRestaurant.sln",
    "test:frontend": "cd angular && npm test",
    "build:prod": "npm run build:backend && npm run build:frontend",
    "build:backend": "cd aspnet-core && dotnet publish src/SmartRestaurant.HttpApi.Host -c Release",
    "build:frontend": "cd angular && npm run build:prod",
    "docker:dev": "cd infrastructure/docker && docker-compose -f docker-compose.dev.yml up -d",
    "docker:prod": "cd infrastructure/docker && docker-compose -f docker-compose.prod.yml up -d --build"
  }
}
```
