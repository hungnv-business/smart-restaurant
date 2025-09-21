# Source Tree (Cây Mã nguồn)

## Project Root Structure (Cấu trúc Gốc Dự án)

```
smart-restaurant/
├── .bmad-core/                     # BMaD Method configuration and templates
├── .bmad-infrastructure-devops/    # BMaD Infrastructure DevOps
├── .claude/                        # Claude Code configuration
├── .cursor/                        # Cursor IDE configuration
├── .git/                          # Git repository
├── .github/                       # GitHub Actions (empty)
├── aspnet-core/                    # ABP Framework backend (.NET 8)
├── angular/                        # Angular 19 frontend application
├── docs/                          # Project documentation
├── flutter_mobile/                # Flutter mobile application
├── infrastructure/                # Docker and deployment configuration
├── node_modules/                  # Dependencies
├── CLAUDE.md                      # Development environment guide
├── README.md                      # Project overview
├── package.json                   # Root workspace configuration
├── package-lock.json              # NPM lock file
└── yarn.lock                      # Yarn lock file
```

## Backend Structure - ABP Framework (.NET 8)

### Core Application Layers (Các Lớp Ứng dụng Cốt lõi)

```
aspnet-core/
├── SmartRestaurant.sln            # Visual Studio solution file
├── common.props                   # Shared MSBuild properties
├── NuGet.Config                   # NuGet package source configuration
└── src/
    ├── SmartRestaurant.Domain.Shared/      # Shared domain constants and enums
    │   ├── Localization/                   # Multi-language support (29 languages including Vietnamese)
    │   │   └── SmartRestaurant/
    │   │       ├── vi.json                 # Vietnamese localization
    │   │       ├── en.json                 # English localization
    │   │       └── [other-languages].json  # 27 other language files
    │   ├── MultiTenancy/                   # Multi-tenant configuration
    │   └── SmartRestaurantGlobalFeatureConfigurator.cs
    │
    ├── SmartRestaurant.Domain/             # Domain entities and business logic
    │   ├── Data/                          # Database migration and seeding
    │   │   ├── ISmartRestaurantDbSchemaMigrator.cs
    │   │   └── SmartRestaurantDbMigrationService.cs
    │   ├── OpenIddict/                    # Authentication data seeding
    │   │   └── OpenIddictDataSeedContributor.cs
    │   └── Settings/                      # Application settings definitions
    │       ├── SmartRestaurantSettingDefinitionProvider.cs
    │       └── SmartRestaurantSettings.cs
    │
    ├── SmartRestaurant.Application.Contracts/  # DTOs and service interfaces
    │   ├── Permissions/                        # Permission definitions
    │   │   ├── SmartRestaurantPermissionDefinitionProvider.cs
    │   │   └── SmartRestaurantPermissions.cs
    │   └── SmartRestaurantDtoExtensions.cs
    │
    ├── SmartRestaurant.Application/        # Application services implementation
    │   ├── SmartRestaurantAppService.cs
    │   ├── SmartRestaurantApplicationAutoMapperProfile.cs
    │   └── SmartRestaurantApplicationModule.cs
    │
    ├── SmartRestaurant.EntityFrameworkCore/    # Data access layer
    │   ├── EntityFrameworkCore/
    │   │   ├── SmartRestaurantDbContext.cs     # Main database context
    │   │   ├── SmartRestaurantDbContextFactory.cs
    │   │   ├── EntityFrameworkCoreSmartRestaurantDbSchemaMigrator.cs
    │   │   └── SmartRestaurantEfCoreEntityExtensionMappings.cs
    │   └── Migrations/                         # EF Core database migrations
    │       ├── 20250818024458_Initial.cs
    │       ├── 20250818024458_Initial.Designer.cs
    │       └── SmartRestaurantDbContextModelSnapshot.cs
    │
    ├── SmartRestaurant.HttpApi/            # Auto-generated REST API controllers
    │   ├── Controllers/
    │   │   └── SmartRestaurantController.cs
    │   └── Models/Test/
    │       └── TestModel.cs
    │
    ├── SmartRestaurant.HttpApi.Host/       # Web host application
    │   ├── Controllers/
    │   │   └── HomeController.cs
    │   ├── Properties/
    │   │   └── launchSettings.json
    │   ├── wwwroot/                        # Static files and ABP resources
    │   │   ├── global-styles.css
    │   │   ├── images/
    │   │   │   └── logo/                   # Application logos
    │   │   │       ├── leptonx/            # LeptonX theme logos
    │   │   │       │   ├── logo-dark.png
    │   │   │       │   ├── logo-light.png
    │   │   │       │   └── logo thumbnails
    │   │   └── libs/                       # Client-side libraries
    │   │       ├── abp/                    # ABP Framework scripts
    │   │       │   ├── core/               # Core ABP functionality
    │   │       │   ├── jquery/             # jQuery integration
    │   │       │   └── utils/              # ABP utilities
    │   │       ├── bootstrap/              # Bootstrap CSS/JS
    │   │       ├── jquery/                 # jQuery library
    │   │       ├── jquery-validation/      # Form validation
    │   │       ├── sweetalert2/            # Alert dialogs
    │   │       └── datatables.net/         # Data tables
    │   ├── Logs/                           # Application logs
    │   │   └── logs.txt
    │   ├── Program.cs                      # Application entry point
    │   ├── appsettings.json               # Production configuration
    │   ├── appsettings.Development.json   # Development configuration
    │   ├── package.json                   # Frontend assets management
    │   ├── yarn.lock                      # Package lock file
    │   ├── web.config                     # IIS configuration
    │   ├── SmartRestaurantBrandingProvider.cs      # App branding
    │   ├── SmartRestaurantHttpApiHostModule.cs     # Host module
    │   └── abp.resourcemapping.js          # ABP resource mapping
    │
    ├── SmartRestaurant.HttpApi.Client/     # HTTP client for API consumption
    │   └── SmartRestaurantHttpApiClientModule.cs
    │
    └── SmartRestaurant.DbMigrator/         # Database migration tool
        ├── Program.cs
        ├── DbMigratorHostedService.cs
        ├── SmartRestaurantDbMigratorModule.cs
        └── appsettings.json
```

