import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo/home_screen.dart';

import 'auth_form.dart';

class AuthScreen extends StatefulWidget {
  static const routeName = 'authscreen';

  const AuthScreen({Key? key}) : super(key: key);
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = FirebaseAuth.instance;
  bool isLoading = false;

  void _submitAuthForm(
      String email,
      String password,
      bool isLogin,
      BuildContext ctx) async {
    setState(() {
      isLoading = true;
    });
    try {
      if (isLogin) {
        await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
        
        setState(() {
          isLoading = false;
        });
      } else {
        UserCredential userCredential = await _auth
            .createUserWithEmailAndPassword(email: email, password: password);
        FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'UserId': userCredential.user!.uid,
          'UserEmail': email,
        });
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false);
        setState(() {
          isLoading = false;
        });
      }
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(e.code),
        backgroundColor: Colors.orange,
      ));
      return;
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
        content: Text(e.code),
        backgroundColor: Theme.of(ctx).errorColor,
      ));
      return;
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(
                    'images/background.jpg',
                  ),
                  fit: BoxFit.cover)),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator()
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AuthForm(_submitAuthForm),
                ),
        ),
      ),
    );
  }
}
