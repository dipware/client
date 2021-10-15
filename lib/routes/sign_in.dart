import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:web3dart/web3dart.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Future<void> addVoter(String sessionID) async {
    CollectionReference sessionDB =
        FirebaseFirestore.instance.collection(sessionID);
    String UID = FirebaseAuth.instance.currentUser!.uid;
    final address = await generateWallet().extractAddress();
    return sessionDB
        .add({
          UID: address.hex // 42
        })
        .then((value) => print("Voter Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  Credentials generateWallet() {
    final rng = Random.secure();
    Credentials random = EthPrivateKey.createRandom(rng);
    random.extractAddress().then((value) {
      print("New address:");
      print(value.hex);
    });
    return random;
  }

  @override
  Widget build(BuildContext context) {
    String _sessionID = "";

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            onChanged: (value) {
              _sessionID = value;
            },
          ),
          TextButton(
            onPressed: () {
              addVoter(_sessionID);
              print(_sessionID);
              setState(() {});
            },
            child: const Text("Sign Up!"),
          ),
        ],
      ),
    );
  }
}
