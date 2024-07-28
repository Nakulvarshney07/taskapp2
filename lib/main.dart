import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:outtaskapp/LoginPage.dart';
import 'package:outtaskapp/taskprovider.dart';
import 'package:outtaskapp/temprorytaskscreen.dart';
import 'package:provider/provider.dart';
import 'compulsorytaskprovider.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.get("today") == null) {
    prefs.setString(
        "today", DateTime.timestamp().millisecondsSinceEpoch.toString());
  }
  final bool isLogged = prefs.getBool('login') ?? false;
  runApp(MyApp(islogged: isLogged));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, required this.islogged});
  final bool islogged;
  @override
  State<MyApp> createState() => _MyAppState();
}



class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    bool userIsLoggedIn=widget.islogged;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TemprorytaskProvider()),
        // Adjust the actual provider creation
        ChangeNotifierProvider(create: (_) => CompulsoryTaskProvider()),
        // Adjust the actual provider creation
      ],
      child: MaterialApp(
        title: "Task App",
        debugShowCheckedModeBanner: false,
        home: Builder(
          builder: (context) {
            // Use a post-frame callback to navigate after the widget tree is built
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  userIsLoggedIn
                      ? const TaskScreen()
                      : const LoginPage(),
                ),
              );
            });

            return Scaffold(
              body: Center(
                child: Column(
                  children: [
                    const SizedBox(
                      height: 200,
                    ),
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Image.asset("assets/icon.jpg"),
                    ),
                    const SizedBox(
                      height: 150,
                    ),
                    const Text("Task Manager", style: TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 30),),
                    // Add your provider-related widgets here
                    // For example:
                    // TaskListWidget(),
                    // CompulsoryTaskListWidget(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
