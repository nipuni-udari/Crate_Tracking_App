import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:crate_tracking/user_provider.dart';
import 'package:crate_tracking/screens/bottom_nav_bar.dart';
import 'package:crate_tracking/screens/mobile_checking.dart';

class ProfileScreen extends StatelessWidget {
  final String mobileNumber;

  const ProfileScreen({Key? key, required this.mobileNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 247, 141, 4), Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Color.fromARGB(255, 242, 43, 3),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      userProvider.username.isNotEmpty
                          ? userProvider.username
                          : "N/A",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      userProvider.UserType.isNotEmpty
                          ? userProvider.UserType
                          : "N/A",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),

              // Profile Info Card
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 5,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ProfileInfoRow(
                        label: "Mobile Number",
                        value:
                            userProvider.mobileNumber.isNotEmpty
                                ? userProvider.mobileNumber
                                : "N/A",
                      ),
                      ProfileInfoRow(
                        label: "User Type",
                        value:
                            userProvider.UserType.isNotEmpty
                                ? userProvider.UserType
                                : "N/A",
                      ),
                      ProfileInfoRow(
                        label: "Sub Location",
                        value:
                            userProvider.subLocationName.isNotEmpty
                                ? userProvider.subLocationName
                                : "N/A",
                      ),
                      ProfileInfoRow(
                        label: "Division",
                        value:
                            userProvider.divisionsName.isNotEmpty
                                ? userProvider.divisionsName
                                : "N/A",
                      ),
                      const Spacer(),

                      // Logout Button
                      SizedBox(
                        width: 200,
                        child: ElevatedButton(
                          onPressed: () {
                            // Perform any necessary logout logic here (e.g., clearing user session)
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MobileScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              227,
                              98,
                              17,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Logout",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

class ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const ProfileInfoRow({Key? key, required this.label, required this.value})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          Text(
            value.isNotEmpty ? value : "N/A",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
