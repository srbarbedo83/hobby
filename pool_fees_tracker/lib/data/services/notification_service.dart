import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Fina camada sobre `flutter_local_notifications`. É chamada tanto do
/// isolate principal da app como do isolate em background do Workmanager
/// — por isso não guarda estado próprio além do plugin.
class NotificationService {
  static final NotificationService instance = NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
  }) async {
    await init();
    const androidDetails = AndroidNotificationDetails(
      'pool_fees_alerts',
      'Alertas de pools',
      channelDescription:
          'Alertas de fora do range, milestones de taxas, abrandamento e preço '
          'das tuas posições Uniswap',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    await _plugin.show(
      id,
      title,
      body,
      const NotificationDetails(android: androidDetails),
    );
  }
}
