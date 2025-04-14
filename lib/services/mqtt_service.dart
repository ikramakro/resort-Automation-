import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mqtt_client/mqtt_browser_client.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:resort_web_app/models/notification_model.dart';
import 'package:resort_web_app/repositories/notifications_reopsitory.dart';
import 'package:resort_web_app/services/connection_service.dart';
import 'package:uuid/uuid.dart';

class MqttService {
  //............INSTANCE
  static MqttService? _instance;

  //...............MQTT CLIENT
  final MqttBrowserClient client;

  //.........SERVICES
  final InternetConnectionService _connectionService =
      InternetConnectionService();

  //.............VARIABLES
  bool isConnected = false;
  int _retryCount = 0;
  bool _reconnecting = false;
  //..........CONSTANTS
  static const _maxRetries = 5;
  static const _retryDelay = Duration(seconds: 1);

  MqttService._()
      : client = MqttBrowserClient(
          'wss://test.mosquitto.org',
          'flutter_web_client',
        ) {
    client.logging(on: true);

    /// Set the correct MQTT protocol for mosquito
    client.setProtocolV311();

    /// The connection timeout period can be set if needed, the default is 5 seconds.
    client.connectTimeoutPeriod = 2000; // milliseconds

    /// The ws port for Mosquitto is 8080, for wss it is 8081
    client.port = 8081;

    /// Add the unsolicited disconnection callback
    client.onDisconnected = _onDisconnected;

    /// Add the successful connection callback
    client.onConnected = _onConnected;

    // client.onSubscribed = _onSubscribed;

    client.websocketProtocols = MqttClientConstants.protocolsSingleDefault;

    client.keepAlivePeriod = 30;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('flutter_web_client')
        .withWillTopic(
            'willtopic') // If you set this you must set a will message
        .withWillMessage('My Will message')
        .startClean() // Non persistent session for testing
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;
    // connect();
  }

  factory MqttService() => _instance ??= MqttService._();

  Future<void> _onConnected() async {
    log('Connected to MQTT broker in OnConnected functions');
    isConnected = true;
    _retryCount = 0;
    const serviceTopic = 'roomNo/+/service/request';
    subscribeToTopic(serviceTopic);
  }

  // void _onSubscribed(String topic) {
  //   if (!isConnected) {
  //     log('Unable to subscribe. Client not connected.');
  //     return;
  //   }

  //   log('Subscribed to topic: $topic');
  //   client.subscribe(topic, MqttQos.exactlyOnce);

  //   client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
  //     if (c == null || c.isEmpty) return;

  //     final receivedTopic =
  //         c[0].topic; // Extract the topic from the received message
  //     final roomNumber =
  //         receivedTopic.split('/')[1]; // Extract the room number from the topic
  //     log("Data receiving topic  $receivedTopic");
  //     try {
  //       final recMessage = c[0].payload as MqttPublishMessage;
  //       final service = MqttPublishPayload.bytesToStringAsString(
  //           recMessage.payload.message);
  //       //...........................ADD THE NOTIFICATION...................................
  //       final notification = NotificationModel(
  //         notificationId: 'Room No. $roomNumber',
  //         roomNumber: roomNumber,
  //         serviceType: service,
  //       );

  //       log('Received servcie on topic $receivedTopic: $service');
  //       await NotificationsRepository().addNotification(notification);
  //     } catch (e) {
  //       log('Error processing received message: $e');
  //     }
  //   });
  // }

  unsubscribeTopic(String topic) {
    if (!isConnected) {
      return;
    }
    log('Unsubscribed from topic: $topic');
    client.unsubscribe(topic);
  }

  Future<void> _onDisconnected() async {
    log('Disconnected from MQTT broker in OnDisconnected functions');
    isConnected = false;
    if (client.connectionStatus?.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      log('Disconnection was requested by the client.');
    }

    //..........CHECKING INTERNET CONNECTION BEFORE RECONNECTING
    bool isConnectedToInternet =
        await _connectionService.hasInternetConnection();
    if (isConnectedToInternet) {
      monitorInternetConnectionAndReconnect();
    }
  }

