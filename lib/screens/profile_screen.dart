import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = false;
  bool _isLoading = false;


  User? user = FirebaseAuth.instance.currentUser;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _nameController.text = user?.displayName ?? '';

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await user?.updateDisplayName(_nameController.text.trim());
        await user?.reload();
        user = FirebaseAuth.instance.currentUser;

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        _showSuccessSnackBar('Profile updated successfully!');
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to update profile: ${e.toString()}');
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = user?.displayName ?? '';
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.red[600], size: 28),
            const SizedBox(width: 12),
            const Text('Confirm Delete'),
          ],
        ),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone and all your data will be lost.',
          style: TextStyle(fontSize: 16, height: 1.5),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Account'),
            onPressed: () async {
              Navigator.of(context).pop(); // Close the dialog
              await _deleteAccount();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await user?.delete();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/register', (_) => false);
        _showSuccessSnackBar('Account deleted successfully');
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (e.code == 'requires-recent-login') {
        await _showReAuthDialog();
      } else {
        _showErrorSnackBar('Error: ${e.message}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('An unexpected error occurred');
    }
  }

  Future<void> _showReAuthDialog() async {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.security, color: Colors.deepPurple[600]),
            const SizedBox(width: 12),
            const Text('Re-authentication Required'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'For security reasons, please enter your password to continue.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.deepPurple[600]!),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password is required';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isLoading = false;
              });
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm'),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  final cred = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: passwordController.text,
                  );
                  await user!.reauthenticateWithCredential(cred);
                  Navigator.pop(context); // Close dialog

                  // Now delete the account
                  await user!.delete();

                  if (mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/register', (_) => false);
                    _showSuccessSnackBar('Account deleted successfully');
                  }
                } on FirebaseAuthException catch (e) {
                  Navigator.pop(context);
                  setState(() {
                    _isLoading = false;
                  });
                  _showErrorSnackBar('Re-authentication failed: ${e.message}');
                }
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String initial = (user?.displayName?.isNotEmpty ?? false)
        ? user!.displayName![0].toUpperCase()
        : user?.email?[0].toUpperCase() ?? 'U';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple[600]!,
              Colors.deepPurple[400]!,
              Colors.deepPurple[200]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (!_isEditing && !_isLoading)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        tooltip: 'Edit Profile',
                        onPressed: () {
                          setState(() {
                            _isEditing = true;
                          });
                        },
                      ),
                  ],
                ),
              ),

              // Profile Content
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(_slideAnimation),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              const SizedBox(height: 20),

                              // Profile Avatar with Animation
                              Hero(
                                tag: 'profile-avatar',
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.deepPurple.withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundColor: Colors.deepPurple[100],
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: Colors.deepPurple[600],
                                      child: Text(
                                        initial,
                                        style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),

                              // Name Field
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  controller: _nameController,
                                  readOnly: !_isEditing,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: Icon(
                                      Icons.person,
                                      color: Colors.deepPurple[600],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide(
                                        color: Colors.deepPurple[600]!,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: _isEditing
                                        ? Colors.deepPurple[50]
                                        : Colors.grey[100],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().length < 2) {
                                      return 'Enter at least 2 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email Field
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: TextFormField(
                                  initialValue: user?.email ?? '',
                                  readOnly: true,
                                  style: const TextStyle(fontSize: 16),
                                  decoration: InputDecoration(
                                    labelText: 'Email Address',
                                    prefixIcon: Icon(
                                      Icons.email,
                                      color: Colors.deepPurple[600],
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey[100],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Language Dropdown
                              Container(
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.deepPurple.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),

                              ),
                              const SizedBox(height: 40),

                              // Save/Cancel Buttons
                              if (_isEditing)
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.deepPurple.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton.icon(
                                          onPressed: _isLoading ? null : _updateProfile,
                                          icon: _isLoading
                                              ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                            ),
                                          )
                                              : const Icon(Icons.save),
                                          label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.deepPurple[600],
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        onPressed: _isLoading ? null : _cancelEdit,
                                        icon: const Icon(Icons.cancel),
                                        label: const Text('Cancel'),
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.deepPurple[600],
                                          padding: const EdgeInsets.symmetric(vertical: 16),
                                          side: BorderSide(color: Colors.deepPurple[600]!),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                              const SizedBox(height: 60),

                              // Delete Account Button
                              Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton.icon(
                                  onPressed: _isLoading ? null : () => _confirmDelete(context),
                                  icon: _isLoading
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  )
                                      : const Icon(Icons.delete_forever),
                                  label: Text(_isLoading ? 'Processing...' : 'Delete Account'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red[600],
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}