import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/string_utils.dart';
import 'dart:async';

class ModelViewerScreen extends StatefulWidget {
  final String modelUrl;
  final String category;

  const ModelViewerScreen({
    super.key,
    required this.modelUrl,
    required this.category,
  });

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  Timer? _loadTimeoutTimer;

  @override
  void initState() {
    super.initState();
    
    try {
      _processUrl();
      
      // Add a timeout for loading to hide the indicator after some time
      _loadTimeoutTimer = Timer(const Duration(seconds: 15), () {
        if (mounted && _isLoading) {
          setState(() {
            _isLoading = false;
          });
        }
      });
      
      // Add error detection after a short delay
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted && _isLoading) {
          // Check if model might be having issues loading
          print('Checking model loading status after 5 seconds');
        }
      });
    } catch (e) {
      print('Error during model initialization: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }
  
  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  void _processUrl() {
    try {
      String url = widget.modelUrl.trim();
      
      // Debug raw URL
      print('Processing model URL: $url');
      
      // Handle URL for assets differently
      if (url.startsWith('assets/')) {
        print('Setting up local asset: $url');
      } else {
        print('Setting up remote URL: $url');
      }
      
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    } catch (e) {
      print('Error processing URL: $e');
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _getProcessedModelUrl(String url) {
    // For debugging
    print('Original model URL: $url');
    
    // Handle local asset paths
    if (url.startsWith('assets/')) {
      print('Using local asset: $url');
      return url;
    }
    
    // Remote URL handling
    if (url.startsWith('http://') || url.startsWith('https://')) {
      print('Using remote URL: $url');
      return url;
    }
    
    // If it's not a full URL or asset path, assume it's a relative path from the API
    String processedUrl = url;
    while (processedUrl.startsWith('/')) {
      processedUrl = processedUrl.substring(1);
    }
    
    // Add the CORS anywhere proxy for Meshy API URLs to bypass CORS restrictions
    processedUrl = 'https://api.meshy.ai/$processedUrl';
    
    // For testing, you can use a CORS proxy like:
    // processedUrl = 'https://cors-anywhere.herokuapp.com/https://api.meshy.ai/$processedUrl';
    
    print('Processed URL: $processedUrl');
    return processedUrl;
  }

  void _tryAgain() {
    print('Attempting to reload model: ${widget.modelUrl}');
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    // Process the URL again and force a reload
    _processUrl();
    
    // Set a short timeout to ensure UI updates
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final String modelUrl = _getProcessedModelUrl(widget.modelUrl);
    
    // Add extra debugging for model loading
    print('Final model URL being used: $modelUrl');
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          '${widget.category.capitalize()} Model',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _tryAgain,
            tooltip: 'Reload model',
          ),
          // Add info button to show URL for debugging
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Model Information'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Category: ${widget.category}'),
                        SizedBox(height: 8),
                        Text('Model URL: $modelUrl'),
                        SizedBox(height: 16),
                        Text('Original URL: ${widget.modelUrl}'),
                        SizedBox(height: 16),
                        Text('AR Troubleshooting:', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text('If AR isn\'t working, check that:'),
                        SizedBox(height: 4),
                        Text('• Your device supports ARCore'),
                        SizedBox(height: 4),
                        Text('• ARCore is installed and updated'),
                        SizedBox(height: 4),
                        Text('• Camera permissions are granted'),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Close'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Model Info',
          ),
        ],
      ),
      body: _hasError
          ? _buildErrorWidget()
          : Stack(
              children: [
                ModelViewer(
                  backgroundColor: Colors.white,
                  src: modelUrl,
                  alt: '3D Model',
                  ar: true,
                  autoRotate: true,
                  cameraControls: true,
                  // Important: Add CORS handling to the inner HTML
                  innerModelViewerHtml: 'crossorigin="anonymous"',
                ),
                if (_isLoading) _buildLoadingWidget(),
              ],
            ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.white.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading 3D Model...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a few moments',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to load 3D model',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'There was a problem loading the 3D model. This could be due to network issues or an invalid model file.',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _tryAgain,
                icon: const Icon(Icons.refresh),
                label: Text(
                  'Try Again',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}