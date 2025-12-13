enum ProjectState {
  planned,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case ProjectState.planned:
        return 'Заплановано';
      case ProjectState.inProgress:
        return 'В процесі';
      case ProjectState.completed:
        return 'Завершено';
      case ProjectState.cancelled:
        return 'Відмінено';
    }
  }

  String toJson() {
    switch (this) {
      case ProjectState.planned:
        return 'planned';
      case ProjectState.inProgress:
        return 'in_progress';
      case ProjectState.completed:
        return 'completed';
      case ProjectState.cancelled:
        return 'cancelled';
    }
  }

  static ProjectState fromJson(String json) {
    switch (json) {
      case 'planned':
        return ProjectState.planned;
      case 'in_progress':
        return ProjectState.inProgress;
      case 'completed':
        return ProjectState.completed;
      case 'cancelled':
        return ProjectState.cancelled;
      default:
        return ProjectState.planned;
    }
  }
}
