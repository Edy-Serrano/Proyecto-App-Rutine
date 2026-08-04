import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rutine/models/task_model.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:path_provider/path_provider.dart';

class HiveService {
  static const String _tasksBoxName = 'tasksBox';
  static const String _prefsBoxName = 'prefsBox';
  static const String _keyName = 'hive_encryption_key';
  
  static late Uint8List _encryptionKey;

  static Future<void> init() async {
    await Hive.initFlutter();

    const secureStorage = FlutterSecureStorage();
    String? encryptionKeyString = await secureStorage.read(key: _keyName);

    if (encryptionKeyString == null) {
      final key = Hive.generateSecureKey();
      await secureStorage.write(
        key: _keyName,
        value: base64UrlEncode(key),
      );
      encryptionKeyString = base64UrlEncode(key);
    }
    
    _encryptionKey = base64Url.decode(encryptionKeyString);

    // MIGRATION: tasksBox
    try {
      await Hive.openBox(_tasksBoxName, encryptionCipher: HiveAesCipher(_encryptionKey));
    } catch (e) {
      print("Migrating $_tasksBoxName to encrypted...");
      final unencryptedBox = await Hive.openBox(_tasksBoxName);
      final mapData = Map<dynamic, dynamic>.from(unencryptedBox.toMap());
      await unencryptedBox.close();
      await Hive.deleteBoxFromDisk(_tasksBoxName);
      
      final newBox = await Hive.openBox(_tasksBoxName, encryptionCipher: HiveAesCipher(_encryptionKey));
      await newBox.putAll(mapData);
    }

    // MIGRATION: prefsBox
    try {
      await Hive.openBox(_prefsBoxName, encryptionCipher: HiveAesCipher(_encryptionKey));
    } catch (e) {
      print("Migrating $_prefsBoxName to encrypted...");
      final unencryptedBox = await Hive.openBox(_prefsBoxName);
      final mapData = Map<dynamic, dynamic>.from(unencryptedBox.toMap());
      await unencryptedBox.close();
      await Hive.deleteBoxFromDisk(_prefsBoxName);
      
      final newBox = await Hive.openBox(_prefsBoxName, encryptionCipher: HiveAesCipher(_encryptionKey));
      await newBox.putAll(mapData);
    }
  }

  static Box get _box => Hive.box(_tasksBoxName);
  static Box get _prefsBox => Hive.box(_prefsBoxName);

  static List<Task> getTasks() {
    final List<Task> tasks = [];
    for (var i = 0; i < _box.length; i++) {
      final map = _box.getAt(i) as Map<dynamic, dynamic>?;
      if (map != null) {
        try {
          tasks.add(Task.fromMap(map));
        } catch (e) {
          print("Error parsing task: $e");
        }
      }
    }
    return tasks;
  }

  static Future<void> saveTasks(List<Task> tasks) async {
    await _box.clear();
    await _box.addAll(tasks.map((t) => t.toMap()).toList());
  }

  static Future<void> addTask(Task task) async {
    await _box.add(task.toMap());
  }

  static Future<void> updateTask(Task task) async {
    final index = getTasks().indexWhere((t) => t.id == task.id);
    if (index != -1) {
      await _box.putAt(index, task.toMap());
    }
  }

  static Future<void> deleteTask(String taskId) async {
    final index = getTasks().indexWhere((t) => t.id == taskId);
    if (index != -1) {
      await _box.deleteAt(index);
    }
  }

  // ─── PREFERENCIAS ─────────────────────────────────────────────────────────

  static String getUserName() {
    return _prefsBox.get('userName', defaultValue: 'Usuario');
  }

  static Future<void> setUserName(String name) async {
    await _prefsBox.put('userName', name);
  }

  static String? getUserImagePath() {
    return _prefsBox.get('userImagePath');
  }

  static Future<void> setUserImagePath(String path) async {
    await _prefsBox.put('userImagePath', path);
  }

  static bool getIsDarkMode() {
    return _prefsBox.get('isDarkMode', defaultValue: true);
  }

  static Future<void> setIsDarkMode(bool isDark) async {
    await _prefsBox.put('isDarkMode', isDark);
  }

  static bool getNotificationsEnabled() {
    return _prefsBox.get('notificationsEnabled', defaultValue: false);
  }

  static Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefsBox.put('notificationsEnabled', enabled);
  }

  static bool getHasCheckedQuoteToday(String dateStr) {
    return _prefsBox.get('checkedQuote_$dateStr', defaultValue: false);
  }

  static Future<void> setHasCheckedQuoteToday(String dateStr, bool checked) async {
    await _prefsBox.put('checkedQuote_$dateStr', checked);
  }

  // ─── BACKUP Y SEGURIDAD ───────────────────────────────────────────────────

  static Future<File> exportSecureBackup() async {
    final tasks = getTasks().map((t) => t.toMap()).toList();
    final jsonStr = jsonEncode(tasks);
    
    final key = enc.Key(_encryptionKey);
    final iv = enc.IV.fromSecureRandom(16);
    
    final encrypter = enc.Encrypter(enc.AES(key));
    final encrypted = encrypter.encrypt(jsonStr, iv: iv);
    
    // Formato: iv_base64:encrypted_base64
    final backupData = "${iv.base64}:${encrypted.base64}";
    
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/rutine_backup.enc');
    await file.writeAsString(backupData);
    
    return file;
  }

  static Future<void> importSecureBackup(File file) async {
    final backupData = await file.readAsString();
    final parts = backupData.split(':');
    if (parts.length != 2) throw Exception("Formato de backup inválido");
    
    final iv = enc.IV.fromBase64(parts[0]);
    final encryptedData = enc.Encrypted.fromBase64(parts[1]);
    final key = enc.Key(_encryptionKey);
    
    final encrypter = enc.Encrypter(enc.AES(key));
    final decryptedStr = encrypter.decrypt(encryptedData, iv: iv);
    
    final List<dynamic> jsonList = jsonDecode(decryptedStr);
    final tasks = jsonList.map((map) => Task.fromMap(map as Map<dynamic, dynamic>)).toList();
    
    await saveTasks(tasks);
  }
}
