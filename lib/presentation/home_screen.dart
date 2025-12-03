import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; // IMPORT THIS
import 'package:studentos/providers/task_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  // LOGIC FOR OPENING MUSIC APPS
  Future<void> _launchMusic(String type) async {
    final Uri url = type == 'spotify' 
      ? Uri.parse("spotify:open") // Tries to open app directly
      : Uri.parse("https://music.youtube.com"); // Opens YT Music web/app
    
    try {
      // mode: LaunchMode.externalApplication forces it to leave the StudentOS app
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        // Fallback for Spotify if app not installed, open web
        if (type == 'spotify') {
           await launchUrl(Uri.parse("https://open.spotify.com"), mode: LaunchMode.externalApplication);
        } else {
          throw 'Could not launch $url';
        }
      }
    } catch (e) {
      debugPrint("Could not launch music: $e");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskListProvider);
    final dailyTasks = tasks.where((t) => t.isDaily && !t.isCompleted).toList();
    final starredTasks = tasks.where((t) => t.isStarred && !t.isCompleted).toList();
    
    final quotes = [
      "The expert in anything was once a beginner.",
      "Focus is the key to productivity.",
      "Don't stop until you're proud.",
      "Study now. Be proud later."
    ];
    final quote = quotes[DateTime.now().day % quotes.length];

    return Scaffold(
      appBar: AppBar(title: const Text("StudentOS")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Daily Motivation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text("💡 Daily Thought", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    quote,
                    style: const TextStyle(color: Colors.black, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // Music Zone
            const Text("Study Music", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1DB954), // Spotify Green
                      foregroundColor: Colors.white
                    ),
                    icon: const Icon(Icons.music_note),
                    label: const Text("Spotify"),
                    onPressed: () => _launchMusic('spotify'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF0000), // Youtube Red
                      foregroundColor: Colors.white
                    ),
                    icon: const Icon(Icons.play_circle_fill),
                    label: const Text("YT Music"),
                    onPressed: () => _launchMusic('yt'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Quick Actions
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.timer), 
                    label: const Text("Start Focus"), 
                    onPressed: () => context.go('/timer')
                  )
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.add_task), 
                    label: const Text("New Task"), 
                    onPressed: () => context.go('/tasks')
                  )
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Daily Routine List
            _buildSectionHeader(context, "Daily Routine"),
            if (dailyTasks.isEmpty) 
               const Padding(padding: EdgeInsets.all(8.0), child: Text("No daily routines pending.", style: TextStyle(color: Colors.grey))),
            ...dailyTasks.map((t) => _buildCompactTaskItem(context, ref, t)),

            const SizedBox(height: 20),

            // Starred List
            _buildSectionHeader(context, "Starred Tasks"),
            if (starredTasks.isEmpty) 
               const Padding(padding: EdgeInsets.all(8.0), child: Text("No starred tasks.", style: TextStyle(color: Colors.grey))),
            ...starredTasks.map((t) => _buildCompactTaskItem(context, ref, t)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
    );
  }

  Widget _buildCompactTaskItem(BuildContext context, WidgetRef ref, dynamic task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        visualDensity: VisualDensity.compact,
        leading: Transform.scale(
          scale: 0.8,
          child: Checkbox(
            value: task.isCompleted,
            shape: const CircleBorder(),
            onChanged: (v) => ref.read(taskListProvider.notifier).toggleComplete(task),
          ),
        ),
        title: Text(task.title, style: const TextStyle(fontSize: 14)),
        trailing: IconButton(
          icon: Icon(task.isStarred ? Icons.star : Icons.star_border, color: Colors.orange, size: 20),
          onPressed: () => ref.read(taskListProvider.notifier).toggleStar(task),
        ),
      ),
    );
  }
}