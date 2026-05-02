import 'package:flutter/material.dart';

class AppConstants {
  static double navBarBottomPadding(BuildContext context) {
    return MediaQuery.of(context).padding.bottom + 25 + 
           MediaQuery.of(context).size.height * 0.065 + 10 ;
  }
}