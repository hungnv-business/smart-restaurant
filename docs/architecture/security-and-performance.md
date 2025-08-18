# Security and Performance

## Security Requirements (Yêu cầu Bảo mật)

**Frontend Security:**
- CSP Headers: `default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data: https:;`
- XSS Prevention: Angular's built-in sanitization + CSP headers + input validation
- Secure Storage: JWT tokens in httpOnly cookies, sensitive data not in localStorage

**Backend Security:**
- Input Validation: ABP Framework automatic validation + custom Vietnamese-specific validators
- Rate Limiting: 100 requests per minute per IP, 1000 requests per minute per authenticated user
- CORS Policy: Restrict to frontend domain only, credentials allowed for same-origin

**Authentication Security:**
- Token Storage: JWT in httpOnly cookies with secure flag and SameSite=Strict
- Session Management: ABP Framework session management with Redis backing store
- Password Policy: Minimum 8 characters, require uppercase, lowercase, numbers for admin accounts

## Performance Optimization (Tối ưu hóa Hiệu suất)

**Frontend Performance:**
- Bundle Size Target: < 500KB main bundle, < 100KB per lazy-loaded route
- Loading Strategy: Lazy loading for feature modules, preloading strategy for critical routes
- Caching Strategy: Service worker for offline capability, HTTP caching for static assets

**Backend Performance:**
- Response Time Target: < 200ms for menu queries, < 500ms for order processing
- Database Optimization: Indexes on frequently queried columns, Vietnamese text search optimization
- Caching Strategy: Redis for menu data (5 min TTL), table status (real-time), user sessions
