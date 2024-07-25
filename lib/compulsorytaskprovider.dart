import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'CompulsoryTask.dart';

final db = FirebaseFirestore.instance;

class CompulsoryTaskProvider with ChangeNotifier {

  List<CompulsoryTask> _tasks = [];
  List<CompulsoryTask> get tasks => _tasks;

  final docref= db.collection("username");

  void addTask(String title, [String? imagePath]) {
    final time = DateTime.timestamp().millisecondsSinceEpoch;
    final newTask = CompulsoryTask(id: DateTime.now().toString(), title: title, imagePath: imagePath, streak: 0, time: time, isComplete: false);
    Map<String, dynamic> data = {
      'title': newTask.title,
      'image': newTask.imagePath,
      'done': newTask.isComplete,
      'streak': 0,
      'dayCount': 1,
      'time': time,
    };
    docref.doc(time.toString()).set(data);
    _tasks.add(newTask);
    notifyListeners();
  }
  
  void addTaskList(String value,String value2, String value3, int Streak, bool isComplete){
    final newTask= CompulsoryTask(id: DateTime.now().toString(), title: value,imagePath: value2, time: value3, streak: Streak, isComplete: isComplete);
    _tasks.add(newTask);
    notifyListeners();
  }

  void removeAll(){
    _tasks=[];
  }
  void notifyProvider(){
    notifyListeners();
  }

  void removeTask(int index) {
    docref.doc(_tasks[index].time.toString()).delete();
    _tasks.removeAt(index);
    notifyListeners();
  }
}
