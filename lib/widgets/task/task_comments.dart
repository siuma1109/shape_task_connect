import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../models/comment.dart';
import '../../repositories/comment_repository.dart';
import '../../services/location_service.dart';
import '../../services/photo_service.dart';
import '../../services/auth_service.dart';
import 'dart:io';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class TaskComments extends StatefulWidget {
  final int taskId;

  const TaskComments({
    super.key,
    required this.taskId,
  });

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
    setState(() {
      _commentsFuture = _commentRepository.getCommentsByTask(widget.taskId);
    });
  }

  Future<void> _refreshComments() async {
    _loadComments();
  }

  Future<void> _addComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    try {
      setState(() {
        _commentController.clear();
        FocusScope.of(context).unfocus(); // Hide keyboard after sending
      });

      final comment = Comment(
        taskId: widget.taskId,
        userId: _authService.currentUserDetails?.id ??
            0, // Use authenticated user ID
        content: content,
        createdAt: DateTime.now(),
      );

      await _commentRepository.createComment(comment);
      _refreshComments();
    } catch (e) {
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
        taskId: widget.taskId,
        userId: _authService.currentUserDetails?.id ??
            0, // Use authenticated user ID
        content: '📍 Shared a location',
        createdAt: DateTime.now(),
        latitude: locationData['latitude'],
        longitude: locationData['longitude'],
        address: locationData['address'],
      );

      await _commentRepository.createComment(comment);
      _loadComments();

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
        taskId: widget.taskId,
        userId: _authService.currentUserDetails?.id ??
            0, // Use authenticated user ID
        content: '📷 Shared a photo\n🏷️ Tags: $labelTexts',
        createdAt: DateTime.now(),
        photoPath: photoPath,
      );

      await _commentRepository.createComment(comment);
      _loadComments();

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

  void _showAttachmentOptions() {
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
                _uploadPhoto(fromCamera: false);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _uploadPhoto(fromCamera: true);
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('Share Location'),
              onTap: () {
                Navigator.pop(context);
                _shareLocation();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refreshComments,
            child: FutureBuilder<List<Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(top: 100),
                          child: Text('No comments yet'),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return ListTile(
                      title: Text(comment.user?.username ??
                          'User id: ${comment.userId}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                    color: Theme.of(context).primaryColor),
                              ),
                            ),
                          if (comment.photoPath != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Image.file(
                                File(comment.photoPath!),
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                        ],
                      ),
                      trailing: Text(_formatDate(comment.createdAt)),
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
                onPressed: _showAttachmentOptions,
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
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _addComment(),
                ),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _addComment,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}
