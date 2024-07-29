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
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 53, 112, 231),
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
