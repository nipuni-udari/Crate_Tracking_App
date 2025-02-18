import 'dart:convert';
import 'package:crate_tracking/screens/bottom_nav_bar.dart';
import 'package:crate_tracking/screens/home/widgets/functions.dart';
import 'package:crate_tracking/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  final String mobileNumber;

  const HomeScreen({Key? key, required this.mobileNumber}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> fetchUserDetails() async {
    final url = Uri.parse(
      "https://demo.secretary.lk/cargills_app/backend/user_details.php",
    );

    try {
      final response = await http.post(
        url,
        body: {'mobile': widget.mobileNumber},
      );

      print("Response body: ${response.body}");

      final data = jsonDecode(response.body);
      print("Decoded JSON: $data");

      if (data['status'] == 'success') {
        final user = data['user'];

        print("User data: $user");
        print("Data types:");
        user.forEach((key, value) {
          print("$key: ${value.runtimeType}");
        });

        Provider.of<UserProvider>(context, listen: false).setUser(
          mobileNumber: widget.mobileNumber,
          username: user['username'].toString(),
          otp: user['otp'].toString(),
          userTypeId: user['user_type_id'].toString(),
          subLocationId: user['sub_location_id'].toString(),
          divisionsId: user['divisions_id'].toString(),
          divisionsName: user['division_name'].toString(),
          UserType: user['user_type'].toString(),
          subLocationName: user['sub_location_name'].toString(),
        );
      } else {
        print("User not found: ${data['message']}");
      }
    } catch (e) {
      print("Error fetching user details: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 252, 132, 58),
        elevation: 5,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'Hi ${userProvider.username.isNotEmpty ? userProvider.username : userProvider.mobileNumber}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  color: Color.fromARGB(255, 252, 132, 58),
                  size: 28,
                ),
              ),
            ],
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        children: [
          // Background Image with Repeat Pattern
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                opacity:
                    0.1, // Adjust transparency level (0.0 - fully transparent, 1.0 - fully visible)
                image: AssetImage("assets/images/background_pattern.jpg"),
                repeat: ImageRepeat.repeat, // Makes the background repeat
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: const [
                  //SpecialOfferBanner(),
                  SizedBox(height: 20),
                  FunctionsWidget(),
                ],
              ),
            ),
          ),
        ],
      ),

      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }
}
