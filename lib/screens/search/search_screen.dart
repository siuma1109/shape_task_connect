import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/task_item.dart';
import '../../models/user.dart';
import '../../repositories/task_repository.dart';
import '../../repositories/user_repository.dart';
import '../../widgets/user/user_details.dart';
import '../../widgets/task/task_list.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _taskRepository = GetIt.instance<TaskRepository>();
  final _userRepository = GetIt.instance<UserRepository>();
  bool _showSearchBar = false;
  bool _isSearchingTasks = false;
  bool _isLoading = false;
  List<User> _userSuggestions = [];
  List<TaskItem> _allTasks = [];
  List<TaskItem> _filteredTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final tasks = await _taskRepository.getAllTasks();
      if (mounted) {
        setState(() {
          _allTasks = tasks;
          _filteredTasks = List.from(_allTasks);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> refreshTasks() async {
    await _loadTasks();
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
            icon: const Icon(Icons.refresh),
            onPressed: refreshTasks,
          ),
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
      body: RefreshIndicator(
        onRefresh: refreshTasks,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  if (_showSearchBar &&
                      _searchController.text.isNotEmpty &&
                      !_isSearchingTasks &&
                      _userSuggestions.isNotEmpty)
                    Expanded(child: _buildUserSuggestions())
                  else
                    Expanded(
                      child: TaskList(
                        tasks: _filteredTasks,
                        onRefresh: refreshTasks,
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  void _handleSearchChange(String query) async {
    if (query.isEmpty) {
      setState(() {
        _userSuggestions.clear();
        _isSearchingTasks = false;
        _filteredTasks = List.from(_allTasks);
      });
      return;
    }

    try {
      // Search users by keyword
      final users = await _userRepository.searchUsers(query);
      if (mounted) {
        setState(() {
          _userSuggestions = users;
          _isSearchingTasks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userSuggestions = [];
          _isSearchingTasks = false;
        });
      }
    }
  }

  Future<void> _handleSearchSubmit(String query) async {
    setState(() {
      _isSearchingTasks = true;
      _userSuggestions.clear();
    });

    try {
      final tasks = await _taskRepository.searchTasks(query);
      if (mounted) {
        setState(() {
          _filteredTasks = tasks;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _filteredTasks = [];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error searching tasks. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildUserSuggestions() {
    return ListView.builder(
      itemCount: _userSuggestions.length,
      itemBuilder: (context, index) {
        final user = _userSuggestions[index];
        return ListTile(
          leading: CircleAvatar(
            child: Text(user.username[0].toUpperCase()),
          ),
          title: Text(user.username),
          subtitle: Text(user.email),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserDetails(user: user),
              ),
            );
          },
        );
      },
    );
  }
}
