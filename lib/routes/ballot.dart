import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class BallotPage extends StatefulWidget {
  const BallotPage({Key? key}) : super(key: key);

  @override
  State<BallotPage> createState() => _BallotPageState();
}

class _BallotPageState extends State<BallotPage> {
  late Client httpClient;
  late Web3Client ethClient;
  bool data = false;
  var myResults;
  final myAddress = '0x79336570b5E3fae0Db6198EDbD8128895B798182';
  late Credentials credentials;

  @override
  void initState() {
    super.initState();
    httpClient = Client();
    ethClient = Web3Client(
        "https://rinkeby.infura.io/v3/4219bd2c584d4e788aefb96b72a3f5c9",
        httpClient);
    getResults(myAddress);
  }

  Future<DeployedContract> loadContract() async {
    String abi = await rootBundle.loadString("assets/abi.json");
    String contractAddress = "0x93790eCe73A285ddd1C271455aDa4e908A1B243B";

    final contract = DeployedContract(
      ContractAbi.fromJson(abi, "Democracy"),
      EthereumAddress.fromHex(contractAddress),
    );
    return contract;
  }

  Future<List<dynamic>> query(String functionName, List<dynamic> args) async {
    final contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = await ethClient.call(
        contract: contract, function: ethFunction, params: args);
    return result;
  }

  Future<void> getResults(String targetAddress) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    List<dynamic> result = await query("getResults", []);
    myResults = result[0];
    data = true;
    setState(() {});
  }

  Future<String> submit(String functionName, List<dynamic> args) async {
    EthPrivateKey credentials = EthPrivateKey.fromHex(
        "31dff975ff91483e5fa4c12264418599e4db311519d9d4722a97158f4fa0fcc4");
    DeployedContract contract = await loadContract();
    final ethFunction = contract.function(functionName);
    final result = ethClient.sendTransaction(
        credentials,
        Transaction.callContract(
            contract: contract, function: ethFunction, parameters: args),
        chainId: 4);
    return result;
  }

  Future<void> sendBallot(String targetAddress, BigInt ballot) async {
    EthereumAddress address = EthereumAddress.fromHex(targetAddress);
    await submit("sendBallot", [ballot]);
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
              : const Center(child: CircularProgressIndicator()),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                  onPressed: () {
                    sendBallot(myAddress, BigInt.from(1));
                  },
                  child: const Text("Yes")),
              TextButton(
                  onPressed: () {
                    sendBallot(myAddress, BigInt.from(0));
                  },
                  child: const Text("No")),
              TextButton(
                  onPressed: () {
                    getResults(myAddress);
                  },
                  child: const Text("Refresh")),
            ],
          ),
        ],
      ),
    );
  }
}
