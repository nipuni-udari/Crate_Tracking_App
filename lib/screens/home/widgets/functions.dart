import 'package:flutter/material.dart';

class FunctionCard extends StatelessWidget {
  final String title;
  final String description;
  final String imagePath;
  final double count;
  final String lable;

  const FunctionCard({
    Key? key,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.count,
    required this.lable,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.9, // 90% of screen width
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Left side: Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 18),
                        const SizedBox(width: 5),
                        Text(
                          count.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
                          "Add",
                          style: const TextStyle(
                            fontSize: 16,
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
                              Icons.add,
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

              // Right side: Full height image
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  width: 200, // Adjust width as needed
                  height: 100, // Adjust height as needed
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

class FunctionsWidget extends StatelessWidget {
  const FunctionsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FunctionCard(
          title: "Loading",
          description: "Loading crates to the truck",
          imagePath: "assets/images/loading.png",
          count: 3.8,
          lable: 'Add',
        ),
        const SizedBox(height: 15),
        FunctionCard(
          title: "Unloading",
          description: "unloading crates from the truck",
          imagePath: "assets/images/unloading.webp",
          count: 4.5,
          lable: 'Add',
        ),
        const SizedBox(height: 15),
        FunctionCard(
          title: "Receiving",
          description: "collecting crates from the customer",
          imagePath: "assets/images/receiving.jpg",
          count: 4.2,
          lable: 'Add',
        ),
      ],
    );
  }
}
