import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:outtaskapp/LoginPage.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}


class _SignUpPageState extends State<SignUpPage> {
  // Text field controllers for email and password
  static final _emailController = TextEditingController();
  static final _passwordController = TextEditingController();
  final db= FirebaseFirestore.instance;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up',style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 25),),
        centerTitle: true,
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 100,
              ),
              const Text(
                "It takes minutes to plan but \n courage to follow it!",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.lightGreen),textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 80,
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
                    final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                      email: _emailController.text,
                      password: _passwordController.text,
                    );
                    Navigator.pushReplacement(
                      context, // BuildContext from the widget
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                    );
                  setState(() {
                  _isLoading = false;
                  _passwordController.text = "";
                  });
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'weak-password') {
                      final snackbar = SnackBar(content: Text("weak password"));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    } else if (e.code == 'email-already-in-use') {
                      final snackbar = SnackBar(content: Text("email already in use"));
                      ScaffoldMessenger.of(context).showSnackBar(snackbar);
                    }
                  } catch (e) {
                    setState(() {
                      _isLoading = false;
                    });
                    final snackbar = SnackBar(content: Text(e.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(snackbar);
                  }
                },
                child: _isLoading ? CircularProgressIndicator() : const Text('Sign Up', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),),
              ),
              const SizedBox(height: 10.0),
              // Sign Up text

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context, // BuildContext from the widget
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account?  ', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
                    const Text('Login', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),),
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
