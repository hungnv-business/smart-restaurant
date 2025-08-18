# Source Tree (Cây Mã nguồn)

## Project Root Structure (Cấu trúc Gốc Dự án)

```
smart-restaurant/
├── .bmad-core/                     # BMaD Method configuration and templates
├── aspnet-core/                    # ABP Framework backend (.NET 8)
├── angular/                        # Angular 19 frontend application
├── docs/                          # Project documentation
├── infrastructure/                # Docker and deployment configuration
├── poseidon-ng-19.0.0/           # Poseidon PrimeNG theme template
├── CLAUDE.md                      # Development environment guide
├── README.md                      # Project overview
├── package.json                   # Root workspace configuration
└── yarn.lock                      # Dependency lock file
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
    │   ├── wwwroot/                        # Static files
    │   │   ├── global-styles.css
    │   │   └── images/
    │   ├── Program.cs                      # Application entry point
    │   ├── appsettings.json               # Production configuration
    │   ├── appsettings.Development.json   # Development configuration
    │   ├── package.json                   # Frontend assets
    │   └── web.config                     # IIS configuration
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
├── tsconfig.json                 # TypeScript configuration
├── yarn.lock                     # Dependency lock file
└── src/
    ├── app/
    │   ├── app.component.ts      # Root application component
    │   ├── app.config.ts         # Application configuration
    │   ├── app.routes.ts         # Routing configuration
    │   ├── route.provider.ts     # Route provider service
    │   ├── home/                 # Home feature module
    │   │   ├── home.component.ts
    │   │   ├── home.component.html
    │   │   ├── home.component.scss
    │   │   ├── home.component.spec.ts
    │   │   └── home.routes.ts
    │   └── shared/               # Shared components and services
    │       └── shared.module.ts
    │
    ├── assets/                   # Static assets
    │   ├── images/              # Application images
    │   │   ├── getting-started/ # ABP getting started assets
    │   │   └── logo/           # Brand logos
    │   │       ├── logo-light.png
    │   │       └── logo-light-thumbnail.png
    │
    ├── environments/            # Environment configurations
    │   ├── environment.ts       # Development environment
    │   └── environment.prod.ts  # Production environment
    │
    ├── favicon.ico             # Website icon
    ├── index.html              # Main HTML file
    ├── main.ts                 # Application bootstrap
    ├── polyfills.ts            # Browser compatibility
    ├── styles.scss             # Global styles
    └── test.ts                 # Test configuration
```

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

## Poseidon Theme Template (Template Theme Poseidon)

### Theme Structure (Cấu trúc Theme)

```
poseidon-ng-19.0.0/                    # PrimeNG Poseidon theme v19.0.0
├── README.md                          # Theme documentation
├── CHANGELOG.md                       # Version history
├── LICENSE.md                         # License information
├── package.json                       # Theme dependencies
├── angular.json                       # Angular configuration
├── tailwind.config.js                 # Tailwind CSS configuration
├── tsconfig.json                      # TypeScript configuration
│
├── src/
│   ├── app/
│   │   ├── layout/                    # Layout components
│   │   │   ├── components/            # UI components
│   │   │   │   ├── app.layout.ts      # Main layout wrapper
│   │   │   │   ├── app.topbar.ts      # Top navigation bar
│   │   │   │   ├── app.sidebar.ts     # Side navigation
│   │   │   │   ├── app.menu.ts        # Menu component
│   │   │   │   ├── app.breadcrumb.ts  # Breadcrumb navigation
│   │   │   │   ├── app.footer.ts      # Footer component
│   │   │   │   ├── app.configurator.ts # Theme configurator
│   │   │   │   ├── app.search.ts      # Search functionality
│   │   │   │   └── app.rightmenu.ts   # Right menu panel
│   │   │   └── service/
│   │   │       └── layout.service.ts  # Layout state management
│   │   │
│   │   ├── apps/                      # Sample applications
│   │   ├── pages/                     # Sample pages
│   │   ├── types/                     # TypeScript interfaces
│   │   └── lib/
│   │       └── utils.ts               # Utility functions
│   │
│   ├── assets/
│   │   ├── demo/                      # Demo-specific styles
│   │   └── layout/                    # Core layout styles
│   │       ├── layout.scss            # Main layout stylesheet
│   │       ├── _breadcrumb.scss       # Breadcrumb styles
│   │       ├── _topbar.scss           # Top bar styles
│   │       ├── _responsive.scss       # Responsive design
│   │       ├── _mixins.scss           # SCSS mixins
│   │       └── _utils.scss            # Utility classes
│   │
│   ├── styles.scss                    # Global styles
│   ├── tailwind.css                   # Tailwind base styles
│   └── main.ts                        # Application entry point
│
└── public/                            # Static assets
    ├── demo/                          # Demo data and images
    │   ├── data/                      # Sample JSON data
    │   └── images/                    # Demo images and icons
    ├── images/                        # Theme images and logos
    └── layout/                        # Layout-specific assets
        ├── images/                    # Layout images
        └── styles/                    # Additional styles
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

### Theme Integration Files (File Tích hợp Theme)

- `layout.service.ts` - Theme state management and customization
- `layout.scss` - Main layout stylesheet for customization
- `tailwind.config.js` - Responsive design configuration
- `app.layout.ts` - Layout wrapper for restaurant interface

### Infrastructure Files (File Hạ tầng)

- `docker-compose.dev.yml` - Development environment with PostgreSQL + Redis
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