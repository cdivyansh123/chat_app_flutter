import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class chatScreen extends StatelessWidget{
  chatScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fultter Chat"),
        actions: [
          IconButton(onPressed: (){
            FirebaseAuth.instance.signOut();
          }, icon: Icon(Icons.exit_to_app,color: Theme.of(context).colorScheme.primary),)
        ],
      ),
      body: Center(
        child: Text("LoggedIN"),
      ),
    );
  }

}