import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const CustomBottomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20.0), // Margin around the navigation bar for floating effect
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 53, 112, 231), // Background color of the navigation bar
        borderRadius: BorderRadius.circular(40.0), // Rounded corners
        boxShadow: [ // Shadow for a floating effect
          BoxShadow(
            color: const Color.fromARGB(255, 24, 30, 41).withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 4,
            offset: const Offset(0, 3), // Shadow position
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric( vertical: 4.0),
        child: Row(
          
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildNavItem(Icons.home, 0, 'Home'),
            _buildNavItem(Icons.map, 1, 'Map'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index, String label) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(9.0),
            decoration: BoxDecoration(
              color: selectedIndex == index ? Colors.white : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20.0,
              color: selectedIndex == index ? const Color.fromARGB(255, 53, 112, 231) : Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: selectedIndex == index ? Colors.white : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
