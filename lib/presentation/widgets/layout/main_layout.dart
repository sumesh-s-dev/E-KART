import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/dimensions.dart';
import '../navigation/bottom_navigation_bar.dart';

class MainLayout extends StatelessWidget {
  final StatefulNavigationShell shell;

  const MainLayout({
    super.key,
    required this.shell,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: shell.currentIndex,
        onTap: (index) => shell.goBranch(index),
      ),
    );
  }
}