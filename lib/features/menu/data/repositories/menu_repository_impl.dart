
import '../../domain/entities/food_entity.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_remote_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource dataSource;

  MenuRepositoryImpl({
    required this.dataSource,
  });

  @override
  Stream<List<FoodEntity>> getFoods() {
    return dataSource.getFoods();
  }

  @override
  Future<List<FoodEntity>> getFoodsOnce() {
    return dataSource.getFoodsOnce();
  }
}
