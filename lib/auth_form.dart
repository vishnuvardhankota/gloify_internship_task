import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthForm extends StatefulWidget {
  final void Function(
      String email,
      String password,
      bool isLogin,
      BuildContext ctx) submitFn;
  const AuthForm(this.submitFn, {Key? key}) : super(key: key);
  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  String email = '';
  String password = '';
  
  var isLogin = true;
  TextEditingController emailController = TextEditingController();

  void _submit() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();

      widget.submitFn(email, password,isLogin, context);
    }
  }

  final _formKey = GlobalKey<FormState>();
  bool isForgot = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isForgot
          ? Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(children: [
                    const Center(
                        child: Text(
                      'Reset Password',
                      style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    )),
                    const SizedBox(
                      height: 6,
                    ),
                    Column(children: [
                      TextFormField(
                        controller: emailController,
                        textInputAction: TextInputAction.next,
                        key: const ValueKey('email'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter Email';
                          }
                          if (!value.endsWith('@gmail.com')) {
                            return 'Please enter Email with @gmail.com';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(),
                            hintText: 'email address'),
                        onSaved: (value) {
                          email = value!.trim();
                        },
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 5,
                          primary: Colors.blue,
                        ),
                        child: const Text('Send Verification Email'),
                        onPressed: () async{
                          if (emailController.text.isEmpty) {
                            return;
                          }
                          await FirebaseAuth.instance
                              .sendPasswordResetEmail(
                                  email: emailController.text)
                              .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Verification Email Sent..'),
                              backgroundColor: Colors.orange,
                            ));
                            setState(() {
                              isForgot = false;
                            });
                          });
                        },
                      ),
                    ]),
                  ]),
                ),
              ),
            )
          : Card(
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(children: [
                    Center(
                        child: isLogin
                            ? const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red),
                              )
                            : const Text(
                                'Register',
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blueAccent),
                              )),
                    const SizedBox(
                      height: 6,
                    ),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.next,
                            key: const ValueKey('email'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter Email';
                              }
                              if (!value.endsWith('@gmail.com')) {
                                return 'Please enter Email with @gmail.com';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                                labelText: 'Email Address',
                                border: OutlineInputBorder(),
                                hintText: 'email address'),
                            onSaved: (value) {
                              email = value!.trim();
                            },
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.go,
                            key: const ValueKey('password'),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter Password';
                              }
                              if (value.length < 8) {
                                return 'Password length must be 8';
                              }
                              return null;
                            },
                            decoration: const InputDecoration(
                                labelText: 'Password',
                                border: OutlineInputBorder(),
                                hintText: 'password'),
                            keyboardType: TextInputType.text,
                            onSaved: (value) {
                              password = value!.trim();
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          if (isLogin)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  child: const Text(
                                    'Forgot Password?',
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isForgot = true;
                                    });
                                  },
                                ),
                              ],
                            ),
                          const SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 5,
                              primary: isLogin ? Colors.red : Colors.blue,
                            ),
                            onPressed: _submit,
                            child: Text(isLogin ? 'LogIn' : 'Create Account'),
                          ),
                          // ignore: deprecated_member_use
                          TextButton(
                            child: Text(
                              isLogin
                                  ? 'Create New Account'
                                  : 'Already hane an account? sign in',
                              style: TextStyle(
                                  color: isLogin ? Colors.red : Colors.blue),
                            ),
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                          )
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ),
    );
  }
}
