import 'package:cloud_firestore/cloud_firestore.dart';

class HomeProvider {
  final FirebaseFirestore firebaseFirestore;

  HomeProvider({required this.firebaseFirestore});

  Future<void> updateDataFirestore(
      String collectionPath, String path, Map<String, String> dataNeedUpdate) {
    return firebaseFirestore
        .collection(collectionPath)
        .doc(path)
        .update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFireStore(
      String pathCollection, int limit, String userId) {
    return firebaseFirestore
        .collection(pathCollection)
        .doc(userId)
        .collection(userId)
        .limit(limit)
        .snapshots();
  }
}
