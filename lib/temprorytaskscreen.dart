import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:outtaskapp/CompulsorytaskScreen.dart';
import 'package:provider/provider.dart';
import 'package:outtaskapp/taskprovider.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';


class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});
  @override
  State<TaskScreen> createState() => _TaskScreenState();
}
Future<void> _launchUrl() async {
  final _url = Uri.parse("https://modefocus78.vercel.app/");
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}
class _TaskScreenState extends State<TaskScreen> {
  late StreamSubscription _intentSub;
  final _sharedFiles = <SharedMediaFile>[];
  Iterable<Map<String, dynamic>> sharedString= [];
  final db = FirebaseFirestore.instance;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller1 = TextEditingController();

  @override
  void initState(){
    super.initState();
    getData();
    _intentSub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);
      });
    }, onError: (err) {
      print("getIntentDataStream error: $err");
    });

    ReceiveSharingIntent.instance.getInitialMedia().then((value) {
      setState(() {
        _sharedFiles.clear();
        _sharedFiles.addAll(value);

        sharedString = _sharedFiles.map((f) => f.toMap());
        for(var newvalue in sharedString){
          showBottomsheet(newvalue['path']);
        }

        // Tell the library that we are done processing the intent.
        ReceiveSharingIntent.instance.reset();
      });
    });

  }

  @override
  void dispose() {
    _intentSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.task_alt, color: Colors.blue),
                label: "Today's Task"),
            BottomNavigationBarItem(
                icon: Icon(Icons.local_fire_department_rounded,
                    color: Colors.black),
                label: "Daily Task")
          ],
          onTap: (index) {
            if (index == 1) {
              Navigator.pushReplacement<void, void>(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => CompulsoryTaskScreen(),
                ),
              );
            }
          },
        ),
        appBar: AppBar(
          title: Text("Today's Tasks"),
          centerTitle: true,
          backgroundColor: Color(0xFF09ADEB),
        ),
        body: Column(
          children: [
            Expanded(
              child: Consumer<TemprorytaskProvider>(
                builder: (context, value, child) => ListView.builder(
                  itemCount: value.tempTasks.length,
                  itemBuilder: (context, index) {
                    final task = value.tempTasks[index];
                    bool isDone = task.isComplete;
                    return GestureDetector(
                      onTap: ()async{
                        String subtitle= task.Subtitle;
                       if(subtitle.contains("https://youtu")){
                         if(subtitle.contains("https://youtu.be/")){
                           String fullLink = subtitle;
                           String videoLink = fullLink.substring(17);
                           print(videoLink);
                          await db.collection("username").doc("youtube").set({ 'src': videoLink});
                         }
                         else{
                           String fullLink = subtitle;
                           String rawvideoLink = fullLink.split("v=")[1];
                           String videoLink = rawvideoLink.split("&")[0]+"?"+rawvideoLink.split("&")[1];
                           print(videoLink);
                          await db.collection("username").doc("youtube").set({ 'src': videoLink});
                         }
                        await _launchUrl();
                       }

                      },
                      child: Card(

                        margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(12),
                          tileColor: task.isComplete
                              ? Color(0xAA09ADEB)
                              : Colors.yellow.withOpacity(0.7),
                          leading: Transform.scale(
                            scale: 1.4,
                            child: Checkbox(
                              checkColor: Colors.black,
                              activeColor: Colors.white,
                              value: isDone,
                              onChanged: (val)async {
                                task.isComplete = !task.isComplete;
                                final docref = db.collection("username").doc("Daily Task").collection(DateFormat.yMMMMd().format(DateTime.now()));
                               await docref.doc(task.time.toString()).update({"done": task.isComplete});
                                value.notifyProvider();
                              },
                              splashRadius: 20,
                            ),
                          ),
                          trailing: IconButton(
                            onPressed: () => value.removeTask(index),
                            icon: Icon(Icons.delete, color: Colors.red, size: 26),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 23),
                          ),
                          subtitle: Text(
                            task.Subtitle,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.lightGreenAccent,
          onPressed: () {
          showBottomsheet(null);
        }, child: Icon(Icons.add),)

    );
  }

void showBottomsheet(String? subtitle){
  final tempProvider= Provider.of<TemprorytaskProvider>(context, listen: false);
    if(subtitle != null ) _controller1.text= subtitle.toString();
  showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
              ),
              child: Column(children: [
                TextField(
                  controller: _controller,
                  decoration:
                  InputDecoration(labelText: 'Add a new task'),
                ),
                TextField(
                  controller: _controller1,
                  decoration: InputDecoration(
                      labelText: 'Add a subtitle to task'),
                ),
                ElevatedButton(
                    child: Text("Add"),
                    onPressed: () async {
                      if (_controller.text.isNotEmpty) {
                        tempProvider.addTask(
                            _controller.text, _controller1.text);
                        _controller.clear();
                        _controller1.clear();
                      }
                    })
              ]))));
}

  void getData()async{

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final diff = BigInt.parse(DateTime.timestamp().millisecondsSinceEpoch.toString())- BigInt.parse(prefs.get("today").toString());
    final docref2 = db.collection("username");
    if(diff >=BigInt.from(86400000) && diff<BigInt.from(172800000)){
      prefs.setString("today", DateTime.timestamp().millisecondsSinceEpoch.toString());
      await docref2.get().then(
            (querySnapshot) {
          for (var docSnapshot in querySnapshot.docs) {
            if (docSnapshot.id != "youtube") {
              if(docSnapshot['done']){
                docref2.doc(docSnapshot.id).update({
                  'done' : false,
                  'streak': docSnapshot['dayCount'],
                  'dayCount': docSnapshot['dayCount']+1,
                });
              }
              else{
                docref2.doc(docSnapshot.id).update({
                  'done' : false,
                  'streak': 0,
                  'dayCount': 1,
                });
              }

            }
          }
        },
        onError: (e) => print("Error completing: $e"),
      );
    }
    final val= Provider.of<TemprorytaskProvider>(context, listen: false);
    if(diff >=BigInt.from(86400000)){
      prefs.setString("today", DateTime.timestamp().millisecondsSinceEpoch.toString());
       db.collection("username").doc("Daily Task").delete().then((value) =>
           val.removeAll(),
         onError: (e) => print("Error updating document $e"),);
       return;
    }
    val.removeAll();
  final docref = db.collection("username").doc("Daily Task").collection(DateFormat.yMMMMd().format(DateTime.now()));
  await docref.get().then(
          (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
            val.addTaskList(docSnapshot['title'], docSnapshot['subtitle'], docSnapshot['time'].toString(), docSnapshot['done']);
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
  }

}
