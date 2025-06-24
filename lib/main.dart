import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos/data/datasources/auth_remote_datasource.dart';
import 'package:flutter_pos/data/datasources/midtrans_remote_datasource.dart';
import 'package:flutter_pos/data/datasources/order_remote_datasource.dart';
import 'package:flutter_pos/data/datasources/product_local_datasource.dart';
import 'package:flutter_pos/data/datasources/product_remote_datasource.dart';
import 'package:flutter_pos/data/datasources/report_remote_datasource.dart';
import 'package:flutter_pos/data/datasources/discount_remote_datasource.dart';
import 'package:flutter_pos/data/datasources/order_local_datasource.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos/presentation/auth/pages/splash_screen_pages.dart';
import 'package:flutter_pos/presentation/draft_order/bloc/draft_order/draft_order_bloc.dart';
import 'package:flutter_pos/presentation/history/bloc/history/history_bloc.dart';
import 'package:flutter_pos/presentation/home/bloc/category/category_bloc.dart';
import 'package:flutter_pos/presentation/home/bloc/checkout/checkout_bloc.dart';
import 'package:flutter_pos/presentation/home/bloc/product/product_bloc.dart';
import 'package:flutter_pos/presentation/order/bloc/order/order_bloc.dart';
import 'package:flutter_pos/presentation/order/bloc/qris/qris_bloc.dart';
import 'package:flutter_pos/presentation/setting/bloc/report/close_cashier/close_cashier_bloc.dart';
import 'package:flutter_pos/presentation/setting/bloc/report/product_sales/product_sales_bloc.dart';
import 'package:flutter_pos/presentation/setting/bloc/report/summary/summary_bloc.dart';
import 'package:flutter_pos/presentation/setting/bloc/sync_order/sync_order_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/constants/colors.dart';
import 'core/utils/session_manager.dart';
import 'presentation/auth/bloc/login/login_bloc.dart';
import 'presentation/home/bloc/logout/logout_bloc.dart';
import 'presentation/setting/bloc/discount/bloc/discount_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  final isExpired = await SessionManager.isSessionExpired();
  if (isExpired) {
    
    final authLocalDatasource = AuthLocalDatasource();
    await authLocalDatasource.removeAuthData();
  } else {
    
    await SessionManager.updateLastActivity();
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  
  void _handleUserInteraction([_]) {
    SessionManager.updateLastActivity();
  }

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      onTap: _handleUserInteraction,
      behavior: HitTestBehavior.opaque,
      child: _buildAppContent(context),
    );
  }

  Widget _buildAppContent(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => LoginBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => LogoutBloc(AuthRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ProductBloc(ProductRemoteDatasource())
            ..add(const ProductEvent.fetchLocal()),
        ),
        BlocProvider(create: (context) => CheckoutBloc()),
        BlocProvider(
          create: (context) => OrderBloc(
            orderRemoteDatasource: OrderRemoteDatasource(),
            orderLocalDatasource: OrderLocalDatasource.instance,
            discountRemoteDatasource: DiscountRemoteDatasource(),
            authLocalDatasource: AuthLocalDatasource(),
          ),
        ),
        BlocProvider(
          create: (context) => QrisBloc(MidtransRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => HistoryBloc(),
        ),
        BlocProvider(
          create: (context) => SyncOrderBloc(OrderRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CategoryBloc(ProductRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DraftOrderBloc(ProductLocalDatasource.instance),
        ),
        BlocProvider(
          create: (context) => SummaryBloc(ReportRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => ProductSalesBloc(ReportRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => CloseCashierBloc(ReportRemoteDatasource()),
        ),
        BlocProvider(
          create: (context) => DiscountBloc(DiscountRemoteDatasource()),
        ),
      ],
      child: Listener(
        onPointerDown: (_) => _handleUserInteraction(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'POS App',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
            useMaterial3: true,
            textTheme: GoogleFonts.quicksandTextTheme(
              Theme.of(context).textTheme,
            ),
            appBarTheme: AppBarTheme(
              color: AppColors.white,
              elevation: 0,
              titleTextStyle: GoogleFonts.quicksand(
                color: AppColors.primary,
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
              ),
              iconTheme: const IconThemeData(
                color: AppColors.primary,
              ),
            ),
          ),
          home: SplashScreenPages(),
        ),
      ),
    );
  }
}
