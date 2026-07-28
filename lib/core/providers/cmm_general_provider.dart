import 'package:flutter/material.dart';

class CmmGeneralProvider extends ChangeNotifier{
  
  bool haveErrors = false;
  void setErrors(bool val) {
    haveErrors = val;
    notifyListeners();
  }

  String? errorMessage;
  void setErrorMessage(String val) {
    errorMessage = val;
    notifyListeners();
  }

  int? statusCode;
  void setStatusCode(int val) {
    statusCode = val;
    notifyListeners();
  }

  bool isLoading = false;
  void setLoadingStatus(bool val) {
    isLoading = val;
    notifyListeners();
  }

  void disposeValues() {
    setErrors(false);
    setErrorMessage('');
    setStatusCode(0);
    setLoadingStatus(false);
  }

  void resetValues() {}
}