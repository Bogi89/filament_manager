import 'package:hive_flutter/hive_flutter.dart';

class HiveTestService {

  static const String boxName = 'test_box';

  static Future<void> saveTestValue(
    String value,
  ) async {

    final box =
        await Hive.openBox(boxName);

    await box.put(
      'test_key',
      value,
    );

  }

  static Future<String?> loadTestValue() async {

    final box =
        await Hive.openBox(boxName);

    return box.get('test_key');

  }

}