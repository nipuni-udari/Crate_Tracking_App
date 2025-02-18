import 'package:flutter/material.dart';

class UserProvider with ChangeNotifier {
  String mobileNumber = '';
  String username = '';
  String otp = '';
  String userTypeId = '';
  String subLocationId = '';
  String divisionsId = '';
  String divisionsName = '';
  String UserType = '';
  String subLocationName = '';

  void setUser({
    required String mobileNumber,
    String? username,
    String? otp,
    String? userTypeId,
    String? subLocationId,
    String? divisionsId,
    String? divisionsName,
    String? UserType,
    String? subLocationName,
  }) {
    this.mobileNumber = mobileNumber;
    if (username != null) this.username = username;
    if (otp != null) this.otp = otp;
    if (userTypeId != null) this.userTypeId = userTypeId;
    if (subLocationId != null) this.subLocationId = subLocationId;
    if (divisionsId != null) this.divisionsId = divisionsId;
    if (divisionsName != null) this.divisionsName = divisionsName;
    if (UserType != null) this.UserType = UserType;
    if (subLocationName != null) this.subLocationName = subLocationName;
    notifyListeners();
  }
}
