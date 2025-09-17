import { Injectable, OnDestroy } from '@angular/core';
import { HubConnection, HubConnectionBuilder, LogLevel } from '@microsoft/signalr';
import { BehaviorSubject, Observable } from 'rxjs';
import { environment } from '../../../../environments/environment';

export interface KitchenUpdateEvent {
  type: 'ORDER_STATUS_CHANGED' | 'NEW_ORDER_RECEIVED' | 'ITEM_PRIORITY_UPDATED';
  orderItemId?: string;
  orderId?: string;
  tableNumber?: string;
  status?: number;
  message?: string;
}

@Injectable({
  providedIn: 'root'
})
export class KitchenSignalRService implements OnDestroy {
  private hubConnection: HubConnection | null = null;
  private connectionState$ = new BehaviorSubject<'disconnected' | 'connecting' | 'connected'>('disconnected');
  private kitchenUpdates$ = new BehaviorSubject<KitchenUpdateEvent | null>(null);

  constructor() {
    // Initialize connection will be called manually when needed
  }

  ngOnDestroy(): void {
    this.disconnect();
  }

  /**
   * Khởi tạo SignalR connection
   */
  private initializeConnection(): void {
    const hubUrl = `${environment.apis.default.url}/hubs/kitchen-priority`;
    
    this.hubConnection = new HubConnectionBuilder()
      .withUrl(hubUrl, {
        accessTokenFactory: () => {
          // Lấy access token từ ABP auth
          const token = localStorage.getItem('access_token') || sessionStorage.getItem('access_token');
          return token || '';
        }
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
      console.log('Kitchen SignalR: Đang kết nối lại...');
    });

    this.hubConnection.onreconnected(() => {
      this.connectionState$.next('connected');
      console.log('Kitchen SignalR: Đã kết nối lại thành công');
      this.joinKitchenGroup();
    });

    this.hubConnection.onclose(() => {
      this.connectionState$.next('disconnected');
      console.log('Kitchen SignalR: Kết nối đã đóng');
    });

    // Kitchen-specific events
    this.hubConnection.on('OrderStatusChanged', (data: any) => {
      console.log('Kitchen SignalR: Order status changed', data);
      this.kitchenUpdates$.next({
        type: 'ORDER_STATUS_CHANGED',
        orderItemId: data.orderItemId,
        orderId: data.orderId,
        tableNumber: data.tableNumber,
        status: data.status,
        message: `Trạng thái món "${data.menuItemName}" đã thay đổi`
      });
    });

    this.hubConnection.on('NewOrderReceived', (data: any) => {
      console.log('Kitchen SignalR: New order received', data);
      this.kitchenUpdates$.next({
        type: 'NEW_ORDER_RECEIVED',
        orderId: data.orderId,
        tableNumber: data.tableNumber,
        message: `Có đơn hàng mới từ bàn ${data.tableNumber}`
      });
    });

    this.hubConnection.on('ItemPriorityUpdated', (data: any) => {
      console.log('Kitchen SignalR: Item priority updated', data);
      this.kitchenUpdates$.next({
        type: 'ITEM_PRIORITY_UPDATED',
        orderItemId: data.orderItemId,
        message: `Độ ưu tiên món đã được cập nhật`
      });
    });

    // Generic message handler
    this.hubConnection.on('ReceiveMessage', (user: string, message: string) => {
      console.log('Kitchen SignalR: Generic message', { user, message });
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
      console.log('Kitchen SignalR: Đã kết nối thành công');
      
      // Join kitchen group sau khi kết nối thành công
      await this.joinKitchenGroup();
    } catch (error) {
      this.connectionState$.next('disconnected');
      console.error('Kitchen SignalR: Lỗi kết nối', error);
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
        console.log('Kitchen SignalR: Đã ngắt kết nối');
      } catch (error) {
        console.error('Kitchen SignalR: Lỗi ngắt kết nối', error);
      }
    }
  }

  /**
   * Join kitchen group để nhận updates
   */
  private async joinKitchenGroup(): Promise<void> {
    if (this.hubConnection?.state === 'Connected') {
      try {
        // Hub tự động join vào "AllKitchens" group khi connect
        // Có thể join vào station cụ thể nếu cần
        await this.hubConnection.invoke('JoinKitchenStation', 'General');
        console.log('Kitchen SignalR: Đã tham gia kitchen group');
      } catch (error) {
        console.error('Kitchen SignalR: Lỗi tham gia kitchen group', error);
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
}