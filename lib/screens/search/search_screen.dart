import 'package:flutter/material.dart';
import '../../models/task_item.dart';
import '../../widgets/task/task_card.dart';
import '../../utils/demo_data.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  bool _isSearchingTasks = false;
  List<String> _userSuggestions = [];
  List<TaskItem> _allTasks = []; // Original list of all tasks
  List<TaskItem> _filteredTasks = []; // Filtered tasks for search results

  @override
  void initState() {
    super.initState();
    _allTasks = DemoData.generateTasks();
    _filteredTasks = List.from(_allTasks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetSearch() {
    setState(() {
      _showSearchBar = false;
      _searchController.clear();
      _isSearchingTasks = false;
      _userSuggestions.clear();
      _filteredTasks = List.from(_allTasks); // Restore all tasks
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _showSearchBar
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search tasks or users...',
                  border: InputBorder.none,
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                style: const TextStyle(color: Colors.black, fontSize: 16.0),
                onChanged: _handleSearchChange,
                onSubmitted: _handleSearchSubmit,
              )
            : const Text(
                'Search',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
        actions: [
          IconButton(
            icon: Icon(_showSearchBar ? Icons.close : Icons.search),
            onPressed: () {
              if (_showSearchBar) {
                _resetSearch();
              } else {
                setState(() {
                  _showSearchBar = true;
                });
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showSearchBar &&
              _searchController.text.isNotEmpty &&
              !_isSearchingTasks &&
              _userSuggestions.isNotEmpty)
            Expanded(
              child: _buildUserSuggestions(),
            )
          else
            Expanded(
              child: _buildTasksList(),
            ),
        ],
      ),
    );
  }

  void _handleSearchChange(String query) {
    if (query.isEmpty) {
      setState(() {
        _userSuggestions.clear();
        _isSearchingTasks = false;
        _filteredTasks = List.from(_allTasks);
      });
      return;
    }

    setState(() {
      _userSuggestions = [
        'User 1',
        'User 2',
        'User 3',
      ]
          .where((user) => user.toLowerCase().contains(query.toLowerCase()))
          .toList();
      _isSearchingTasks = false;
    });
  }

  void _handleSearchSubmit(String query) {
    setState(() {
      _isSearchingTasks = true;
      _userSuggestions.clear();
      _filteredTasks = _allTasks
          .where((task) =>
              task.title.toLowerCase().contains(query.toLowerCase()) ||
              task.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Widget _buildUserSuggestions() {
    return ListView.builder(
      itemCount: _userSuggestions.length,
      itemBuilder: (context, index) {
        final user = _userSuggestions[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(user[0]),
          ),
          title: Text(user),
          onTap: () {
            // TODO: Handle user selection
          },
        );
      },
    );
  }

  Widget _buildTasksList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredTasks.length,
      itemBuilder: (context, index) {
        return TaskCard(todo: _filteredTasks[index]);
      },
    );
  }
}
