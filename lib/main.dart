import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/report_repository.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';
import 'state/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const CampusSosApp());
}

class CampusSosApp extends StatelessWidget {
  const CampusSosApp({super.key});

  @override
  Widget build(BuildContext context) {
    const violet = Color(0xFF6546E8);
    const ink = Color(0xFF17233D);
    return ChangeNotifierProvider(
      create: (_) => AppState(repository: ReportRepository()),
      child: MaterialApp(
        title: 'Campus SOS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8FC),
          colorScheme: ColorScheme.fromSeed(
            seedColor: violet,
            primary: violet,
            surface: Colors.white,
            onSurface: ink,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFFF7F8FC),
            foregroundColor: ink,
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE4E7F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: Color(0xFFE4E7F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: const BorderSide(color: violet, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
