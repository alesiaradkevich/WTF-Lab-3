abstract class SettingsProviderApi {
  Future<void> setTheme(bool isDark);

  Future<void> setIsLocked(bool value);

  Future<void> setFontSize(int value);

  Future<void> setBubbleAlignment(bool value);

  Future<void> setCenterDate(bool value);

  Future<void> setBackgroundImage(String path);

  void setDefault();

  Future<bool> get theme;

  Future<bool> get isLocked;

  Future<int> get fontSize;

  Future<bool> get bubbleAlignment;

  Future<bool> get centerDate;

  Future<String> get backgroundImage;
}
