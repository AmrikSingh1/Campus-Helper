import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';  // Add this for PlatformException
import '../../constants/app_colors.dart';
import '../../widgets/custom_button.dart';
import '../../services/auth_service.dart';
import '../../utils/route_transitions.dart';
import '../home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _slideAnimation;

  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Use the AuthService instance for Google Sign-In
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutQuint),
      ),
    );

    // Start animations
    _animationController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Email/Password Sign In
  void _signInWithEmail() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Email sign-in: Starting login process with email: ${_emailController.text.trim()}');
      try {
        // Sign in with email and password using AuthService
        print('Email sign-in: Attempting Firebase authentication via AuthService');
        final userCredential = await _authService.signInWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        print('Email sign-in: Authentication successful');
        
        // Navigate to home screen on successful sign in
        if (mounted) {
          print('Email sign-in: Navigating to home screen');
          Navigator.of(context).pushAndRemoveUntil(
            AppRoutes.createZoomRoute(const HomeScreen()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Auth errors
        print('Email sign-in: FirebaseAuthException: ${e.code} - ${e.message}');
        setState(() {
          _errorMessage = _getMessageFromErrorCode(e.code);
        });
      } catch (e) {
        // Handle general errors
        print('Email sign-in: General error: $e');
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
        });
      } finally {
        // Ensure loading state is reset
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  // Google Sign In
  void _signInWithGoogle() async {
    // Prevent multiple taps
    if (_isLoading) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Show a snackbar to inform the user that sign-in is in progress
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Sign-In in progress...'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFF6946B2),
          ),
        );
      }
      
      final userCredential = await _authService.signInWithGoogle();
      
      // Clear any existing snackbars
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
      }
      
      // If sign-in was canceled or failed
      if (userCredential == null) {
        // Check if the user is signed in anyway (might happen with the fallback method)
        if (_authService.isUserSignedIn()) {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              AppRoutes.createZoomRoute(const HomeScreen()),
              (route) => false,
            );
          }
          return;
        }
        
        setState(() {
          _isLoading = false;
          _errorMessage = 'Google sign-in was canceled. Please try again or use email login.';
        });
        return;
      }
      
      // Navigate to home screen on successful sign in
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          AppRoutes.createZoomRoute(const HomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      // Check if user is signed in despite the error
      if (_authService.isUserSignedIn()) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            AppRoutes.createZoomRoute(const HomeScreen()),
            (route) => false,
          );
        }
        return;
      }
      
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sign-in with Google failed. Please try again or use email login.';
      });
    } finally {
      // Ensure loading state is reset if we're still in this screen
      if (mounted && !_authService.isUserSignedIn()) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Helper function to get user-friendly error messages
  String _getMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'User has been disabled.';
      case 'user-not-found':
        return 'User not found. Please check your email or register.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'too-many-requests':
        return 'Too many unsuccessful login attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'pigeonUserDetails-error':
        return 'There was an issue with Google Sign-In. Please try again or use email login.';
      case 'sign_in_canceled':
        return 'Google sign-in was canceled. Please try again.';
      case 'sign_in_failed':
        return 'Google sign-in failed. Please try again.';
      case 'account-exists-with-different-credential':
        return 'An account already exists with the same email address but different sign-in credentials. Please sign in using the original method.';
      case 'invalid-credential':
        return 'The Google sign-in credentials are invalid. Please try again.';
      case 'operation-not-allowed':
        return 'Google sign-in is not enabled. Please contact support.';
      case 'google-signin-error':
        return 'Google sign-in failed. Please try again or use email login.';
      default:
        return 'An error occurred: $errorCode';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 40),
                    
                    // App Logo with animation
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value),
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6946B2),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6946B2).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.white,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Welcome Text with animation
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.7),
                        child: Text(
                          'Welcome Back!',
                          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: const Color(0xFF6946B2),
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.5),
                        child: Text(
                          'Sign in to continue',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.darkGrey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Error Message (if any)
                    if (_errorMessage != null)
                      FadeTransition(
                        opacity: _fadeInAnimation,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade300),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Colors.red.shade700,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _errorMessage!,
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_errorMessage!.contains('Google sign-in'))
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    "Please try signing in with your email and password instead.",
                                    style: TextStyle(
                                      color: Colors.red.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    
                    // Login Form with animations
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Transform.translate(
                        offset: Offset(0, _slideAnimation.value * 0.3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: InputDecoration(
                                    hintText: 'Email',
                                    prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6946B2)),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF6946B2), width: 1.5),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6946B2)),
                                    helperText: 'At least 6 characters with 1 uppercase, 1 number & 1 special character',
                                    helperMaxLines: 2,
                                    helperStyle: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Color(0xFF6946B2), width: 1.5),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                        color: Colors.grey,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    if (value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    // Check for uppercase letters
                                    if (!RegExp(r'[A-Z]').hasMatch(value)) {
                                      return 'Password must include at least one uppercase letter';
                                    }
                                    // Check for digits
                                    if (!RegExp(r'[0-9]').hasMatch(value)) {
                                      return 'Password must include at least one number';
                                    }
                                    // Check for special characters
                                    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                                      return 'Password must include at least one special character';
                                    }
                                    return null;
                                  },
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Forgot Password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      // Navigate to password reset flow
                                      _showForgotPasswordDialog();
                                    },
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF6946B2),
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(50, 30),
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 28),
                                
                                // IMPROVED: Sign In Button with proper sizing and shadow
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF6946B2).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                        spreadRadius: 0,
                                      )
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signInWithEmail,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6946B2),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      disabledBackgroundColor: Colors.grey.shade300,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // OR Divider
                                Row(
                                  children: [
                                    const Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: AppColors.mediumGrey,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        'OR',
                                        style: TextStyle(
                                          color: AppColors.darkGrey,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Divider(
                                        thickness: 1,
                                        color: AppColors.mediumGrey,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // IMPROVED: Google Sign In Button with proper sizing and alignment
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: OutlinedButton(
                                    onPressed: _isLoading ? null : _signInWithGoogle,
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide.none,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _isLoading 
                                          ? Container(
                                              width: 24,
                                              height: 24,
                                              padding: const EdgeInsets.all(2.0),
                                              child: const CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                                              ),
                                            )
                                          : Image.asset(
                                              'assets/images/google_logo.png',
                                              width: 24,
                                              height: 24,
                                              errorBuilder: (context, error, stackTrace) {
                                                // Fallback if image not found
                                                return const Icon(
                                                  Icons.g_mobiledata,
                                                  size: 28,
                                                  color: Colors.red,
                                                );
                                              },
                                            ),
                                        const SizedBox(width: 16),
                                        Text(
                                          'Sign In with Google',
                                          style: TextStyle(
                                            color: _isLoading ? AppColors.darkGrey.withOpacity(0.5) : AppColors.darkGrey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Create Account Link
                    FadeTransition(
                      opacity: _fadeInAnimation,
                      child: Align(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: TextStyle(color: AppColors.darkGrey),
                            ),
                            TextButton(
                              onPressed: () {
                                // Navigate to sign up screen
                                Navigator.push(
                                  context,
                                  AppRoutes.createSlideRoute(const SignUpScreen()),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF6946B2),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                'Create Account',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      ),
    );
  }

  // Show forgot password dialog
  void _showForgotPasswordDialog() {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool isLoading = false;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Reset Password',
                style: TextStyle(
                  color: Color(0xFF6946B2),
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF6946B2)),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF6946B2), width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    if (isLoading)
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6946B2)),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.darkGrey,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (formKey.currentState!.validate()) {
                      setState(() {
                        isLoading = true;
                      });
                      
                      try {
                        await _auth.sendPasswordResetEmail(
                          email: emailController.text.trim(),
                        );
                        
                        if (mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Password reset email sent. Please check your inbox.'),
                              backgroundColor: const Color(0xFF6946B2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          isLoading = false;
                        });
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6946B2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text('Send Reset Link'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}

// Sign Up Screen
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Sign Up with Email/Password
  void _signUp() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print('Email sign-up: Starting registration process with email: ${_emailController.text.trim()}');
      try {
        // Create user with email and password using AuthService
        print('Email sign-up: Attempting to create user with Firebase via AuthService');
        // Get the AuthService instance
        final AuthService _authService = AuthService();
        await _authService.signUpWithEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );
        
        print('Email sign-up: User created successfully');
        
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully! A verification email has been sent.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        
        // Navigate to home screen on successful sign up
        if (mounted) {
          print('Email sign-up: Navigating to home screen');
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } on FirebaseAuthException catch (e) {
        // Handle specific Firebase Auth errors with detailed messages
        print('Email sign-up: FirebaseAuthException: ${e.code} - ${e.message}');
        String errorMsg = _getDetailedMessageFromErrorCode(e.code);
        setState(() {
          _errorMessage = errorMsg;
        });
        
        // Show error in a SnackBar for better visibility
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      } on PlatformException catch (e) {
        // Handle platform exceptions (often network related)
        print('Email sign-up: PlatformException: ${e.code} - ${e.message}');
        
        // Special handling for PigeonUserDetails error
        if (e.code == 'pigeonUserDetails-error') {
          print('Email sign-up: PigeonUserDetails error detected, but Firebase Auth was successful');
          
          // Show a warning to the user that account was created but with some limitations
          setState(() {
            _errorMessage = _getDetailedMessageFromErrorCode('pigeonUserDetails-error');
          });
          
          // Show a notification
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_getDetailedMessageFromErrorCode('pigeonUserDetails-error')),
                backgroundColor: Colors.orange, // Warning color
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                action: SnackBarAction(
                  label: 'Continue',
                  textColor: Colors.white,
                  onPressed: () {
                    // Navigate to home screen since Firebase Auth was successful
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            );
          }
          
          // Reset loading state
          setState(() {
            _isLoading = false;
          });
          
          // We don't return here to allow the user to decide whether to proceed
        } else {
          setState(() {
            _errorMessage = 'Connection error: ${e.message}. Please check your internet connection.';
          });
        }
      } catch (e) {
        // Handle general errors
        print('Email sign-up: General error: $e');
        
        // Special handling for PigeonUserDetails type error
        if (e.toString().contains('PigeonUserDetails') || 
            e.toString().contains('type \'List<Object?>\'')) {
          print('Email sign-up: Detected PigeonUserDetails type error in general error handler');
          
          setState(() {
            _errorMessage = _getDetailedMessageFromErrorCode('pigeonUserDetails-error');
            _isLoading = false;
          });
          
          // Show info SnackBar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Account created, but some user details couldn\'t be processed.'),
                backgroundColor: Colors.blue,
                duration: Duration(seconds: 5),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Continue',
                  textColor: Colors.white,
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                ),
              ),
            );
          }
        } else {
          setState(() {
            _errorMessage = 'An unexpected error occurred. Please try again later.';
          });
          
          // Show error in a SnackBar
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Registration failed: ${e.toString()}'),
                backgroundColor: Colors.red.shade700,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        }
      } finally {
        // Ensure loading state is reset
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }
  
  // Helper function to get detailed user-friendly error messages for sign-up
  String _getDetailedMessageFromErrorCode(String errorCode) {
    switch (errorCode) {
      case 'email-already-in-use':
        return 'This email address is already associated with an account. Please sign in or use a different email.';
      case 'invalid-email':
        return 'The email address is not valid. Please enter a proper email format (e.g., user@example.com).';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled. Please contact support.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password with at least 6 characters including numbers and special characters.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many unsuccessful attempts. Please try again later or reset your password.';
      case 'user-disabled':
        return 'This user account has been disabled. Please contact support for assistance.';
      case 'pigeonUserDetails-error':
        return 'Your account was created successfully, but there was an issue with user details. You can proceed to sign in.';
      default:
        return 'Error: $errorCode. Please try again or contact support if the issue persists.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error Message (if any)
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Colors.red.shade700,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                
                _errorMessage != null ? const SizedBox(height: 24) : const SizedBox.shrink(),
                
                // Sign Up Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF6946B2)),
                          helperText: 'At least 6 characters with 1 uppercase, 1 number & 1 special character',
                          helperMaxLines: 2,
                          helperStyle: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF6946B2), width: 1.5),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters';
                          }
                          // Check for uppercase letters
                          if (!RegExp(r'[A-Z]').hasMatch(value)) {
                            return 'Password must include at least one uppercase letter';
                          }
                          // Check for digits
                          if (!RegExp(r'[0-9]').hasMatch(value)) {
                            return 'Password must include at least one number';
                          }
                          // Check for special characters
                          if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                            return 'Password must include at least one special character';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Confirm Password Field
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Sign Up Button
                      CustomButton(
                        text: 'Create Account',
                        onPressed: _signUp,
                        isLoading: _isLoading,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Already have an account link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account?',
                            style: TextStyle(color: AppColors.darkGrey),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
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