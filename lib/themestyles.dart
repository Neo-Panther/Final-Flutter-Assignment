import 'package:flutter/material.dart';

 class Styles {
   
  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      primarySwatch: Colors.deepPurple,
      primaryColor: isDarkTheme ? Colors.white : Colors.black,
      errorColor: Colors.red,
      hintColor: isDarkTheme ?Color.fromARGB(255, 3, 96, 0)  : Colors.grey,
      backgroundColor: isDarkTheme ? Colors.black : Color.fromARGB(255, 165, 201, 255),

      indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),

      highlightColor: isDarkTheme ? Color(0xff372901) : Color(0xffFCE192),
      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Color(0xff4285F4),

      focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? Color.fromARGB(255, 5, 0, 74) : Color.fromARGB(255, 212, 255, 193),
      canvasColor: isDarkTheme ? Colors.black : Colors.grey[50],
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light()),
      textSelectionTheme: TextSelectionThemeData(selectionColor: isDarkTheme ? Colors.white : Colors.black),
    );
    
  }
}