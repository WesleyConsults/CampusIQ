enum HomeSetupStep {
  university,
  courses,
  timetable,
  academicHistory,
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
      !hasUniversityAndGradingSystem || !hasCurrentCourses || !hasTimetable;

  int get completedStepCount => [
        hasUniversityAndGradingSystem,
        hasCurrentCourses,
        hasTimetable,
        hasAcademicHistory,
      ].where((isComplete) => isComplete).length;

  HomeSetupStep? get nextSetupStep {
    if (!hasUniversityAndGradingSystem) return HomeSetupStep.university;
    if (!hasCurrentCourses) return HomeSetupStep.courses;
    if (!hasTimetable) return HomeSetupStep.timetable;
    if (!hasAcademicHistory) return HomeSetupStep.academicHistory;
    return null;
  }
}