### Test Projects (Dự án Kiểm thử)

```
aspnet-core/test/
├── SmartRestaurant.Application.Tests/      # Application service tests
│   ├── Samples/
│   │   └── SampleAppServiceTests.cs
│   ├── SmartRestaurantApplicationTestBase.cs
│   └── SmartRestaurantApplicationTestModule.cs
│
├── SmartRestaurant.Domain.Tests/           # Domain logic tests
│   ├── Samples/
│   │   └── SampleDomainTests.cs
│   ├── SmartRestaurantDomainTestBase.cs
│   └── SmartRestaurantDomainTestModule.cs
│
├── SmartRestaurant.EntityFrameworkCore.Tests/  # Data access tests
│   ├── EntityFrameworkCore/
│   │   ├── Applications/
│   │   │   └── EfCoreSampleAppServiceTests.cs
│   │   ├── Domains/
│   │   │   └── EfCoreSampleDomainTests.cs
│   │   └── Samples/
│   │       └── SampleRepositoryTests.cs
│   └── SmartRestaurantEntityFrameworkCoreTestModule.cs
│
├── SmartRestaurant.HttpApi.Client.ConsoleTestApp/  # API client test console
│   ├── ClientDemoService.cs
│   ├── ConsoleTestAppHostedService.cs
│   ├── Program.cs
│   └── SmartRestaurantConsoleApiClientModule.cs
│
└── SmartRestaurant.TestBase/               # Shared test infrastructure
    ├── Security/
    │   └── FakeCurrentPrincipalAccessor.cs
    ├── SmartRestaurantTestBase.cs
    ├── SmartRestaurantTestBaseModule.cs
    ├── SmartRestaurantTestConsts.cs
    └── SmartRestaurantTestDataSeedContributor.cs
```

## Frontend Structure - Angular 19

### Application Structure (Cấu trúc Ứng dụng)

