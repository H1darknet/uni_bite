
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/food_model.dart';

class MenuRemoteDataSource {
  final FirebaseFirestore firestore;

  MenuRemoteDataSource({
    required this.firestore,
  });

  // Firestore'dagi taomlarni real vaqtda kuzatish
  Stream<List<FoodModel>> getFoods() {
    return firestore
        .collection('foods')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return FoodModel.fromMap(
          doc.id,
          doc.data(),
        );
      }).toList();
    });
  }

  // Taomlarni bir marta olish
  Future<List<FoodModel>> getFoodsOnce() async {
    final snapshot = await firestore
        .collection('foods')
        .get();

    return snapshot.docs.map((doc) {
      return FoodModel.fromMap(
        doc.id,
        doc.data(),
      );
    }).toList();
  }
}
