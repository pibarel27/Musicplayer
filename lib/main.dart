import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spotify Clone',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.green,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const MusicPlayer(),
    );
  }
}

class MusicPlayer extends StatefulWidget {
  const MusicPlayer({super.key});

  @override
  MusicPlayerState createState() => MusicPlayerState();
}

class MusicPlayerState extends State<MusicPlayer> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration position = Duration.zero;
  Duration duration = Duration.zero;

  final List<Map<String, String>> playlist = [
    {
      "title": "SoundHelix Song 1",
      "artist": "Demo Artist",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "cover": "https://picsum.photos/400?random=1",
    },
    {
      "title": "SoundHelix Song 2",
      "artist": "Demo Artist",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
      "cover": "https://picsum.photos/400?random=2",
    },
    {
      "title": "SoundHelix Song 3",
      "artist": "Demo Artist",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3",
      "cover": "https://picsum.photos/400?random=3",
    },
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSong();
  }

  void _loadSong() async {
    await _player.setUrl(playlist[currentIndex]["url"]!);
    _player.positionStream.listen((p) {
      setState(() => position = p);
    });
    _player.durationStream.listen((d) {
      setState(() => duration = d ?? Duration.zero);
    });
  }

  void _togglePlayPause() {
    if (isPlaying) {
      _player.pause();
    } else {
      _player.play();
    }
    setState(() => isPlaying = !isPlaying);
  }

  void _nextSong() {
    currentIndex = (currentIndex + 1) % playlist.length;
    _loadSong();
    setState(() => isPlaying = false);
    _togglePlayPause();
  }

  void _prevSong() {
    currentIndex = (currentIndex - 1 + playlist.length) % playlist.length;
    _loadSong();
    setState(() => isPlaying = false);
    _togglePlayPause();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final song = playlist[currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("🎵 Spotify Clone"),
        actions: [
          IconButton(
            icon: const Icon(Icons.queue_music, color: Colors.green),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Colors.black87,
                context: context,
                builder: (context) => ListView(
                  children: playlist
                      .map(
                        (s) => ListTile(
                          leading: Image.network(
                            s["cover"]!,
                            width: 50,
                            fit: BoxFit.cover,
                          ),
                          title: Text(
                            s["title"]!,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            s["artist"]!,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            setState(() {
                              currentIndex = playlist.indexOf(s);
                              _loadSong();
                              _togglePlayPause();
                            });
                          },
                        ),
                      )
                      .toList(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(
                song["cover"]!,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 20),

            // Song Info
            Text(
              song["title"]!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              song["artist"]!,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Progress Bar
            Slider(
              activeColor: Colors.green,
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble() > 0
                  ? duration.inSeconds.toDouble()
                  : 1,
              onChanged: (value) {
                _player.seek(Duration(seconds: value.toInt()));
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDuration(position),
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  _formatDuration(duration),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: _prevSong,
                ),
                IconButton(
                  icon: Icon(
                    isPlaying ? Icons.pause_circle : Icons.play_circle,
                    color: Colors.green,
                    size: 60,
                  ),
                  onPressed: _togglePlayPause,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 40,
                  ),
                  onPressed: _nextSong,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }
}
