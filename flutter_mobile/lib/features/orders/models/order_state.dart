import 'package:flutter/foundation.dart';
import 'order_models.dart';
import '../../tables/models/table_models.dart';
import '../../menu/models/menu_models.dart';

enum OrderWorkflowStep {
  tableSelection,
  menuBrowsing,
  orderReview,
  confirmation;

  String get displayName {
    switch (this) {
      case OrderWorkflowStep.tableSelection:
        return 'Chọn bàn';
      case OrderWorkflowStep.menuBrowsing:
        return 'Chọn món';
      case OrderWorkflowStep.orderReview:
        return 'Xem lại';
      case OrderWorkflowStep.confirmation:
        return 'Xác nhận';
    }
  }

  String get description {
    switch (this) {
      case OrderWorkflowStep.tableSelection:
        return 'Chọn bàn để phục vụ khách hàng';
      case OrderWorkflowStep.menuBrowsing:
        return 'Duyệt menu và chọn món ăn';
      case OrderWorkflowStep.orderReview:
        return 'Kiểm tra lại đơn hàng';
      case OrderWorkflowStep.confirmation:
        return 'Xác nhận và gửi đơn hàng';
    }
  }
}

class OrderWorkflowState {
  final OrderWorkflowStep currentStep;
  final RestaurantTable? selectedTable;
  final List<MenuItem> selectedItems;
  final Map<String, int> itemQuantities;
  final Map<String, String> itemNotes;
  final String? generalNotes;
  final List<MissingIngredient> missingIngredients;
  final bool isLoading;
  final String? error;
  final bool isConnected;

  OrderWorkflowState({
    this.currentStep = OrderWorkflowStep.tableSelection,
    this.selectedTable,
    this.selectedItems = const [],
    this.itemQuantities = const {},
    this.itemNotes = const {},
    this.generalNotes,
    this.missingIngredients = const [],
    this.isLoading = false,
    this.error,
    this.isConnected = true,
  });

  double get totalAmount {
    double total = 0;
    for (var item in selectedItems) {
      final quantity = itemQuantities[item.id] ?? 0;
      total += item.price * quantity;
    }
    return total;
  }

  int get totalItems {
    return itemQuantities.values.fold(0, (sum, quantity) => sum + quantity);
  }

  bool get canProceedToNext {
    switch (currentStep) {
      case OrderWorkflowStep.tableSelection:
        return selectedTable != null;
      case OrderWorkflowStep.menuBrowsing:
        return selectedItems.isNotEmpty && totalItems > 0;
      case OrderWorkflowStep.orderReview:
        return true;
      case OrderWorkflowStep.confirmation:
        return false; // Final step
    }
  }

  bool get canGoBack {
    return currentStep != OrderWorkflowStep.tableSelection;
  }

  OrderWorkflowStep? get nextStep {
    final currentIndex = OrderWorkflowStep.values.indexOf(currentStep);
    if (currentIndex < OrderWorkflowStep.values.length - 1) {
      return OrderWorkflowStep.values[currentIndex + 1];
    }
    return null;
  }

  OrderWorkflowStep? get previousStep {
    final currentIndex = OrderWorkflowStep.values.indexOf(currentStep);
    if (currentIndex > 0) {
      return OrderWorkflowStep.values[currentIndex - 1];
    }
    return null;
  }

  List<CreateOrderItemDto> get orderItemDtos {
    return selectedItems.map((item) {
      final quantity = itemQuantities[item.id] ?? 0;
      final notes = itemNotes[item.id];
      return CreateOrderItemDto(
        menuItemId: item.id,
        quantity: quantity,
        notes: notes,
      );
    }).where((dto) => dto.quantity > 0).toList();
  }

