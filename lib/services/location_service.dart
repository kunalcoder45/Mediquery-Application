// import 'package:geolocator/geolocator.dart';

// class LocationService {
//   Future<Position> getCurrentPosition() async {
//     final hasPermission = await _requestLocationPermission();
//     if (!hasPermission) {
//       throw Exception('Location permission denied.');
//     }
//     return await Geolocator.getCurrentPosition(
//       desiredAccuracy: LocationAccuracy.high,
//       timeLimit: const Duration(seconds: 15),
//     );
//   }

//   Future<bool> _requestLocationPermission() async {
//     LocationPermission permission = await Geolocator.checkPermission();
//     if (permission == LocationPermission.denied) {
//       permission = await Geolocator.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }
//     if (permission == LocationPermission.deniedForever) {
//       return false;
//     }
//     return true;
//   }
// }


// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart' as permission_handler;

// class LocationService {
//   /// Get current user position (with permission + service checks)
//   Future<Position> getCurrentPosition() async {
//     try {
//       // Step 1: Check if location services are enabled (GPS ON/OFF)
//       final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         // Don't automatically open settings - let user decide
//         throw Exception('Location services are disabled. Please enable GPS in your device settings and try again.');
//       }

//       // Step 2: Check & request permission
//       final hasPermission = await _requestLocationPermission();
//       if (!hasPermission) {
//         throw Exception('Location permission is required to find nearby stores.');
//       }

//       // Step 3: Get position with timeout and error handling
//       return await _getPositionWithRetry();
      
//     } catch (e) {
//       // Re-throw with user-friendly message
//       throw Exception(_getUserFriendlyError(e.toString()));
//     }
//   }

//   /// Internal: Get position with retry logic
//   Future<Position> _getPositionWithRetry() async {
//     try {
//       // Try to get position with reasonable timeout
//       return await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//         timeLimit: const Duration(seconds: 10), // Reduced timeout
//       );
//     } catch (e) {
//       // If high accuracy fails, try with lower accuracy
//       print('High accuracy failed, trying medium accuracy: $e');
//       try {
//         return await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.medium,
//           timeLimit: const Duration(seconds: 8),
//         );
//       } catch (e2) {
//         // Last resort - try with low accuracy
//         print('Medium accuracy failed, trying low accuracy: $e2');
//         return await Geolocator.getCurrentPosition(
//           desiredAccuracy: LocationAccuracy.low,
//           timeLimit: const Duration(seconds: 5),
//         );
//       }
//     }
//   }

//   /// Internal: Ask for location permission safely (NO AUTOMATIC SETTINGS)
//   Future<bool> _requestLocationPermission() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
      
//       // If denied, ask for permission
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
        
//         // If still denied after asking, return false
//         if (permission == LocationPermission.denied) {
//           return false;
//         }
//       }
      
//       // If permanently denied, return false (don't open settings automatically)
//       if (permission == LocationPermission.deniedForever) {
//         return false;
//       }
      
//       // Permission granted
//       return permission == LocationPermission.whileInUse || 
//              permission == LocationPermission.always;
             
//     } catch (e) {
//       print('Permission request error: $e');
//       return false;
//     }
//   }

//   /// Convert technical errors to user-friendly messages
//   String _getUserFriendlyError(String error) {
//     if (error.contains('Location services are disabled')) {
//       return 'Please turn on location services in your device settings and try again.';
//     } else if (error.contains('permission')) {
//       return 'Location access is needed to find nearby medical stores. Please allow location permission.';
//     } else if (error.contains('timeout') || error.contains('TimeoutException')) {
//       return 'Unable to get your location right now. Please check if GPS is enabled and try again.';
//     } else {
//       return 'Failed to get current location. Please try entering your location manually or check your GPS settings.';
//     }
//   }

//   /// Check if we can use location services without requesting
//   Future<bool> canUseLocation() async {
//     final serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return false;
    
//     final permission = await Geolocator.checkPermission();
//     return permission == LocationPermission.whileInUse || 
//            permission == LocationPermission.always;
//   }

