import { Injectable } from '@angular/core';

export interface NotificationSoundConfig {
  enabled: boolean;
  volume: number; // 0.0 to 1.0
  speechEnabled: boolean; // Text-to-speech
  speechRate: number; // 0.1 to 10 (tốc độ đọc)
  speechPitch: number; // 0 to 2 (cao độ giọng)
  speechVoice: string; // Giọng đọc
  sounds: {
    newOrder: string;
    itemUpdate: string;
    itemRemoved: string;
    itemAdded: string;
  };
}

@Injectable({
  providedIn: 'root',
})
export class NotificationSoundService {
  private audioContext: AudioContext | null = null;
  private sounds: Map<string, AudioBuffer> = new Map();

  private config: NotificationSoundConfig = {
    enabled: true,
    volume: 0.7,
    speechEnabled: true,
    speechRate: 0.9,
    speechPitch: 1.0,
    speechVoice: 'vi-VN', // Vietnamese voice preference
    sounds: {
      newOrder: '/assets/sounds/new-order.mp3',
      itemUpdate: '/assets/sounds/new-order.mp3', // Dùng chung âm thanh new-order
      itemRemoved: '/assets/sounds/new-order.mp3', // Dùng chung âm thanh new-order
      itemAdded: '/assets/sounds/new-order.mp3', // Dùng chung âm thanh new-order
    },
  };

  private speechSynthesis: SpeechSynthesis | null = null;
  private availableVoices: SpeechSynthesisVoice[] = [];

  constructor() {
    this.initializeAudioContext();
    this.loadSounds();
    this.initializeSpeechSynthesis();
  }

