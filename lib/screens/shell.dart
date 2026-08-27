import 'package:flutter/material.dart';

import '../theme/palette.dart';
import 'history_screen.dart';
import 'medication_editor.dart';
import 'meds_screen.dart';
import 'settings_screen.dart';
import 'today_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = const [
      TodayScreen(),
      MedsScreen(),
      HistoryScreen(),
      SettingsScreen(),
    ];
    return Scaffold(
      backgroundColor: VitaliaPalette.paper,
      body: SafeArea(child: pages[_index]),
      floatingActionButton: _index == 1
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const MedicationEditor(),
                  ),
                );
              },
              backgroundColor: VitaliaPalette.sage,
              foregroundColor: VitaliaPalette.paper,
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view),
            label: 'Meds',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_graph_outlined),
            selectedIcon: Icon(Icons.auto_graph),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_outlined),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
