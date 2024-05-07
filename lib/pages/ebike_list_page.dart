import 'package:flutter/material.dart';


class EbikeListPage extends StatefulWidget {
  const EbikeListPage({super.key});

  @override
  EbikeListPageState createState() => EbikeListPageState();
}

class EbikeListPageState extends State<EbikeListPage> {
  final List<Map<String, dynamic>> _ebikes = [
    {
      'name': 'Ebike 1',
      'photo': 'assets/images/ebike1.jpg',
      'chargingPercentage': 80,
      'mileage': 70,
      'reservationUrl': '/reservation/ebike1',
    },
    {
      'name': 'Ebike 2',
      'photo': 'assets/images/ebike1.jpg',
      'chargingPercentage': 90,
      'mileage': 100,
      'reservationUrl': '/reservation/ebike2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bike Renting'),
      ),
      body: ListView.builder(
        itemCount: _ebikes.length,
        itemBuilder: (context, index) {
          final ebike = _ebikes[index];
          return GestureDetector(
            onTap: () {
              // Navigate to the reservation page for the selected bike.
              Navigator.pushNamed(context, ebike['reservationUrl']);
            },
            child: ListTile(
              leading: Image.asset(
                ebike['photo'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(
                ebike['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Charging percentage: ${ebike['chargingPercentage']}%'),
                  Text('Kelometrage: ${ebike['kelometrage']} km'),
                ],
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  // Handle the reservation button press event.
                },
                child: const Text('Reserve'),
              ),
            ),
          );
        },
      ),
    );
  }
}