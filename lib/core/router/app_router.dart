import 'package:go_router/go_router.dart';
import 'package:campusiq/features/cwa/presentation/screens/cwa_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/cwa',
  routes: [
    GoRoute(
      path: '/cwa',
      name: 'cwa',
      builder: (context, state) => const CwaScreen(),
    ),
    // Phase 2: /timetable
    // Phase 3: /schedule
    // Phase 4: /sessions
    // Phase 5: /streak
  ],
);
