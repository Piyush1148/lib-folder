import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import '../services/meshy_service.dart';
import '../services/firebase_service.dart';
import '../models/model_data.dart';
import 'model_viewer_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/string_utils.dart';
import 'saved_models_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class MeshyScreen extends StatefulWidget {
  const MeshyScreen({super.key});

  @override
  State<MeshyScreen> createState() => _MeshyScreenState();
}

class _MeshyScreenState extends State<MeshyScreen> with SingleTickerProviderStateMixin {
  final MeshyService _meshyService = MeshyService();
  final FirebaseService _firebaseService = FirebaseService();
  final _dio = Dio();
  final _picker = ImagePicker();
  bool _isLoading = false;
  String _status = '';
  String? _taskId;
  Timer? _pollTimer;
  Map<String, dynamic>? _result;
  bool _isCartoonMode = false;
  bool _isStructuralAccuracyMode = false;
  String _selectedCategory = 'Furniture';
  final List<String> _categories = ['Furniture', 'Character', 'Object'];
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _processImage() async {
    try {
      setState(() => _isLoading = true);

      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image == null) {
        setState(() {
          _status = 'No image selected';
          _isLoading = false;
        });
        return;
      }

      setState(() => _status = 'Creating 3D model...');

      // Use the enhanced MeshyService with parameters based on image type
      if (_isCartoonMode) {
        _taskId = await _meshyService.createTask(File(image.path),
            texturePrompt:
                "Vibrant cartoon character with accurate colors and smooth texture",
            topology: "quad",
            targetPolycount: 30000,
            isPBREnabled: true);
      } else if (_isStructuralAccuracyMode) {
        _taskId = await _meshyService.createTask(
          File(image.path),
          topology: "triangle",
          targetPolycount: 80000,
          isPBREnabled: true,
          texturePrompt:
              "Accurate furniture model with precise structure and proportions",
        );
      } else {
        _taskId = await _meshyService.createTask(File(image.path),
            topology: "quad",
            targetPolycount: 30000,
            isPBREnabled: true,
            aiModel: "meshy-4");
      }

      _startPolling();
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 5),
      (timer) async {
        if (_taskId == null) return;

        try {
          final result = await _meshyService.checkStatus(_taskId!);
          
          // Ensure URLs are properly formatted
          if (result['status'] == 'SUCCEEDED') {
            if (result['model_url'] != null && !result['model_url'].toString().startsWith('http')) {
              result['model_url'] = 'https://api.meshy.ai${result['model_url']}';
            }
            if (result['thumbnail_url'] != null && !result['thumbnail_url'].toString().startsWith('http')) {
              result['thumbnail_url'] = 'https://api.meshy.ai${result['thumbnail_url']}';
            }
          }

          // Update the result state
          setState(() {
            _result = result;
          });

          switch (result['status']) {
            case 'SUCCEEDED':
              timer.cancel();
              try {
                await _saveModelToFirebase(result);
                setState(() {
                  _status = 'Complete! Click "View in 3D" to see your model';
                  _isLoading = false;
                });
                
                // Print the model URL for debugging
                print('Model URL: ${result['model_url']}');
              } catch (e) {
                setState(() {
                  _status = 'Model generated but failed to save. Please try again.';
                  _isLoading = false;
                });
              }
              break;
            case 'FAILED':
              timer.cancel();
              setState(() {
                _status = 'Failed: ${result['error'] ?? 'Unknown error occurred'}';
                _isLoading = false;
                _result = null;
              });
              break;
            case 'IN_PROGRESS':
              final progress = result['progress'] ?? 0;
              setState(() {
                _status = progress >= 100 ? 'Finalizing model...' : 'Processing: $progress%';
              });
              break;
            default:
              setState(() => _status = 'Status: ${result['status']}');
          }
        } catch (e) {
          print('Error in polling: $e'); // Add error logging
          timer.cancel();
          setState(() {
            _status = 'Error: $e';
            _isLoading = false;
            _result = null;
          });
        }
      },
    );
  }

  Future<void> _saveModelToFirebase(Map<String, dynamic> result) async {
    try {
      final modelData = ModelData(
        id: _taskId!,
        modelUrl: result['model_url'],
        thumbnailUrl: result['thumbnail_url'],
        userId: FirebaseAuth.instance.currentUser!.uid,
        createdAt: DateTime.now(),
        category: _selectedCategory,
        tags: [],
      );
      await _firebaseService.saveModelData(modelData);
    } catch (e) {
      print('Failed to save model to Firebase: $e');
      throw e; // Rethrow to handle in _startPolling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          '3D Generator',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: TextButton.icon(
              onPressed: () {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  print('Navigating to SavedModelsScreen with userId: ${user.uid}');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SavedModelsScreen(userId: user.uid),
                    ),
                  ).then((_) {
                    // Refresh state when returning from history
                    setState(() {});
                    print('Returned from SavedModelsScreen');
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('You need to be logged in to view history')),
                  );
                }
              },
              icon: const Icon(Icons.history, color: Colors.white),
              label: Text(
                'History',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Greeting Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E88E5), Color(0xFF64B5F6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getGreeting(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          FirebaseAuth.instance.currentUser?.displayName ?? 'User',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Mode Selection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Processing Mode',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildModeSwitch(
                          'Cartoon/Character Mode',
                          'Optimized for character and cartoon-style models',
                          _isCartoonMode,
                          (value) => setState(() => _isCartoonMode = value),
                        ),
                        const SizedBox(height: 16),
                        _buildModeSwitch(
                          'Structural Accuracy Mode',
                          'Enhanced precision for architectural and mechanical models',
                          _isStructuralAccuracyMode,
                          (value) => setState(() => _isStructuralAccuracyMode = value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Category Selection Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Category',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[300]!),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              items: _categories.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: GoogleFonts.poppins(
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  setState(() {
                                    _selectedCategory = newValue;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Generate Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _processImage,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFF1E88E5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Generate 3D Model',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Status Section
                  if (_status.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            _status,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: Colors.grey[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          if (_result != null) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                _result!['thumbnail_url'],
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                // Ensure the model URL is properly formatted
                                String modelUrl = _result!['model_url'];
                                print('Opening model URL: $modelUrl');
                                
                                // Navigate to the ModelViewerScreen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ModelViewerScreen(
                                      modelUrl: modelUrl,
                                      category: _selectedCategory,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.view_in_ar, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'View In Your Space',
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeSwitch(String title, String description, bool value, Function(bool) onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF1E88E5),
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }
}