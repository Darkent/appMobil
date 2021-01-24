import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUser {
  static final PreferencesUser _instancia = new PreferencesUser._();
  bool newNotification = false;
  StreamController<int> receive = StreamController<int>.broadcast();
  factory PreferencesUser() {
    return _instancia;
  }

  PreferencesUser._();

  SharedPreferences _preferences;

  initPrefs() async {
    WidgetsFlutterBinding.ensureInitialized();
    _preferences = await SharedPreferences.getInstance();
  }

  set series(List series) {
    _preferences.setStringList("series", series);
  }

  get series {
    return _preferences.getStringList("series") ?? [];
  }

  get notification {
    return _preferences.getInt("notification") ?? 0;
  }

  set notification(int n) {
    _preferences.setInt("notification", n);
  }

  get itemsCar {
    return _preferences.getInt("items") ?? 0;
  }

  set itemsCar(int items) {
    _preferences.setInt("items", items);
  }

  get userData {
    return _preferences.getString("user") ?? "-";
  }

  set userData(Map data) {
    String temporal = json.encode(data);
    _preferences.setString("user", temporal);
  }

  get productsCar {
    return _preferences.getString("productsCar") ?? "[]";
  }

  set productsCar(List<dynamic> productsCar) {
    _preferences.setString("productsCar", json.encode(productsCar));
  }

  set purchases(List<String> id) {
    _preferences.setStringList("external_ids", id);
  }

  get purchases {
    return _preferences.getStringList("external_ids") ?? [];
  }

  set tokenFirebase(String tk) {
    _preferences.setString("tokenFirebase", tk);
  }

  get tokenFirebase {
    return _preferences.getString("tokenFirebase") ?? "-";
  }

  set tmpPdf(String url) {
    _preferences.setString("pdf", url);
  }

  get tmpPdf {
    return _preferences.getString("pdf") ?? "";
  }

  Future<bool> deleteCar() async {
    bool removed = await _preferences.remove("productsCar");

    return removed;
  }

  Future<bool> deleteUser() async {
    bool removed = await _preferences.remove("user");

    return removed;
  }

  Future<void> reset() async {
    receive.close();
    await _preferences.clear();
  }
}
