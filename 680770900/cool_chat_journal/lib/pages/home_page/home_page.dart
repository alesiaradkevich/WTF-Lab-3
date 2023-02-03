import 'package:flutter/material.dart';

import 'events_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.appName});

  final String appName;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => print('Click to menu'),),
        title: Text(appName),
      ),
      body: ListView(
        children: const [
          EventsCard(
            icon: Icon(Icons.flight_takeoff),
            title: 'Travel',
            subtitle: 'No events. Click to create',
          ),
          EventsCard(
            icon: Icon(Icons.chair),
            title: 'Family',
            subtitle: 'No events. Click to create',
          ),
          EventsCard(
            icon: Icon(Icons.fitness_center),
            title: 'Sport',
            subtitle: 'No events. Click to create',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => print('Click to floating action button'),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}

class BottomNavigation extends StatefulWidget {
  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  
  int _currentIndex = 0;
  
  @override
  Widget build(BuildContext context) {

    var labelSize = Theme.of(context).textTheme.bodyMedium?.fontSize ?? 12.0;

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      unselectedFontSize: labelSize,
      selectedFontSize: labelSize + 2.0,
      onTap: (value) {
        setState(() {
          _currentIndex = value;
        });
      },

      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),

        BottomNavigationBarItem(
          icon: Icon(Icons.assignment),
          label: 'Daily',
        ),
      ],
    );
  }
}