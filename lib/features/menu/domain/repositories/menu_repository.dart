
import '../entities/food_entity.dart';

abstract class MenuRepository {
  Stream<List<FoodEntity>> getFoods();

  Future<List<FoodEntity>> getFoodsOnce();
}
