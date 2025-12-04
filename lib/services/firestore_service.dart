import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchCollection(String collectionName) async {
    final snapshot = await _db.collection(collectionName).get();
    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> addDocument(String collectionName, Map<String, dynamic> data) async {
    await _db.collection(collectionName).add(data);
  }
}
