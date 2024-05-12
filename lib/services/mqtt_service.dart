import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  //late MqttServerClient client;
  final client = MqttServerClient('192.168.0.6', 'FlutterApp'); 

  Future<void> connect(String brokerAddress) async {
    //client = MqttServerClient(brokerAddress, 'Flutter_App');
    client.logging(on: true);
    client.autoReconnect = true;
    client.onAutoReconnect = onAutoReconnect;
    client.onAutoReconnected = onAutoReconnected;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    client.pongCallback = pong;
    try {
      await client.connect();
    } catch (e) {
      debugPrint('Exception: $e' );
      disconnect();
    }
  }

  void disconnect() {
    client.disconnect();
  }

  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void unsubscribe(String topic) {
    client.unsubscribe(topic);
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void onAutoReconnect() {
    log('Client auto reconnection sequence will start' as num);
  }

  void onAutoReconnected() {
    debugPrint('Client auto reconnection sequence has completed');
  }

  void onConnected() {
    debugPrint('Connected');
  }

  void onDisconnected() {
    debugPrint('Disconnected');
  }

  void onSubscribed(String topic) {
    debugPrint('Subscribed topic: $topic');
  }

  void onSubscribeFail(String topic) {
    debugPrint('Failed to subscribe $topic');
  }

  void pong() {
    debugPrint('Ping response client callback invoked');
  }
}
