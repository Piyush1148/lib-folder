import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product.dart';
import 'dart:async';

class ViewIn3DScreen extends StatefulWidget {
  final Product product;
  
  const ViewIn3DScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ViewIn3DScreen> createState() => _ViewIn3DScreenState();
}

class _ViewIn3DScreenState extends State<ViewIn3DScreen> {
  bool _isLoading = true;
  bool _hasError = false;
  late Timer _loadTimeoutTimer;

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
  Widget build(BuildContext context) {
    final String modelUrl = _getProcessedModelUrl(widget.product.model);
    
    // Add extra debugging for model loading
    print('Final model URL being used: $modelUrl');
    print('Is local asset: ${widget.product.model.startsWith('assets/')}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.product.category} Model',
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
                        Text('Product: ${widget.product.title}'),
                        SizedBox(height: 8),
                        Text('Model URL: $modelUrl'),
                        SizedBox(height: 8),
                        Text('Category: ${widget.product.category}'),
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
                // Add key to force reload when URL changes
                ModelViewer(
                  key: ValueKey(modelUrl),
                  src: modelUrl,
                  alt: '3D Model Viewer',
                  ar: true,
                  autoRotate: true,
                  cameraControls: true,
                  disableZoom: false,
                  shadowIntensity: 1,
                  backgroundColor: const Color(0xFFF5F5F5),
                ),
                if (_isLoading) _buildLoadingWidget(),
              ],
            ),
    );
  }
  
  @override
  void dispose() {
    _loadTimeoutTimer?.cancel();
    super.dispose();
  }

  void _processUrl() {
    try {
      String url = widget.product.model.trim();
      
      // Debug raw URL
      print('Processing product model URL: $url');
      
      // Handle URL for assets differently
      if (url.startsWith('assets/')) {
        print('Setting up local asset: $url');
        // For ModelViewer, configure with the file name for local assets
        // This sets up the correct context for ModelViewer
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
    
    // Handle local asset paths - this is the key issue we're fixing
    if (url.startsWith('assets/')) {
      print('Using local asset: $url');
      
      // For local assets in model_viewer_plus, we need to ensure proper loading in WebView
      // This approach should work for most Android devices
      // Option 1: Direct path mapping for Android
      return url;
      
      // Note: The above approach uses the Flutter asset system directly.
      // If this doesn't work, uncomment one of these alternative approaches:
      
      /*
      // Option 2: Using android_asset protocol
      // String processedUrl = 'file:///android_asset/flutter_assets/' + url;
      // print('Converted local asset to: $processedUrl');
      // return processedUrl;
      */
      
      /*
      // Option 3: Using a direct web URL for GLB files (if you host your models online)
      // String modelName = url.split('/').last;
      // String processedUrl = 'https://your-cdn.com/models/$modelName';
      // print('Using CDN URL: $processedUrl');
      // return processedUrl;
      */
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
    processedUrl = 'https://api.meshy.ai/$processedUrl';
    print('Processed URL: $processedUrl');
    
    return processedUrl;
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
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'An error occurred while loading the 3D model.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _tryAgain,
            child: Text('Try Again'),
          ),
        ],
      ),
    );
  }

  void _tryAgain() {
    print('Attempting to reload model: ${widget.product.model}');
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    // Process the URL again and force a reload
    _processUrl();
    
    // Set a short timeout to ensure UI updates and we don't hang indefinitely
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    });
  }
}