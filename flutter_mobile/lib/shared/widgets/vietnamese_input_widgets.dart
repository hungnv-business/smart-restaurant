import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/vietnamese_formatter.dart';
import '../constants/vietnamese_constants.dart';

/// Vietnamese-specific input formatters and widgets

/// Formatter for Vietnamese currency input
class VietnameseCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.isEmpty) {
      return const TextEditingValue(text: '');
    }

    // Parse and format
    final number = int.tryParse(digitsOnly);
    if (number == null) {
      return oldValue;
    }

    final formatted = VietnameseFormatter.formatNumber(number);
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Formatter for Vietnamese phone number input
class VietnamesePhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove non-digits and limit to 10 digits
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (digitsOnly.length > 10) {
      digitsOnly = digitsOnly.substring(0, 10);
    }

    // Format as Vietnamese phone number
    String formatted = digitsOnly;
    if (digitsOnly.length >= 3) {
      formatted = digitsOnly.substring(0, 3);
      if (digitsOnly.length >= 6) {
        formatted += ' ${digitsOnly.substring(3, 6)}';
        if (digitsOnly.length >= 10) {
          formatted += ' ${digitsOnly.substring(6, 10)}';
        } else if (digitsOnly.length > 6) {
          formatted += ' ${digitsOnly.substring(6)}';
        }
      } else if (digitsOnly.length > 3) {
        formatted += ' ${digitsOnly.substring(3)}';
      }
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Vietnamese currency input field
class VietnameseCurrencyField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final double? initialValue;
  final ValueChanged<double?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextEditingController? controller;

  const VietnameseCurrencyField({
    Key? key,
    this.label,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.controller,
  }) : super(key: key);

  @override
  State<VietnameseCurrencyField> createState() => _VietnameseCurrencyFieldState();
}

class _VietnameseCurrencyFieldState extends State<VietnameseCurrencyField> {
  late TextEditingController _controller;
  bool _isOwnController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isOwnController = true;
      _controller = TextEditingController();
    }

    if (widget.initialValue != null) {
      _controller.text = VietnameseFormatter.formatNumber(widget.initialValue!);
    }
  }

  @override
  void dispose() {
    if (_isOwnController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        VietnameseCurrencyInputFormatter(),
      ],
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hintText ?? 'Nhập số tiền',
        suffixText: 'đ',
        suffixStyle: TextStyle(
          color: Colors.blue[600],
          fontWeight: FontWeight.w600,
          fontSize: 16.sp,
        ),
        prefixIcon: Icon(
          Icons.attach_money,
          color: Colors.blue[600],
        ),
      ),
      validator: widget.validator,
      onChanged: (value) {
        if (widget.onChanged != null) {
          final number = double.tryParse(value.replaceAll('.', ''));
          widget.onChanged!(number);
        }
      },
    );
  }
}

/// Vietnamese phone number input field
class VietnamesePhoneField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextEditingController? controller;

  const VietnamesePhoneField({
    Key? key,
    this.label,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.controller,
  }) : super(key: key);

  @override
  State<VietnamesePhoneField> createState() => _VietnamesePhoneFieldState();
}

class _VietnamesePhoneFieldState extends State<VietnamesePhoneField> {
  late TextEditingController _controller;
  bool _isOwnController = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isOwnController = true;
      _controller = TextEditingController();
    }

    if (widget.initialValue != null) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    if (_isOwnController) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        VietnamesePhoneInputFormatter(),
        LengthLimitingTextInputFormatter(12), // "090 123 4567" format
      ],
      enabled: widget.enabled,
      decoration: InputDecoration(
        labelText: widget.label ?? VietnameseConstants.phoneNumber,
        hintText: widget.hintText ?? '090 123 4567',
        prefixIcon: Icon(
          Icons.phone,
          color: Colors.blue[600],
        ),
        prefixText: '+84 ',
        prefixStyle: TextStyle(
          color: Colors.grey[600],
          fontSize: 16.sp,
        ),
      ),
      validator: widget.validator ?? (value) {
        if (value == null || value.isEmpty) {
          return VietnameseConstants.requiredField;
        }
        
        final cleanValue = value.replaceAll(' ', '');
        if (!VietnameseFormatter.isValidVietnamesePhone('0$cleanValue')) {
          return VietnameseConstants.invalidPhoneNumber;
        }
        
        return null;
      },
      onChanged: widget.onChanged,
    );
  }
}

