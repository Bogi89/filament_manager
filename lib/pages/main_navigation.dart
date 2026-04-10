import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/app_state.dart';
import 'dashboard_page.dart';
import 'filament_page.dart';
import 'cost_page.dart';
import 'history_page.dart';
import 'statistics_page.dart';
import 'settings_page.dart';
import '../widgets/spool_icon.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {

  int _selectedIndex = 0;

  void _onItemTapped(int index){
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    final appState = context.watch<AppState>();

    final pages = [

      DashboardPage(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),

      const FilamentPage(),

      CostPage(
        filaments: appState.filaments,
        onSaveJob: appState.addJob,
        onUpdateFilament: appState.updateFilament,
      ),

      HistoryPage(
        jobs: appState.jobs,
      ),

      StatisticsPage(
        jobs: appState.jobs,
        filaments: appState.filaments,
      ),

      const SettingsPage(),

    ];

    return Scaffold(

      backgroundColor:
          Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0F0F14)
              : Colors.grey[100],

      body: pages[_selectedIndex],

      bottomNavigationBar: Builder(
        builder: (context) {

          final isDark =
              Theme.of(context).brightness == Brightness.dark;

          return BottomNavigationBar(

            backgroundColor:
                isDark
                    ? const Color(0xFF111118)
                    : Colors.white,

            elevation: 10,

            type: BottomNavigationBarType.fixed,

            selectedItemColor:
                isDark
                    ? const Color(0xFF7C4DFF) // Dark → Lila
                    : const Color(0xFF3B82F6), // Light → Blau

            unselectedItemColor:
                isDark
                    ? Colors.grey.shade400
                    : Colors.grey.shade600,

            currentIndex: _selectedIndex,

            onTap: _onItemTapped,

            items: [

              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard),
                label: "Dashboard",
              ),

              BottomNavigationBarItem(
  icon: SpoolIcon(size: 26),
  label: 'Filament',
),

              BottomNavigationBarItem(
                icon: Icon(Icons.euro),
                label: "Kosten",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "Historie",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: "Statistik",
              ),

              BottomNavigationBarItem(
                icon: Icon(Icons.settings),
                label: "Settings",
              ),

            ],

          );

        },
      ),

    );
  }
}