  OrderWorkflowState copyWith({
    OrderWorkflowStep? currentStep,
    RestaurantTable? selectedTable,
    List<MenuItem>? selectedItems,
    Map<String, int>? itemQuantities,
    Map<String, String>? itemNotes,
    String? generalNotes,
    List<MissingIngredient>? missingIngredients,
    bool? isLoading,
    String? error,
    bool? isConnected,
    bool clearError = false,
    bool clearSelectedTable = false,
  }) {
    return OrderWorkflowState(
      currentStep: currentStep ?? this.currentStep,
      selectedTable: clearSelectedTable ? null : (selectedTable ?? this.selectedTable),
      selectedItems: selectedItems ?? this.selectedItems,
      itemQuantities: itemQuantities ?? this.itemQuantities,
      itemNotes: itemNotes ?? this.itemNotes,
      generalNotes: generalNotes ?? this.generalNotes,
      missingIngredients: missingIngredients ?? this.missingIngredients,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isConnected: isConnected ?? this.isConnected,
    );
  }
}

class OrderWorkflowNotifier extends ChangeNotifier {
  OrderWorkflowState _state = OrderWorkflowState();

  OrderWorkflowState get state => _state;

  void updateState(OrderWorkflowState newState) {
    _state = newState;
    notifyListeners();
  }

  void setCurrentStep(OrderWorkflowStep step) {
    updateState(_state.copyWith(currentStep: step));
  }

  void selectTable(RestaurantTable table) {
    updateState(_state.copyWith(selectedTable: table));
  }

  void clearTable() {
    updateState(_state.copyWith(clearSelectedTable: true));
  }

  void addMenuItem(MenuItem item, {int quantity = 1}) {
    final newItems = List<MenuItem>.from(_state.selectedItems);
    if (!newItems.any((i) => i.id == item.id)) {
      newItems.add(item);
    }

    final newQuantities = Map<String, int>.from(_state.itemQuantities);
    newQuantities[item.id] = (newQuantities[item.id] ?? 0) + quantity;

    updateState(_state.copyWith(
      selectedItems: newItems,
      itemQuantities: newQuantities,
    ));
  }

  void removeMenuItem(String itemId) {
    final newItems = _state.selectedItems.where((i) => i.id != itemId).toList();
    final newQuantities = Map<String, int>.from(_state.itemQuantities);
    final newNotes = Map<String, String>.from(_state.itemNotes);
    
    newQuantities.remove(itemId);
    newNotes.remove(itemId);

    updateState(_state.copyWith(
      selectedItems: newItems,
      itemQuantities: newQuantities,
      itemNotes: newNotes,
    ));
  }

  void updateItemQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeMenuItem(itemId);
      return;
    }

    final newQuantities = Map<String, int>.from(_state.itemQuantities);
    newQuantities[itemId] = quantity;

    updateState(_state.copyWith(itemQuantities: newQuantities));
  }

  void updateItemNotes(String itemId, String notes) {
    final newNotes = Map<String, String>.from(_state.itemNotes);
    if (notes.trim().isEmpty) {
      newNotes.remove(itemId);
    } else {
      newNotes[itemId] = notes.trim();
    }

    updateState(_state.copyWith(itemNotes: newNotes));
  }

  void updateGeneralNotes(String notes) {
    updateState(_state.copyWith(
      generalNotes: notes.trim().isEmpty ? null : notes.trim(),
    ));
  }

  void setMissingIngredients(List<MissingIngredient> ingredients) {
    updateState(_state.copyWith(missingIngredients: ingredients));
  }

  void setLoading(bool loading) {
    updateState(_state.copyWith(isLoading: loading));
  }

  void setError(String? error) {
    updateState(_state.copyWith(error: error, clearError: error == null));
  }

  void setConnectionStatus(bool connected) {
    updateState(_state.copyWith(isConnected: connected));
  }

  void goToNextStep() {
    final nextStep = _state.nextStep;
    if (nextStep != null && _state.canProceedToNext) {
      setCurrentStep(nextStep);
    }
  }

  void goToPreviousStep() {
    final previousStep = _state.previousStep;
    if (previousStep != null && _state.canGoBack) {
      setCurrentStep(previousStep);
    }
  }

  void reset() {
    updateState(OrderWorkflowState());
  }

  void clearItems() {
    updateState(_state.copyWith(
      selectedItems: [],
      itemQuantities: {},
      itemNotes: {},
    ));
  }
}