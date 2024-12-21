import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  loc.Location location = loc.Location();

  Future<bool> checkPermission(BuildContext context) async {
    var permissionGranted = await location.hasPermission();

    if (permissionGranted == loc.PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != loc.PermissionStatus.granted) {
        return false;
      }
    }

    return permissionGranted == loc.PermissionStatus.granted;
  }

  Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      final locationData = await location.getLocation();

      final placemarks = await placemarkFromCoordinates(
        locationData.latitude!,
        locationData.longitude!,
      );
      final address = placemarks.first;
      final addressStr =
          '${address.street}, ${address.locality}, ${address.country}'
              .replaceAll('null, ', '')
              .replaceAll(', null', '');

      return {
        'latitude': locationData.latitude,
        'longitude': locationData.longitude,
        'address': addressStr,
      };
    } catch (e) {
      return null;
    }
  }

  Future<bool> openMap(double lat, double lng) async {
    final url =
        Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    return await launchUrl(url);
  }
}