```
angular/
├── angular.json                   # Angular workspace configuration
├── karma.conf.js                 # Test runner configuration  
├── package.json                  # Dependencies and scripts
├── tailwind.config.js            # Tailwind CSS configuration
├── tsconfig.json                 # TypeScript configuration
├── tsconfig.app.json             # App-specific TypeScript config
├── tsconfig.spec.json            # Test TypeScript config
├── yarn.lock                     # Dependency lock file
├── dist/                         # Build output directory
└── src/
    ├── app/
    │   ├── app.component.ts      # Root application component
    │   ├── app.config.ts         # Application configuration
    │   ├── app.routes.ts         # Routing configuration
    │   ├── home/                 # Home feature module
    │   │   ├── home.component.ts
    │   │   ├── home.component.html
    │   │   ├── home.component.scss
    │   │   ├── home.component.spec.ts
    │   │   └── home.routes.ts
    │   └── layout/               # Poseidon theme layout components
    │       ├── components/       # Layout UI components
    │       │   ├── app.breadcrumb.ts     # Breadcrumb navigation
    │       │   ├── app.configurator.ts   # Theme settings panel
    │       │   ├── app.footer.ts         # Footer component
    │       │   ├── app.menu.ts           # Main navigation menu
    │       │   ├── app.menuitem.ts       # Menu item component
    │       │   ├── app.rightmenu.ts      # Right sidebar menu
    │       │   ├── app.search.ts         # Search functionality
    │       │   ├── app.sidebar.ts        # Left sidebar
    │       │   ├── app.topbar.ts         # Top navigation bar
    │       │   └── restaurant.layout.ts  # Main restaurant layout wrapper
    │       └── service/          # Layout services
    │           └── layout.service.ts     # Layout state management
    │
    ├── assets/                   # Static assets and themes
    │   ├── demo/                 # Poseidon theme demo assets
    │   │   ├── code.scss         # Code highlighting styles
    │   │   ├── demo.scss         # Demo-specific styles
    │   │   ├── data/             # Sample JSON data
    │   │   │   ├── chat.json
    │   │   │   ├── file-management.json
    │   │   │   ├── kanban.json
    │   │   │   ├── mail.json
    │   │   │   └── members.json
    │   │   └── images/           # Demo images and assets
    │   │       ├── auth/         # Authentication backgrounds
    │   │       ├── avatar/       # User avatar images
    │   │       ├── dashboard/    # Dashboard illustrations
    │   │       ├── ecommerce/    # E-commerce sample images
    │   │       ├── landing/      # Landing page assets
    │   │       └── product/      # Product sample images
    │   │
    │   └── layout/               # Core layout styles and assets
    │       ├── layout.scss       # Main layout stylesheet
    │       ├── images/           # Layout-specific images
    │       │   ├── logo-poseidon.png     # Poseidon theme logo
    │       │   ├── logo-poseidon.svg     # Vector logo
    │       │   ├── logo-poseidon-dark.png # Dark theme logo
    │       │   └── profile.jpg           # Default profile image
    │       ├── sidebar/          # Sidebar theme styles
    │       │   ├── _sidebar.scss
    │       │   ├── _sidebar_themes.scss
    │       │   └── themes/       # Light/dark sidebar themes
    │       ├── topbar/           # Top bar theme styles
    │       │   ├── _topbar.scss
    │       │   └── themes/       # Light/dark topbar themes
    │       └── variables/        # SCSS theme variables
    │           ├── _common.scss
    │           ├── _dark.scss
    │           └── _light.scss
    │
    ├── favicon.ico              # Website icon
    ├── index.html               # Main HTML file
    ├── main.ts                  # Application bootstrap
    ├── styles.scss              # Global styles
    └── tailwind.css             # Tailwind CSS imports
```

## Mobile App Structure - Flutter 3.35.1

### Application Structure (Cấu trúc Ứng dụng)

