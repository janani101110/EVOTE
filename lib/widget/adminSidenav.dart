import 'package:flutter/material.dart';

class Adminsidenav extends StatefulWidget {
  final Function(String) onItemSelected; // To notify parent widget which item is selected

  const Adminsidenav({super.key, required this.onItemSelected});

  @override
  State<Adminsidenav> createState() => _AdminsidenavState();
}

class _AdminsidenavState extends State<Adminsidenav> {
  String selectedItem = 'Dashboard';

  final List<String> navItems = [
    'Dashboard',
    'Candidates',
    
    'Divisions',
    'Voters',
    'Admins',
    'Results',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      height: double.infinity,
      color: const Color.fromARGB(255, 32, 6, 92), // Dark sidebar background
      child: Column(
        children: [
          Container(
            height: 80,
            alignment: Alignment.center,
            child: const Text(
              'Admin Panel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: navItems.length,
              itemBuilder: (context, index) {
                final item = navItems[index];
                final isSelected = selectedItem == item;

                return ListTile(
                  title: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Colors.orange : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      selectedItem = item;
                    });
                    widget.onItemSelected(item); // callback to parent
                  },
                  selected: isSelected,
                  selectedTileColor: Colors.orange.withOpacity(0.2),
                  hoverColor: Colors.orange.withOpacity(0.1),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
