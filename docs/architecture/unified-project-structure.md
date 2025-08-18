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
│   │   │   ├── app.component.ts    # Root application component
│   │   │   ├── app.config.ts       # Application configuration
│   │   │   ├── app.routes.ts       # Routing configuration
│   │   │   ├── home/               # Home feature module
│   │   │   │   ├── home.component.ts
│   │   │   │   ├── home.component.html
│   │   │   │   ├── home.component.scss
│   │   │   │   ├── home.component.spec.ts
│   │   │   │   └── home.routes.ts
│   │   │   └── layout/             # Poseidon theme layout
│   │   │       ├── components/     # Layout UI components
│   │   │       │   ├── app.breadcrumb.ts
│   │   │       │   ├── app.configurator.ts
│   │   │       │   ├── app.footer.ts
│   │   │       │   ├── app.menu.ts
│   │   │       │   ├── app.menuitem.ts
│   │   │       │   ├── app.rightmenu.ts
│   │   │       │   ├── app.search.ts
│   │   │       │   ├── app.sidebar.ts
│   │   │       │   ├── app.topbar.ts
│   │   │       │   └── restaurant.layout.ts
│   │   │       └── service/
│   │   │           └── layout.service.ts
│   │   ├── assets/                 # Static assets and themes
│   │   │   ├── demo/               # Poseidon demo assets
│   │   │   └── layout/             # Theme styles and images
│   │   ├── favicon.ico
│   │   ├── index.html
│   │   ├── main.ts
│   │   ├── styles.scss
│   │   └── tailwind.css
│   ├── angular.json                # Angular configuration
│   ├── karma.conf.js               # Test configuration
│   ├── package.json                # Dependencies
│   ├── tailwind.config.js          # Tailwind CSS config
│   ├── tsconfig.json               # TypeScript configuration
│   ├── tsconfig.app.json           # App TypeScript config
│   ├── tsconfig.spec.json          # Test TypeScript config
│   └── yarn.lock                   # Dependency lock file
├── flutter_mobile/                 # Flutter mobile apps
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
├── infrastructure/                 # Docker & deployment
│   └── docker/
│       ├── docker-compose.dev.yml  # Development environment
│       ├── docker-compose.prod.yml # Production environment
│       ├── Dockerfile.api          # Backend container
│       ├── Dockerfile.web          # Frontend container
│       ├── nginx.conf              # Nginx configuration
│       └── init-scripts/           # Database initialization
│           └── 01-vietnamese-collation.sql
├── docs/                           # Documentation
│   ├── architecture.md             # Main architecture overview
│   ├── architecture/               # Detailed architecture documents
│   ├── prd.md                      # Product Requirements Document
│   ├── prd/                        # Detailed PRD and epics
│   │   └── epics/                  # Individual epic specifications
│   ├── qa/                         # Quality assurance
│   │   ├── assessments/            # Risk assessments
│   │   └── gates/                  # Quality gates
│   ├── stories/                    # User story implementations
│   └── brainstorming-session-results.md
├── .env.example                    # Environment template
├── CLAUDE.md                       # Development environment guide
├── README.md                       # Project overview
├── package.json                    # Root workspace configuration
├── package-lock.json               # NPM lock file
└── yarn.lock                       # Yarn lock file
```

**Root Package.json Scripts for ABP Workflow (Script Package.json Gốc cho ABP Workflow):**
```json
{
  "scripts": {
    "dev": "concurrently \"npm run dev:api\" \"npm run dev:web\"",
    "dev:api": "cd aspnet-core && dotnet run --project src/SmartRestaurant.HttpApi.Host",
    "dev:web": "cd angular && npm start",
    "dev:mobile": "cd flutter_mobile && flutter run",
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
