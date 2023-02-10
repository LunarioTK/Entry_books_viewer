import 'package:flutter/material.dart';

class MyPanelState extends ChangeNotifier {
  bool isOpen = false;

  set setPanelOpen(bool isPanelOpen) {
    isOpen = isPanelOpen;
    notifyListeners();
  }
}
