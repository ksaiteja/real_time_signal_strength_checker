import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

class UserPage extends StatefulWidget {
  UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Map<String, LatLng> markers = {};
  bool isLoading = false;
  late StreamController<String> _selectedMarkerController;
  String selectedMarker = '';
  Position? position;

  @override
  void initState() {
    super.initState();
    fetchData();
    _selectedMarkerController = StreamController<String>.broadcast();
    _selectedMarkerController.add(selectedMarker);
  }

  @override
  void dispose() {
    _selectedMarkerController.close();
    super.dispose();
  }

  void updateSelectedMarker(String newMarker) {
    _selectedMarkerController.add(newMarker); // Update stream controller first
    setState(() {
      selectedMarker = newMarker; // Update state
    });
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });
    // Fetch data from Firestore
    position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('locations').get();

    // Extract data from documents and update markers map
    querySnapshot.docs.forEach((QueryDocumentSnapshot document) {
      String docName = document.id;
      double latitude = document[
          'latitude']; // Adjust the field name according to your data model
      double longitude = document[
          'longitude']; // Adjust the field name according to your data model

      markers[docName] = LatLng(latitude, longitude);
    });
    setState(() {
      isLoading = false;
    });
  }

  // final Map<String, LatLng> markers = {
  //   'Shamshabad': LatLng(17.2600989, 78.3834968),
  //   'Narkhoda': LatLng(17.257969876191893, 78.33441953546087),
  //   'Vardhaman': LatLng(17.254281347867536, 78.30772619205854),
  // };
  List<String> providers = ['Jio', 'Airtel', 'Vi'];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                FlutterMap(
                  options: _buildMapOptions(),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(markers: [
                      (Marker(
                        point: LatLng(position!.latitude, position!.longitude),
                        height: 50,
                        width: 50,
                        child: const Icon(
                          Icons.location_history_rounded,
                          color: Colors.blue,
                        ),
                      )),
                      ..._buildMarkers(),
                    ]),
                    CircleLayer(
                      circles: _buildCircleMarkers(),
                    ),
                  ],
                ),
                _buildDraggableScrollableSheet(height, width),
              ],
            ),
    );
  }

  MapOptions _buildMapOptions() {
    return MapOptions(
      initialRotation: 0,
      interactionOptions: const InteractionOptions(
        enableMultiFingerGestureRace: true,
      ),
      initialZoom: 13,
      initialCenter: LatLng(position!.latitude, position!.longitude),
      // initialCameraFit: CameraFit.coordinates(
      //   coordinates: markers.values.toList(),
      // ),
    );
  }

  List<Marker> _buildMarkers() {
    return markers.entries.map((e) {
      return Marker(
        point: e.value,
        height: 50,
        width: 50,
        child: IconButton(
          iconSize: 30,
          onPressed: () {
            updateSelectedMarker(e.key);
          },
          icon: Icon(
            Icons.location_pin,
            color: selectedMarker == e.key ? Colors.green : Colors.red,
          ),
        ),
      );
    }).toList();
  }

  List<CircleMarker> _buildCircleMarkers() {
    return markers.entries.map((e) {
      return CircleMarker(
        color: Colors.blue.withOpacity(0.3),
        point: e.value,
        radius: 500,
        useRadiusInMeter: true,
      );
    }).toList();
  }

  Widget _buildDraggableScrollableSheet(double height, double width) {
    return Visibility(
      visible: selectedMarker.isNotEmpty,
      child: DraggableScrollableSheet(
        minChildSize: 0.1,
        maxChildSize: 0.58,
        initialChildSize: 0.4,
        builder: (BuildContext context, ScrollController scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            child: _buildSheetContainer(height, width),
          );
        },
      ),
    );
  }

  Widget _buildSheetContainer(double height, double width) {
    return Container(
      width: width,
      height: height * 0.58,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(1, 0),
          ),
        ],
        color: const Color.fromARGB(255, 233, 232, 232),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Container(
            height: 6,
            width: 40,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 158, 154, 154),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              selectedMarker.split('-')[0],
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          Center(
            child: Text(
              selectedMarker.split('-')[1],
              style: GoogleFonts.notoSans(
                fontSize: 15,
              ),
            ),
          ),
          StreamBuilder<String>(
            stream: _selectedMarkerController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                String updatedSelectedMarker = snapshot.data!;
                return AllProvidersList(
                  selectedMarker: updatedSelectedMarker,
                );
              } else {
                return const CircularProgressIndicator(); // Or any other loading indicator
              }
            },
          ),
        ],
      ),
    );
  }
}

class AllProvidersList extends StatelessWidget {
  const AllProvidersList({super.key, required this.selectedMarker});
  final String selectedMarker;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('locations')
            .doc(selectedMarker)
            .collection('networks')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return const Center(
              child: Text("Error loading data. Please try again."),
            );
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No data available."),
            );
          }
          var docs = snapshot.data!.docs;
          List<ProviderContainer> providerWidgets = [];
          for (var doc in docs) {
            providerWidgets.add(ProviderContainer(
                provider: doc.id, signalStrength: doc['signal-strength']));
          }
          return ListView(
            shrinkWrap: true,
            children: providerWidgets,
          );
        });
  }
}

class ProviderContainer extends StatelessWidget {
  ProviderContainer({
    Key? key,
    required this.provider,
    required this.signalStrength,
  }) : super(key: key);

  final String provider;
  final int signalStrength;
  late String img;
  late String signalValue;
  late Color signalColor;

  @override
  Widget build(BuildContext context) {
    _setProviderProperties();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Image(height: 50, width: 50, image: AssetImage(img)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildRichText('Provider Name: ', provider),
                const SizedBox(height: 5),
                _buildRichText('Signal Strength: ', signalValue,
                    textColor: signalColor),
              ],
            ),
          ),
          SignalStrengthIndicator.bars(
            activeColor: signalColor,
            inactiveColor: signalColor.withOpacity(0.3),
            value: signalStrength / 4,
            size: 50,
            barCount: 4,
            spacing: 0.2,
          )
        ],
      ),
    );
  }

  void _setProviderProperties() {
    img = _getProviderImage();
    signalValue = _getSignalValue();
    signalColor = _getSignalColor();
  }

  String _getProviderImage() {
    switch (provider.toLowerCase()) {
      case 'jio':
        return 'assets/jio-logo-red.png';
      case 'airtel':
        return 'assets/airtel-logo.png';
      case 'vi':
        return 'assets/vi-logo.png';
      default:
        return '';
    }
  }

  String _getSignalValue() {
    switch (signalStrength) {
      case 1:
        return 'Poor';
      case 2:
        return 'Fair';
      case 3:
        return 'Good';
      case 4:
        return 'Very Good';

      default:
        return 'Unknown';
    }
  }

  Color _getSignalColor() {
    switch (signalStrength) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.amber.shade500;
      case 4:
        return Colors.green;

      default:
        return Colors.grey;
    }
  }

  Widget _buildRichText(String prefix, String text, {Color? textColor}) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: prefix,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: text,
            style: TextStyle(color: textColor ?? Colors.black),
          ),
        ],
      ),
    );
  }
}
