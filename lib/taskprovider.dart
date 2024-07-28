import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:outtaskapp/temproryTask.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

final db = FirebaseFirestore.instance;

class TemprorytaskProvider with ChangeNotifier{
  List<Temprorytask> _tempTasks=[];
   List<Temprorytask> get tempTasks =>_tempTasks;



   void addTask(String value,String value2)async{
     final prefs = await SharedPreferences.getInstance();
     final email = prefs.getString('email');
     final docref= db.collection(email.toString()).doc("Daily Task").collection(DateFormat.yMMMMd().format(DateTime.now()));
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

  void removeTask(int index)async{
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final docref= db.collection(email.toString()).doc("Daily Task").collection(DateFormat.yMMMMd().format(DateTime.now()));
     docref.doc(_tempTasks[index].time.toString()).delete();
    _tempTasks.removeAt(index);
    notifyListeners();
  }

}