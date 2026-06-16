import 'package:flutter/material.dart';

import 'shell.dart';
import 'theme.dart';

class Match3EarnApp extends StatelessWidget {
  const Match3EarnApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'ShapeCash',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        home: const AppShell(),
      );
}
