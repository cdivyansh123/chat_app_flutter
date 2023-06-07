import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/widgets/user_image_picker.dart';

final _fireBase = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AuthScreenState();
  }
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isLogin = true;
  var enteredEmail = '';
  var enteredPassword = '';
  var _isAuthenticating=false;
  File? _selectedImage;

  void _submit() async {
    final isValid = _form.currentState!.validate();

    if (!isValid || !_isLogin && _selectedImage==null) {
      return;
    }



    _form.currentState!.save();
    try {
      setState(() {
        _isAuthenticating=true;
      });
      if (_isLogin) {
        final userCredentials = await _fireBase.signInWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

      } else {
        final userCredentials = await _fireBase.createUserWithEmailAndPassword(
            email: enteredEmail, password: enteredPassword);

        final storageRef=FirebaseStorage.instance.ref().child('user_images').child('${userCredentials.user!.uid}.jpg');
        await storageRef.putFile(_selectedImage!);
        final imageUrl=await storageRef.getDownloadURL();
        print(imageUrl);
      }
    } on FirebaseAuthException catch (error) {
      // if(error.code=="email-already-in-use"){
      //
      // }
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? "Authentication Failed.")));
      setState(() {
        _isAuthenticating=false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin:
                    EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
              Card(
                margin: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16),
                  child: Form(
                    key: _form,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if(!_isLogin)
                          UserImagePicker(onPickImage: (pickedImage){
                            _selectedImage=pickedImage;
                          },),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Email Address",
                          ),
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                !value.contains('@')) {
                              return "Please enter valid email address";
                            }
                            return null;
                          },
                          onSaved: (value) {
                            enteredEmail = value!;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Password",
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().length < 6) {
                              return "Passworb must be atleast 6 characters long";
                            }
                          },
                          onSaved: (value) {
                            enteredPassword = value!;
                          },
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        if(_isAuthenticating)
                          CircularProgressIndicator(),
                        if(!_isAuthenticating)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer),
                            child: Text(_isLogin ? "Login" : "Sign Up")),
                        if(!_isAuthenticating)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? "Create an account"
                                : "already have an account. Login")),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
