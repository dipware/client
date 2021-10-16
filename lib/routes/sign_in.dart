import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({Key? key}) : super(key: key);

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  Credentials? credentials;

  // Future<Credentials> addVoter(String sessionID) async {
  //   CollectionReference sessionDB =
  //       FirebaseFirestore.instance.collection(sessionID);
  //   String UID = FirebaseAuth.instance.currentUser!.uid;
  //   final credentials = generateWallet();
  //   final address = await credentials.extractAddress();
  //   await sessionDB
  //       .add({
  //         UID: address.hex // 42
  //       })
  //       .then((value) => print("Voter Added"))
  //       .catchError((error) => print("Failed to add user: $error"));
  //   return credentials;
  // }

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
    // String _sessionID = "";

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Row(
          //   children: [
          //     const Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 10),
          //     ),
          //     Expanded(
          //       child: TextField(
          //         decoration: const InputDecoration(
          //           border: OutlineInputBorder(),
          //           hintText: "Input Session Name",
          //         ),
          //         onChanged: (value) {
          //           _sessionID = value;
          //         },
          //       ),
          //     ),
          //     const Padding(
          //       padding: EdgeInsets.symmetric(horizontal: 10),
          //     ),
          //   ],
          // ),
          TextButton(
            onPressed: () async {
              credentials ??= generateWallet();
              final address = await credentials!.extractAddress();
              showDialog(
                context: context,
                builder: (_) {
                  const size = 280.0;
                  return Dialog(
                    child: CustomPaint(
                      size: const Size.square(size),
                      painter: QrPainter(
                        data: address.hex,
                        version: QrVersions.auto,
                        eyeStyle: const QrEyeStyle(
                          eyeShape: QrEyeShape.square,
                          color: Color(0xff128760),
                        ),
                        dataModuleStyle: const QrDataModuleStyle(
                          dataModuleShape: QrDataModuleShape.circle,
                          color: Color(0xff1a5441),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
            child: const Text("Sign Up!"),
          ),
        ],
      ),
    );
  }
}
