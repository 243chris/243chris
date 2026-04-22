import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:africonnect/core/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;

  const PostCard({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
  }) : super(key: key);

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final _supabase = Supabase.instance.client;
  bool _isLiked = false;
  int _likesCount = 0;

  @override
  void initState() {
    super.initState();
    _likesCount = widget.post.likesCount;
    _checkIfLiked();
  }

  Future<void> _checkIfLiked() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    final result = await _supabase.from('likes')
        .select()
        .eq('user_id', user.id)
        .eq('target_type', 'post')
        .eq('target_id', widget.post.id)
        .maybeSingle();
    if (mounted) setState(() => _isLiked = result != null);
  }

  Future<void> _toggleLike() async {
    if (widget.onLike != null) {
      widget.onLike!();
    }
    
    final user = _supabase.auth.currentUser;
    if (user == null) return;
    
    final previousState = _isLiked;
    final previousCount = _likesCount;
    
    setState(() {
      _isLiked = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
    });

    try {
      if (!_isLiked) {
        await _supabase.from('likes')
            .delete()
            .eq('user_id', user.id)
            .eq('target_type', 'post')
            .eq('target_id', widget.post.id);
      } else {
        await _supabase.from('likes').insert({
          'user_id': user.id,
          'target_type': 'post',
          'target_id': widget.post.id,
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLiked = previousState;
          _likesCount = previousCount;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de liker ce post')),
        );
      }
    }
  }

  Future<void> _repost() async {
    await _supabase.from('posts').insert({
      'user_id': _supabase.auth.currentUser!.id,
      'is_repost': true,
      'original_post_id': widget.post.id,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post repartagé!')),
      );
    }
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Signaler ce contenu'),
        content: const Text('Pourquoi signalez-vous ce post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _supabase.from('reports').insert({
                'reporter_id': _supabase.auth.currentUser!.id,
                'target_type': 'post',
                'target_id': widget.post.id,
                'reason': 'Contenu inapproprié',
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Merci, nous allons vérifier.')),
              );
            },
            child: const Text('Signaler'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: widget.post.profile?.avatarUrl != null
                      ? NetworkImage(widget.post.profile!.avatarUrl!)
                      : null,
                  child: widget.post.profile?.avatarUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.profile?.username ?? 'Utilisateur',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        timeago.format(widget.post.createdAt),
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: _showReportDialog,
                ),
              ],
            ),
            if (widget.post.content != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(widget.post.content!),
              ),
            if (widget.post.mediaUrls != null && widget.post.mediaUrls!.isNotEmpty)
              Container(
                height: 200,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[200],
                ),
                child: widget.post.mediaType == 'image'
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          widget.post.mediaUrls!.first,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(child: Icon(Icons.video_library, size: 50)),
              ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isLiked ? Icons.favorite : Icons.favorite_border,
                    color: _isLiked ? Colors.red : null,
                  ),
                  onPressed: _toggleLike,
                ),
                Text('$_likesCount'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.comment_outlined),
                  onPressed: widget.onComment ?? () {},
                ),
                Text('${widget.post.commentsCount}'),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.repeat),
                  onPressed: widget.onShare ?? _repost,
                ),
                Text('${widget.post.sharesCount}'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: widget.onShare ?? () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}