/// Vietnamese date picker field
class VietnameseDateField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final ValueChanged<DateTime?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextEditingController? controller;

  const VietnameseDateField({
    Key? key,
    this.label,
    this.hintText,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.controller,
  }) : super(key: key);

  @override
  State<VietnameseDateField> createState() => _VietnameseDateFieldState();
}

class _VietnameseDateFieldState extends State<VietnameseDateField> {
  late TextEditingController _controller;
  bool _isOwnController = false;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isOwnController = true;
      _controller = TextEditingController();
    }

    _selectedDate = widget.initialDate;
    if (_selectedDate != null) {
      _controller.text = VietnameseFormatter.formatDate(_selectedDate!);
    }
  }

  @override
  void dispose() {
    if (_isOwnController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: widget.firstDate ?? now.subtract(const Duration(days: 365 * 10)),
      lastDate: widget.lastDate ?? now.add(const Duration(days: 365 * 2)),
      locale: const Locale('vi', 'VN'),
      helpText: 'Chọn ngày',
      cancelText: VietnameseConstants.cancel,
      confirmText: VietnameseConstants.confirm,
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _controller.text = VietnameseFormatter.formatDate(picked);
      });

      if (widget.onChanged != null) {
        widget.onChanged!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      onTap: widget.enabled ? _selectDate : null,
      decoration: InputDecoration(
        labelText: widget.label ?? 'Ngày',
        hintText: widget.hintText ?? 'dd/MM/yyyy',
        prefixIcon: Icon(
          Icons.calendar_today,
          color: Colors.blue[600],
        ),
        suffixIcon: widget.enabled
            ? Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
              )
            : null,
      ),
      validator: widget.validator,
    );
  }
}

/// Vietnamese time picker field
class VietnameseTimeField extends StatefulWidget {
  final String? label;
  final String? hintText;
  final TimeOfDay? initialTime;
  final ValueChanged<TimeOfDay?>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final TextEditingController? controller;

  const VietnameseTimeField({
    Key? key,
    this.label,
    this.hintText,
    this.initialTime,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.controller,
  }) : super(key: key);

  @override
  State<VietnameseTimeField> createState() => _VietnameseTimeFieldState();
}

class _VietnameseTimeFieldState extends State<VietnameseTimeField> {
  late TextEditingController _controller;
  bool _isOwnController = false;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _isOwnController = true;
      _controller = TextEditingController();
    }

    _selectedTime = widget.initialTime;
    if (_selectedTime != null) {
      _controller.text = _selectedTime!.format(context);
    }
  }

  @override
  void dispose() {
    if (_isOwnController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      helpText: 'Chọn giờ',
      cancelText: VietnameseConstants.cancel,
      confirmText: VietnameseConstants.confirm,
      hourLabelText: 'Giờ',
      minuteLabelText: 'Phút',
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _controller.text = picked.format(context);
      });

      if (widget.onChanged != null) {
        widget.onChanged!(picked);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      readOnly: true,
      onTap: widget.enabled ? _selectTime : null,
      decoration: InputDecoration(
        labelText: widget.label ?? 'Giờ',
        hintText: widget.hintText ?? 'HH:mm',
        prefixIcon: Icon(
          Icons.access_time,
          color: Colors.blue[600],
        ),
        suffixIcon: widget.enabled
            ? Icon(
                Icons.arrow_drop_down,
                color: Colors.grey[600],
              )
            : null,
      ),
      validator: widget.validator,
    );
  }
}