import 'package:flutter/material.dart';

class FoodCategory extends StatelessWidget {
  const FoodCategory({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _categoryItem(Icons.local_pizza, 'Pizza'),
        _categoryItem(Icons.fastfood, 'Sandwich'),
      ],
    );
  }

  Widget _categoryItem(IconData icon, String title) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Color.fromARGB(255, 252, 132, 58)),
        Text(title, style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
