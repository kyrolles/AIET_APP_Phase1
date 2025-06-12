import 'package:flutter/material.dart';
import 'dart:async';
import '../services/map_search_service.dart';
import 'search_result_card.dart';

class MapSearchAppBar extends StatefulWidget implements PreferredSizeWidget {
  final VoidCallback onClose;

  const MapSearchAppBar({
    super.key,
    required this.onClose,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<MapSearchAppBar> createState() => _MapSearchAppBarState();
}

class _MapSearchAppBarState extends State<MapSearchAppBar> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchFocusNode.requestFocus();
    _initializeSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _initializeSearch() async {
    try {
      await MapSearchService.initialize();
    } catch (e) {
      print('Failed to initialize search service: $e');
    }
  }

  void _performSearch(String query) {
    print('🔍 Search triggered with query: "$query"');

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      print('🔍 Debounce timer executed for query: "$query"');

      if (query.trim().isEmpty) {
        print('🔍 Query is empty, clearing results');
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      print('🔍 Starting search...');
      setState(() {
        _isSearching = true;
      });

      try {
        print('🔍 Calling MapSearchService.search...');
        final results = await MapSearchService.search(query: query);
        print('🔍 Search completed. Found ${results.length} results');

        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      } catch (e) {
        print('🔍 Search error: $e');
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search error: $e')),
          );
        }
      }
    });
  }

  void _navigateToRoom(SearchResult result) {
    // Close search and show result
    widget.onClose();

    // Show room details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Found: ${result.roomName} - Period ${result.period}'),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Details',
          textColor: Colors.white,
          onPressed: () {
            _showRoomDetails(context, result);
          },
        ),
      ),
    );
  }

  void _showRoomDetails(BuildContext context, SearchResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Room ${result.roomName}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Period: ${result.period}'),
            Text('Subject: ${result.subjectName}'),
            if (result.teachers.isNotEmpty)
              Text('Teachers: ${result.teachers.join(', ')}'),
            if (result.groups.isNotEmpty)
              Text('Groups: ${result.groups.join(', ')}'),
            if (result.isCurrentPeriod)
              Container(
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text('Currently Active',
                    style: TextStyle(color: Colors.green)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
        ),
        onPressed: widget.onClose,
      ),
      title: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(color: Colors.black, fontSize: 16),
        decoration: const InputDecoration(
          hintText: 'Search professors, groups, subjects...',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        onChanged: _performSearch, // This is crucial!
      ),
      actions: [
        if (_searchController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.black),
            onPressed: () {
              _searchController.clear();
              _performSearch('');
              _searchFocusNode.requestFocus();
            },
          ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBody() {
    if (_searchController.text.isEmpty) {
      return _buildSearchSuggestions();
    }

    if (_isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (_searchResults.isEmpty) {
      return _buildNoResults();
    }

    return _buildSearchResults();
  }

  Widget _buildSearchSuggestions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Search Examples:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSuggestionChip('Dina', Icons.person, 'Find Professor Dina'),
          _buildSuggestionChip('0GNC2', Icons.group, 'Find Group 0GNC2'),
          _buildSuggestionChip(
              'Production Technology', Icons.book, 'Find Subject'),
          _buildSuggestionChip('B-IED071', Icons.code, 'Find Subject Code'),
        ],
      ),
    );
  }

  Widget _buildSuggestionChip(String text, IconData icon, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          _searchController.text = text;
          _performSearch(text);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue),
              const SizedBox(width: 8),
              Text(text,
                  style: const TextStyle(
                      color: Colors.blue, fontWeight: FontWeight.w500)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for:\n• Professor names (Dina, Norhan)\n• Group codes (0GNC2, 1l1)\n• Subject names (Production Technology)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return SearchResultCard(
          result: result,
          onTap: () => _navigateToRoom(result),
        );
      },
    );
  }
}
