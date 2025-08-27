import 'package:flutter/material.dart';
import 'package:split_bill/src/pages/bill_splitter_page.dart';
import 'package:split_bill/src/themes/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: BillSplitterPage(), theme: AppTheme.light);
  }
}
