import 'package:flutter/material.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Support Center',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.deepPurple.shade50,
              Colors.deepPurple.shade100,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How can we help you?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple[500],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our team is here to assist you with any questions or concerns.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.deepPurple.shade700,
                ),
              ),
              const SizedBox(height: 30),

              // Contact Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildContactItem(
                        icon: Icons.email,
                        title: 'Email us at',
                        subtitle: 'support@dhanyasetu.app',
                      ),
                      const Divider(height: 30, thickness: 0.5),
                      _buildContactItem(
                        icon: Icons.phone,
                        title: 'Call us at',
                        subtitle: '+91 98765 43210',
                      ),
                      const Divider(height: 30, thickness: 0.5),
                      _buildContactItem(
                        icon: Icons.access_time,
                        title: 'Working hours',
                        subtitle: 'Mon-Fri, 9AM to 6PM',
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Illustration with improved styling
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Image.asset(
                    'assets/images/support.png',
                    height: 180,
                    color: Colors.deepPurple.withOpacity(0.7),
                    colorBlendMode: BlendMode.srcATop,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Additional help text
              Center(
                child: Text(
                  'We typically respond within 24 hours',
                  style: TextStyle(
                    color: Colors.deepPurple.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.deepPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.deepPurple,
            size: 24,
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.deepPurple.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}