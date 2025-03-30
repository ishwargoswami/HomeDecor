import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/user_model.dart';
import 'package:flutter_foodybite/screens/login_screen.dart';
import 'package:flutter_foodybite/services/auth_provider.dart';
import 'package:provider/provider.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userStream = authProvider.userStream;
    
    return StreamBuilder<UserModel?>(
      stream: userStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final user = snapshot.data;
          return _buildProfileContent(context, user, authProvider);
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel? user, AuthProvider authProvider) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 20),
          // Profile header with user info
          _buildProfileHeader(context, user),
          
          SizedBox(height: 20),
          // Profile options
          _buildProfileOptions(context, authProvider),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserModel? user) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                ? NetworkImage(user.photoUrl!) as ImageProvider
                : AssetImage('assets/profile.png'),
            child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: 60,
                    color: Theme.of(context).colorScheme.secondary,
                  )
                : null,
          ),
          SizedBox(height: 15),
          
          // User name
          Text(
            user?.name ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: 5),
          
          // User email
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          
          SizedBox(height: 15),
          
          // Edit profile button
          OutlinedButton.icon(
            onPressed: () {
              // TODO: Implement edit profile functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Edit profile functionality coming soon")),
              );
            },
            icon: Icon(Icons.edit),
            label: Text("Edit Profile"),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context, AuthProvider authProvider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildOptionTile(
            context,
            icon: Icons.favorite_border,
            title: "Favorite Restaurants",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Favorites functionality coming soon")),
              );
            },
          ),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.payment,
            title: "Payment Methods",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Payment methods functionality coming soon")),
              );
            },
          ),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.notifications_none,
            title: "Notifications",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Notifications functionality coming soon")),
              );
            },
          ),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: "Help Center",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Help center functionality coming soon")),
              );
            },
          ),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.info_outline,
            title: "About Us",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("About us functionality coming soon")),
              );
            },
          ),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.exit_to_app,
            title: "Log Out",
            isLogout: true,
            onTap: () async {
              // Show confirmation dialog
              bool? confirm = await _showLogoutConfirmationDialog(context);
              
              if (confirm == true) {
                await authProvider.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red : null,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isLogout ? Colors.red : null,
          fontWeight: isLogout ? FontWeight.bold : null,
        ),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1);
  }

  Future<bool?> _showLogoutConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log Out"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                "Log Out",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
