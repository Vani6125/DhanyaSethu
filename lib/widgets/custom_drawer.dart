import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/logout_screen.dart';


class CustomDrawer extends StatelessWidget {
  final User? user;
  final BuildContext context;

  const CustomDrawer({
    super.key,
    required this.user,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade700,
                    Colors.deepPurple.shade500,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Text(
                  'Welcome ${user?.displayName ?? 'No Name'}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              accountEmail: Text(
                user?.email ?? 'No Email',
                style: const TextStyle(fontSize: 18),
              ),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade200,
                  child: Text(
                    (user?.displayName?.isNotEmpty ?? false)
                        ? user!.displayName![0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 28,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            _buildDrawerItem(
              icon: Icons.person,
              title: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _buildDrawerItem(
              icon: Icons.info_outline,
              title: 'About',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/about');
              },
            ),
            _buildDrawerItem(
              icon: Icons.support_agent,
              title: 'Support',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/support');
              },
            ),
            Divider(
              color: Colors.deepPurple.shade200,
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Logout',
              onTap: ()  {

                 showLogoutDialog(context); // Use your existing dialog function
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.deepPurple.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.deepPurple.shade800,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      tileColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}