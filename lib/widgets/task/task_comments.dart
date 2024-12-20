import 'package:flutter/material.dart';
import 'package:shape_task_connect/models/comment.dart';
import '../../models/task.dart';
import 'package:get_it/get_it.dart';
import '../../../repositories/comment_repository.dart';
import '../../../services/location_service.dart';
import '../../../services/photo_service.dart';
import '../../../services/auth_service.dart';
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class TaskComments extends StatefulWidget {
  final Task task;
  final Future<void> Function()? onRefresh;

  const TaskComments({
    super.key,
    required this.task,
    this.onRefresh,
  });

  static Future<bool?> show(BuildContext context, Task task,
      {Future<void> Function()? onRefresh}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      builder: (context) => TaskComments(task: task, onRefresh: onRefresh),
    );
  }

  @override
  State<TaskComments> createState() => _TaskCommentsState();
}

class _TaskCommentsState extends State<TaskComments> {
  final _commentRepository = GetIt.instance<CommentRepository>();
  final _commentController = TextEditingController();
  final _locationService = GetIt.instance<LocationService>();
  final _photoService = GetIt.instance<PhotoService>();
  final _authService = GetIt.instance<AuthService>();
  late Future<List<Comment>> _commentsFuture;
  final _imageLabeler = ImageLabeler(options: ImageLabelerOptions());
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _imageLabeler.close();
    super.dispose();
  }

  void _loadComments() {
    try {
      _commentsFuture = _commentRepository.getCommentsByTask(widget.task.id!);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load comments. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      _commentsFuture = Future.value([]);
    }
  }

  Future<void> _refreshComments() async {
    setState(() {
      _commentsFuture = _commentRepository.getCommentsByTask(widget.task.id!);
    });
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      setState(() {
        _isLoading = true;
        _commentController.clear();
        FocusScope.of(context).unfocus();
      });

      final comment = Comment(
        taskId: widget.task.id!,
        userId: _authService.currentUserDetails!.uid,
        content: content,
      );

      await _commentRepository.createComment(comment);
      setState(() {
        _commentsFuture = _commentRepository.getCommentsByTask(widget.task.id!);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to add comment. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareLocation() async {
    final hasPermission = await _locationService.checkPermission(context);
    if (!hasPermission) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location permission is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final locationData = await _locationService.getCurrentLocation();
    if (locationData == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to get location'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final comment = Comment(
        taskId: widget.task.id!,
        userId: _authService.currentUserDetails!.uid,
        content: '📍 Shared a location',
        latitude: locationData['latitude'],
        longitude: locationData['longitude'],
        address: locationData['address'],
      );

      await _commentRepository.createComment(comment);
      setState(() {
        _commentsFuture = _commentRepository.getCommentsByTask(widget.task.id!);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location shared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share location'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _uploadPhoto({required bool fromCamera}) async {
    final photoPath =
        await _photoService.pickAndSavePhoto(fromCamera: fromCamera);
    if (photoPath == null) return;

    try {
      final inputImage = InputImage.fromFilePath(photoPath);
      final labels = await _imageLabeler.processImage(inputImage);

      final labelTexts = labels.take(3).map((label) => label.label).join(', ');

      final comment = Comment(
        taskId: widget.task.id!,
        userId: _authService.currentUserDetails!.uid,
        content: '📷 Shared a photo\n🏷️ Tags: $labelTexts',
        photoPath: photoPath,
      );

      await _commentRepository.createComment(comment);
      setState(() {
        _commentsFuture = _commentRepository.getCommentsByTask(widget.task.id!);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo shared successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to share photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _showAttachmentOptions() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                _uploadPhoto(fromCamera: false).then((_) {
                  setState(() => _isLoading = false);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                _uploadPhoto(fromCamera: true).then((_) {
                  setState(() => _isLoading = false);
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Share Location'),
              onTap: () {
                Navigator.pop(context);
                setState(() => _isLoading = true);
                _shareLocation().then((_) {
                  setState(() => _isLoading = false);
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSend() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() => _isLoading = true);

    try {
      await _addComment();

      _commentController.clear();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          _buildHandle(),
          _buildHeader(),
          Expanded(
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refreshComments,
                        child: FutureBuilder<List<Comment>>(
                          future: _commentsFuture,
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                  child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            final comments = snapshot.data ?? [];

                            if (comments.isEmpty) {
                              return ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: const [
                                  Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 100),
                                      child: Text(
                                        'No comments yet! 🎉\nBe the first to comment!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }

                            return ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: comments.length,
                              itemBuilder: (context, index) {
                                final comment = comments[index];
                                return ListTile(
                                  title: Text(comment.user?.displayName ??
                                      'User id: ${comment.userId}'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(comment.content),
                                      if (comment.address != null)
                                        InkWell(
                                          onTap: () => _locationService.openMap(
                                            comment.latitude!,
                                            comment.longitude!,
                                          ),
                                          child: Text(
                                            '📍 ${comment.address}',
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .primaryColor),
                                          ),
                                        ),
                                      if (comment.photoPath != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Image.file(
                                            File(comment.photoPath!),
                                            height: 200,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: Text(
                                      _formatDate(comment.createdAt.toDate())),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.attach_file),
                            onPressed:
                                _isLoading ? null : _showAttachmentOptions,
                          ),
                          Expanded(
                            child: TextField(
                              controller: _commentController,
                              decoration: const InputDecoration(
                                hintText: 'Add a comment...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                              ),
                              maxLines: null,
                              enabled: !_isLoading,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) =>
                                  _isLoading ? null : _handleSend(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _isLoading ? null : _handleSend,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black26,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: const Row(
        children: [
          Text(
            'Comments',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
