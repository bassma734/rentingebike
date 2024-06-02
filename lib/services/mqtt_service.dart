import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  MqttServerClient client =

<<<<<<< HEAD
      MqttServerClient.withPort('192.168.0.7', 'mobile_App', 1883);
=======
  MqttServerClient.withPort('192.168.1.53', 'mobile_App', 1883);
>>>>>>> 06231fae07383023c12d1fc3ecf70141f152782a


  Future<int> connect() async {
    client.logging(on: true);
    client.keepAlivePeriod = 60;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.pongCallback = pong;

    final connMessage =
    MqttConnectMessage().startClean().withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      if (kDebugMode) {
        print('MQTTClient::Client exception - $e');
      }
      client.disconnect();
    } on SocketException catch (e) {
      if (kDebugMode) {
        print('MQTTClient::Socket exception - $e');
      }
      client.disconnect();
    }

    return 0;
  }

  void disconnect(){
    client.disconnect();
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atMostOnce);
  }

  void onConnected() {
    if (kDebugMode) {
      print('MQTTClient::Connected');
    }
  }

  void onDisconnected() {
    if (kDebugMode) {
      print('MQTTClient::Disconnected');
    }
  }

  void onSubscribed(String topic) {
    if (kDebugMode) {
      print('MQTTClient::Subscribed to topic: $topic');
    }
  }

  void pong() {
    if (kDebugMode) {
      print('MQTTClient::Ping response received');
    }
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.exactlyOnce, builder.payload!);
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? getMessagesStream() {
    return client.updates;
  }
}