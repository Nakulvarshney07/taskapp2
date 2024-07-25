import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:outtaskapp/temproryTask.dart';
import 'package:intl/intl.dart';

final db = FirebaseFirestore.instance;

class TemprorytaskProvider with ChangeNotifier{
  List<Temprorytask> _tempTasks=[];
   List<Temprorytask> get tempTasks =>_tempTasks;

   final docref= db.collection("username").doc("Daily Task").collection(DateFormat.yMMMMd().format(DateTime.now()));

   void addTask(String value,String value2)async{
  final time = DateTime.timestamp().microsecondsSinceEpoch;
    final newTask=Temprorytask(id: DateTime.now().toString(), title: value,Subtitle: value2, time: time, isComplete: false);
    Map<String, dynamic> data = {
      'title': newTask.title,
      'subtitle': newTask.Subtitle,
      'done': newTask.isComplete,
      'time': time
    };
   docref.doc(time.toString()).set(data);
    _tempTasks.add(newTask);
    notifyListeners();
   }

  void addTaskList(String value,String value2, String value3, bool isComplete){
    final newTask=Temprorytask(id: DateTime.now().toString(), title: value,Subtitle: value2, time: value3, isComplete: isComplete);
    _tempTasks.add(newTask);
    notifyListeners();
  }

  void removeAll(){
     _tempTasks=[];
  }
  void notifyProvider(){
    notifyListeners();
  }

  void removeTask(int index){
     docref.doc(_tempTasks[index].time.toString()).delete();
    _tempTasks.removeAt(index);
    notifyListeners();
  }

}