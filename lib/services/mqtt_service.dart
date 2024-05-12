import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  late MqttServerClient _client;

  Future<void> connect(String brokerAddress) async {
    _client = MqttServerClient(brokerAddress, '');
    _client.logging(on: true);
    _client.autoReconnect = true;
    _client.onAutoReconnect = onAutoReconnect;
    _client.onAutoReconnected = onAutoReconnected;
    _client.onConnected = onConnected;
    _client.onDisconnected = onDisconnected;
    _client.onSubscribed = onSubscribed;
    _client.onSubscribeFail = onSubscribeFail;
    _client.pongCallback = pong;

    try {
      await _client.connect();
    } catch (e) {
      debugPrint('Exception: $e' );
      disconnect();
    }
  }

  void disconnect() {
    _client.disconnect();
  }

  void subscribe(String topic) {
    _client.subscribe(topic, MqttQos.atLeastOnce);
  }

  void unsubscribe(String topic) {
    _client.unsubscribe(topic);
  }

  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    _client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
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
