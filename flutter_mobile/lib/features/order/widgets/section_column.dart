import 'package:flutter/material.dart';
import '../../../core/models/table_models.dart';
import 'table_card.dart';

/// Widget hiển thị một cột chứa các bàn thuộc cùng một section
class SectionColumn extends StatelessWidget {
  final String sectionName;
  final List<ActiveTableDto> tables;
  final VoidCallback? onTableUpdated;
  final bool isCompact;
  
  const SectionColumn({
    Key? key,
    required this.sectionName,
    required this.tables,
    this.onTableUpdated,
    this.isCompact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context),
        const SizedBox(height: 8),
        Expanded(
          child: _buildTableList(),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context) {
    // Responsive padding và text size
    final padding = isCompact 
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 6)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
        
    final titleStyle = isCompact
        ? Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold);
        
    final countStyle = isCompact
        ? Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          )
        : Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          );
    
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(isCompact ? 6 : 8),
      ),
      child: Row(
        children: [
          Flexible(
            child: Text(
              sectionName,
              style: titleStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${tables.length}',
            style: countStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildTableList() {
    final bottomPadding = isCompact ? 6.0 : 8.0;
    
    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: bottomPadding),
          child: TableCard(
            table: tables[index],
            onTableUpdated: onTableUpdated,
            isCompact: isCompact,
          ),
        );
      },
    );
  }
}