  //................COONECTION IS SUCCESSFULL NOW JUST TEST IT
  connect() async {
    if (isConnected) {
      log('Already connected to MQTT broker');
      return;
    }

    // ..........CHECKING INTERNET CONNECTION BEFORE RECONNECTING
    bool isConnectedToInternet =
        await _connectionService.hasInternetConnection();
    if (!isConnectedToInternet) return;

    //............CONNECT TO MQTT BROKER
    try {
      log('Attempting to connect to MQTT broker...');
      final connectionFuture = client.connect();
      await connectionFuture.timeout(const Duration(seconds: 10),
          onTimeout: () {
        throw TimeoutException('Connection timed out.');
      });
    } catch (e) {
      log('Error connecting to MQTT broker: $e');
      client.disconnect();
      _scheduleReconnect();
    }
  }

  void monitorInternetConnectionAndReconnect() {
    log("Monitor Internet Connection and Reconnect Function triggered");
    Connectivity().onConnectivityChanged.listen((result) {
      if (!(result.contains(ConnectivityResult.none)) && !isConnected) {
        log('Internet connection restored. Attempting to reconnect...');
        connect();
      } else if (result.contains(ConnectivityResult.none)) {
        log('No internet connection');
      } else {
        log('Else condition');
        log(result.toString());
      }
    });
  }

  _scheduleReconnect() {
    if (_reconnecting || _retryCount >= _maxRetries) return;

    _reconnecting = true;

    _retryCount++;
    Future.delayed(_retryDelay, () async {
      _reconnecting = false;
      await connect();
    });
  }

  void subscribeToTopic(String topic) {
    if (!isConnected) {
      log('Unable to subscribe. Client not connected.');
      return;
    }

    log('Subscribing to topic: $topic');
    client.subscribe(topic, MqttQos.exactlyOnce);

    // Add a filtering mechanism for the topic
    client.updates?.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      if (c == null || c.isEmpty) return;
      try {
        final receivedTopic =
            c[0].topic; // Extract the topic from the received message
        final roomNumber = receivedTopic
            .split('/')[1]; // EXTRACT THE ROOM NUMBER FROM THE TOPIC
        log("Data receiving topic  $receivedTopic");
        final recMessage = c[0].payload as MqttPublishMessage;
        final service = MqttPublishPayload.bytesToStringAsString(
            recMessage.payload.message);
        log('Received message on topic $receivedTopic: $service');

        //...........................ADD THE NOTIFICATION...................................//
        final notificationId = Uuid().v4();
        final notification = NotificationModel(
          notificationId: notificationId,
          roomNumber: roomNumber,
          serviceType: service,
        );

        log('Received servcie on topic $receivedTopic: $service');
        await NotificationsRepository().addNotification(notification);
      } catch (e) {
        log('Error processing received message: $e');
      }
    });
  }

  publishMessage({
    required String topic,
    required String message,
  }) {
    if (!isConnected) {
      log('MQTT is not connected. Cannot publish.');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
    log('Message published to $topic: $message');
  }

  void publishDeviceUpdate(
    String roomNumber,
    String deviceId,
    String status,
    String? attributeValue,
    MqttService mqttService,
  ) {
    final topic = 'roomNo/$roomNumber/device/$deviceId/status';
    final message = {
      'deviceId': deviceId,
      'status': status,
      'attribute': attributeValue ?? '',
    };
    final jsonMessage = jsonEncode(message);
    publishMessage(topic: topic, message: jsonMessage);
    log('Published device update: $message');
  }
}

// void _loadCertificates() {
//   Future.wait([
//     writeAssetToFile('assets/certificates/mosquitto.org.crt', 'ca.crt'),
//     writeAssetToFile('assets/certificates/client.crt', 'client.crt'),
//     writeAssetToFile('assets/certificates/client.key', 'client.key'),
//   ]).then((filePaths) {
//     client.securityContext = SecurityContext.defaultContext
//       ..setTrustedCertificates(filePaths[0]) // CA cert
//       ..useCertificateChain(filePaths[1]) // Client cert
//       ..usePrivateKey(filePaths[2]); // Private key
//   });
// }

// Future<String> _writeAssetToFile(String assetPath, String fileName) async {
//   final byteData = await rootBundle.load(assetPath);
//   final file = File('${(await getTemporaryDirectory()).path}/$fileName');
//   await file.writeAsBytes(byteData.buffer.asUint8List());
//   return file.path;
// }
