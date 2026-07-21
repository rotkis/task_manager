/// Valores padrão usados em várias partes do app.
class AppConstants {
  AppConstants._();

  // --- Durações padrão por tipo de tarefa ---
  static const int defaultPomodoroFocusMinutes = 25;
  static const int defaultPomodoroBreakMinutes = 5;
  static const int defaultTimedExerciseSeconds = 60;
  static const int defaultRepsTarget = 10;
  static const int defaultSetsTarget = 3;

  // --- Recompensa padrão ---
  static const int defaultRewardPoints = 10;

  // --- GitHub Releases (verificação de atualizações) ---
  static const String githubRepoOwner = 'rotkis';
  static const String githubRepoName = 'task_manager';
  static const String githubApiUrl =
      'https://api.github.com/repos/$githubRepoOwner/$githubRepoName/releases/latest';

  /// Tempo mínimo entre checagens de atualização (24 horas).
  static const int updateCheckIntervalHours = 24;

  /// SharedPreferences keys
  static const String prefLastUpdateCheck = 'last_update_check';
  static const String prefDismissedVersion = 'dismissed_update_version';
}
