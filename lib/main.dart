import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hrroadways/colors.dart';
import 'package:hrroadways/pages/home.dart';
import 'package:provider/provider.dart';

import 'providers/routes_path_search_provider.dart';
import 'providers/routes_search_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // This makes the status bar and navigation bar transparent
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, // Required for Edge-to-Edge
    systemNavigationBarDividerColor: Colors.transparent,
    statusBarColor: Colors.transparent,
  ));

  // This tells the Android engine to let the app draw behind the bars
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RoutesSearchProvider()),
        ChangeNotifierProvider(create: (_) => RoutesPathSearchProvider()),
      ],
      child: MaterialApp(
        title: 'HR Roadways',
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.dark),
          useMaterial3: true,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Color(0xff282E3D),
            prefixIconColor: Color(0xff9CA3AF),
            suffixIconColor: Color(0xff9CA3AF),
            prefixIconConstraints: BoxConstraints(minWidth: 24, minHeight: 24),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColors),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.light, width: 0.8),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.borderColors),
            ),
            labelStyle: TextStyle(color: Color(0xff9CA3AF)),
            hintStyle: TextStyle(
              color: Color(0xff9CA3AF),
              fontWeight: FontWeight.bold,
            ),
          ),
          textTheme: TextTheme(
            bodyLarge: TextStyle(fontSize: 18, color: Color(0xff9CA3AF)),
            bodyMedium: TextStyle(fontSize: 16, color: Color(0xff9CA3AF)),
            titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff9CA3AF),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
