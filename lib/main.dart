import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'ui/screens/general_screen.dart';
import 'ui/screens/admin_login_screen.dart';
import 'ui/screens/admin_screen.dart';
import 'ui/screens/maintenance_screen.dart';
import 'ui/widgets/app_initialization_wrapper.dart';
import 'ui/widgets/global_maintenance_listener.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BAS Rituals',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
      ),
      navigatorKey: navigatorKey,
      initialRoute: '/',
      builder: (context, child) {
        return GlobalMaintenanceListener(child: child!);
      },
      routes: {
        '/': (context) => const AppInitializationWrapper(),
        '/app': (context) => const GeneralScreen(),
        '/maintenance': (context) => const MaintenanceScreen(),
        '/admin': (context) => const AdminLoginScreen(),
        '/admin/dashboard': (context) => const AdminScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle any admin routes
        if (settings.name?.startsWith('/admin/') == true && settings.name != '/admin') {
          // All admin routes go to the AdminScreen (has built-in auth)
          return MaterialPageRoute<void>(builder: (context) => const AdminScreen());
        }
        return null;
      },
    );
  }
}
