abstract class ILocalPreferences {
  Future<void> storeData(String key, dynamic value);
  Future<T?> retrieveData<T>(String key);
  Future<void> removeData(String key);
  Future<void> clearAll();
}
