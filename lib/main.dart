import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wallet_connect/local_storage.dart';
import 'package:wallet_connect_plugin/wallet_connect_plugin.dart';
import 'package:web3dart/credentials.dart';
import 'package:web3dart/crypto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(title: 'Wallet Connect'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormState>();
  final _uriTextFieldController = TextEditingController();
  String address = '-';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text(widget.title)),
        body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 16),
              SizedBox(
                width: 300,
                child: TextFormField(
                  controller: _uriTextFieldController,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                      labelText: 'URI',
                      labelStyle: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w700),
                      hintText: 'Paste your URI here...',
                      hintStyle: TextStyle(fontSize: 11)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState?.validate() == true) {
                      await WalletConnectPlugin.connectWallet(
                          _uriTextFieldController.text);
                    }
                  },
                  child: const Text('Connect')),
              const SizedBox(height: 40),
              Text('Address: $address'),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () async => await createPrivateKey(),
                          child: const Text('Create PrivateKey')),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                          onPressed: () async {
                            final _address = await getAddress();
                            setState(() => address = _address);
                          },
                          child: const Text('Get Address')),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: IconButton(
                  iconSize: 50,
                  onPressed: () async =>
                      await WalletConnectPlugin.showBiometricDialog(),
                  icon: const Icon(
                    Icons.fingerprint_outlined,
                    color: Colors.blueAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> createPrivateKey() async {
    if ((await LocalStorage().getPrivateKey()).isEmpty) {
      final rng = Random.secure();
      final privateKey = EthPrivateKey.createRandom(rng);
      final key = bytesToHex(privateKey.privateKey);
      await LocalStorage().setPrivateKey(key);
      await Fluttertoast.showToast(
        msg: 'Private key created',
        toastLength: Toast.LENGTH_SHORT,
      );
    } else {
      await Fluttertoast.showToast(
        msg: 'Your private key already created',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  Future<String> getAddress() async {
    final priKeyFromStorage = await LocalStorage().getPrivateKey();
    if (priKeyFromStorage.isNotEmpty) {
      final val = hexToBytes(await LocalStorage().getPrivateKey());
      final publicKey = privateKeyBytesToPublic(val);
      final address = publicKeyToAddress(publicKey);
      return bytesToHex(address, include0x: true, forcePadLength: 40);
    } else {
      await Fluttertoast.showToast(
        msg: 'Please create private key first',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
    return '-';
  }
}
