import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'repositories/vape_repository.dart';
import 'theme/app_theme.dart';
import 'views/vape_dashboard_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);

  final repository = VapeRepository();
  runApp(VapeManagementApp(repository: repository));
}

class VapeManagementApp extends StatelessWidget {
  final VapeRepository repository;

  const VapeManagementApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vape Management',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: VapeDashboardView(repository: repository),
    );
  }
}
