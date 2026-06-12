import 'dart:convert';
import 'dart:developer';
import 'package:conquest/core/constants/app_constants.dart';
import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/data/models/gps_model.dart';
import 'package:conquest/presentation/viewmodels/map_viewmodel.dart';
import 'package:conquest/presentation/views/map/widgets/expanded_session_card.dart';
import 'package:conquest/presentation/views/map/widgets/map_top_bar.dart';
import 'package:conquest/presentation/views/map/widgets/session_card.dart';
import 'package:conquest/presentation/views/map/widgets/session_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final _mapController = MapController();
  LatLng? _currentLocation;
  LatLng? _initialCenter;
  bool _mapReady = false;
  bool _isExpanded = false;
  bool _locating = true;

  @override
  void initState() {
    super.initState();
    _initLocation();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mapProvider.notifier).checkPermissions();
    });
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.enabled) {
        _initLocation();
      }
    });
  }

  Future<void> _initLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _initialCenter = _currentLocation;
          _locating = false;
        });
        if (_mapReady) _safeMoveMap(_currentLocation!, 15);
      }
      return;
    } catch (e) {
      log('Live location failed: $e', name: 'MapScreen');
    }

    if (mounted && _initialCenter == null) {
      final ipLocation = await _getIpLocation();
      if (ipLocation != null && mounted) {
        setState(() {
          _initialCenter = ipLocation;
        });
      }
    }

    if (mounted) setState(() => _locating = false);
  }

  Future<LatLng?> _getIpLocation() async {
    try {
      final response = await http.get(Uri.parse('http://ip-api.com/json/'));
      final data = jsonDecode(response.body);
      if (data['status'] != 'success') return null;
      return LatLng(
        (data['lat'] as num).toDouble(),
        (data['lon'] as num).toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  void _safeMoveMap(LatLng point, double zoom) {
    if (!point.latitude.isFinite || !point.longitude.isFinite) return;
    if (!_mapReady) return;
    _mapController.move(point, zoom);
  }

  void _flyToSession(GpsSession session) {
    if (session.points.isEmpty) return;

    if (session.points.length == 1) {
      _safeMoveMap(session.latLngs.first, 16);
      return;
    }

    final latlngs = session.latLngs;
    final allSame = latlngs.every(
      (p) =>
          p.latitude == latlngs.first.latitude &&
          p.longitude == latlngs.first.longitude,
    );

    if (allSame) {
      _safeMoveMap(latlngs.first, 16);
      return;
    }

    try {
      final bounds = LatLngBounds.fromPoints(latlngs);
      _mapController.fitCamera(
        CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(60)),
      );
    } catch (e) {
      _safeMoveMap(latlngs.first, 15);
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final screenWidth = MediaQuery.of(context).size.width;

    ref.listen(mapProvider, (prev, next) {
      if (!_mapReady) return;
      if (next.focusedSession != null &&
          prev?.focusedSession?.sessionId != next.focusedSession?.sessionId) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (mounted) _flyToSession(next.focusedSession!);
        });
      }
    });

    return Theme(
      data: ThemeData.light(),
      child: Scaffold(
        body: Stack(
          children: [
            if (_locating)
              const Positioned.fill(
                child: Center(
                  child: CupertinoActivityIndicator(
                    radius: 12,
                    color: AppColors.greenish_4,
                  ),
                ),
              )
            else if (_initialCenter == null)
              Positioned.fill(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_off,
                        size: 48,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Enable location to use the map',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => Geolocator.openLocationSettings(),
                        child: const Text('Open Settings'),
                      ),
                    ],
                  ),
                ),
              )
            else
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _initialCenter!,
                  initialZoom: 15,
                  onMapReady: () {
                    _mapReady = true;
                    if (_currentLocation != null) {
                      _safeMoveMap(_currentLocation!, 15);
                    }
                  },
                  onTap: (_, __) {
                    setState(() {
                      _isExpanded = false;
                    });
                    ref.read(mapProvider.notifier).clearFocus();
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.yourapp.conquest',
                    maxZoom: 19,
                    maxNativeZoom: 19,
                  ),

                  if (state.dayLog != null)
                    PolylineLayer(
                      polylines: state.dayLog!.sessions
                          .where((s) => s.points.isNotEmpty)
                          .where(
                            (s) => s.latLngs.every(
                              (p) =>
                                  p.latitude.isFinite && p.longitude.isFinite,
                            ),
                          )
                          .where(
                            (s) =>
                                s.sessionId != state.focusedSession?.sessionId,
                          )
                          .map(
                            (s) => Polyline(
                              points: s.latLngs,
                              color: AppColors.greenish_3.withValues(
                                alpha: 0.5,
                              ),
                              strokeWidth: 4,
                              pattern: StrokePattern.dashed(segments: [8, 6]),
                            ),
                          )
                          .toList(),
                    ),

                  if (state.focusedSession != null &&
                      state.focusedSession!.points.isNotEmpty &&
                      state.focusedSession!.latLngs.every(
                        (p) => p.latitude.isFinite && p.longitude.isFinite,
                      ))
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.focusedSession!.latLngs,
                          color: AppColors.greenish_3,
                          strokeWidth: 4,
                        ),
                      ],
                    ),

                  if (state.isTracking && state.currentPoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: state.currentPoints
                              .map((p) => p.toLatLng())
                              .toList(),
                          color: AppColors.greenish_3,
                          strokeWidth: 4,
                        ),
                      ],
                    ),

                  if (_currentLocation != null &&
                      _currentLocation!.latitude.isFinite &&
                      _currentLocation!.longitude.isFinite)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation!,
                          width: screenWidth * 0.12,
                          height: screenWidth * 0.12,
                          child: Image.asset(
                            'assets/images/character/stand_0.png',
                            filterQuality: FilterQuality.none,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                ],
              ),

            const Positioned(top: 0, left: 0, right: 0, child: MapTopBar()),

            if (_initialCenter != null &&
                !state.isTracking &&
                state.focusedSession == null)
              Positioned(
                bottom: AppConstants.navBarBottomPadding(context),
                right: 16,
                width: 150,
                child: SessionList(),
              ),

            if (_initialCenter != null &&
                state.focusedSession != null &&
                !_isExpanded)
              Positioned(
                bottom: AppConstants.navBarBottomPadding(context),
                right: 16,
                width: 150,
                child: SessionCard(
                  session: state.focusedSession!,
                  onExpand: () => setState(() => _isExpanded = true),
                ),
              ),

            if (_initialCenter != null &&
                state.focusedSession != null &&
                _isExpanded)
              Center(
                child: SizedBox(
                  width: 250,
                  child: ExpandedCard(
                    session: state.focusedSession!,
                    onCollapse: () => setState(() => _isExpanded = false),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
