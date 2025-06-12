import 'package:flutter/material.dart';
import 'dart:async';
import 'services/map_search_service.dart';

class SearchMapScreen extends StatefulWidget {
  final DateTime selectedDate;

  const SearchMapScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<SearchResult> _results = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _initSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initSearch() async {
    await MapSearchService.initialize();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () async {
      if (query.trim().isEmpty) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);

      try {
        final results = await MapSearchService.search(
          query: query,
          searchDate: widget.selectedDate, // Use the date from timeline
        );

        setState(() {
          _results = results;
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          _results = [];
          _isSearching = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: const InputDecoration(
            hintText: 'Search professors, groups, subjects...',
            border: InputBorder.none,
          ),
        ),
      ),
      body: Column(
        children: [
          // Date indicator
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: Colors.blue.withOpacity(0.1),
            child: Text(
              'Search date: ${_formatDate(widget.selectedDate)}',
              style: TextStyle(color: Colors.blue[700]),
            ),
          ),
          // Results
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.month}/${date.day}';
  }

  Widget _buildResults() {
    if (_searchController.text.isEmpty) {
      return Center(
        child: Text('Start typing to search...'),
      );
    }

    if (_isSearching) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_results.isEmpty) {
      return Center(
        child: Text('No results found'),
      );
    }

    return ListView.builder(
      itemCount: _results.length,
      itemBuilder: (context, index) {
        final result = _results[index];

        // Build subtitle with all the data
        String subtitle = 'Period ${result.period}';

        if (result.teachers.isNotEmpty) {
          subtitle += ' • ${result.teachers.join(', ')}';
        }

        if (result.subjectName.isNotEmpty) {
          subtitle += '\n${result.subjectName}';
        }

        if (result.groups.isNotEmpty) {
          subtitle += ' • ${result.groups.join(', ')}';
        }

        return ListTile(
          title: Text(result.roomName),
          subtitle: Text(subtitle),
          isThreeLine: true,
          onTap: () =>
              Navigator.pop(context, result.roomName), // Just return room name
        );
      },
    );
  }
}
