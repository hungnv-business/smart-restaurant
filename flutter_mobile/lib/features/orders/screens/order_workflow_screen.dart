import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_state.dart';
import '../widgets/order_stepper.dart';
import '../widgets/table_selection_widget.dart';
import '../widgets/menu_browsing_widget.dart';
import '../widgets/order_summary_widget.dart';
import '../widgets/order_confirmation_widget.dart';
import '../widgets/connection_status_widget.dart';

class OrderWorkflowScreen extends StatefulWidget {
  const OrderWorkflowScreen({super.key});

  @override
  State<OrderWorkflowScreen> createState() => _OrderWorkflowScreenState();
}

class _OrderWorkflowScreenState extends State<OrderWorkflowScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => OrderWorkflowNotifier(),
      child: Consumer<OrderWorkflowNotifier>(
        builder: (context, notifier, child) {
          return Scaffold(
            appBar: _buildAppBar(context, notifier),
            body: Column(
              children: [
                // Connection status indicator
                const ConnectionStatusWidget(),
                
                // Order stepper
                OrderStepper(
                  currentStep: notifier.state.currentStep,
                  onStepTapped: (step) => _onStepTapped(context, notifier, step),
                ),
                
                // Step content
                Expanded(
                  child: _buildStepContent(context, notifier),
                ),
                
                // Navigation buttons
                _buildNavigationButtons(context, notifier),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, OrderWorkflowNotifier notifier) {
    final state = notifier.state;
    
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tạo đơn hàng',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            state.currentStep.description,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
      actions: [
        if (state.selectedTable != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text(
                'Bàn ${state.selectedTable!.tableNumber}',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
        if (state.totalItems > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Chip(
              label: Text(
                '${state.totalItems} món',
                style: const TextStyle(fontSize: 12),
              ),
              backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
            ),
          ),
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _resetWorkflow(context, notifier),
          tooltip: 'Làm mới',
        ),
      ],
    );
  }

  Widget _buildStepContent(BuildContext context, OrderWorkflowNotifier notifier) {
    if (notifier.state.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang xử lý...'),
          ],
        ),
      );
    }

    if (notifier.state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Có lỗi xảy ra',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notifier.state.error!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => notifier.setError(null),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    switch (notifier.state.currentStep) {
      case OrderWorkflowStep.tableSelection:
        return const TableSelectionWidget();
      case OrderWorkflowStep.menuBrowsing:
        return const MenuBrowsingWidget();
      case OrderWorkflowStep.orderReview:
        return const OrderSummaryWidget();
      case OrderWorkflowStep.confirmation:
        return const OrderConfirmationWidget();
    }
  }

  Widget _buildNavigationButtons(BuildContext context, OrderWorkflowNotifier notifier) {
    final state = notifier.state;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          if (state.canGoBack)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: state.isLoading ? null : () => notifier.goToPreviousStep(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Quay lại'),
              ),
            ),
          
          if (state.canGoBack) const SizedBox(width: 16),
          
          // Next/Finish button
          Expanded(
            flex: 2,
            child: _buildNextButton(context, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context, OrderWorkflowNotifier notifier) {
    final state = notifier.state;
    
    if (state.currentStep == OrderWorkflowStep.confirmation) {
      return ElevatedButton.icon(
        onPressed: state.isLoading ? null : () => _completeOrder(context, notifier),
        icon: const Icon(Icons.check),
        label: const Text('Hoàn thành'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: (state.canProceedToNext && !state.isLoading)
          ? () => _proceedToNext(context, notifier)
          : null,
      icon: const Icon(Icons.arrow_forward),
      label: Text(_getNextButtonLabel(state.currentStep)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  String _getNextButtonLabel(OrderWorkflowStep step) {
    switch (step) {
      case OrderWorkflowStep.tableSelection:
        return 'Chọn món';
      case OrderWorkflowStep.menuBrowsing:
        return 'Xem lại';
      case OrderWorkflowStep.orderReview:
        return 'Xác nhận';
      case OrderWorkflowStep.confirmation:
        return 'Hoàn thành';
    }
  }

  void _onStepTapped(BuildContext context, OrderWorkflowNotifier notifier, OrderWorkflowStep step) {
    final currentStepIndex = OrderWorkflowStep.values.indexOf(notifier.state.currentStep);
    final tappedStepIndex = OrderWorkflowStep.values.indexOf(step);
    
    // Only allow going back or staying on current step
    if (tappedStepIndex <= currentStepIndex) {
      notifier.setCurrentStep(step);
    }
  }

  Future<void> _proceedToNext(BuildContext context, OrderWorkflowNotifier notifier) async {
    final state = notifier.state;
    
    // Validate current step before proceeding
    if (!_validateCurrentStep(context, notifier)) {
      return;
    }
    
    // Special handling for order review step - check missing ingredients
    if (state.currentStep == OrderWorkflowStep.orderReview) {
      await _checkMissingIngredients(context, notifier);
    }
    
    notifier.goToNextStep();
  }

  bool _validateCurrentStep(BuildContext context, OrderWorkflowNotifier notifier) {
    final state = notifier.state;
    
    switch (state.currentStep) {
      case OrderWorkflowStep.tableSelection:
        if (state.selectedTable == null) {
          _showSnackBar(context, 'Vui lòng chọn bàn để tiếp tục');
          return false;
        }
        break;
        
      case OrderWorkflowStep.menuBrowsing:
        if (state.selectedItems.isEmpty || state.totalItems == 0) {
          _showSnackBar(context, 'Vui lòng chọn ít nhất một món ăn');
          return false;
        }
        break;
        
      case OrderWorkflowStep.orderReview:
      case OrderWorkflowStep.confirmation:
        return true;
    }
    
    return true;
  }

  Future<void> _checkMissingIngredients(BuildContext context, OrderWorkflowNotifier notifier) async {
    notifier.setLoading(true);
    
    try {
      // Simulate API call to check missing ingredients
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock missing ingredients data
      final missingIngredients = <MissingIngredient>[
        // MissingIngredient(
        //   ingredientName: 'Thịt bò',
        //   menuItemName: 'Phở Bò',
        //   requiredQuantity: 200,
        //   currentStock: 100,
        //   unit: 'g',
        //   isOptional: false,
        // ),
      ];
      
      notifier.setMissingIngredients(missingIngredients);
      
      if (missingIngredients.isNotEmpty) {
        await _showMissingIngredientsDialog(context, missingIngredients);
      }
    } catch (e) {
      notifier.setError('Không thể kiểm tra nguyên liệu: $e');
    } finally {
      notifier.setLoading(false);
    }
  }

  Future<void> _showMissingIngredientsDialog(
    BuildContext context, 
    List<MissingIngredient> missingIngredients,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cảnh báo thiếu nguyên liệu'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Một số nguyên liệu không đủ cho đơn hàng này:'),
                const SizedBox(height: 16),
                ...missingIngredients.map((ingredient) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        ingredient.isOptional ? Icons.info : Icons.warning,
                        color: ingredient.isOptional 
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.error,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(ingredient.displayText)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Continue with order despite missing ingredients
              },
              child: const Text('Tiếp tục'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _completeOrder(BuildContext context, OrderWorkflowNotifier notifier) async {
    notifier.setLoading(true);
    
    try {
      // Simulate API call to create order
      await Future.delayed(const Duration(seconds: 2));
      
      if (!context.mounted) return;
      
      // Show success dialog
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Đơn hàng đã được tạo'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.green),
                SizedBox(height: 16),
                Text('Đơn hàng đã được gửi tới bếp và đang được chuẩn bị.'),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to main screen
                },
                child: const Text('Hoàn thành'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      notifier.setError('Không thể tạo đơn hàng: $e');
    } finally {
      notifier.setLoading(false);
    }
  }

  void _resetWorkflow(BuildContext context, OrderWorkflowNotifier notifier) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Làm mới đơn hàng'),
          content: const Text('Bạn có chắc chắn muốn xóa tất cả thông tin đã nhập?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                notifier.reset();
              },
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}