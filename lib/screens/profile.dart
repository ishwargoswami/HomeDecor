import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/user_model.dart';
import 'package:flutter_foodybite/screens/login_screen.dart';
import 'package:flutter_foodybite/services/auth_provider.dart';
import 'package:flutter_foodybite/services/theme_provider.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
          
          // Backup and Sync section
          SizedBox(height: 20),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 4,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Data & Sync",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 15),
                  Consumer<DecorProvider>(
                    builder: (context, provider, child) {
                      return ListTile(
                        leading: Icon(
                          Icons.sync,
                          color: provider.isSyncing
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey[600],
                        ),
                        title: Text("Sync Data"),
                        subtitle: Text(
                          provider.isSyncing
                              ? "Syncing in progress..."
                              : "Last sync: Recently",
                        ),
                        trailing: provider.isSyncing
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                              )
                            : Icon(Icons.navigate_next),
                        onTap: provider.isSyncing
                            ? null
                            : () async {
                                await provider.forceSyncData();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Data synced successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                      );
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(
                      Icons.cloud_done,
                      color: Colors.grey[600],
                    ),
                    title: Text("Backup Data"),
                    subtitle: Text("Save your projects and items"),
                    trailing: Icon(Icons.navigate_next),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Your data is automatically backed up in the cloud'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
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
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                child: ClipOval(
                  child: SizedBox(
                    width: 120,
                    height: 120,
                    child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: user.photoUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) {
                              print('Error loading profile image: $error');
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.secondary,
                              );
                            },
                          )
                        : Image.asset(
                            'assets/profile.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.person,
                                size: 60,
                                color: Theme.of(context).colorScheme.secondary,
                              );
                            },
                          ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () => _updateProfileImage(context),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
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
            onPressed: () => _showEditProfileDialog(context, user),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Theme toggle option
          _buildThemeToggle(context, themeProvider),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.favorite_border,
            title: "Favorite Restaurants",
            onTap: () => _showFavoritesScreen(context),
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
            onTap: () => _showNotificationsScreen(context),
          ),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.help_outline,
            title: "Help Center",
            onTap: () => _showHelpCenterDialog(context),
          ),
          _buildDivider(),
          
          _buildOptionTile(
            context,
            icon: Icons.info_outline,
            title: "About Us",
            onTap: () => _showAboutUsDialog(context),
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

  Future<void> _updateProfileImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final user = authProvider.user;
      
      if (user != null) {
        try {
          // Show loading dialog
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Dialog(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 20),
                      Text("Uploading image..."),
                    ],
                  ),
                ),
              );
            },
          );
          
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
          
          await storageRef.putFile(File(pickedFile.path));
          final downloadUrl = await storageRef.getDownloadURL();
          
          print('Image uploaded successfully. URL: $downloadUrl');
          
          // Update user profile using AuthProvider
          await authProvider.updateProfileImage(user.uid!, downloadUrl);
          
          // Close loading dialog
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          print('Error updating profile image: ${e.toString()}');
          // Close loading dialog if open
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile image: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _showEditProfileDialog(BuildContext context, UserModel? user) async {
    if (user == null) return;
    
    final nameController = TextEditingController(text: user.name ?? '');
    final formKey = GlobalKey<FormState>();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              Text(
                'Email: ${user.email}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                
                try {
                  // Update Firestore document
                  await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                    'name': nameController.text,
                  });
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update profile: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showFavoritesScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Favorites'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: 80,
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
                ),
                SizedBox(height: 20),
                Text(
                  'Your favorite restaurants will appear here',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Explore Restaurants'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Notifications'),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: Text('Push Notifications'),
                subtitle: Text('Receive notifications about new projects and updates'),
                value: true,
                onChanged: (value) {},
              ),
              Divider(),
              SwitchListTile(
                title: Text('Email Notifications'),
                subtitle: Text('Receive email updates about your account'),
                value: false,
                onChanged: (value) {},
              ),
              Divider(),
              SwitchListTile(
                title: Text('New Product Alerts'),
                subtitle: Text('Be notified when new decor items are added'),
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpCenterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 10),
            Text('Help Center'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                'How to create a project?',
                'Tap on the + button at the bottom of the screen and select "Create Project". Fill in the details and save.',
              ),
              SizedBox(height: 10),
              _buildHelpItem(
                'How to add items to my project?',
                'Browse items in the Home tab, tap on an item and select "Add to Project".',
              ),
              SizedBox(height: 10),
              _buildHelpItem(
                'How to sync my data?',
                'Go to Profile > Data & Sync > Sync Data to manually sync your data.',
              ),
              SizedBox(height: 20),
              Text(
                'Need more help?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text('Contact us at: support@homedecorplanner.com'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 5),
        Text(content),
      ],
    );
  }

  void _showAboutUsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info, color: Theme.of(context).colorScheme.secondary),
            SizedBox(width: 10),
            Text('About Us'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/app_icon.png',
              height: 80,
              width: 80,
            ),
            SizedBox(height: 20),
            Text(
              'HomeDecor Planner',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text('Version 1.0.0'),
            SizedBox(height: 20),
            Text(
              'HomeDecor Planner helps you visualize and organize your home decoration projects easily.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Text(
              '© 2023 HomeDecor Planner\nAll rights reserved',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, ThemeProvider themeProvider) {
    return SwitchListTile(
      title: Text(
        "Dark Mode",
        style: TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      secondary: Icon(
        themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
        color: Theme.of(context).colorScheme.secondary,
      ),
      value: themeProvider.isDarkMode,
      activeColor: Theme.of(context).colorScheme.secondary,
      onChanged: (value) {
        themeProvider.toggleTheme();
      },
      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 0),
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
