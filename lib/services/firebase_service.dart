import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/model_data.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  String _sanitizeUrl(String url) {
    if (url.isEmpty) return url;
    
    // Ensure the URL has a proper HTTP/HTTPS prefix
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      // Remove any leading slashes
      while (url.startsWith('/')) {
        url = url.substring(1);
      }
      url = 'https://api.meshy.ai/$url';
    }
    
    // Replace spaces with URL encoding
    url = url.replaceAll(' ', '%20');
    
    return url;
  }
  
  Future<void> saveModelData(ModelData modelData) async {
    try {
      // Sanitize URLs before storing
      final String sanitizedModelUrl = _sanitizeUrl(modelData.modelUrl);
      final String sanitizedThumbnailUrl = _sanitizeUrl(modelData.thumbnailUrl);
      
      await _firestore
          .collection('users')
          .doc(modelData.userId)
          .collection('models')
          .doc(modelData.id)
          .set({
        'id': modelData.id,
        'modelUrl': sanitizedModelUrl,
        'thumbnailUrl': sanitizedThumbnailUrl,
        'category': modelData.category,
        'createdAt': Timestamp.fromDate(modelData.createdAt),
        'tags': modelData.tags,
      });
      
      print('Saved model to Firebase: $sanitizedModelUrl');
    } catch (e) {
      print('Error saving model data: $e');
      throw Exception('Failed to save model data: $e');
    }
  }

  Stream<QuerySnapshot> getUserModels(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('models')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> toggleFavorite(String userId, String modelId) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({'favorites': [modelId]});
      } else {
        List<String> favorites = List<String>.from(userDoc.data()?['favorites'] ?? []);
        
        if (favorites.contains(modelId)) {
          favorites.remove(modelId);
        } else {
          favorites.add(modelId);
        }

        await userRef.update({'favorites': favorites});
      }
    } catch (e) {
      throw Exception('Failed to update favorites: $e');
    }
  }

  Stream<List<String>> getFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .snapshots()
        .map((doc) => List<String>.from(doc.data()?['favorites'] ?? []));
  }

  Future<void> deleteModel(String userId, String modelId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('models')
          .doc(modelId)
          .delete();
    } catch (e) {
      print('Error deleting model: $e');
      throw Exception('Failed to delete model: $e');
    }
  }
}