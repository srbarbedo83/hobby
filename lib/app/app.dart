import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/hobbies/hobby_list_screen.dart';

class RitmoApp extends StatelessWidget {
  const RitmoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ritmo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      home: const HobbyListScreen(),
    );
  }
}
