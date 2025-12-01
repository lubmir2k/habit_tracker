import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/storage_service.dart';
import '../widgets/app_drawer.dart';

/// Profile screen for viewing and editing user information.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  User? _user;

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _ageController;
  late TextEditingController _countryController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _ageController = TextEditingController();
    _countryController = TextEditingController();
    _loadUser();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final storageService = await StorageService.getInstance();
    final user = storageService.getCurrentUser();

    if (mounted) {
      setState(() {
        _user = user;
        _isLoading = false;
        if (user != null) {
          _populateControllers(user);
        }
      });
    }
  }

  void _populateControllers(User user) {
    _nameController.text = user.name;
    _usernameController.text = user.username;
    _ageController.text = user.age.toString();
    _countryController.text = user.country;
  }

  void _enterEditMode() {
    if (_user != null) {
      _populateControllers(_user!);
    }
    setState(() => _isEditing = true);
  }

  void _cancelEdit() {
    if (_user != null) {
      _populateControllers(_user!);
    }
    setState(() => _isEditing = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final scaffoldMessenger = ScaffoldMessenger.of(context);

    setState(() => _isSaving = true);

    try {
      final updatedUser = _user!.copyWith(
        name: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        country: _countryController.text.trim(),
      );

      final storageService = await StorageService.getInstance();
      final success = await storageService.saveUser(updatedUser);

      if (!mounted) return;

      if (success) {
        setState(() {
          _user = updatedUser;
          _isEditing = false;
          _isSaving = false;
        });
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Profile saved')),
        );
      } else {
        setState(() => _isSaving = false);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('Failed to save profile')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        scaffoldMessenger.showSnackBar(
          const SnackBar(content: Text('An error occurred while saving')),
        );
      }
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    if (value.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(value.trim());
    if (age == null) {
      return 'Please enter a valid number';
    }
    if (age < 1 || age > 120) {
      return 'Age must be between 1 and 120';
    }
    return null;
  }

  String? _validateCountry(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Country is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Profile' : 'Personal Info'),
        actions: _buildAppBarActions(),
      ),
      drawer: _isEditing ? null : const AppDrawer(),
      body: _buildBody(),
    );
  }

  List<Widget>? _buildAppBarActions() {
    if (_isLoading || _user == null) return null;

    if (_isEditing) {
      return [
        TextButton(
          onPressed: _isSaving ? null : _cancelEdit,
          child: const Text('Cancel'),
        ),
      ];
    }

    return [
      IconButton(
        icon: const Icon(Icons.edit),
        onPressed: _enterEditMode,
        tooltip: 'Edit profile',
      ),
    ];
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No user data found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Please log in with a registered account',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 24),
          if (_isEditing) _buildEditForm() else _buildViewCard(),
        ],
      ),
    );
  }

  Widget _buildViewCard() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Name'),
            subtitle: Text(_user!.name),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.alternate_email),
            title: const Text('Username'),
            subtitle: Text(_user!.username),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.cake),
            title: const Text('Age'),
            subtitle: Text(_user!.age.toString()),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('Country'),
            subtitle: Text(_user!.country),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Name',
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: _validateName,
            textInputAction: TextInputAction.next,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Username',
              prefixIcon: Icon(Icons.alternate_email),
              border: OutlineInputBorder(),
            ),
            validator: _validateUsername,
            textInputAction: TextInputAction.next,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: 'Age',
              prefixIcon: Icon(Icons.cake),
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: _validateAge,
            textInputAction: TextInputAction.next,
            enabled: !_isSaving,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country',
              prefixIcon: Icon(Icons.public),
              border: OutlineInputBorder(),
            ),
            validator: _validateCountry,
            textInputAction: TextInputAction.done,
            enabled: !_isSaving,
            onFieldSubmitted: (_) => _saveProfile(),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving ? null : _saveProfile,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}
