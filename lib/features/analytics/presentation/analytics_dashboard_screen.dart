import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({Key? key}) : super(key: key);

  @override
  _AnalyticsDashboardScreenState createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic> _stats = {};
  List<Map<String, dynamic>> _regionData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAnalytics();
  }

  Future<void> _fetchAnalytics() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isLoading = true);
    try {
      final postsCount = await _supabase.from('posts')
          .select('id', count: CountOption.exact)
          .eq('user_id', userId);

      final totalLikes = await _supabase.rpc('get_user_total_likes',
          params: {'p_user_id': userId});
      final totalComments = await _supabase.rpc('get_user_total_comments',
          params: {'p_user_id': userId});

      final regionResult = await _supabase.from('post_analytics')
          .select('region, views')
          .maybeSingle();

      setState(() {
        _stats = {
          'posts': postsCount.count ?? 0,
          'likes': totalLikes ?? 0,
          'comments': totalComments ?? 0,
        };
        _regionData = regionResult != null ? [regionResult] : [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _statCard('Publications', _stats['posts'] ?? 0, Icons.post_add),
                      _statCard('Likes', _stats['likes'] ?? 0, Icons.favorite),
                      _statCard('Commentaires',
                          _stats['comments'] ?? 0, Icons.comment),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Vues par région',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sections: _regionData.isEmpty
                                    ? [
                                        PieChartSectionData(
                                          value: 1,
                                          title: 'Pas de données',
                                          color: Colors.grey,
                                        ),
                                      ]
                                    : _regionData
                                        .map((region) => PieChartSectionData(
                                              value: (region['views'] as num?)
                                                      ?.toDouble() ??
                                                  1,
                                              title: region['region'] ?? '',
                                              color: Colors.primaries[
                                                  _regionData
                                                      .indexOf(region) %
                                                  Colors.primaries.length],
                                            ))
                                        .toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Engagement',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: LineChart(
                              LineChartData(
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: List.generate(
                                        7,
                                        (index) => FlSpot(
                                            index.toDouble(),
                                            (index * 15 + 20)
                                                .toDouble())),
                                    isCurved: true,
                                    color: Colors.blue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _statCard(String title, int value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, size: 30),
              const SizedBox(height: 8),
              Text('$value',
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              Text(title, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      ),
    );
  }
}