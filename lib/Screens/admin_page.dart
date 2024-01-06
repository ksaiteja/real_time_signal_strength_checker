import 'dart:async';
import 'package:carrier_info_wp/carrier_info_wp.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:real_time_signal_strength_checker/Screens/user_page.dart';
import 'package:signal_strength/signal_strength.dart' as ss;
import 'package:geocoding/geocoding.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({Key? key}) : super(key: key);

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final _signalStrengthPlugin = ss.SignalStrength();
  final _carrierInfoWp = CarrierInfoWp();

  bool isLoading = true;
  NetworkStats? _stats;
  double? latitude;
  double? longitude;
  Placemark? location;
  String? sublocality;
  String? street;
  String? networkProvider;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        return; // Handle case where location services are not enabled
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      await placemarkFromCoordinates(position.latitude, position.longitude)
          .then((placemarks) {
        if (placemarks.isNotEmpty) {
          location = placemarks[1];
        }
      });

      var stats = NetworkStats(
        await _signalStrengthPlugin.isOnCellular(),
        await _signalStrengthPlugin.isOnWifi(),
        await _signalStrengthPlugin.getWifiSignalStrength(),
        await _signalStrengthPlugin.getCellularSignalStrength(),
      );

      final info = await _carrierInfoWp.getInfo();

      setState(() {
        _stats = stats;
        latitude = position.latitude;
        longitude = position.longitude;
        networkProvider = info.carrierName;
        sublocality = location!.subLocality.toString();
        street = location!.street.toString();
        isLoading = false;
      });

      print('Latitude: $latitude, Longitude: $longitude');
    } catch (e) {
      print(e.toString());
    }
  }

  void uploadData() {
    CollectionReference locationsCollection =
        FirebaseFirestore.instance.collection('locations');
    DocumentReference documentReference =
        locationsCollection.doc('$sublocality-$street');

    locationsCollection.doc('$sublocality-$street').get().then((docSnapshot) {
      if (!docSnapshot.exists) {
        documentReference.set({
          'latitude': latitude,
          'longitude': longitude,
        }).then((value) {
          print('Data set successfully for subLocality $sublocality-$street');
        }).catchError((error) {
          print('Failed to set data: $error');
        });
      }
    });

    FirebaseFirestore.instance
        .collection('locations')
        .doc('$sublocality-$street')
        .collection('networks')
        .doc(networkProvider)
        .set({'signal-strength': _stats?.cellularSignalStrength![0]});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Page'),
      ),
      body: isLoading ? _buildLoadingIndicator() : _buildContent(),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_stats != null) ...[
          // Display network statistics
          _buildNetworkStatistics(),
        ] else ...[
          // No stats available
          _buildNoStatsAvailable(),
        ],
        const Spacer(),
        _buildButtons(),
      ],
    );
  }

  Widget _buildNetworkStatistics() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          _buildStatText(
              'Cell Strength', _stats?.cellularSignalStrength![0] ?? "null"),
          _buildStatText('Wifi Strength', _stats?.wifiSignalStrength ?? "null"),
          _buildStatText('On Cellular', _stats?.hasCellular ?? "null"),
          _buildStatText('On Wifi', _stats?.hasWifi ?? "null"),
          _buildStatText('Latitude', latitude?.toString() ?? "null"),
          _buildStatText('Longitude', longitude?.toString() ?? "null"),
          _buildStatText('Carrier Name', networkProvider ?? "null"),
          _buildStatText('SubLocality', sublocality ?? "null"),
          _buildStatText('Street', street ?? "null"),
        ],
      ),
    );
  }

  Widget _buildStatText(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.deepPurpleAccent,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            value?.toString() ?? 'N/A',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoStatsAvailable() {
    return const Column(
      children: [
        Text('No stats available'),
        Text('Please Turn on the lcoation and phone permissions manually'),
      ],
    );
  }

  Widget _buildButtons() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserPage()),
              );
            },
            label: 'User Page',
          ),
          _buildElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              uploadData();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Data has been updated"),
                duration: Duration(seconds: 2),
              ));
              setState(() {
                isLoading = false;
              });
            },
            label: 'Update',
          ),
          _buildElevatedButton(
            onPressed: () async {
              setState(() {
                isLoading = true;
              });
              await getCurrentLocation();
              setState(() {
                isLoading = false;
              });
            },
            label: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildElevatedButton(
      {required VoidCallback onPressed, required String label}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurpleAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class NetworkStats {
  NetworkStats(
    this.hasCellular,
    this.hasWifi,
    this.wifiSignalStrength,
    this.cellularSignalStrength,
  );

  bool hasCellular;
  bool hasWifi;
  int? wifiSignalStrength;
  List<int>? cellularSignalStrength;
}
