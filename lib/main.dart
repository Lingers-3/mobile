import 'package:flutter/material.dart';
import 'package:pocketeer_mobile/providers/item_provider.dart';
import 'package:pocketeer_mobile/providers/tag_provider.dart';
import 'package:provider/provider.dart';
import 'package:pocketeer_mobile/routes/app_router.dart';
import 'package:pocketeer_mobile/providers/item_type_provider.dart';
import 'package:pocketeer_mobile/providers/resource_reservation_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ItemTypeProvider()),
        ChangeNotifierProvider(create: (_) => ItemProvider()),
        ChangeNotifierProvider(create: (_) => TagProvider()),
        ChangeNotifierProvider(create: (_) => ResourceReservationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocketeer',
      debugShowCheckedModeBanner: false,
      onGenerateRoute: AppRouter.generate,
      initialRoute: AppRouter.authGate,

      builder: (context, child) {
        return child!;
      },
    );
  }
}