  /**
   * Khởi tạo AudioContext (cần user interaction trước)
   */
  private async initializeAudioContext(): Promise<void> {
    try {
      this.audioContext = new (window.AudioContext ||
        (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext)();
    } catch (error) {
      // Silent error handling
    }
  }

  /**
   * Load các file âm thanh
   */
  private async loadSounds(): Promise<void> {
    if (!this.audioContext) return;

    for (const [key, url] of Object.entries(this.config.sounds)) {
      try {
        const response = await fetch(url);
        if (response.ok) {
          const arrayBuffer = await response.arrayBuffer();
          const audioBuffer = await this.audioContext.decodeAudioData(arrayBuffer);
          this.sounds.set(key, audioBuffer);
        }
      } catch (error) {
        // Fallback to simple beep for missing sounds
        this.createBeepSound(key);
      }
    }
  }

  /**
   * Tạo âm thanh beep đơn giản khi không load được file - dùng chung 1 âm thanh
   */
  private createBeepSound(key: string): void {
    if (!this.audioContext) return;

    const sampleRate = this.audioContext.sampleRate;
    const duration = 0.2; // 200ms
    const frequency = 800; // Dùng chung tần số 800Hz cho tất cả

    const buffer = this.audioContext.createBuffer(1, sampleRate * duration, sampleRate);
    const data = buffer.getChannelData(0);

    for (let i = 0; i < buffer.length; i++) {
      data[i] = Math.sin((2 * Math.PI * frequency * i) / sampleRate) * 0.3;
    }

    this.sounds.set(key, buffer);
  }

  /**
   * Khởi tạo Speech Synthesis API
   */
  private initializeSpeechSynthesis(): void {
    try {
      if ('speechSynthesis' in window) {
        this.speechSynthesis = window.speechSynthesis;

        // Load available voices
        this.loadVoices();

        // Listen for voice changes
        if (this.speechSynthesis) {
          this.speechSynthesis.addEventListener('voiceschanged', () => {
            this.loadVoices();
          });
        }
      }
    } catch (error) {
      // Silent error handling
    }
  }

  /**
   * Load danh sách giọng đọc có sẵn
   */
  private loadVoices(): void {
    if (!this.speechSynthesis) return;

    this.availableVoices = this.speechSynthesis.getVoices();

    // Tìm giọng Việt Nam hoặc giọng phù hợp
    const vietnameseVoice = this.availableVoices.find(
      voice => voice.lang.startsWith('vi') || voice.lang.includes('VN'),
    );

    if (vietnameseVoice) {
      this.config.speechVoice = vietnameseVoice.name;
    } else {
      // Fallback to default voice
      const defaultVoice = this.availableVoices.find(voice => voice.default);
      if (defaultVoice) {
        this.config.speechVoice = defaultVoice.name;
      }
    }
  }

  /**
   * Đọc text bằng giọng nói
   */
  async speakText(text: string): Promise<void> {
    if (!this.config.speechEnabled || !this.speechSynthesis || !text.trim()) {
      return;
    }

    try {
      // Stop any current speech
      this.speechSynthesis.cancel();

      const utterance = new SpeechSynthesisUtterance(text);

      // Cấu hình giọng đọc
      const selectedVoice = this.availableVoices.find(
        voice => voice.name === this.config.speechVoice,
      );
      if (selectedVoice) {
        utterance.voice = selectedVoice;
      }

      utterance.rate = this.config.speechRate;
      utterance.pitch = this.config.speechPitch;
      utterance.volume = this.config.volume;

      // Event listeners
      utterance.onstart = () => {
        // Speech started
      };

      utterance.onerror = () => {
        // Speech error occurred
      };

      utterance.onend = () => {
        // Speech finished
      };

      this.speechSynthesis.speak(utterance);
    } catch (error) {
      // Silent error handling
    }
  }

  /**
   * Phát âm thanh theo loại thông báo
   */
  async playSound(type: 'newOrder' | 'itemUpdate' | 'itemRemoved' | 'itemAdded'): Promise<void> {
    if (!this.config.enabled || !this.audioContext || !this.sounds.has(type)) {
      return;
    }

    try {
      // Resume audio context if suspended (browser policy)
      if (this.audioContext.state === 'suspended') {
        await this.audioContext.resume();
      }

      const audioBuffer = this.sounds.get(type);
      if (!audioBuffer) return;

      const source = this.audioContext.createBufferSource();
      const gainNode = this.audioContext.createGain();

      source.buffer = audioBuffer;
      gainNode.gain.value = this.config.volume;

      source.connect(gainNode);
      gainNode.connect(this.audioContext.destination);

      source.start(0);
    } catch (error) {
      // Silent error handling
    }
  }

  /**
   * Phát âm thanh và đọc message
   */
  async playNotification(
    type: 'newOrder' | 'itemUpdate' | 'itemRemoved' | 'itemAdded',
    message?: string,
  ): Promise<void> {
    // Phát âm thanh trước
    await this.playSound(type);

    // Đợi một chút rồi đọc message
    if (message && this.config.speechEnabled) {
      setTimeout(() => {
        this.speakText(message);
      }, 500); // Delay 500ms để âm thanh phát xong
    }
  }

  /**
   * Bật/tắt âm thanh
   */
  setEnabled(enabled: boolean): void {
    this.config.enabled = enabled;
    localStorage.setItem('kitchen-sound-enabled', enabled.toString());
  }

  /**
   * Bật/tắt text-to-speech
   */
  setSpeechEnabled(enabled: boolean): void {
    this.config.speechEnabled = enabled;
    localStorage.setItem('kitchen-speech-enabled', enabled.toString());
  }

  /**
   * Cài đặt tốc độ đọc
   */
  setSpeechRate(rate: number): void {
    this.config.speechRate = Math.max(0.1, Math.min(10, rate));
    localStorage.setItem('kitchen-speech-rate', this.config.speechRate.toString());
  }

  /**
   * Cài đặt cao độ giọng
   */
  setSpeechPitch(pitch: number): void {
    this.config.speechPitch = Math.max(0, Math.min(2, pitch));
    localStorage.setItem('kitchen-speech-pitch', this.config.speechPitch.toString());
  }

  /**
   * Chọn giọng đọc
   */
  setSpeechVoice(voiceName: string): void {
    const voice = this.availableVoices.find(v => v.name === voiceName);
    if (voice) {
      this.config.speechVoice = voiceName;
      localStorage.setItem('kitchen-speech-voice', voiceName);
    }
  }

  /**
   * Cài đặt âm lượng
   */
  setVolume(volume: number): void {
    this.config.volume = Math.max(0, Math.min(1, volume));
    localStorage.setItem('kitchen-sound-volume', this.config.volume.toString());
  }

  /**
   * Khởi tạo âm thanh và speech (cần gọi sau user interaction đầu tiên)
   */
  async initialize(): Promise<void> {
    try {
      // Load settings from localStorage
      const savedEnabled = localStorage.getItem('kitchen-sound-enabled');
      const savedVolume = localStorage.getItem('kitchen-sound-volume');
      const savedSpeechEnabled = localStorage.getItem('kitchen-speech-enabled');
      const savedSpeechRate = localStorage.getItem('kitchen-speech-rate');
      const savedSpeechPitch = localStorage.getItem('kitchen-speech-pitch');
      const savedSpeechVoice = localStorage.getItem('kitchen-speech-voice');

      if (savedEnabled !== null) {
        this.config.enabled = savedEnabled === 'true';
      }
      if (savedVolume !== null) {
        this.config.volume = parseFloat(savedVolume);
      }
      if (savedSpeechEnabled !== null) {
        this.config.speechEnabled = savedSpeechEnabled === 'true';
      }
      if (savedSpeechRate !== null) {
        this.config.speechRate = parseFloat(savedSpeechRate);
      }
      if (savedSpeechPitch !== null) {
        this.config.speechPitch = parseFloat(savedSpeechPitch);
      }
      if (savedSpeechVoice !== null) {
        this.config.speechVoice = savedSpeechVoice;
      }

      // Test play a short silent sound to unlock audio
      if (this.audioContext && this.config.enabled) {
        const source = this.audioContext.createBufferSource();
        const buffer = this.audioContext.createBuffer(1, 1, this.audioContext.sampleRate);
        source.buffer = buffer;
        source.connect(this.audioContext.destination);
        source.start(0);
      }

      // Reload voices after settings are loaded
      this.loadVoices();
    } catch (error) {
      // Silent error handling
    }
  }

  /**
   * Test phát âm thanh và đọc text - dùng chung âm thanh newOrder
   */
  async testSound(
    type: 'newOrder' | 'itemUpdate' | 'itemRemoved' | 'itemAdded' = 'newOrder',
  ): Promise<void> {
    await this.initialize();

    const testMessages = {
      newOrder: 'Có đơn hàng mới cần chuẩn bị',
      itemAdded: 'Đã thêm món mới vào đơn hàng',
      itemUpdate: 'Số lượng món ăn đã được cập nhật',
      itemRemoved: 'Đã xóa món khỏi đơn hàng',
    };

    // Luôn dùng âm thanh newOrder cho tất cả các loại test
    await this.playNotification('newOrder', testMessages[type]);
  }

  /**
   * Test chỉ đọc text
   */
  async testSpeech(text: string = 'Đây là test giọng đọc tiếng Việt'): Promise<void> {
    await this.initialize();
    await this.speakText(text);
  }

  /**
   * Dừng tất cả âm thanh và speech
   */
  stopAll(): void {
    if (this.speechSynthesis) {
      this.speechSynthesis.cancel();
    }
    // AudioContext không có stop all, nhưng sounds sẽ tự dừng
  }

  /**
   * Lấy danh sách giọng đọc có sẵn
   */
  getAvailableVoices(): SpeechSynthesisVoice[] {
    return [...this.availableVoices];
  }

  /**
   * Kiểm tra trạng thái speech synthesis
   */
  isSpeechSupported(): boolean {
    return 'speechSynthesis' in window && this.speechSynthesis !== null;
  }

  /**
   * Lấy trạng thái hiện tại
   */
  getConfig(): NotificationSoundConfig {
    return { ...this.config };
  }
}
