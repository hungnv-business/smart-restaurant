# SmartRestaurant - Vietnamese Restaurant Management System

A comprehensive restaurant management system built with modern technologies and Vietnamese localization.

## 🏗️ Architecture

- **Backend**: ABP Framework 8.0 + .NET 8 + PostgreSQL
- **Frontend**: Angular 19 + PrimeNG + TypeScript
- **Mobile**: Flutter 3.35.1 (Vietnamese restaurant workflows)
- **Infrastructure**: Docker + Docker Compose
- **Database**: PostgreSQL 15+ with Vietnamese collation

## 🚀 Quick Start

### Prerequisites

- .NET 8 SDK
- Node.js 20+
- Docker & Docker Compose
- ABP CLI: `dotnet tool install -g Volo.Abp.Cli`

### Development Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart-restaurant
   ```

2. **Start with Docker (Recommended)**
   ```bash
   npm run docker:dev
   ```

3. **Or run locally**
   ```bash
   # Install dependencies
   npm install
   
   # Start database (PostgreSQL)
   cd infrastructure/docker
   docker-compose -f docker-compose.dev.yml up postgres -d
   
   # Run migrations
   npm run migrate
   
   # Start development servers
   npm run dev
   ```

4. **Access the application**
   - Frontend: http://localhost:4200
   - Backend API: https://localhost:44391
   - Swagger UI: https://localhost:44391/swagger

### Default Credentials
- Username: `admin`
- Password: `1q2w3E*`

## 📁 Project Structure

```
smart-restaurant/
├── aspnet-core/          # ABP Framework Backend (.NET 8)
├── angular/              # Angular 19 Frontend  
├── flutter_mobile/       # Flutter Mobile App (Vietnamese workflows)
├── infrastructure/       # Docker & deployment configs
├── docs/                 # Documentation
└── package.json          # Root scripts & workspace config
```

## 🛠️ Development Commands

### Backend (.NET)
```bash
# Run API server
npm run dev:api

# Run database migrations  
npm run migrate

# Run tests
npm run test:backend

# Generate new migration
cd aspnet-core
dotnet ef migrations add MigrationName -p src/SmartRestaurant.EntityFrameworkCore
```

### Frontend (Angular)
```bash
# Run development server
npm run dev:web

# Generate ABP proxies (after backend changes)
npm run generate-proxy

# Install ABP libraries
npm run install-libs

# Run tests
npm run test:frontend
```

### Mobile (Flutter)
```bash
# Run Flutter mobile app
npm run dev:mobile

# Run mobile tests  
npm run test:mobile

# Build mobile app
npm run build:mobile
```

### Full Stack
```bash
# Run both API and Web
npm run dev

# Run all tests
npm run test

# Build for production
npm run build
```

### Docker
```bash
# Development environment
npm run docker:dev

# Production environment  
npm run docker:prod

# Stop containers
npm run docker:dev:down
```

## 🌐 Vietnamese Features

- **Localization**: Full Vietnamese language support
- **Currency**: Vietnamese Dong (₫) formatting
- **Text Search**: Diacritics-aware search (Phở, Cơm, etc.)
- **Date/Time**: Vietnamese locale formatting
- **Restaurant Data**: Vietnamese menu items and workflows

## 🔧 Configuration

### Environment Variables
Copy `.env.example` to `.env` and configure:

```env
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your_password
API_BASE_URL=https://api.yourdomain.com
WEB_BASE_URL=https://yourdomain.com
```

### Database Connection
Update `aspnet-core/src/SmartRestaurant.HttpApi.Host/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "Default": "User ID=postgres;Password=postgres;Host=localhost;Port=5432;Database=SmartRestaurant;"
  }
}
```

## 🧪 Testing

### Unit Tests
```bash
# Backend tests
npm run test:backend

# Frontend tests  
npm run test:frontend
```

### Integration Tests
```bash
# End-to-end tests
npm run test:e2e
```

### Test Data
The system includes Vietnamese restaurant test data:
- Menu items: Phở Bò, Cơm Tấm, Bún Bò Huế
- Currency: Vietnamese Dong (₫)
- Proper Vietnamese text sorting

## 📚 Documentation

- [Development Guide](./CLAUDE.md) - Detailed setup and troubleshooting
- [Architecture Overview](./docs/architecture/index.md)
- [API Documentation](https://localhost:44391/swagger) (when running)
- [ABP Framework Docs](https://docs.abp.io)

## 🏃‍♂️ Development Workflow

1. **Creating new features**:
   - Add domain entities in `SmartRestaurant.Domain`
   - Create application services in `SmartRestaurant.Application`
   - Generate Angular proxies: `npm run generate-proxy`
   - Build frontend components

2. **Database changes**:
   - Add/modify entities
   - Create migration: `dotnet ef migrations add MigrationName`
   - Apply migration: `npm run migrate`

3. **Testing**:
   - Write unit tests for services
   - Add integration tests for APIs
   - Test Vietnamese text handling

## 🐛 Troubleshooting

### Common Issues

1. **ABP CLI not found**
   ```bash
   dotnet tool install -g Volo.Abp.Cli
   ```

2. **Database connection failed**
   ```bash
   # Check PostgreSQL is running
   docker ps | grep postgres
   npm run docker:dev
   ```

3. **Proxy generation failed**
   ```bash
   # Ensure API is running first
   npm run dev:api
   # Then in another terminal
   npm run generate-proxy
   ```

4. **Vietnamese characters not displaying**
   - Verify database encoding is UTF8
   - Check locale settings
   - Ensure Vietnamese collation is configured

See [CLAUDE.md](./CLAUDE.md) for detailed troubleshooting guide.

## 🚢 Deployment

### Production Deployment
```bash
# Build and deploy with Docker
npm run docker:prod

# Or build manually
npm run build
```

### Environment Setup
- Configure SSL certificates in `infrastructure/docker/ssl/`
- Update environment variables in `.env`
- Set up domain names and DNS

## 🤝 Contributing

1. Fork the repository
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Open pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🍜 Vietnamese Restaurant Features

This system is specifically designed for Vietnamese restaurants with:

- **Menu Management**: Vietnamese dish categories and items
- **Order Processing**: Table-based ordering with Vietnamese workflows  
- **Kitchen Display**: Real-time order updates in Vietnamese
- **Payment**: Support for Vietnamese payment methods
- **Reports**: Vietnamese currency and date formatting
- **Staff Management**: Role-based access for Vietnamese restaurant staff

---

Built with ❤️ for Vietnamese restaurants using ABP Framework and Angular.