import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/post_model.dart';
import 'package:africonnect/features/feed/widgets/post_card.dart';
import 'package:africonnect/features/feed/widgets/create_post_bottom_sheet.dart';
import 'package:africonnect/widgets/common/loading_indicator.dart';
import 'package:africonnect/widgets/common/error_widget.dart' as app_error;

class FeedScreen extends StatefulWidget {
  const FeedScreen({Key? key}) : super(key: key);

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _supabase = Supabase.instance.client;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _isAlgorithmic = true;

  @override
  void initState() {
    super.initState();
    _fetchFeed();
    _subscribeToRealtime();
  }

  void _subscribeToRealtime() {
    _supabase.channel('public:posts').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'posts',
      callback: (_) => _fetchFeed(),
    ).subscribe();
  }

  Future<void> _fetchFeed() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      var query = _supabase.from('posts')
          .select('*, profiles(*)')
          .order('created_at', ascending: false)
          .limit(20);

      final response = await query;
      setState(() {
        _posts = (response as List).map((json) => PostModel.fromJson(json)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();
      });
    }
  }

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => CreatePostBottomSheet(
        onPostCreated: _fetchFeed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AfriConnect', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isAlgorithmic ? Icons.auto_awesome : Icons.access_time),
            tooltip: _isAlgorithmic ? 'Fil algortihmique' : 'Fil chronologique',
            onPressed: () => setState(() => _isAlgorithmic = !_isAlgorithmic),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchFeed,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreatePost,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) => const PostCardSkeleton(),
      );
    }

    if (_hasError) {
      return app_error.ErrorDisplay.network(onRetry: _fetchFeed);
    }

    if (_posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Aucun post pour le moment',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Soyez le premier à poster!',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _posts.length,
      itemBuilder: (context, index) => PostCard(post: _posts[index]),
    );
  }
}