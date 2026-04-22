import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:africonnect/core/models/post_model.dart';
import 'package:africonnect/core/models/comment_model.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  _PostDetailScreenState createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _supabase = Supabase.instance.client;
  List<CommentModel> _comments = [];
  final _commentController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    final response = await _supabase.from('comments')
        .select('*, profiles(*)')
        .eq('post_id', widget.post.id)
        .order('created_at', ascending: false);
    setState(() {
      _comments = (response as List).map((json) => CommentModel.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;
    await _supabase.from('comments').insert({
      'post_id': widget.post.id,
      'user_id': _supabase.auth.currentUser!.id,
      'content': _commentController.text,
    });
    _commentController.clear();
    _fetchComments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: widget.post.profile?.avatarUrl != null
                                ? NetworkImage(widget.post.profile!.avatarUrl!)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.profile?.username ?? 'Utilisateur',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                timeago.format(widget.post.createdAt),
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      if (widget.post.content != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(widget.post.content!),
                        ),
                      if (widget.post.mediaUrls != null && widget.post.mediaUrls!.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.post.mediaUrls!.first,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text('${widget.post.likesCount} likes'),
                          const SizedBox(width: 16),
                          Text('${widget.post.commentsCount} commentaires'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Commentaires',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _comments.isEmpty
                        ? const Center(child: Text('Aucun commentaire'))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _comments.length,
                            itemBuilder: (context, index) {
                              final comment = _comments[index];
                              return ListTile(
                                leading: const CircleAvatar(child: Icon(Icons.person)),
                                title: Text(comment.content),
                                subtitle: Text(
                                  timeago.format(comment.createdAt),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Ajouter un commentaire...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}