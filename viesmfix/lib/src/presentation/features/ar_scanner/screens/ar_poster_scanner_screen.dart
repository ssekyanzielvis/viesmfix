import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// AR-powered movie poster scanner screen
class ARPosterScannerScreen extends ConsumerStatefulWidget {
  const ARPosterScannerScreen({super.key});

  @override
  ConsumerState<ARPosterScannerScreen> createState() =>
      _ARPosterScannerScreenState();
}

class _ARPosterScannerScreenState extends ConsumerState<ARPosterScannerScreen> {
  bool _isScanning = false;
  bool _posterDetected = false;
  String? _detectedMovieTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Poster Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () {
              // TODO: Toggle flash
            },
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () {
              // TODO: Flip camera
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera preview placeholder
          Container(
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 100,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Camera View',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Point at a movie poster to scan',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Scanning frame overlay
          if (_isScanning)
            Center(
              child: Container(
                width: 280,
                height: 400,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _posterDetected ? Colors.green : Colors.white,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    // Corner brackets
                    ..._buildCornerBrackets(
                      _posterDetected ? Colors.green : Colors.white,
                    ),

                    // Scanning animation
                    if (!_posterDetected) _buildScanningAnimation(theme),
                  ],
                ),
              ),
            ),

          // Detection result
          if (_posterDetected && _detectedMovieTitle != null)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: _buildDetectionCard(theme),
            ),

          // Instructions
          if (!_isScanning)
            Positioned(
              bottom: 120,
              left: 20,
              right: 20,
              child: Card(
                color: Colors.black.withOpacity(0.7),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scan Movie Posters',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Point your camera at any movie poster to instantly get info, trailers, and reviews',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Scan button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _toggleScanning,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isScanning ? Colors.red : Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Icon(
                    _isScanning ? Icons.stop : Icons.camera,
                    size: 36,
                    color: _isScanning ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCornerBrackets(Color color) {
    return [
      // Top-left
      Positioned(
        top: 0,
        left: 0,
        child: Icon(Icons.crop_square, size: 40, color: color),
      ),
      // Top-right
      Positioned(
        top: 0,
        right: 0,
        child: Transform.rotate(
          angle: 1.5708, // 90 degrees
          child: Icon(Icons.crop_square, size: 40, color: color),
        ),
      ),
      // Bottom-left
      Positioned(
        bottom: 0,
        left: 0,
        child: Transform.rotate(
          angle: -1.5708, // -90 degrees
          child: Icon(Icons.crop_square, size: 40, color: color),
        ),
      ),
      // Bottom-right
      Positioned(
        bottom: 0,
        right: 0,
        child: Transform.rotate(
          angle: 3.14159, // 180 degrees
          child: Icon(Icons.crop_square, size: 40, color: color),
        ),
      ),
    ];
  }

  Widget _buildScanningAnimation(ThemeData theme) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Positioned(
          top: value * 380,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.blue.withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
      onEnd: () {
        if (_isScanning && !_posterDetected) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildDetectionCard(ThemeData theme) {
    return Card(
      color: Colors.black.withOpacity(0.9),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 48),
            const SizedBox(height: 12),
            Text(
              'Poster Detected!',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _detectedMovieTitle!,
              style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton('View Details', Icons.info_outline, () {
                  // TODO: Navigate to movie details
                }),
                _buildActionButton(
                  'Watch Trailer',
                  Icons.play_circle_outline,
                  () {
                    // TODO: Play trailer
                  },
                ),
                _buildActionButton('Add to List', Icons.add_circle_outline, () {
                  // TODO: Add to watchlist
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _toggleScanning() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        // Simulate detection after 3 seconds
        Future.delayed(const Duration(seconds: 3), () {
          if (_isScanning) {
            setState(() {
              _posterDetected = true;
              _detectedMovieTitle = 'Inception';
            });
          }
        });
      } else {
        _posterDetected = false;
        _detectedMovieTitle = null;
      }
    });
  }
}
