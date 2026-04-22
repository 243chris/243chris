import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:africonnect/core/models/user_model.dart';
import 'package:africonnect/core/models/post_model.dart';
import 'package:africonnect/features/auth/presentation/login_screen.dart';
import 'package:africonnect/features/feed/widgets/post_card.dart';
import 'package:africonnect/features/ai_tools/presentation/caricature_generator_screen.dart';
import 'package:africonnect/features/profile/presentation/edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _supabase = Supabase.instance.client;
  UserModel? _profile;
  List<PostModel> _posts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final targetId = widget.userId ?? _supabase.auth.currentUser?.id;
    if (targetId == null) return;

    final profileResponse = await _supabase.from('profiles')
        .select()
        .eq('id', targetId)
        .single();
    final postsResponse = await _supabase.from('posts')
        .select('*, profiles(*)')
        .eq('user_id', targetId)
        .order('created_at', ascending: false);

    setState(() {
      _profile = UserModel.fromJson(profileResponse);
      _posts = (postsResponse as List).map((json) => PostModel.fromJson(json)).toList();
      _isLoading = false;
    });
  }

  Future<void> _signOut() async {
    await _supabase.auth.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  bool get _isOwnProfile =>
      widget.userId == null || widget.userId == _supabase.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profile?.username ?? 'Profil'),
        actions: [
          if (_isOwnProfile)
            PopupMenuButton(
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Text('Modifier le profil'),
                ),
                const PopupMenuItem(
                  value: 'ai',
                  child: Text('Générateur IA'),
                ),
                const PopupMenuItem(
                  value: 'logout',
                  child: Text('Déconnexion'),
                ),
              ],
              onSelected: (value) {
                if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(profile: _profile),
                    ),
                  );
                } else if (value == 'ai') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CaricatureGeneratorScreen(),
                    ),
                  );
                } else if (value == 'logout') {
                  _signOut();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchProfile,
              child: ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: _profile?.avatarUrl != null
                              ? NetworkImage(_profile!.avatarUrl!)
                              : null,
                          child: _profile?.avatarUrl == null
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _profile?.fullName ?? _profile?.username ?? '',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '@${_profile?.username ?? ''}',
                          style: const TextStyle(color: Colors.grey),
                        ),
                        if (_profile?.bio != null) ...[
                          const SizedBox(height: 8),
                          Text(_profile!.bio!),
                        ],
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _statItem('Posts', _posts.length),
                            _statItem('Abonnements', 0),
                            _statItem('Abonnés', 0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Mes posts',
                        style:
                            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  if (_posts.isEmpty)
                    const Center(child: Text('Aucun post'))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) =>
                          PostCard(post: _posts[index]),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _statItem(String label, int value) {
    return Column(
      children: [
        Text('$value',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}