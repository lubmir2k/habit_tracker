import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/user.dart';
import '../services/storage_service.dart';

/// Registration screen for new user account creation.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _ageController = TextEditingController();
  final _countryController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Prebuilt habits selection
  final Map<String, bool> _prebuiltHabits = {
    for (var habit in AppConstants.prebuiltHabits) habit: false,
  };

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.length < AppConstants.minUsernameLength) {
      return 'Username must be at least ${AppConstants.minUsernameLength} characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }
    if (age < AppConstants.minAge || age > AppConstants.maxAge) {
      return 'Age must be between ${AppConstants.minAge} and ${AppConstants.maxAge}';
    }
    return null;
  }

  String? _validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Country is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < AppConstants.minPasswordLength) {
      return 'Password must be at least ${AppConstants.minPasswordLength} characters';
    }
    return null;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final storageService = await StorageService.getInstance();

      // Check if username already exists
      if (storageService.userExists(_usernameController.text.trim())) {
        if (!mounted) return;
        _showError('Username already exists');
        return;
      }

      // Get selected prebuilt habits
      final selectedHabits = _prebuiltHabits.entries
          .where((entry) => entry.value)
          .map((entry) => entry.key)
          .toList();

      final user = User(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        country: _countryController.text.trim(),
        password: _passwordController.text,
        prebuiltHabits: selectedHabits.isNotEmpty ? selectedHabits : null,
      );

      final success = await storageService.saveUser(user);

      if (success && mounted) {
        _showSuccess('Registration successful! Please login.');
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        _showError('Failed to save user data');
      }
    } catch (e) {
      _showError('An error occurred during registration');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // App Logo/Name
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Create your account',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _validateName,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    prefixIcon: Icon(Icons.account_circle_outlined),
                  ),
                  validator: _validateUsername,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Age Field
                TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                  keyboardType: TextInputType.number,
                  validator: _validateAge,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),

                // Country Field
                TextFormField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.public),
                  ),
                  validator: _validateCountry,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 16),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 24),

                // Prebuilt Habits Section
                Text(
                  'Start with these habits (optional):',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _prebuiltHabits.keys.map((habit) {
                    return FilterChip(
                      label: Text(habit),
                      selected: _prebuiltHabits[habit]!,
                      onSelected: (selected) {
                        setState(() => _prebuiltHabits[habit] = selected);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),

                // Sign Up Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign Up'),
                ),
                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? "),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
