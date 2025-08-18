# External APIs

## Vietnamese Banking QR Payment API (API Thanh toán QR Ngân hàng Việt Nam)

- **Purpose:** QR code generation for bank transfer payments
- **Documentation:** https://developer.vietqr.io/docs/api
- **Base URL(s):** https://api.vietqr.io/v2/
- **Authentication:** API Key authentication
- **Rate Limits:** 1000 requests per hour

**Key Endpoints Used:**
- `POST /generate` - Generate QR payment code
- `GET /banks` - Get supported Vietnamese banks list

**Integration Notes:** Vietnamese banking standard for QR payments, supports major banks (Vietcombank, BIDV, Techcombank, etc.), manual confirmation required by staff

## Kitchen Printer Integration (Tích hợp Máy in Bếp)

- **Purpose:** Direct printing to ESC/POS compatible kitchen printers
- **Documentation:** ESC/POS command specification
- **Base URL(s):** Local network printer IP addresses
- **Authentication:** Network printer access
- **Rate Limits:** Hardware-dependent

**Key Endpoints Used:**
- Direct socket connection for ESC/POS commands
- Print job management via network protocols

**Integration Notes:** Support for Vietnamese text encoding, kitchen station routing (Hotpot, Grilled, Drinking), receipt formatting for restaurant workflows
