import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_planner_app/features/auth/screens/ai_itenirary_screen.dart';
import 'package:travel_planner_app/features/chatbot/gemini_ai.dart';
import 'profile_screen.dart';
import 'location_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'map_screen.dart';
import 'package:travel_planner_app/features/map/service/location_service.dart';
import 'package:firebase_auth/firebase_auth.dart';


void main() {
  runApp(const TravelPlannerApp());
}

class TravelPlannerApp extends StatelessWidget {
  const TravelPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Travel Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  String? userName;
  String? photoUrl;
  String currentCity = "Loading...";
  final List<Map<String, String>> preferences = [
    {"title": "Beach", "image": "assets/preferences/beach.png"},
    {"title": "Adventure", "image": "assets/preferences/adventure.png"},
    {"title": "Wildlife", "image": "assets/preferences/wildlife.png"},
    {"title": "Camping", "image": "assets/preferences/camping.png"},
    {"title": "Nature", "image": "assets/preferences/nature.png"},
    {"title": "Heritage", "image": "assets/preferences/heritage.png"},
  ];

  final Set<String> selectedPreferences = {};

  @override
  void initState() {
    super.initState();
    _loadCity();
    _loadUserData();
    loadPreferences();
  }

  Future<void> _loadCity() async {
    try {
      final city = await LocationService().getCurrentCity();

      if (mounted) {
        setState(() {
          currentCity = city;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          currentCity = "Unknown";
        });
      }
    }
  }

  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;

      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (doc.exists && mounted) {
        setState(() {
          photoUrl = doc.data()?['photoURL'];
          userName = doc.data()?['name'] ?? 'Traveler';
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  Future<void> loadPreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();

      if (data != null && data['preferences'] != null) {
        setState(() {
          selectedPreferences.addAll(
            List<String>.from(data['preferences']),
          );
        });
      }
    }
  }

  Future<void> savePreferences() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .update({
      'preferences': selectedPreferences.toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child:
      SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Location Section
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Location",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                currentCity,
                                style: GoogleFonts.montserrat(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Notification + Profile
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                // TODO: Notifications Screen
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfileScreen(),
                                ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.white,
                              backgroundImage:
                                  photoUrl != null && photoUrl!.isNotEmpty
                                      ? NetworkImage(photoUrl!)
                                      : null,
                              child: photoUrl == null || photoUrl!.isEmpty
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.blue,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "$userName",
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Plan your next adventure today!",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Search Destination
            TextField(
              decoration: InputDecoration(
                hintText: "Search destinations...",
                hintStyle: GoogleFonts.poppins(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),


            //user travel preferences
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    "Preferences",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: preferences.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {

                      final item = preferences[index];
                      final selected =
                      selectedPreferences.contains(item["title"]);

                      return FilterChip(

                        selected: selected,

                        onSelected: (value) async{
                          setState(() {
                            value
                                ? selectedPreferences.add(item["title"]!)
                                : selectedPreferences.remove(item["title"]);
                          });
                          await savePreferences();
                        },

                        avatar: CircleAvatar(
                          radius: 14,
                          backgroundImage:
                          AssetImage(item["image"]!),
                        ),

                        label: Text(
                          item["title"]!,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),

                        backgroundColor: Colors.white,

                        selectedColor: Colors.blue,

                        checkmarkColor: Colors.white,

                        side: BorderSide(
                          color: selected
                              ? Colors.blue
                              : Colors.grey.shade300,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            Text(
              "Trending Destinations",
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('locations')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final locations = snapshot.data!.docs;

                return SizedBox(
                  height: 250,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: locations.length,
                    itemBuilder: (context, index) {
                      final location = locations[index];

                      return GestureDetector(
                        onTap: () {
                          // Navigate to details
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => LocationDetailScreen(
                                name: location['name'],
                                imageUrl: location['imageURL'],
                                description: location['description'],
                                rating: (location['rating'] as num).toDouble(),
                                budget: (location['budget'] as num).toInt(),
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 200,
                          margin: const EdgeInsets.all(10),
                          child: Column(
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(15),
                                  child: Image.network(
                                    location['imageURL'],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Text(location['name']),
                              Text("⭐ ${location['rating']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Text(
              "Upcoming Trips",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Card(
              child: ListTile(
                leading: Icon(Icons.flight_takeoff),
                title: Text("Goa Vacation"),
                subtitle: Text("12 Jun - 16 Jun"),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                quickAction(Icons.hotel, "Hotels"),
                quickAction(Icons.flight, "Flights"),
                quickAction(Icons.map, "Maps"),
                quickAction(Icons.currency_rupee, "Budget"),
              ],
            ),
          ],
        ),
      ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'map_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MapScreen(),
                ),
              );
            },
            child: const Icon(Icons.map),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'ai_fab',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChatbotScreen(),
                ),
              );
            },
            child: const Icon(Icons.smart_toy),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 35),
            label: "Add",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.flight),
            label: "Trips",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Journal",
          ),
        ],
      ),
    );
  }

  Widget destinationCard(String place) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          place,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget quickAction(IconData icon, String title) {
    return Column(
      children: [
        CircleAvatar(
          radius: 28,
          child: Icon(icon),
        ),
        const SizedBox(height: 5),
        Text(title),
      ],
    );
  }
}
