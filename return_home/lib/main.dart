import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  LatLng? _currentPosition; // Mevcut konumu depolamak için

  @override
  void initState() {
    super.initState();
    _getCurrentLocation(); // Uygulama başlarken mevcut konumu al
  }

  // Mevcut konumu almak için Geolocator kullanıyoruz
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servislerinin aktif olup olmadığını kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Konum servisleri kapalıysa uyarı verilebilir
      print('Konum servisleri kapalı.');
      return;
    }

    // Konum iznini kontrol et
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Konum izni reddedildi
        print('Konum izni reddedildi.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Kullanıcı konum iznini kalıcı olarak reddetti
      print('Konum izni kalıcı olarak reddedildi.');
      return;
    }

    // Mevcut konumu al
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Haritada Konumum'),
        ),
        body: _currentPosition == null
            ? const Center(child: CircularProgressIndicator())
            : FlutterMap(
                options: MapOptions(
                  center: _currentPosition, // Mevcut konuma odaklan
                  zoom: 15.0, // Yakınlaştırma seviyesi
                ),
                nonRotatedChildren: [
                  RichAttributionWidget(
                    attributions: [
                      TextSourceAttribution(
                        'OpenStreetMap contributors',
                        onTap: () => launchUrl(
                          Uri.parse('https://openstreetmap.org/copyright'),
                        ),
                      )
                    ],
                  )
                ],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _currentPosition!, // Mevcut konuma işaretçi ekle
                        builder: (ctx) => const Icon(
                          Icons.circle,
                          color: Colors.blue,
                          size: 15.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}
