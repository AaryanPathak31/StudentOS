import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:studentos/presentation/home_screen.dart';
import 'package:studentos/presentation/tasks/tasks_screen.dart';
import 'package:studentos/presentation/notes/note_editor_screen.dart';
import 'package:studentos/presentation/notes/notes_list_screen.dart'; 
import 'package:studentos/presentation/timer/timer_screen.dart';
import 'package:studentos/presentation/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithBottomNav(child: child);
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(path: '/tasks', builder: (context, state) => const TasksScreen()),
          GoRoute(path: '/notes', builder: (context, state) => const NotesListScreen()),
          GoRoute(path: '/timer', builder: (context, state) => const TimerScreen()),
          GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
        ],
      ),
      // Independent Route (No bottom nav)
      GoRoute(path: '/note_editor', builder: (context, state) {
        final id = state.extra as String?;
        return NoteEditorScreen(noteId: id);
      }),
    ],
  );
});

// Wrapper for Bottom Navigation
class ScaffoldWithBottomNav extends StatelessWidget {
  final Widget child;
  const ScaffoldWithBottomNav({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    // FIX: Use GoRouterState.of(context).uri.toString() for v13+
    final location = GoRouterState.of(context).uri.toString();
    
    int index = 0;
    if(location.startsWith('/tasks')) index = 1;
    if(location.startsWith('/notes')) index = 2;
    if(location.startsWith('/timer')) index = 3;
    if(location.startsWith('/settings')) index = 4;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (idx) {
          switch (idx) {
            case 0: GoRouter.of(context).go('/'); break;
            case 1: GoRouter.of(context).go('/tasks'); break;
            case 2: GoRouter.of(context).go('/notes'); break;
            case 3: GoRouter.of(context).go('/timer'); break;
            case 4: GoRouter.of(context).go('/settings'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Tasks'),
          NavigationDestination(icon: Icon(Icons.description), label: 'Notes'),
          NavigationDestination(icon: Icon(Icons.timer), label: 'Focus'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}