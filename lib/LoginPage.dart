import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outtaskapp/SignUPpage.dart';
import 'package:outtaskapp/temprorytaskscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}


class _LoginPageState extends State<LoginPage> {
  // Text field controllers for email and password
  static final _emailController = TextEditingController();
  static final _passwordController = TextEditingController();
  final db= FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 150,
              ),

              const Text(
                "Welcome!",
                style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: Colors.red),
              ),
              const SizedBox(
                height: 50,
              ),
              TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "Email Address",
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.blue,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  )),
              const SizedBox(height: 20.0),
              // Password text field with hint text
              TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.redAccent,
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.lightBlue),
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                  )),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ButtonStyle(
                    minimumSize: const MaterialStatePropertyAll(Size(300,45)),
                    backgroundColor: MaterialStateProperty.all(Colors.lightBlueAccent)
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  try {
                    final prefs = await SharedPreferences.getInstance();
                    final credential = await FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                        email: _emailController.text,
                        password: _passwordController.text)
                        .then((value) async {

                      prefs.setString("email",_emailController.text);
                      prefs.setBool('login', true);
                      Navigator.pushReplacement(
                        context, // BuildContext from the widget
                        MaterialPageRoute(
                            builder: (context) => const TaskScreen()),
                      ); });
                    setState(() {
                      _isLoading = false;
                      _passwordController.text = "";
                    });
                  } on FirebaseAuthException catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    final snackbar = SnackBar(content: Text(e.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  }
                },
                child: _isLoading ? CircularProgressIndicator() : const Text('Login', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),),
              ),
              const SizedBox(height: 10.0),
              // Sign Up text

              TextButton(
                onPressed: () {

                  Navigator.pushReplacement(
                    context, // BuildContext from the widget
                    MaterialPageRoute(builder: (context) => const SignUpPage()),
                  );
                  print('Navigate to Sign Up');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Create an Account?   ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    const Text('Sign Up', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),

                  ],
                ),
              ),
              const SizedBox(
                height: 150,
              )
            ],
          ),
        ),
      ),
    );
  }
}
