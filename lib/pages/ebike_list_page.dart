// ebike_list_page.dart
import 'package:flutter/material.dart';
import '../pages/ebike_model.dart';
import '../pages/reservation_form_page.dart';

class EbikeListPage extends StatefulWidget {
  const EbikeListPage({super.key});

  @override
  EbikeListPageState createState() => EbikeListPageState();
}

class EbikeListPageState extends State<EbikeListPage> {
  final List<Ebike> ebikesList = [
    Ebike(
      name: 'Ebike 1',
      photo: 'assets/images/ebike1.jpg',
      chargingPercentage: 80,
      mileage: 70,
    ),
    Ebike(
      name: 'Ebike 2',
      photo: 'assets/images/ebike1.jpg',
      chargingPercentage: 90,
      mileage: 100,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E-bike Renting'),
      ),
      body: ListView.builder(
        itemCount: ebikesList.length,
        itemBuilder: (context, index) {
          final ebike = ebikesList[index];
          return _buildEbikeListTile(ebike);
        },
      ),
    );
  }

  Widget _buildEbikeListTile(Ebike ebike) {
    return GestureDetector(
      
      child: ListTile(
        leading: Image.asset(
          ebike.photo,
          width: 50,
          height: 50,
          fit: BoxFit.cover,
        ),
        title: Text(
          ebike.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Charging percentage: ${ebike.chargingPercentage}%'),
            Text('Kelometrage: ${ebike.mileage} km'),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            _handleReservationButtonPress(ebike);
          },
          child: const Text('Reserve'),
        ),
      ),
    );
  }

  void _handleReservationButtonPress(Ebike ebike) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReservationFormPage(ebike: ebike),
      ),
    );
  }
}