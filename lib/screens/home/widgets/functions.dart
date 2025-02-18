import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FunctionsWidget extends StatefulWidget {
  const FunctionsWidget({Key? key}) : super(key: key);

  @override
  _FunctionsWidgetState createState() => _FunctionsWidgetState();
}

class _FunctionsWidgetState extends State<FunctionsWidget> {
  final TextEditingController _truckNoController = TextEditingController();
  String loadingCount = '0';
  String unloadingCount = '0';
  String receivingCount = '0';
  String exactCratesCount = '0';
  String systemCratesCount = '0';

  Future<void> searchTruck() async {
    String truckNo = _truckNoController.text.trim();
    if (truckNo.isEmpty) return;

    final response = await http.post(
      Uri.parse(
        'https://demo.secretary.lk/cargills_app/backend/crate_tracking_counts.php',
      ),
      body: {'truckNo': truckNo},
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      setState(() {
        loadingCount = data['loading']?.toString() ?? '0';
        unloadingCount = data['unloading']?.toString() ?? '0';
        receivingCount = data['receiving']?.toString() ?? '0';
        exactCratesCount = data['exact_crates_count']?.toString() ?? '0';
        systemCratesCount = data['system_crates_count']?.toString() ?? '0';
      });
    } else {
      print("Failed to fetch data");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Special Offer Banner
        SpecialOfferBanner(
          exactCratesCount: exactCratesCount,
          systemCratesCount: systemCratesCount,
        ),
        // TextField for Truck No
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.5),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _truckNoController,
                  style: const TextStyle(color: Colors.orange),
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: 'Enter Truck No',
                    labelStyle: const TextStyle(color: Colors.orange),
                    border: InputBorder.none,
                    prefixIcon: const Icon(
                      Icons.local_shipping,
                      color: Colors.orange,
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search, color: Colors.orange),
                      onPressed: searchTruck,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Function Cards
        FunctionCard(
          title: "Loading",
          description: "Loading crates to the truck",
          imagePath: "assets/images/loading.png",
          count: loadingCount,
          lable: 'Crate count',
          exactCount: exactCratesCount,
        ),
        const SizedBox(height: 15),
        FunctionCard(
          title: "Unloading",
          description: "Unloading crates from the truck",
          imagePath: "assets/images/unloading.webp",
          count: unloadingCount,
          lable: 'Crate count',
          exactCount: exactCratesCount,
        ),
        const SizedBox(height: 15),
        FunctionCard(
          title: "Receiving",
          description: "Collecting crates from the customer",
          imagePath: "assets/images/receiving.jpg",
          count: receivingCount,
          lable: 'Crate count',
          exactCount: exactCratesCount,
        ),
      ],
    );
  }
}

class FunctionCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final String count;
  final String lable;
  final String exactCount;

  const FunctionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.count,
    required this.lable,
    required this.exactCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const SizedBox(width: 5),
                        Text(
                          count,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Exact crates count: $exactCount",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 10),
                        CircleAvatar(
                          backgroundColor: Colors.orange,
                          radius: 18,
                          child: IconButton(
                            icon: const Icon(
                              Icons.fire_truck,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: () {
                              // Handle button click
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 200,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Special Offer Banner Widget
class SpecialOfferBanner extends StatefulWidget {
  final String exactCratesCount;
  final String systemCratesCount;

  const SpecialOfferBanner({
    Key? key,
    required this.exactCratesCount,
    required this.systemCratesCount,
  }) : super(key: key);

  @override
  _SpecialOfferBannerState createState() => _SpecialOfferBannerState();
}

class _SpecialOfferBannerState extends State<SpecialOfferBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _animation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 203, 70, 17),
                Color.fromARGB(255, 243, 161, 60),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/crate_image.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Track Crates Like a Pro!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Never lose a crate again! '
                      'Our app provides real-time tracking, analytics, and more. '
                      'Start your free trial today!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Add your action here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            'Exact crate Count: ${widget.exactCratesCount}',
                            style: TextStyle(
                              color: Color.fromARGB(255, 252, 37, 37),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10), // Space between buttons
                        ElevatedButton(
                          onPressed: () {
                            // Add your action here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: Text(
                            'System crate Count: ${widget.systemCratesCount}',
                            style: TextStyle(
                              color: Color.fromARGB(255, 252, 37, 37),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
