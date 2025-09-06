import 'package:flutter/material.dart';
import '../../../core/models/table_models.dart';
import 'table_card.dart';

/// Widget hiển thị một cột chứa các bàn thuộc cùng một section
class SectionColumn extends StatelessWidget {
  final String sectionName;
  final List<ActiveTableDto> tables;
  
  const SectionColumn({
    Key? key,
    required this.sectionName,
    required this.tables,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            sectionName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '${tables.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableList() {
    return ListView.builder(
      itemCount: tables.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TableCard(table: tables[index]),
        );
      },
    );
  }
}