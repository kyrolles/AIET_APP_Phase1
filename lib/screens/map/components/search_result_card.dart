import 'package:flutter/material.dart';
import '../services/map_search_service.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResult result;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 12),
              _buildSessionInfo(),
              const SizedBox(height: 8),
              _buildMatches(),
              if (result.isCurrentPeriod) _buildCurrentIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: result.isCurrentPeriod ? Colors.green : Colors.blue,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            result.roomName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Period ${result.period}',
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Spacer(),
        if (result.isCurrentPeriod)
          const Icon(
            Icons.circle,
            color: Colors.green,
            size: 12,
          ),
      ],
    );
  }

  Widget _buildSessionInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (result.subjectName.isNotEmpty)
          Text(
            result.subjectName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        if (result.subject.isNotEmpty)
          Text(
            result.subject,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        const SizedBox(height: 4),
        if (result.teachers.isNotEmpty) _buildTeachers(),
        if (result.groups.isNotEmpty) _buildGroups(),
      ],
    );
  }

  Widget _buildTeachers() {
    return Row(
      children: [
        Icon(Icons.person, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            result.teachers.join(', '),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroups() {
    return Row(
      children: [
        Icon(Icons.group, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            result.groups.join(', '),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatches() {
    if (result.matches.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: result.matches.take(3).map((match) {
        final matchType = match.split(':')[0];
        Color chipColor;
        IconData chipIcon;

        switch (matchType) {
          case 'Teacher':
            chipColor = Colors.blue;
            chipIcon = Icons.person;
            break;
          case 'Group':
            chipColor = Colors.orange;
            chipIcon = Icons.group;
            break;
          case 'Subject':
            chipColor = Colors.purple;
            chipIcon = Icons.book;
            break;
          default:
            chipColor = Colors.grey;
            chipIcon = Icons.info;
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: chipColor.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(chipIcon, size: 12, color: chipColor),
              const SizedBox(width: 4),
              Text(
                match,
                style: TextStyle(
                  fontSize: 11,
                  color: chipColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCurrentIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time, size: 14, color: Colors.green),
          SizedBox(width: 4),
          Text(
            'Currently Active',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
