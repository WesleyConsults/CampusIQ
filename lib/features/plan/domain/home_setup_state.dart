enum HomeSetupStep {
  university,
  timetable,
}

class HomeSetupState {
  final bool hasUniversityAndGradingSystem;
  final bool hasCurrentCourses;
  final bool hasTimetable;
  final bool hasAcademicHistory;
  final bool hasSeenInitialWelcome;
  final String? firstName;

  const HomeSetupState({
    required this.hasUniversityAndGradingSystem,
    required this.hasCurrentCourses,
    required this.hasTimetable,
    required this.hasAcademicHistory,
    required this.hasSeenInitialWelcome,
    this.firstName,
  });

  bool get isInitialHomeSetup =>
      !hasUniversityAndGradingSystem || !hasTimetable;

  int get completedStepCount => [
        hasUniversityAndGradingSystem,
        hasTimetable,
      ].where((isComplete) => isComplete).length;

  HomeSetupStep? get nextSetupStep {
    if (!hasUniversityAndGradingSystem) return HomeSetupStep.university;
    if (!hasTimetable) return HomeSetupStep.timetable;
    return null;
  }
}
