import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../shared/constants/app_colors.dart';

class VoiceInputWidget extends StatefulWidget {
  final Function(String) onSpeechResult;
  final String? hintText;
  final bool enabled;

  const VoiceInputWidget({
    super.key,
    required this.onSpeechResult,
    this.hintText,
    this.enabled = true,
  });

  @override
  State<VoiceInputWidget> createState() => _VoiceInputWidgetState();
}

class _VoiceInputWidgetState extends State<VoiceInputWidget>
    with TickerProviderStateMixin {
  late SpeechToText _speechToText;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  bool _isListening = false;
  bool _isInitialized = false;
  String _lastWords = '';
  double _confidence = 0.0;

  @override
  void initState() {
    super.initState();
    _speechToText = SpeechToText();
    _initializeSpeech();
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initializeSpeech() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (permission.isDenied) {
        _showPermissionDeniedDialog();
        return;
      }

      final available = await _speechToText.initialize(
        onError: _onSpeechError,
        onStatus: _onSpeechStatus,
      );

      setState(() {
        _isInitialized = available;
      });

      if (!available) {
        _showSpeechNotAvailableDialog();
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      _showSpeechNotAvailableDialog();
    }
  }

  void _onSpeechError(dynamic error) {
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();
    
    String message = 'Lỗi nhận diện giọng nói';
    if (error.toString().contains('network')) {
      message = 'Cần kết nối internet để sử dụng nhận diện giọng nói';
    } else if (error.toString().contains('permission')) {
      message = 'Cần cấp quyền microphone để sử dụng tính năng này';
    }
    
    _showErrorSnackbar(message);
  }

  void _onSpeechStatus(String status) {
    debugPrint('Speech status: $status');
    
    if (status == 'done' || status == 'notListening') {
      setState(() {
        _isListening = false;
      });
      _pulseController.stop();
      
      if (_lastWords.isNotEmpty && _confidence > 0.5) {
        widget.onSpeechResult(_lastWords);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || !widget.enabled) {
      return _buildDisabledButton();
    }

    return _buildVoiceButton();
  }

  Widget _buildDisabledButton() {
    return IconButton(
      onPressed: null,
      icon: Icon(
        Icons.mic_off,
        color: Colors.grey[400],
      ),
      tooltip: 'Nhận diện giọng nói không khả dụng',
    );
  }

  Widget _buildVoiceButton() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isListening ? _pulseAnimation.value : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: _isListening 
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _isListening ? _stopListening : _startListening,
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening ? AppColors.primary : Colors.grey[600],
              ),
              tooltip: _isListening 
                  ? 'Dừng nhận diện' 
                  : widget.hintText ?? 'Nhấn để nói',
            ),
          ),
        );
      },
    );
  }

  Future<void> _startListening() async {
    if (!_isInitialized) return;

    try {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 10),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: 'vi_VN', // Vietnamese locale
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      setState(() {
        _isListening = true;
        _lastWords = '';
        _confidence = 0.0;
      });

      _pulseController.repeat(reverse: true);
      _showListeningSnackbar();
      
    } catch (e) {
      _onSpeechError(e);
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    _pulseController.stop();
  }

  void _onSpeechResult(dynamic result) {
    setState(() {
      _lastWords = result.recognizedWords as String;
      _confidence = result.confidence as double;
    });

    debugPrint('Speech result: $_lastWords (confidence: $_confidence)');
  }

  void _showListeningSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.mic,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            const Text('Đang nghe... Hãy nói tên món ăn'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cần quyền microphone'),
        content: const Text(
          'Để sử dụng tính năng tìm kiếm bằng giọng nói, '
          'ứng dụng cần quyền truy cập microphone.\n\n'
          'Vui lòng cấp quyền trong cài đặt thiết bị.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bỏ qua'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Mở cài đặt'),
          ),
        ],
      ),
    );
  }

  void _showSpeechNotAvailableDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nhận diện giọng nói không khả dụng'),
        content: const Text(
          'Thiết bị của bạn không hỗ trợ nhận diện giọng nói '
          'hoặc chức năng này chưa được kích hoạt.\n\n'
          'Vui lòng sử dụng bàn phím để nhập.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }
}

class VoiceSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String? hintText;
  final Function(String)? onChanged;
  final Function(String)? onVoiceResult;
  final bool enabled;

  const VoiceSearchField({
    super.key,
    required this.controller,
    this.hintText,
    this.onChanged,
    this.onVoiceResult,
    this.enabled = true,
  });

  @override
  State<VoiceSearchField> createState() => _VoiceSearchFieldState();
}

class _VoiceSearchFieldState extends State<VoiceSearchField> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      onChanged: widget.onChanged,
      enabled: widget.enabled,
      decoration: InputDecoration(
        hintText: widget.hintText ?? 'Tìm kiếm món ăn...',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: VoiceInputWidget(
          onSpeechResult: (text) {
            widget.controller.text = text;
            widget.onVoiceResult?.call(text);
            widget.onChanged?.call(text);
          },
          hintText: 'Nói tên món ăn',
          enabled: widget.enabled,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}