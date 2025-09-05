import 'package:flutter/material.dart';
import '../models/order_state.dart';

class OrderStepper extends StatelessWidget {
  final OrderWorkflowStep currentStep;
  final Function(OrderWorkflowStep)? onStepTapped;

  const OrderStepper({
    super.key,
    required this.currentStep,
    this.onStepTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: OrderWorkflowStep.values.map((step) {
          final index = OrderWorkflowStep.values.indexOf(step);
          final currentIndex = OrderWorkflowStep.values.indexOf(currentStep);
          final isActive = index == currentIndex;
          final isCompleted = index < currentIndex;
          final canTap = index <= currentIndex;

          return Expanded(
            child: GestureDetector(
              onTap: canTap ? () => onStepTapped?.call(step) : null,
              child: Row(
                children: [
                  // Step indicator
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Step circle
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStepColor(context, isActive, isCompleted),
                            border: Border.all(
                              color: _getStepBorderColor(context, isActive, isCompleted),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: isCompleted
                                ? Icon(
                                    Icons.check,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.onPrimary,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getStepTextColor(context, isActive, isCompleted),
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Step label
                        Text(
                          step.displayName,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                            color: _getStepLabelColor(context, isActive, isCompleted),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Connector line (except for last step)
                  if (index < OrderWorkflowStep.values.length - 1)
                    Container(
                      height: 2,
                      width: 24,
                      color: isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                    ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStepColor(BuildContext context, bool isActive, bool isCompleted) {
    if (isCompleted) {
      return Theme.of(context).colorScheme.primary;
    } else if (isActive) {
      return Theme.of(context).colorScheme.primaryContainer;
    } else {
      return Colors.transparent;
    }
  }

  Color _getStepBorderColor(BuildContext context, bool isActive, bool isCompleted) {
    if (isCompleted || isActive) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.outline;
    }
  }

  Color _getStepTextColor(BuildContext context, bool isActive, bool isCompleted) {
    if (isCompleted) {
      return Theme.of(context).colorScheme.onPrimary;
    } else if (isActive) {
      return Theme.of(context).colorScheme.onPrimaryContainer;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Color _getStepLabelColor(BuildContext context, bool isActive, bool isCompleted) {
    if (isCompleted || isActive) {
      return Theme.of(context).colorScheme.primary;
    } else {
      return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }
}