
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource dataSource;

  AuthRepositoryImpl({required this.dataSource});

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String password,
  }) {
    return dataSource.register(
      name: name,
      email: email,
      password: password,
    );
  }

  @override
  Future<UserEntity> login({
    required String email,
    required String password,
  }) {
    return dataSource.login(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return dataSource.authStateChanges;
  }
}
