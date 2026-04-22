import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/page_model.dart';
import 'package:africonnect/core/models/post_model.dart';
import 'package:africonnect/features/feed/widgets/post_card.dart';

class PageScreen extends StatefulWidget {
  final String pageId;

  const PageScreen({Key? key, required this.pageId}) : super(key: key);

  @override
  _PageScreenState createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  final _supabase = Supabase.instance.client;
  PageModel? _page;
  List<PostModel> _posts = [];
  bool _isLoading = true;
  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  Future<void> _fetchPage() async {
    final pageResponse = await _supabase.from('pages')
        .select('*, profiles(*)')
        .eq('id', widget.pageId)
        .single();
    final postsResponse = await _supabase.from('posts')
        .select('*, profiles(*))')
        .eq('user_id', pageResponse['owner_id'])
        .order('created_at', ascending: false);

    final userId = _supabase.auth.currentUser?.id;
    if (userId != null) {
      final follow = await _supabase.from('page_followers')
          .select()
          .eq('page_id', widget.pageId)
          .eq('user_id', userId)
          .maybeSingle();
      _isFollowing = follow != null;
    }

    setState(() {
      _page = PageModel.fromJson(pageResponse);
      _posts =
          (postsResponse as List).map((json) => PostModel.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  Future<void> _toggleFollow() async {
    final userId = _supabase.auth.currentUser!.id;
    if (_isFollowing) {
      await _supabase.from('page_followers')
          .delete()
          .eq('page_id', widget.pageId)
          .eq('user_id', userId);
    } else {
      await _supabase.from('page_followers').insert({
        'page_id': widget.pageId,
        'user_id': userId,
      });
    }
    setState(() => _isFollowing = !_isFollowing);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(_page?.name ?? ''),
                    background: _page?.coverUrl != null
                        ? Image.network(_page!.coverUrl!, fit: BoxFit.cover)
                        : Container(color: Colors.grey),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_page?.description ?? ''),
                        const SizedBox(height: 16),
                        Text(
                            '${_page?.followersCount ?? 0} abonnés'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _toggleFollow,
                          child: Text(_isFollowing
                              ? 'Ne plus suivre'
                              : 'Suivre'),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => PostCard(post: _posts[index]),
                    childCount: _posts.length,
                  ),
                ),
              ],
            ),
    );
  }
}