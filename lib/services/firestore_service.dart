import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addItem(Map<String, dynamic> item) async {
    await _db.collection('items').add(item);
  }

  Future<List<Map<String, dynamic>>> fetchItems() async {
    QuerySnapshot snapshot = await _db.collection('items').get();
    return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }
}