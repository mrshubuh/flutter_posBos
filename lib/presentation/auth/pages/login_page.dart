import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pos/core/utils/snackbar_utils.dart';
import 'package:flutter_pos/data/datasources/auth_local_datasource.dart';
import 'package:flutter_pos/presentation/auth/bloc/login/login_bloc.dart';

import '../../../core/components/buttons.dart';
import '../../../core/constants/colors.dart';
import '../../home/pages/dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 80.0),
                Image.asset(
                  'assets/logo/logor.png',
                  width: 200,
                  height: 200,
                  fit: BoxFit.contain,
                ),
                // const Text(
                //   "POS",
                //   style: TextStyle(
                //     fontSize: 32,
                //     fontWeight: FontWeight.bold,
                //     color: Colors.black,
                //   ),
                // ),
                // const SizedBox(height: 8.0),
                const Text(
                  'Login to your account',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 40.0),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    prefixIcon: const Icon(Icons.email, color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12.0),
                // CustomTextField(
                //   controller: passwordController,
                //   label: 'Password',
                //   obscureText: true,
                // ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: Colors.grey.withValues(alpha: 0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                  ),
                  style: const TextStyle(color: Colors.black),
                  obscureText: true,
                ),
                const SizedBox(height: 24.0),
                BlocListener<LoginBloc, LoginState>(
                  listener: (context, state) {
                    state.maybeWhen(
                      orElse: () {},
                      success: (authResponseModel) {
                        AuthLocalDatasource().saveAuthData(authResponseModel);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DashboardPage(),
                          ),
                        );
                      },
                      error: (message) {
                        SnackbarUtils(
                          text: message,
                          backgroundColor: Colors.red,
                        ).showErrorSnackBar(context);
                      },
                    );
                  },
                  child: BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      return state.maybeWhen(
                        orElse: () {
                          return Button.filled(
                            onPressed: () {
                              context.read<LoginBloc>().add(
                                    LoginEvent.login(
                                      email: usernameController.text,
                                      password: passwordController.text,
                                    ),
                                  );
                            },
                            label: 'Login',
                          );
                        },
                        loading: () {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
