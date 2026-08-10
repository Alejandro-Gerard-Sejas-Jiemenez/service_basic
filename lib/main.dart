import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'data/repositories/expense_repository.dart';
import 'ui/core/theme.dart';
import 'ui/features/home/view_models/expense_view_model.dart';
import 'ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize spanish date formatting symbols
  await initializeDateFormatting('es', null);
  
  final repository = ExpenseRepository();
  final viewModel = ExpenseViewModel(repository: repository);
  
  runApp(MyApp(viewModel: viewModel));
}

class MyApp extends StatelessWidget {
  final ExpenseViewModel viewModel;

  const MyApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Servicios Básicos',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', ''), // Spanish
        Locale('en', ''), // English
      ],
      home: HomeView(viewModel: viewModel),
    );
  }
}
