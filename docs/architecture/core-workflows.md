# Core Workflows

## Order Processing Workflow (Quy trình Xử lý Đơn hàng)

```mermaid
sequenceDiagram
    participant S as Staff (Angular)
    participant API as ABP API
    participant Hub as SignalR Hub
    participant K as Kitchen (Display)
    participant P as Printer
    participant DB as PostgreSQL
    
    S->>API: Select Table
    API->>DB: Update table status
    S->>API: Browse Menu & Add Items
    API->>DB: Validate menu availability
    S->>API: Confirm Order
    API->>DB: Create order record
    API->>Hub: Broadcast new order
    Hub->>K: Real-time order display
    API->>P: Print kitchen bill
    P->>K: Physical bill printed
    
    K->>Hub: Update cooking status
    Hub->>API: Status change event
    API->>DB: Update order status
    Hub->>S: Real-time status update
    
    S->>API: Confirm order ready
    API->>DB: Mark order complete
    S->>API: Process payment
    API->>DB: Create payment record
    S->>API: Confirm payment received
    API->>DB: Complete transaction
    API->>Hub: Reset table status
    Hub->>S: Table available
```

## Vietnamese Payment Workflow (Quy trình Thanh toán Việt Nam)

```mermaid
sequenceDiagram
    participant S as Staff
    participant API as Payment API
    participant QR as QR Service
    participant Bank as Vietnamese Bank
    participant C as Customer
    participant P as Printer
    
    S->>API: Initiate payment
    API->>P: Print detailed invoice
    P->>C: Invoice with QR code
    
    alt Cash Payment
        C->>S: Pay cash
        S->>API: Confirm cash received
        API->>API: Complete payment
    else Bank Transfer
        C->>Bank: Scan QR & transfer
        Bank->>C: Transfer confirmation
        S->>API: Confirm transfer received
        API->>API: Complete payment
    end
    
    API->>API: Reset table status
    API->>S: Payment completed
```

## Kitchen Priority Management Workflow (Quy trình Quản lý Ưu tiên Bếp)

```mermaid
sequenceDiagram
    participant K as Kitchen Staff
    participant Hub as SignalR Hub
    participant API as Kitchen API
    participant Algo as Priority Algorithm
    
    Hub->>K: New orders received
    K->>API: Request priority view
    API->>Algo: Calculate cooking priorities
    Algo->>API: FIFO + Quick-cook suggestions
    API->>K: Optimized cooking sequence
    
    K->>Hub: Start cooking item
    Hub->>API: Update item status
    K->>Hub: Item ready
    Hub->>API: Mark item complete
    API->>Hub: Broadcast to staff
    Hub->>K: Updated priority list
```
