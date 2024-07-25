class CompulsoryTask {
  final String id;
  final String title;
  bool isComplete;
  final String? imagePath;
  final time;
  bool showDeleteOpt;
  int streak;
  CompulsoryTask({required this.id, required this.title, required this.isComplete, required this.imagePath, required this.streak, this.showDeleteOpt=false, required this.time});
}