//   /// Open location settings manually (call this only when user explicitly wants to)
//   Future<void> openLocationSettings() async {
//     try {
//       await Geolocator.openLocationSettings();
//     } catch (e) {
//       // If Geolocator fails, try with permission_handler
//       await permission_handler.openAppSettings();
//     }
//   }
// }


import 'package:geolocator/geolocator.dart';

class LocationService {
  
  /// Main function - handles timeouts properly
  Future<Position> getCurrentPosition() async {
    try {
      print('🔍 Starting location process...');
      
      // Step 1: Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('📍 Location services disabled, requesting...');
        serviceEnabled = await Geolocator.openLocationSettings();
        if (!serviceEnabled) {
          throw Exception('Location services are disabled. Please enable GPS.');
        }
        await Future.delayed(const Duration(milliseconds: 800));
      }
      
      // Step 2: Handle permissions
      LocationPermission permission = await _handlePermissions();
      if (permission == LocationPermission.denied || 
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission is required to find nearby stores.');
      }
      
      print('✅ Permissions granted, getting location...');
      
      // Step 3: Try multiple approaches for location
      return await _getLocationWithFallbacks();
      
    } catch (e) {
      print('❌ Location error: $e');
      rethrow;
    }
  }
  
  /// Try multiple methods to get location
  Future<Position> _getLocationWithFallbacks() async {
    
    // Method 1: Try last known location first (fastest)
    try {
      print('📍 Trying last known location...');
      Position? lastPosition = await Geolocator.getLastKnownPosition(
        forceAndroidLocationManager: true,
      );
      
      if (lastPosition != null) {
        // Check if last location is recent (within 10 minutes)
        final timeDiff = DateTime.now().difference(lastPosition.timestamp);
        if (timeDiff.inMinutes < 10) {
          print('✅ Using recent last known location: ${lastPosition.latitude}, ${lastPosition.longitude}');
          return lastPosition;
        } else {
          print('⚠️ Last known location too old (${timeDiff.inMinutes} minutes), getting fresh...');
        }
      }
    } catch (e) {
      print('⚠️ Last known location failed: $e');
    }
    
    // Method 2: Try current location with very short timeout first
    try {
      print('📍 Trying quick current location (3s)...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 3),
        forceAndroidLocationManager: true,
      );
    } catch (e) {
      print('⚠️ Quick location failed: $e');
    }
    
    // Method 3: Try with longer timeout but lower accuracy
    try {
      print('📍 Trying medium accuracy (6s)...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 6),
        forceAndroidLocationManager: false, // Use Google Play services
      );
    } catch (e) {
      print('⚠️ Medium accuracy failed: $e');
    }
    
    // Method 4: Final attempt - any location
    try {
      print('📍 Final attempt - any accuracy (10s)...');
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.lowest,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      print('❌ All location methods failed: $e');
      
      // Method 5: Try last known location again (even if old)
      try {
        Position? lastPosition = await Geolocator.getLastKnownPosition();
        if (lastPosition != null) {
          print('✅ Using old last known location as fallback');
          return lastPosition;
        }
      } catch (e2) {
        print('❌ Even last known location failed: $e2');
      }
      
      throw Exception('Unable to get your location. Please try again or check if GPS is working properly.');
    }
  }
  
  /// Handle permissions step by step
  Future<LocationPermission> _handlePermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    print('📋 Current permission: $permission');
    
    if (permission == LocationPermission.denied) {
      print('🔐 Requesting permission...');
      permission = await Geolocator.requestPermission();
      print('📋 After request: $permission');
    }
    
    return permission;
  }
  
  /// Quick check without requesting anything
  Future<bool> isLocationAvailable() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      
      return serviceEnabled && 
             (permission == LocationPermission.whileInUse || 
              permission == LocationPermission.always);
    } catch (e) {
      return false;
    }
  }
  
  /// Get location settings info for debugging
  Future<Map<String, dynamic>> getLocationInfo() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      final permission = await Geolocator.checkPermission();
      final lastKnown = await Geolocator.getLastKnownPosition();
      
      return {
        'serviceEnabled': serviceEnabled,
        'permission': permission.toString(),
        'hasLastKnown': lastKnown != null,
        'lastKnownAge': lastKnown != null 
          ? DateTime.now().difference(lastKnown.timestamp).inMinutes 
          : null,
      };
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}