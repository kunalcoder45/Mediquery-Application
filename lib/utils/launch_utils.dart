import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

Future<void> launchPhoneDialer(String phoneNumber) async {
  if (phoneNumber != 'Not available') {
    final url = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw Exception('Could not launch phone dialer.');
    }
  }
}

// Main function - simple and clean
Future<void> openGoogleMaps(String storeName, String storeAddress, String userLocation) async {
  try {
    print('Opening maps for: $storeName');
    print('From location: $userLocation');
    
    // Clean and prepare the query
    final destination = '$storeName, $storeAddress'.trim();
    
    bool success = false;
    
    // Try platform-specific apps first
    if (Platform.isAndroid) {
      success = await _tryAndroidMaps(destination, userLocation);
    } else if (Platform.isIOS) {
      success = await _tryIOSMaps(destination, userLocation);
    }
    
    // If app launch failed, use browser
    if (!success) {
      await _openWebMaps(destination, userLocation);
    }
    
  } catch (e) {
    print('Maps error: $e');
    throw Exception('Could not open maps');
  }
}

// Android specific maps
Future<bool> _tryAndroidMaps(String destination, String userLocation) async {
  try {
    // Simple geo intent - most reliable
    final geoQuery = Uri.encodeComponent(destination);
    final geoUrl = Uri.parse('geo:0,0?q=$geoQuery');
    
    if (await canLaunchUrl(geoUrl)) {
      await launchUrl(geoUrl, mode: LaunchMode.externalApplication);
      print('✅ Opened with geo intent');
      return true;
    }
    
    return false;
  } catch (e) {
    print('Android maps failed: $e');
    return false;
  }
}

// iOS specific maps
Future<bool> _tryIOSMaps(String destination, String userLocation) async {
  try {
    final query = Uri.encodeComponent(destination);
    final mapsUrl = Uri.parse('maps:?q=$query');
    
    if (await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl, mode: LaunchMode.externalApplication);
      print('✅ Opened with iOS maps');
      return true;
    }
    
    return false;
  } catch (e) {
    print('iOS maps failed: $e');
    return false;
  }
}

// Web browser fallback - guaranteed to work
Future<void> _openWebMaps(String destination, String userLocation) async {
  try {
    String webUrl;
    
    // If user location is available, show directions
    if (userLocation.isNotEmpty && 
        userLocation != 'Your Current Location' && 
        userLocation != 'Current Location') {
      
      // Directions URL
      final source = Uri.encodeComponent(userLocation);
      final dest = Uri.encodeComponent(destination);
      webUrl = 'https://www.google.com/maps/dir/$source/$dest';
      
    } else {
      // Simple search URL
      final query = Uri.encodeComponent(destination);
      webUrl = 'https://www.google.com/maps/search/$query';
    }
    
    print('Opening web URL: $webUrl');
    
    final url = Uri.parse(webUrl);
    
    // Always use external browser for maps
    await launchUrl(
      url, 
      mode: LaunchMode.externalApplication,
    );
    
    print('✅ Opened in browser');
    
  } catch (e) {
    print('Web maps error: $e');
    
    // Last resort - simple Google search
    final query = Uri.encodeComponent('$destination directions');
    final searchUrl = Uri.parse('https://www.google.com/search?q=$query');
    
    await launchUrl(
      searchUrl,
      mode: LaunchMode.externalApplication,
    );
  }
}

// Backward compatibility functions
Future<void> launchGoogleMapsWithQuery(String storeName, String storeAddress) async {
  await openGoogleMaps(storeName, storeAddress, '');
}

Future<void> launchGoogleMapsDirections(String destinationName, String destinationAddress, {String? userLocation}) async {
  await openGoogleMaps(destinationName, destinationAddress, userLocation ?? '');
}