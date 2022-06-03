import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _key = "private_key";

class LocalStorage {
  static final LocalStorage _localStorage = LocalStorage._internal();

  factory LocalStorage() => _localStorage;

  LocalStorage._internal();

  final _storage = const FlutterSecureStorage();

  Future<void> setPrivateKey(String privateKey) async =>
      await _storage.write(key: _key, value: privateKey);

  Future<String> getPrivateKey() async => await _storage.read(key: _key) ?? "";
}
