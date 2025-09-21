import { Injectable, OnDestroy } from '@angular/core';
import { HubConnection, HubConnectionBuilder, LogLevel } from '@microsoft/signalr';
import { BehaviorSubject, Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

export interface KitchenUpdateEvent {
  type:
    | 'NEW_ORDER_RECEIVED'
    | 'ORDER_ITEM_QUANTITY_UPDATED'
    | 'ORDER_ITEMS_ADDED'
    | 'ORDER_ITEM_REMOVED'
    | 'ORDER_ITEM_SERVED';
  order?: unknown;
  orderId?: string;
  orderNumber?: string;
  tableId?: string;
  tableName?: string;
  orderItemId?: string;
  menuItemName?: string;
  newQuantity?: number;
  addedItemsDetail?: string;
  quantity?: number;
  message?: string;
  notifiedAt?: Date;
  updatedAt?: Date;
  addedAt?: Date;
  removedAt?: Date;
  servedAt?: Date;
}

@Injectable({
  providedIn: 'root',
})
export class KitchenSignalRService implements OnDestroy {
  private hubConnection: HubConnection | null = null;
  private connectionState$ = new BehaviorSubject<'disconnected' | 'connecting' | 'connected'>(
    'disconnected',
  );
  private kitchenUpdates$ = new BehaviorSubject<KitchenUpdateEvent | null>(null);

  // Reconnect logic
  private reconnectAttempts = 0;
  private readonly maxReconnectAttempts = 10;
  private reconnectTimeouts = [1000, 2000, 5000, 10000, 30000]; // ms
  private reconnectTimer: ReturnType<typeof setTimeout> | null = null;

  constructor() {
    // Initialize connection will be called manually when needed
  }

  ngOnDestroy(): void {
    // Clear reconnect timer
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }
    this.disconnect();
  }

  /**
   * Khởi tạo SignalR connection
   */
  private initializeConnection(): void {
    const hubUrl = `${environment.apis.default.url}/signalr-hubs/kitchen`;

    this.hubConnection = new HubConnectionBuilder()
      .withUrl(hubUrl, {
        accessTokenFactory: () => {
          // Lấy access token từ ABP auth với retry logic
          const token =
            localStorage.getItem('access_token') || sessionStorage.getItem('access_token');
          if (!token) {
            console.warn('🔑 KitchenSignalR: No access token found for SignalR connection');
          } else {
            console.log('🔑 KitchenSignalR: Using access token for connection');
          }
          return token || '';
        },
      })
      .withAutomaticReconnect([0, 2000, 10000, 30000]) // Retry intervals in ms
      .configureLogging(LogLevel.Information)
      .build();

    // Setup event handlers
    this.setupEventHandlers();
  }

  /**
   * Setup các event handlers cho SignalR
   */
  private setupEventHandlers(): void {
    if (!this.hubConnection) return;

    // Connection state events
    this.hubConnection.onreconnecting(() => {
      this.connectionState$.next('connecting');
    });

    this.hubConnection.onreconnected(() => {
      this.connectionState$.next('connected');
      this.reconnectAttempts = 0; // Reset attempts
    });

    this.hubConnection.onclose(async error => {
      this.connectionState$.next('disconnected');
      console.warn('🔌 KitchenSignalR: Connection closed', error);

      // Bắt đầu quá trình reconnect
      this.startReconnectProcess();
    });

    // Lắng nghe sự kiện đơn hàng mới từ mobile
    this.hubConnection.on('NewOrderReceived', (data: KitchenNotification) => {
      this.kitchenUpdates$.next({
        type: 'NEW_ORDER_RECEIVED',
        order: data.Order || data.order,
        message: data.Message || data.message,
        notifiedAt: new Date(data.NotifiedAt || data.notifiedAt),
      });
    });

    // Lắng nghe sự kiện cập nhật số lượng món từ mobile
    this.hubConnection.on('OrderItemQuantityUpdated', (data: KitchenNotification) => {
      this.kitchenUpdates$.next({
        type: 'ORDER_ITEM_QUANTITY_UPDATED',
        tableName: data.TableName || data.tableName,
        orderItemId: data.OrderItemId || data.orderItemId,
        menuItemName: data.MenuItemName || data.menuItemName,
        newQuantity: data.NewQuantity || data.newQuantity,
        message: data.Message || data.message,
        updatedAt: new Date(data.UpdatedAt || data.updatedAt),
      });
    });

    // Lắng nghe sự kiện thêm món vào order từ mobile
    this.hubConnection.on('OrderItemsAdded', (data: KitchenNotification) => {
      this.kitchenUpdates$.next({
        type: 'ORDER_ITEMS_ADDED',
        tableName: data.TableName || data.tableName,
        addedItemsDetail: data.AddedItemsDetail || data.addedItemsDetail,
        message: data.Message || data.message,
        addedAt: new Date(data.AddedAt || data.addedAt),
      });
    });

    // Lắng nghe sự kiện xóa món khỏi order từ mobile
    this.hubConnection.on('OrderItemRemoved', (data: KitchenNotification) => {
      this.kitchenUpdates$.next({
        type: 'ORDER_ITEM_REMOVED',
        tableName: data.TableName || data.tableName,
        orderItemId: data.OrderItemId || data.orderItemId,
        menuItemName: data.MenuItemName || data.menuItemName,
        quantity: data.Quantity || data.quantity,
        message: data.Message || data.message,
        removedAt: new Date(data.RemovedAt || data.removedAt),
      });
    });

    // Lắng nghe sự kiện món đã được phục vụ từ mobile
    this.hubConnection.on('OrderItemServed', (data: KitchenNotification) => {
      this.kitchenUpdates$.next({
        type: 'ORDER_ITEM_SERVED',
        orderId: data.OrderId || data.orderId,
        orderNumber: data.OrderNumber || data.orderNumber,
        menuItemName: data.MenuItemName || data.menuItemName,
        quantity: data.Quantity || data.quantity,
        tableName: data.TableName || data.tableName,
        tableId: data.TableId || data.tableId,
        message: data.Message || data.message,
        servedAt: new Date(data.ServedAt || data.servedAt),
      });
    });

    // Lắng nghe confirmation khi join Kitchen group thành công
    this.hubConnection.on('JoinedKitchenGroup', (data: unknown) => {
      console.log('✅ KitchenSignalR: Successfully joined Kitchen group', data);
    });
  }

  /**
   * Kết nối đến SignalR Hub
   */
  async connect(): Promise<void> {
    if (!this.hubConnection) {
      this.initializeConnection();
    }

    if (this.hubConnection?.state === 'Connected') {
      return;
    }

    try {
      this.connectionState$.next('connecting');
      await this.hubConnection!.start();
      this.connectionState$.next('connected');
    } catch (error) {
      this.connectionState$.next('disconnected');
      throw error;
    }
  }

  /**
   * Ngắt kết nối
   */
  async disconnect(): Promise<void> {
    if (this.hubConnection) {
      try {
        await this.hubConnection.stop();
      } catch (error) {
        // Silent error handling
      }
    }
  }

  /**
   * Observable cho connection state
   */
  getConnectionState(): Observable<'disconnected' | 'connecting' | 'connected'> {
    return this.connectionState$.asObservable();
  }

  /**
   * Observable cho kitchen updates
   */
  getKitchenUpdates(): Observable<KitchenUpdateEvent | null> {
    return this.kitchenUpdates$.asObservable();
  }

  /**
   * Kiểm tra trạng thái kết nối hiện tại
   */
  get isConnected(): boolean {
    return this.hubConnection?.state === 'Connected';
  }

  /**
   * Lấy connection state hiện tại
   */
  get currentConnectionState(): 'disconnected' | 'connecting' | 'connected' {
    return this.connectionState$.value;
  }

  /**
   * Bắt đầu quá trình reconnect với exponential backoff
   */
  private startReconnectProcess(): void {
    // Clear any existing reconnect timer
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = null;
    }

    // Reset attempts nếu đã vượt quá max
    if (this.reconnectAttempts >= this.maxReconnectAttempts) {
      this.reconnectAttempts = 0;
      return;
    }

    // Tính thời gian delay
    const timeoutIndex = Math.min(this.reconnectAttempts, this.reconnectTimeouts.length - 1);
    const delay = this.reconnectTimeouts[timeoutIndex];

    this.reconnectTimer = setTimeout(async () => {
      this.reconnectAttempts++;
      this.connectionState$.next('connecting');

      try {
        await this.connect();
        // Reset attempts nếu kết nối thành công
        this.reconnectAttempts = 0;
      } catch (error) {
        // Thử lại nếu chưa đạt max attempts
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
          this.startReconnectProcess();
        } else {
          this.connectionState$.next('disconnected');
        }
      }
    }, delay);
  }
}
