import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LiveStreamScreen extends StatefulWidget {
  final String streamId;
  final String title;
  final String roomName;

  const LiveStreamScreen({
    Key? key,
    required this.streamId,
    required this.title,
    required this.roomName,
  }) : super(key: key);

  @override
  _LiveStreamScreenState createState() => _LiveStreamScreenState();
}

class _LiveStreamScreenState extends State<LiveStreamScreen> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isMuted = false;
  bool _isCameraOff = false;
  int _viewerCount = 0;

  @override
  void initState() {
    super.initState();
    _connectToLiveStream();
  }

  Future<void> _connectToLiveStream() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  Future<void> _toggleMute() async {
    setState(() => _isMuted = !_isMuted);
  }

  Future<void> _toggleCamera() async {
    setState(() => _isCameraOff = !_isCameraOff);
  }

  Future<void> _endStream() async {
    await _supabase.from('live_streams').update({
      'status': 'ended',
      'ended_at': DateTime.now().toIso8601String(),
    }).eq('id', widget.streamId);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          TextButton(
            onPressed: _endStream,
            child: const Text('Terminer'),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: _isCameraOff
                          ? const Text('Caméra désactivée',
                              style: TextStyle(color: Colors.white54))
                          : const Icon(Icons.videocam,
                              size: 100, color: Colors.white54),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
                        onPressed: _toggleMute,
                        iconSize: 32,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: Icon(
                            _isCameraOff ? Icons.videocam_off : Icons.videocam),
                        onPressed: _toggleCamera,
                        iconSize: 32,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.flip_camera_ios),
                        onPressed: () {},
                        iconSize: 32,
                        color: Colors.white,
                      ),
                      IconButton(
                        icon: const Icon(Icons.stop_circle),
                        color: Colors.red,
                        onPressed: _endStream,
                        iconSize: 32,
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}