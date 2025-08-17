import 'package:flutter/material.dart';
import '../models/store.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../utils/launch_utils.dart';

class StoreSearchModal extends StatefulWidget {
  const StoreSearchModal({super.key});

  @override
  _StoreSearchModalState createState() => _StoreSearchModalState();
}

class _StoreSearchModalState extends State<StoreSearchModal> {
  final TextEditingController _locationController = TextEditingController();
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  bool _isLoading = false;
  String? _error;
  List<Store> _stores = [];
  int _selectedRadius = 5;
  String _searchLocationDisplay = '';

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _fetchStores(String location, int radius) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _stores = [];
      _searchLocationDisplay = location;
    });

    try {
      final result = await _apiService.fetchStores(location, radius);
      if (mounted) {
        setState(() {
          _stores = result['stores'];
          _searchLocationDisplay = result['location_name'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Replace your _handleCurrentLocationSearch method

  Future<void> _handleCurrentLocationSearch() async {
    print('🎯 User clicked My Location button');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Show location info for debugging
      final locationInfo = await _locationService.getLocationInfo();
      print('🔍 Location Info: $locationInfo');

      print('🔄 Starting location process...');

      // This will try multiple fallback methods
      final position = await _locationService.getCurrentPosition();

      print('✅ Location received: ${position.latitude}, ${position.longitude}');

      if (mounted) {
        final locationString = '${position.latitude},${position.longitude}';
        _locationController.text = 'Your Current Location';

        print('🔍 Fetching stores for location...');
        await _fetchStores(locationString, _selectedRadius);
        print('✅ Process completed successfully');
      }
    } catch (e) {
      print('❌ Location process failed: $e');

      if (mounted) {
        String userFriendlyError = _getLocationErrorMessage(e.toString());

        setState(() {
          _error = userFriendlyError;
        });

        // Show specific help based on error
        if (e.toString().contains('Unable to get your location')) {
          _showLocationTroubleshootDialog();
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Better error messages
  String _getLocationErrorMessage(String error) {
    if (error.contains('services are disabled')) {
      return 'Please turn on GPS/Location services and try again.';
    } else if (error.contains('permission')) {
      return 'Location permission is needed. Please allow and try again.';
    } else if (error.contains('Unable to get your location')) {
      return 'GPS signal is weak. Try moving to an open area or enter location manually.';
    } else if (error.contains('timeout') ||
        error.contains('TimeoutException')) {
      return 'GPS is taking too long. Try going outside or enter location manually.';
    } else {
      return 'Could not get current location. Please try entering your location manually.';
    }
  }

  // Troubleshooting dialog for GPS issues
  void _showLocationTroubleshootDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.gps_not_fixed, color: Colors.orange),
                SizedBox(width: 8),
                Text('GPS Trouble?'),
              ],
            ),
            content: const Text(
              'Having trouble getting your location? Try:\n\n'
              '📍 Go outside or near a window\n'
              '🔄 Turn GPS off and on again\n'
              '📱 Restart location services\n'
              '⏱️ Wait a moment and try again\n'
              '✏️ Or type your city name above\n\n'
              'GPS works best outdoors with clear sky view.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Enter Manually'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Try again after 2 seconds
                  Future.delayed(const Duration(seconds: 2), () {
                    _handleCurrentLocationSearch();
                  });
                },
                child: const Text('Try Again'),
              ),
            ],
          ),
    );
  }

  String _formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()}m';
    }
    return '${distance.toStringAsFixed(1)}km';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 10,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildModalHeader(context, isDark),
              Expanded(
                child: SingleChildScrollView(
                  controller: controller,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSearchInputs(isDark),
                      const SizedBox(height: 16),
                      _buildSearchButtons(),
                      const SizedBox(height: 16),
                      if (_isLoading) _buildLoadingIndicator(),
                      if (!_isLoading && _error != null)
                        _buildErrorContainer(isDark),
                      if (!_isLoading && _stores.isNotEmpty)
                        _buildResultsList(isDark),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Find Medical Stores',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchInputs(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _locationController,
          decoration: InputDecoration(
            hintText: 'Enter location (e.g., Delhi, Mumbai)',
            prefixIcon: const Icon(Icons.location_pin, color: Colors.blue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          readOnly: _isLoading,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.filter_list,
              color: isDark ? Colors.white70 : Colors.black54,
            ),
            const SizedBox(width: 8),
            const Text('Search Radius:', style: TextStyle(fontSize: 14)),
            const SizedBox(width: 8),
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children:
                    [1, 2, 5, 10, 15, 25]
                        .map(
                          (r) => ChoiceChip(
                            label: Text('${r}km'),
                            selected: _selectedRadius == r,
                            onSelected:
                                _isLoading
                                    ? null
                                    : (selected) {
                                      if (selected) {
                                        setState(() {
                                          _selectedRadius = r;
                                        });
                                      }
                                    },
                            selectedColor: Colors.blue,
                            labelStyle: TextStyle(
                              color:
                                  _selectedRadius == r
                                      ? Colors.white
                                      : (isDark
                                          ? Colors.white70
                                          : Colors.black87),
                              fontWeight: FontWeight.w500,
                            ),
                            backgroundColor:
                                isDark ? Colors.grey[700] : Colors.grey[300],
                            elevation: _selectedRadius == r ? 2 : 0,
                          ),
                        )
                        .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.search, size: 18),
            label: const Text('Search'),
            onPressed:
                _isLoading || _locationController.text.isEmpty
                    ? null
                    : () =>
                        _fetchStores(_locationController.text, _selectedRadius),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.my_location, size: 18),
            label: const Text('My Location'),
            onPressed: _isLoading ? null : _handleCurrentLocationSearch,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Column(
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 16),
            Text(
              'Finding nearby medical stores...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorContainer(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.red[900] : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning,
            color: isDark ? Colors.red[300] : Colors.red[900],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                color: isDark ? Colors.red[200] : Colors.red[900],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.blue[900] : Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? Colors.blue[800]! : Colors.blue[300]!,
              width: 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: isDark ? Colors.blue[300] : Colors.blue[900],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Found ${_stores.length} stores within $_selectedRadius km of $_searchLocationDisplay',
                  style: TextStyle(
                    color: isDark ? Colors.blue[200] : Colors.blue[900],
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._stores.map((store) => _buildStoreCard(store, isDark)),
      ],
    );
  }

  Widget _buildStoreCard(Store store, bool isDark) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    store.name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        store.category == 'Clinic'
                            ? Colors.cyan[100]
                            : Colors.green[100],
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    store.category,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          store.category == 'Clinic'
                              ? Colors.cyan[900]
                              : Colors.green[900],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              '📍 ${_formatDistance(store.distance)} away',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on, size: 18, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    store.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white70 : Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (store.openingHours != 'Not available')
              Row(
                children: [
                  const Icon(Icons.access_time, size: 18, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      store.openingHours,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (store.phone != 'Not available')
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Call'),
                      onPressed: () async {
                        try {
                          await launchPhoneDialer(store.phone);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not make a call.'),
                              ),
                            );
                          }
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.grey[700] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'No Phone',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.directions, size: 18),
                    label: const Text('Directions'),
                    onPressed: () async {
                      try {
                        // Updated: Use store name and address instead of user location
                        await launchGoogleMapsDirections(
                          store.name,
                          store.address,
                          userLocation:
                              _searchLocationDisplay, // Optional: pass user location if available
                        );
                      } catch (e) {
                        // Fallback: try the simple search method
                        try {
                          await launchGoogleMapsWithQuery(
                            store.name,
                            store.address,
                          );
                        } catch (e2) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Could not open map. Error: ${e2.toString()}',
                                ),
                                action: SnackBarAction(
                                  label: 'Copy Address',
                                  onPressed: () {
                                    // Optional: copy address to clipboard
                                  },
                                ),
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
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