```
flutter_mobile/
├── android/                         # Android platform configuration
│   ├── app/
│   │   ├── build.gradle.kts        # Android build configuration
│   │   └── src/
│   │       ├── debug/              # Debug configuration
│   │       ├── main/               # Main Android manifest
│   │       └── profile/            # Profile configuration
│   ├── gradle/                     # Gradle wrapper
│   ├── local.properties           # Local Android SDK path
│   └── settings.gradle.kts         # Android project settings
│
├── ios/                            # iOS platform configuration
│   ├── Runner/                     # iOS app target
│   │   ├── AppDelegate.swift       # iOS app delegate
│   │   ├── Assets.xcassets/        # App icons and images
│   │   ├── Info.plist             # iOS app configuration
│   │   └── Runner-Bridging-Header.h
│   ├── Runner.xcodeproj/           # Xcode project
│   ├── Runner.xcworkspace/         # Xcode workspace
│   └── Podfile                     # CocoaPods dependencies
│
├── lib/                            # Flutter Dart source code
│   ├── features/                   # Feature-based organization
│   │   ├── orders/                 # Gọi món (Order Management)
│   │   │   └── orders_screen.dart
│   │   ├── reservations/           # Đặt bàn (Table Reservations)
│   │   │   └── reservations_screen.dart
│   │   └── takeaway/               # Mang về (Takeaway Orders)
│   │       └── takeaway_screen.dart
│   │
│   ├── shared/                     # Shared components and services
│   │   ├── constants/              # Vietnamese constants
│   │   │   ├── route_constants.dart
│   │   │   └── vietnamese_constants.dart
│   │   ├── models/                 # Data models
│   │   │   ├── user_model.dart
│   │   │   └── user_model.g.dart   # Generated code
│   │   ├── services/               # Business services
│   │   │   ├── api/                # API client services
│   │   │   │   └── api_client.dart
│   │   │   ├── auth/               # Authentication service
│   │   │   │   └── auth_service.dart
│   │   │   └── router_service.dart # Navigation service
│   │   ├── utils/                  # Vietnamese utilities
│   │   │   ├── responsive_helper.dart
│   │   │   └── vietnamese_formatter.dart
│   │   └── widgets/                # Reusable UI components
│   │       ├── login_screen.dart
│   │       ├── main_scaffold.dart
│   │       ├── not_found_screen.dart
│   │       ├── splash_screen.dart
│   │       └── vietnamese_input_widgets.dart
│   │
│   └── main.dart                   # Application entry point
│
├── test/                           # Flutter tests
│   ├── unit/                       # Unit tests
│   │   └── vietnamese_formatter_test.dart
│   ├── utils/                      # Test utilities
│   │   └── test_helpers.dart
│   ├── widgets/                    # Widget tests
│   │   └── login_screen_test.dart
│   └── widget_test.dart            # Default widget tests
│
├── integration_test/               # Integration tests
│   └── app_test.dart              # End-to-end tests
│
├── pubspec.yaml                    # Flutter dependencies and configuration
├── pubspec.lock                    # Dependency lock file
├── analysis_options.yaml          # Dart analyzer configuration
└── README.md                       # Flutter app documentation
```

### Key Flutter Mobile Features (Tính năng Chính của Flutter Mobile)

#### Vietnamese Restaurant Workflows (Quy trình Nhà hàng Việt Nam)
- **Gọi món (Orders)**: Real-time order management for staff
- **Đặt bàn (Reservations)**: Table booking system for customers
- **Mang về (Takeaway)**: Takeaway order processing

#### Technical Implementation (Triển khai Kỹ thuật)
- **State Management**: Provider pattern for Vietnamese restaurant workflows
- **API Integration**: RESTful API client connecting to ABP backend
- **Localization**: Vietnamese-first with English fallback
- **Responsive Design**: Tablet and phone support for restaurant staff
- **Authentication**: OAuth integration with ABP Identity system

## Documentation Structure (Cấu trúc Tài liệu)

### Architecture Documentation (Tài liệu Kiến trúc)

```
docs/
├── architecture.md                          # Main architecture overview
├── architecture/                           # Detailed architecture documents
│   ├── index.md                           # Architecture index
│   ├── introduction.md                    # Architecture introduction
│   ├── high-level-architecture.md         # System overview
│   ├── tech-stack.md                      # Technology stack decisions
│   ├── coding-standards.md                # Development standards
│   ├── unified-project-structure.md       # Project structure specification
│   ├── backend-architecture.md            # Backend design
│   ├── frontend-architecture.md           # Frontend design
│   ├── api-specification.md               # API documentation
│   ├── data-models.md                     # Database design
│   ├── database-management.md             # Database operations
│   ├── deployment-architecture.md         # Infrastructure design
│   ├── monitoring-and-observability.md    # Observability strategy
│   ├── security-and-performance.md        # Security & performance
│   ├── error-handling-strategy.md         # Error management
│   ├── testing-strategy.md                # Testing approach
│   ├── development-workflow.md            # Development processes
│   ├── core-workflows.md                  # Business workflows
│   ├── external-apis.md                   # External integrations
│   ├── components.md                      # Component specifications
│   ├── cross-epic-dependencies-documentation.md  # Dependencies
│   └── checklist-results-report.md        # Validation results
│
├── prd.md                                  # Main product requirements
├── prd/                                    # Detailed requirements
│   ├── index.md                           # PRD index
│   ├── goals-and-background.md            # Project goals
│   ├── requirements.md                    # Business requirements
│   ├── technical-assumptions.md           # Technical constraints
│   ├── user-interface-design-goals.md     # UI/UX requirements
│   ├── epic-list.md                       # List of epics
│   ├── epic-details.md                    # Detailed epic descriptions
│   ├── epics/                             # Individual epic files
│   │   ├── index.md
│   │   ├── epic-1-source-code-foundation.md
│   │   ├── epic-2-user-management.md
│   │   ├── epic-3-table-layout-management.md
│   │   ├── epic-4-menu-management.md
│   │   ├── epic-5-inventory-management.md
│   │   ├── epic-6-order-processing.md
│   │   ├── epic-7-takeaway-delivery.md
│   │   ├── epic-8-payment-processing.md
│   │   ├── epic-9-deployment.md
│   │   ├── epic-10-reporting-analytics.md
│   │   ├── epic-11-table-reservation.md
│   │   ├── epic-12-customer-management.md
│   │   └── epic-13-payroll-hr.md
│   ├── next-steps.md                      # Implementation roadmap
│   └── checklist-results-report.md        # Validation results
│
├── stories/                               # User story implementations
│   ├── 1.1.project-structure-dev-environment-setup.md
│   └── 1.2.angular-poseidon-theme-integration.md
│
├── qa/                                    # Quality assurance
│   ├── assessments/                       # Risk assessments
│   │   └── 1.2-risk-20250818.md
│   └── gates/                            # Quality gates
│       └── 1.1-project-structure-dev-environment-setup.yml
│
└── brainstorming-session-results.md       # Design session notes
```

