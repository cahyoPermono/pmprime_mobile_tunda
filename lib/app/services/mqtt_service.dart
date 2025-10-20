import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart' as mqtt;
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:vasa_mobile_tunda_flutter/app/controllers/engine_controller.dart';

enum MqttConnectionState { disconnected, connecting, connected, error }

class MqttService extends GetxService {
  late MqttServerClient _client;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Connection state
  final Rx<MqttConnectionState> connectionState =
      MqttConnectionState.disconnected.obs;

  // Configuration
  static const String _host = 'notifvasa.pelindo.co.id';
  static const int _port = 8884;
  static const String _clientId = 'vasa_tunda_flutter';

  // Topics
  final List<String> _subscriptions = [];
  String? _username;

  // Notification settings
  bool _notificationsInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    if (_notificationsInitialized) return;

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _notificationsInitialized = true;
  }

  Future<void> _onNotificationTap(NotificationResponse response) async {
    // Handle notification tap - navigate to appropriate page
    final payload = response.payload;
    if (payload != null) {
      final data = json.decode(payload);

      if (data['type'] == 'spk') {
        // Navigate to SPK detail or list
        Get.toNamed('/spk-detail', arguments: data['spkId']);
      } else if (data['type'] == 'engine') {
        // Navigate to engine status
        Get.toNamed('/engine-status');
      }
    }
  }

  Future<bool> connect(String username) async {
    _username = username;

    try {
      connectionState.value = MqttConnectionState.connecting;

      _client = MqttServerClient.withPort(_host, _clientId, _port);

      // MQTT connection settings
      _client.logging(on: true);
      _client.keepAlivePeriod = 60;
      _client.autoReconnect = true;

      // Connection message
      final connMessage =
          mqtt.MqttConnectMessage()
              .withClientIdentifier(_clientId)
              .startClean();

      _client.connectionMessage = connMessage;

      // Setup callbacks
      _setupCallbacks();

      // Attempt connection
      final result = await _client.connect();

      if (result?.state != null &&
          result!.state == mqtt.MqttConnectionState.connected) {
        connectionState.value = MqttConnectionState.connected;
        _subscribeToTopics();
        return true;
      } else {
        connectionState.value = MqttConnectionState.error;
        debugPrint('MQTT Connection failed: ${result?.state}');
        return false;
      }
    } catch (e) {
      connectionState.value = MqttConnectionState.error;
      debugPrint('MQTT Connection error: $e');
      return false;
    }
  }

  void _setupCallbacks() {
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onUnsubscribed = _onUnsubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.pongCallback = _pongCallback;

    _client.updates?.listen((
      List<mqtt.MqttReceivedMessage<mqtt.MqttMessage>> messages,
    ) {
      for (final message in messages) {
        final topic = message.topic;
        final payload = message.payload as mqtt.MqttPublishMessage;
        final messageData = utf8.decode(payload.payload.message);

        _handleMessage(topic, messageData);
      }
    });
  }

  void _onConnected() {
    debugPrint('MQTT Connected');
    connectionState.value = MqttConnectionState.connected;
  }

  void _onDisconnected() {
    debugPrint('MQTT Disconnected');
    connectionState.value = MqttConnectionState.disconnected;

    // Auto-reconnect after delay
    Future.delayed(const Duration(seconds: 5), () {
      if (_username != null) {
        connect(_username!);
      }
    });
  }

  void _onSubscribed(String topic) {
    debugPrint('Subscribed to: $topic');
    _subscriptions.add(topic);
  }

  void _onUnsubscribed(String? topic) {
    if (topic != null) {
      _subscriptions.remove(topic);
      debugPrint('Unsubscribed from: $topic');
    }
  }

  void _onSubscribeFail(String topic) {
    debugPrint('Failed to subscribe to: $topic');
  }

  void _pongCallback() {
    debugPrint('MQTT Ping response received');
  }

  void _subscribeToTopics() {
    if (_username == null) return;

    final topics = [
      '/notif/tunda/spk/$_username',
      '/notif/tunda/ohn/$_username',
      '/tunda/off/$_username',
      '/tunda/on/$_username',
    ];

    for (final topic in topics) {
      _client.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    }
  }

  void _handleMessage(String topic, String message) {
    debugPrint('MQTT Message received - Topic: $topic, Message: $message');

    try {
      final data = json.decode(message);

      // Handle different message types
      if (topic.contains('/notif/tunda/spk/')) {
        _handleSpkNotification(data);
      } else if (topic.contains('/notif/tunda/ohn/')) {
        _handleOhnNotification(data);
      } else if (topic.contains('/tunda/off/')) {
        _handleEngineOffCommand(data);
      } else if (topic.contains('/tunda/on/')) {
        _handleEngineOnCommand(data);
      }
    } catch (e) {
      debugPrint('Error parsing MQTT message: $e');
    }
  }

  void _handleSpkNotification(dynamic data) {
    _showNotification(
      title: 'Pemberitahuan SPK Baru',
      body: 'Anda memiliki SPK baru untuk ditangani',
      payload: json.encode({'type': 'spk', 'spkId': data['id']}),
    );
  }

  void _handleOhnNotification(dynamic data) {
    _showNotification(
      title: 'Pemberitahuan OHN Baru',
      body: 'Anda memiliki OHN baru untuk ditangani',
      payload: json.encode({'type': 'ohn', 'ohnId': data['id']}),
    );
  }

  void _handleEngineOffCommand(dynamic data) {
    // Publish event for engine controller to handle
    Get.find<EngineController>().handleEngineOffCommand(data);
  }

  void _handleEngineOnCommand(dynamic data) {
    // Publish event for engine controller to handle
    Get.find<EngineController>().handleEngineOnCommand(data);
  }

  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'vasa_tunda_channel',
          'Vasa Tunda Notifications',
          channelDescription: 'Notifications for Vasa Tunda app',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  void disconnect() {
    _client.disconnect();
    connectionState.value = MqttConnectionState.disconnected;
  }

  bool get isConnected =>
      connectionState.value == MqttConnectionState.connected;

  void publishMessage(String topic, String message) {
    if (isConnected) {
      final builder = mqtt.MqttClientPayloadBuilder();
      builder.addString(message);
      _client.publishMessage(topic, mqtt.MqttQos.atLeastOnce, builder.payload!);
    }
  }

  void subscribeToProgressTopic(String nomorSpkPandu) {
    final topic = '/notif/progress/pandu/$nomorSpkPandu';
    if (!_subscriptions.contains(topic)) {
      _client.subscribe(topic, mqtt.MqttQos.atLeastOnce);
    }
  }

  void unsubscribeFromProgressTopic(String nomorSpkPandu) {
    final topic = '/notif/progress/pandu/$nomorSpkPandu';
    _client.unsubscribe(topic);
  }
}
