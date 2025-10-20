import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vasa_mobile_tunda_flutter/app/data/models/spk_model.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  late FlutterSecureStorage _secureStorage;

  // Keys for SharedPreferences (non-sensitive data)
  static const String _keyUsername = 'username';
  static const String _keyHasLoggedIn = 'hasLoggedIn';
  static const String _keyProfileData = 'profileData';
  static const String _keyLastUpdate = 'lastUpdate';
  static const String _keyEngineStatus = 'engineStatus';
  static const String _keyNotifSpk = 'notifSpk';
  static const String _keyPanduid = 'panduid';
  static const String _keyNotifWorking = 'notifWorking';
  static const String _keyLastState = 'lastState';
  static const String _keyWorkerData = 'workerData';

  // Keys for SecureStorage (sensitive data)
  static const String _keyAuthToken = 'authToken';
  static const String _keyRefreshToken = 'refreshToken';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage();

    // Initialize with default values if needed
    await _initializeDefaults();
  }

  Future<void> _initializeDefaults() async {
    if (!await hasLoggedIn()) {
      await _prefs.setBool(_keyHasLoggedIn, false);
    }
  }

  // Authentication related methods
  Future<void> setLoggedIn(bool value) async {
    await _prefs.setBool(_keyHasLoggedIn, value);
  }

  Future<bool> hasLoggedIn() async {
    return _prefs.getBool(_keyHasLoggedIn) ?? false;
  }

  Future<void> setUsername(String username) async {
    await _prefs.setString(_keyUsername, username);
  }

  Future<String?> getUsername() async {
    return _prefs.getString(_keyUsername);
  }

  Future<void> setProfileData(Map<String, dynamic> profile) async {
    await _prefs.setString(_keyProfileData, json.encode(profile));
  }

  Future<Map<String, dynamic>?> getProfileData() async {
    final data = _prefs.getString(_keyProfileData);
    return data != null ? json.decode(data) : null;
  }

  // Engine status methods
  Future<void> setEngineStatus(String status) async {
    await _prefs.setString(_keyEngineStatus, status);
  }

  Future<String?> getEngineStatus() async {
    return _prefs.getString(_keyEngineStatus);
  }

  Future<void> setLastUpdate(String update) async {
    await _prefs.setString(_keyLastUpdate, update);
  }

  Future<String?> getLastUpdate() async {
    return _prefs.getString(_keyLastUpdate);
  }

  // Notification methods
  Future<void> setNotifSpk(bool value) async {
    await _prefs.setBool(_keyNotifSpk, value);
  }

  Future<bool> getNotifSpk() async {
    return _prefs.getBool(_keyNotifSpk) ?? false;
  }

  Future<void> setPanduid(String? panduid) async {
    if (panduid == null) {
      await _prefs.remove(_keyPanduid);
    } else {
      await _prefs.setString(_keyPanduid, panduid);
    }
  }

  Future<String?> getPanduid() async {
    return _prefs.getString(_keyPanduid);
  }

  Future<void> setNotifWorking(String value) async {
    await _prefs.setString(_keyNotifWorking, value);
  }

  Future<String?> getNotifWorking() async {
    return _prefs.getString(_keyNotifWorking);
  }

  // Pemanduan workflow methods
  Future<void> setLastState(String state) async {
    await _prefs.setString(_keyLastState, state);
  }

  Future<String?> getLastState() async {
    return _prefs.getString(_keyLastState);
  }

  Future<void> setWorkerData(Map<String, dynamic> data) async {
    await _prefs.setString(_keyWorkerData, json.encode(data));
  }

  Future<Map<String, dynamic>?> getWorkerData() async {
    final data = _prefs.getString(_keyWorkerData);
    return data != null ? json.decode(data) : null;
  }

  // Secure storage methods (for sensitive data)
  Future<void> setAuthToken(String token) async {
    await _secureStorage.write(key: _keyAuthToken, value: token);
  }

  Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _keyAuthToken);
  }

  Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  // Clear all data (logout)
  Future<void> clearAllData() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
    await _initializeDefaults();
  }

  // Clear only authentication data
  Future<void> clearAuthData() async {
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyHasLoggedIn);
    await _prefs.remove(_keyProfileData);
    await _secureStorage.delete(key: _keyAuthToken);
    await _secureStorage.delete(key: _keyRefreshToken);
  }

  // Clear pemanduan data
  Future<void> clearPemanduanData() async {
    await _prefs.remove(_keyPanduid);
    await _prefs.remove(_keyLastState);
    await _prefs.remove(_keyWorkerData);
    await _prefs.remove(_keyNotifWorking);
  }

  // Save SPK data for offline access
  Future<void> saveSpkList(List<SpkModel> spkList) async {
    final data = spkList.map((spk) => spk.toJson()).toList();
    await _prefs.setString('spkList', json.encode(data));
  }

  Future<List<SpkModel>> getSpkList() async {
    final data = _prefs.getString('spkList');
    if (data != null) {
      final List<dynamic> decoded = json.decode(data);
      return decoded.map((item) => SpkModel.fromJson(item)).toList();
    }
    return [];
  }

  // Generic methods for storing any data
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<bool> containsKey(String key) async {
    return _prefs.containsKey(key);
  }
}
