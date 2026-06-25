import 'package:flutter/material.dart';
import 'add_hotel_screen.dart';

class HotelOwnerDashboard extends StatelessWidget {
  const HotelOwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Hotel Owner Dashboard"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          children: [
            _buildCard(
              icon: Icons.add_business,
              title: "Add Hotel",
              onTap: () {
                // Navigate to Add Hotel Screen
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddHotelScreen(),
                    ),
                  );
                };
              },
            ),
            _buildCard(
              icon: Icons.hotel,
              title: "My Hotels",
              onTap: () {
                // Navigate to Hotel List
              },
            ),
            _buildCard(
              icon: Icons.book_online,
              title: "Bookings",
              onTap: () {
                // Navigate to Booking List
              },
            ),
            _buildCard(
              icon: Icons.analytics,
              title: "Analytics",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 45, color: Colors.orange),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}