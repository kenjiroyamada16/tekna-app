enum TaskStatus {
  todo('To Do'),
  doing('In Progress'),
  done('Done');

  final String label;

  const TaskStatus(this.label);
}
