import 'package:conquest/core/theme/app_colors.dart';
import 'package:conquest/core/validators/input_validators.dart';
import 'package:conquest/presentation/viewmodels/auth_viewmodel.dart';
import 'package:conquest/presentation/views/shared_widgets/app_text_field.dart';
import 'package:conquest/presentation/views/shared_widgets/glass_container.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fade;

  final _fullnameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _fullnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    setState(() {
      _fullNameError = InputValidators.validateFullName(
        _fullnameController.text,
      );

      _emailError = InputValidators.validateEmail(_emailController.text);

      _passwordError = InputValidators.validatePassword(
        _passwordController.text,
      );
    });

    if (_fullNameError != null ||
        _emailError != null ||
        _passwordError != null) {
      return;
    }

    FocusScope.of(context).unfocus();

    ref
        .read(authViewModelProvider.notifier)
        .register(
          _fullnameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    ref.listen(authViewModelProvider, (previous, next) {
      if (previous is! AsyncLoading) return;

      next.when(
        data: (success) {
          if (success) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
        },
        loading: () {},
        error: (e, _) {
          if (e is DioException &&
              e.response?.statusCode == 400 &&
              e.response?.data['detail'] == 'Email already registered') {
            setState(() {
              _emailError = 'Email already registered';
            });
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registration Failed')),
            );
          }
        },
      );
    });

    return Scaffold(
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          Positioned(
            bottom: -(screenHeight * 0.75),
            left: -(screenWidth),
            child: Hero(
              tag: 'logo',
              child: SvgPicture.asset(
                'assets/images/logo_screen.svg',
                width: screenWidth * 3,
              ),
            ),
          ),
          FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: SizedBox(
                height: screenHeight,
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: GlassContainer(
                        borderRadius: 24,
                        blur: 100,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 30,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'sign up',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontFamily: 'Vertigo',
                                  letterSpacing: 10,
                                ),
                              ),
                              const SizedBox(height: 32),
                              AppTextField(
                                label: 'Full Name',
                                controller: _fullnameController,
                                iconAsset: 'assets/icons/profile.svg',
                                maxLength: 20,
                                error: _fullNameError,
                              ),
                              const SizedBox(height: 16),

                              AppTextField(
                                label: 'Email',
                                controller: _emailController,
                                iconAsset: 'assets/icons/email.svg',
                                keyboardType: TextInputType.emailAddress,
                                maxLength: 254,
                                error: _emailError,
                              ),
                              const SizedBox(height: 16),

                              AppTextField(
                                label: 'Password',
                                maxLength: 16,
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                error: _passwordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:
                                      ref.watch(authViewModelProvider).isLoading
                                      ? null
                                      : _register,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.greenish_3,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      ref.watch(authViewModelProvider).isLoading
                                      ? const CupertinoActivityIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Sign Up',
                                          style: TextStyle(color: Colors.white),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
