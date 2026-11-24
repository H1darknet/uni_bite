
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';

// Authentication
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'shared/providers/auth_provider.dart';
import 'features/auth/presentation/screens/auth_gate.dart';

// Menu
import 'features/menu/data/datasources/menu_remote_datasource.dart';
import 'features/menu/data/repositories/menu_repository_impl.dart';
import 'features/menu/presentation/providers/menu_provider.dart';

// Cart
import 'features/cart/presentation/providers/cart_provider.dart';

// Orders
import 'features/orders/data/datasources/order_remote_datasource.dart';
import 'features/orders/data/repositories/order_repository_impl.dart';
import 'features/orders/domain/usecases/create_order.dart';
import 'features/orders/presentation/providers/order_provider.dart';
import 'features/orders/presentation/providers/order_history_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const UniBiteApp());
}

class UniBiteApp extends StatelessWidget {
  const UniBiteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Authentication Provider
        ChangeNotifierProvider<AuthProvider>(
          create: (_) {
            final dataSource = AuthRemoteDataSource(
              firebaseAuth: FirebaseAuth.instance,
              firestore: FirebaseFirestore.instance,
            );

            final repository = AuthRepositoryImpl(
              dataSource: dataSource,
            );

            final authProvider = AuthProvider(
              registerUser: RegisterUser(repository),
              loginUser: LoginUser(repository),
              logoutUser: LogoutUser(repository),
              repository: repository,
            );

            authProvider.initialize();

            return authProvider;
          },
        ),

        // Menu Provider
        ChangeNotifierProvider<MenuProvider>(
          create: (_) {
            final dataSource = MenuRemoteDataSource(
              firestore: FirebaseFirestore.instance,
            );

            final repository = MenuRepositoryImpl(
              dataSource: dataSource,
            );

            return MenuProvider(repository: repository);
          },
        ),

        // Cart Provider
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(),
        ),

        // Order Provider
        ChangeNotifierProvider<OrderProvider>(
          create: (_) {
            final dataSource = OrderRemoteDataSource(
              firestore: FirebaseFirestore.instance,
            );

            final repository = OrderRepositoryImpl(
              dataSource: dataSource,
            );

            final createOrder = CreateOrder(repository);

            return OrderProvider(
              createOrderUseCase: createOrder,
            );
          },
        ),

        // Order History Provider
        ChangeNotifierProvider<OrderHistoryProvider>(
          create: (_) {
            final dataSource = OrderRemoteDataSource(
              firestore: FirebaseFirestore.instance,
            );

            final repository = OrderRepositoryImpl(
              dataSource: dataSource,
            );

            return OrderHistoryProvider(
              repository: repository,
            );
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Uni_Bite',
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