## Infrastructure & Deployment (Hạ tầng & Triển khai)

### Docker Configuration (Cấu hình Docker)

```
infrastructure/
└── docker/
    ├── docker-compose.dev.yml     # Development environment
    ├── docker-compose.prod.yml    # Production environment
    ├── Dockerfile.api             # Backend container definition
    ├── Dockerfile.web             # Frontend container definition
    ├── nginx.conf                 # Reverse proxy configuration
    └── init-scripts/              # Database initialization
        └── 01-vietnamese-collation.sql  # Vietnamese text support
```


## Key Files for Restaurant Implementation (File Quan trọng cho Triển khai Nhà hàng)

### Critical Backend Files (File Backend Quan trọng)

- `SmartRestaurantDbContext.cs` - Main database context for restaurant entities
- `SmartRestaurantPermissions.cs` - Role-based access control definitions
- `vi.json` - Vietnamese localization for restaurant terminology
- `SmartRestaurantAppService.cs` - Core restaurant business logic
- `appsettings.json` - Production configuration with PostgreSQL connection

### Critical Frontend Files (File Frontend Quan trọng)

- `app.config.ts` - Angular application configuration with ABP integration
- `shared.module.ts` - Shared components for restaurant workflows
- `environment.ts` - Development environment with API endpoints
- `styles.scss` - Global styles including Vietnamese font support

### Critical Flutter Mobile Files (File Flutter Mobile Quan trọng)

- `main.dart` - Flutter application entry point and configuration
- `pubspec.yaml` - Flutter dependencies and Vietnamese localization setup
- `api_client.dart` - RESTful API client connecting to ABP backend
- `auth_service.dart` - Authentication service with ABP Identity integration
- `vietnamese_formatter.dart` - Vietnamese text formatting utilities
- `vietnamese_constants.dart` - Vietnamese restaurant terminology and text
- `orders_screen.dart` - Order management interface for restaurant staff
- `reservations_screen.dart` - Table reservation system for customers

### Theme Integration Files (File Tích hợp Theme)

- `layout.service.ts` - Theme state management and customization
- `layout.scss` - Main layout stylesheet for customization
- `tailwind.config.js` - Responsive design configuration
- `app.layout.ts` - Layout wrapper for restaurant interface

### Infrastructure Files (File Hạ tầng)

- `docker-compose.dev.yml` - Development environment with PostgreSQL + in-memory cache
- `01-vietnamese-collation.sql` - Database setup for Vietnamese text support
- `Dockerfile.api` - Backend containerization
- `nginx.conf` - Reverse proxy for production deployment

## Development Workflow Files (File Quy trình Phát triển)

### ABP Framework Integration (Tích hợp ABP Framework)

- **Proxy Generation**: Auto-generated TypeScript services from backend APIs
- **Migration Files**: EF Core migrations for database schema changes  
- **Localization Files**: Multi-language support with Vietnamese primary
- **Permission System**: Role-based access control for restaurant staff
- **Configuration**: Environment-specific settings for development/production

### Testing Infrastructure (Hạ tầng Kiểm thử)

- **Backend Tests**: xUnit + Moq for .NET testing
- **Frontend Tests**: Jasmine + Karma for Angular testing
- **Integration Tests**: End-to-end testing with Playwright
- **Test Data**: Vietnamese restaurant sample data for testing

This source tree provides a comprehensive foundation for the Vietnamese restaurant management system with proper separation of concerns, ABP Framework best practices, and integration with modern frontend technologies.