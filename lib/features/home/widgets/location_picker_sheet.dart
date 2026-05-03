import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:amora/core/constants/colors.dart';
import 'package:amora/features/profile/providers/profile_provider.dart';
import 'package:amora/core/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationPickerSheet extends ConsumerStatefulWidget {
  const LocationPickerSheet({super.key});

  @override
  ConsumerState<LocationPickerSheet> createState() =>
      _LocationPickerSheetState();
}

class _LocationPickerSheetState extends ConsumerState<LocationPickerSheet> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  Future<bool> _ensureCurrentLocationPermission() async {
    final permission = await _locationService.requestLocationPermission();

    if (permission == LocationPermission.denied) {
      await _showPermissionDialog(
        title: 'Location permission required',
        message:
            'Location permission is needed to use your current location. Please allow access when prompted.',
      );
      return false;
    }

    if (permission == LocationPermission.deniedForever) {
      await _showPermissionDialog(
        title: 'Location permission permanently denied',
        message:
            'Location permissions are permanently denied. Please enable them in system settings to continue.',
        showSettingsAction: true,
      );
      return false;
    }

    return true;
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String message,
    bool showSettingsAction = false,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
          if (showSettingsAction)
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await Geolocator.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
        ],
      ),
    );
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      if (!await _ensureCurrentLocationPermission()) {
        return;
      }

      Position? position = await _locationService.getCurrentPosition();
      if (position != null) {
        String? address = await _locationService.getAddressFromLatLng(
          position.latitude,
          position.longitude,
        );

        if (address != null) {
          await _updateLocation(address, position.latitude, position.longitude);
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateLocation(String name, double lat, double lng) async {
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;
    if (profile == null) return;

    final repository = ref.read(profileRepositoryProvider);

    // First, save the current location if it exists and is different from the new one
    final savedLocations = List<Map<String, dynamic>>.from(
      profile.savedLocations,
    );

    if (profile.locationName != null &&
        profile.locationName != name &&
        profile.latitude != null &&
        profile.longitude != null) {
      final currentLocExists = savedLocations.any(
        (loc) => loc['name'] == profile.locationName,
      );
      if (!currentLocExists) {
        savedLocations.add({
          'name': profile.locationName,
          'latitude': profile.latitude,
          'longitude': profile.longitude,
        });
      }
    }

    // Then, add the new location if not already there
    final newLocExists = savedLocations.any((loc) => loc['name'] == name);
    if (!newLocExists) {
      savedLocations.add({'name': name, 'latitude': lat, 'longitude': lng});
    }

    final updatedProfile = profile.copyWith(
      locationName: name,
      latitude: lat,
      longitude: lng,
      savedLocations: savedLocations,
    );

    await repository.updateProfile(updatedProfile);
    ref.invalidate(userProfileProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Relocate',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : _useCurrentLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 56.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            icon: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.my_location),
            label: Text(
              _isLoading ? 'Getting location...' : 'Use Current Location',
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Previous Locations',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16.h),
          profileAsync.when(
            data: (profile) {
              if (profile == null || profile.savedLocations.isEmpty) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.h),
                    child: Text(
                      'No previous locations saved',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: profile.savedLocations.length,
                separatorBuilder: (context, index) => Divider(height: 1.h),
                itemBuilder: (context, index) {
                  final loc = profile.savedLocations[index];
                  final isCurrent = profile.locationName == loc['name'];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.history,
                        color: AppColors.primary,
                        size: 20.w,
                      ),
                    ),
                    title: Text(
                      loc['name'] ?? 'Unknown',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isCurrent ? FontWeight.bold : null,
                        color: isCurrent ? AppColors.primary : null,
                      ),
                    ),
                    trailing: isCurrent
                        ? Icon(
                            Icons.check_circle,
                            color: AppColors.primary,
                            size: 20.w,
                          )
                        : null,
                    onTap: () => _updateLocation(
                      loc['name'],
                      loc['latitude'],
                      loc['longitude'],
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Text('Error: $e'),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}
