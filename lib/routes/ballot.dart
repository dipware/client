import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:web3dart/web3dart.dart';
import '../utils/eth_utils.dart';

class BallotPage extends StatefulWidget {
  const BallotPage({Key? key, required this.credentials}) : super(key: key);
  final Credentials credentials;

  @override
  State<BallotPage> createState() => _BallotPageState();
}

class _BallotPageState extends State<BallotPage> {
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  var myResults;
  final myAddress = '0x79336570b5E3fae0Db6198EDbD8128895B798182';
  EthereumAddress? _address;
  // late Credentials credentials = EthPrivateKey.fromHex(
  //     "31dff975ff91483e5fa4c12264418599e4db311519d9d4722a97158f4fa0fcc4");

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/4219bd2c584d4e788aefb96b72a3f5c9",
        httpClient);
    ethClient.addedBlocks().listen((hash) {
      print("    New Block: $hash");
      getResults(myAddress);
      setState(() {});
    });
    getResults(myAddress).then((value) {
      setState(() {});
    });
    widget.credentials.extractAddress().then((address) {
      _address = address;
    });
  }

  Future<void> getResults(String targetAddress) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await utils.query("getResults", []);
    myResults = result[0];
    data = true;
    // setState(() {});
  }

  Future<void> sendBallot(
      String targetAddress, Credentials credentials, BigInt ballot) async {
    // EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    await utils.submit("sendBallot", credentials, [ballot]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          data
              ? Text('$myResults')
              : const Center(
                  child: CircularProgressIndicator(),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {
                  sendBallot(
                    myAddress,
                    widget.credentials,
                    BigInt.from(1),
                  );
                },
                child: const Text("Yes"),
              ),
              TextButton(
                onPressed: () {
                  sendBallot(
                    myAddress,
                    widget.credentials,
                    BigInt.from(0),
                  );
                },
                child: const Text("No"),
              ),
            ],
          ),
          TextButton(
            onPressed: () {
              if (_address != null) {
                showDialog(
                  context: context,
                  builder: (_) {
                    const size = 280.0;
                    return Dialog(
                      child: CustomPaint(
                        size: const Size.square(size),
                        painter: QrPainter(
                          data: _address!.hex,
                          version: QrVersions.auto,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: Colors.black,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
            },
            child: const Text("Show QR"),
          ),
        ],
      ),
    );
  }
}
