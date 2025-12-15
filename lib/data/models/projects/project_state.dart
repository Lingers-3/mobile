enum ProjectState {
  planned,
  inProgress,
  completed,
  cancelled;

  String get label {
    switch (this) {
      case ProjectState.planned:
        return 'Planning';
      case ProjectState.inProgress:
        return 'In progress';
      case ProjectState.completed:
        return 'Completed';
      case ProjectState.cancelled:
        return 'Canceled';
    }
  }

  String toJson() {
    switch (this) {
      case ProjectState.planned:
        return 'Planning';
      case ProjectState.inProgress:
        return 'Active';
      case ProjectState.completed:
        return 'Completed';
      case ProjectState.cancelled:
        return 'Canceled';
    }
  }

  static ProjectState fromJson(String json) {
    switch (json) {
      case 'Planning':
        return ProjectState.planned;
      case 'Active':
        return ProjectState.inProgress;
      case 'Completed':
        return ProjectState.completed;
      case 'Canceled':
        return ProjectState.cancelled;
      default:
        return ProjectState.planned;
    }
  }
}
