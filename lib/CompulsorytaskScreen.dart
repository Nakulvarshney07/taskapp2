import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:outtaskapp/temprorytaskscreen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'compulsorytaskprovider.dart';
import 'package:path_provider/path_provider.dart';


const String appGroupId = 'com.example.outtaskapp'; // Add from here
const String iOSWidgetName = 'MotivationWidget';
const String androidWidgetName = 'MotivationWidget';

class CompulsoryTaskScreen extends StatefulWidget {
  const CompulsoryTaskScreen({super.key});
  @override
  State<CompulsoryTaskScreen> createState() => _CompulsoryTaskScreenState();
}



class _CompulsoryTaskScreenState extends State<CompulsoryTaskScreen> {
  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await rootBundle.load('assets/$path');

    Directory appDocDir = await getApplicationDocumentsDirectory();
    String imagesAppDirectory = appDocDir.path;
    final file =
    await File('$imagesAppDirectory/$path').create(recursive: true);

    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file;
  }
  void updateWidget(bool allcomplete) async {

    // HomeWidget.saveWidgetData<String>('filename', filepath);

    if(allcomplete){
    File file = await getImageFileFromAssets("img.png");
    HomeWidget.saveWidgetData<String>("filename", file.path);
    }
    else{
      File file = await getImageFileFromAssets("complete.png");
      HomeWidget.saveWidgetData<String>("filename", file.path);
    }
    HomeWidget.updateWidget(
      iOSName: iOSWidgetName,
      androidName: androidWidgetName,
    );
  }
  final TextEditingController _controller = TextEditingController();
  int count = 0;
  int completedtasks = 0;
  final _globalKey = GlobalKey();
  String? imagePath;

  @override
  void initState() {
    super.initState();
    getData();
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        unselectedFontSize: 14,
        selectedLabelStyle: TextStyle(color: Colors.grey),
        unselectedLabelStyle: TextStyle(color: Colors.grey),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.task_alt,
                color: Colors.black,
              ),
              label: "Today's Task"
              ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.local_fire_department_rounded,
                color: Colors.blue,
                size: 30,
              ),
              label: "Daily Task")
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement<void, void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const TaskScreen(),
              ),
            );
          } else if (index == 1) {
            Navigator.pushReplacement<void, void>(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) => const CompulsoryTaskScreen(),
              ),
            );
          }
        },
      ),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Daily Tasks'),
        backgroundColor: Color(0xFF09ADEB),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              Consumer<CompulsoryTaskProvider>(
                builder: (context, taskProvider, child) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: GridView.count(
                      padding: const EdgeInsets.all(10),
                      childAspectRatio: 0.8 / 1,
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 20.0,
                      children: List.generate(
                        taskProvider.tasks.length,
                        (index) {
                          final task = taskProvider.tasks[index];
                          bool isDone = task.isComplete;
                          return TapRegion(
                            onTapOutside: (PointerDownEvent) {
                              task.showDeleteOpt = false;
                              taskProvider.notifyProvider();
                            },
                            child: GestureDetector(
                                onLongPress: () {
                                  task.showDeleteOpt = true;
                                  taskProvider.notifyProvider();
                                },
                                child: Stack(
                                  children: [
                                    Opacity(
                                      opacity: task.showDeleteOpt ? 0.4 : 1,
                                      child: Container(
                                        padding: const EdgeInsets.all(10),

                                        decoration: BoxDecoration(
                                            color: task.isComplete
                                                ? Color(0xBB09ADEB)
                                                : const Color(0x77FFAC66),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Checkbox(
                                                    activeColor:
                                                        Colors.yellowAccent,
                                                    checkColor: Colors.black,
                                                    value: isDone,
                                                    onChanged: (value) async {
                                                      final prefs = await SharedPreferences.getInstance();
                                                      final email = prefs.getString('email');
                                                      final docref =
                                                          db.collection(
                                                              email.toString());
                                                      task.isComplete =
                                                          !task.isComplete;
                                                      await docref
                                                          .doc(task.time
                                                              .toString())
                                                          .update({
                                                        "done": task.isComplete
                                                      });
                                                      getData();
                                                    }),
                                                const SizedBox(
                                                  width: 5,
                                                ),
                                                SizedBox(
                                                  width: (width/2)-90,
                                                  child:Text(
                                                    task.title,
                                                    style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 18, overflow: TextOverflow.ellipsis),
                                                    softWrap: true,
                                                    maxLines: 2,

                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              width: 100,
                                              height: 100,
                                              child: task.imagePath != null
                                                  ? Image.file(
                                                      File(
                                                        task.imagePath!,
                                                      ),
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (BuildContext context,
                                                              Object error,
                                                              StackTrace?
                                                                  stackTrace) {
                                                        return Image.asset(
                                                            "assets/icon.jpg", width: 100, height: 100, fit: BoxFit.cover,);
                                                      },
                                                    )
                                                  : Image.asset(
                                                      "assets/icon.jpg",
                                                      width: 100, height: 100,
                                                      fit: BoxFit.cover,
                                                    ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            if (isDone)
                                              Text(" 🔥 ${task.streak + 1}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 20)),
                                            if (!isDone)
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "😴 ${task.streak + 1}",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 22,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  Text(
                                                    "❓",
                                                    style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w800),
                                                  ),
                                                ],
                                              )
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (task.showDeleteOpt)
                                      Positioned(
                                        child: Center(
                                          child: Container(
                                            constraints:
                                                const BoxConstraints.expand(),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              color:
                                                  Colors.red.withOpacity(0.5),
                                            ),
                                            alignment: Alignment.center,
                                            child: IconButton(
                                                onPressed: () {
                                                  taskProvider
                                                      .removeTask(index);
                                                },
                                                icon: const Icon(
                                                  Icons.delete,
                                                  size: 100,
                                                  color: Colors.red,
                                                )),
                                          ),
                                        ),
                                      ),
                                  ],
                                )),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellowAccent.shade400,
        onPressed: () {
          showModalBottomSheet(
            isScrollControlled: true,
            context: context,
            builder: (_) => SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _controller,
                      decoration:
                          const InputDecoration(labelText: 'Add a new task'),
                    ),
                    ElevatedButton(
                      child: const Text('Add'),
                      onPressed: () async {
                        if (_controller.text.isNotEmpty) {
                          await _pickImage(context);
                          _controller.clear();
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final provider =
        Provider.of<CompulsoryTaskProvider>(context, listen: false);
    //always try to use provider before any await to avoid any future error
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      provider.addTask(_controller.text, image.path);
      _controller.clear();
    }
  }

  void getData() async {
    count = 0;
    completedtasks = 0;
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    final docref = db.collection(email.toString());
    final val = Provider.of<CompulsoryTaskProvider>(context, listen: false);
    val.removeAll();
    await docref.get().then(
      (querySnapshot) {
        for (var docSnapshot in querySnapshot.docs) {
          if (docSnapshot.id != "youtube") {
            count = count + 1;
            if (docSnapshot['done']) completedtasks = completedtasks + 1;
            val.addTaskList(
                docSnapshot['title'],
                docSnapshot['image'],
                docSnapshot['time'].toString(),
                docSnapshot['streak'],
                docSnapshot['done']);
          }
        }
      },
      onError: (e) => print("Error completing: $e"),
    );
    if (count == completedtasks) {
      updateWidget(true);
    } else {
      updateWidget(false);
    }
  }
}
