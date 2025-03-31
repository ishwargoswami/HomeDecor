import 'package:flutter/material.dart';
import 'package:flutter_foodybite/models/user_model.dart';
import 'package:flutter_foodybite/models/budget_model.dart';
import 'package:flutter_foodybite/models/notification_model.dart';
import 'package:flutter_foodybite/models/user_settings_model.dart';
import 'package:flutter_foodybite/screens/login_screen.dart';
import 'package:flutter_foodybite/services/auth_provider.dart';
import 'package:flutter_foodybite/services/theme_provider.dart';
import 'package:flutter_foodybite/services/decor_provider.dart';
import 'package:flutter_foodybite/services/budget_provider.dart';
import 'package:flutter_foodybite/services/notification_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userStream = authProvider.userStream;
    
    return StreamBuilder<UserModel?>(
      stream: userStream,
      key: ValueKey<DateTime>(DateTime.now()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        
        final user = snapshot.data;
        return _buildProfileContent(context, user, authProvider);
      },
    );
  }

  Widget _buildProfileContent(BuildContext context, UserModel? user, AuthProvider authProvider) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final decorProvider = Provider.of<DecorProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _showEditProfileDialog(context, user),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          authProvider.refreshUser();
          return Future<void>.delayed(Duration.zero);
        },
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User profile card
                _buildProfileCard(context, user),
                SizedBox(height: 24),
                
                // Activity stats
                _buildActivityStats(context, decorProvider),
                SizedBox(height: 24),
                
                // App settings
                _buildAppSettings(context, themeProvider),
                SizedBox(height: 24),
                
                // Account settings
                _buildAccountSettings(context, user),
                SizedBox(height: 24),
                
                // Security settings
                _buildSecuritySettings(context, user),
                SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildProfileCard(BuildContext context, UserModel? user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  child: ClipOval(
                    child: SizedBox(
                      width: 100,
                      height: 100,
                      child: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: user.photoUrl!,
                              fit: BoxFit.cover,
                              cacheKey: '${user.photoUrl}_${DateTime.now().millisecondsSinceEpoch}',
                              placeholder: (context, url) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              errorWidget: (context, url, error) {
                                print('Error loading profile image: $error');
                                return Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                );
                              },
                            )
                          : Icon(
                              Icons.person,
                              size: 50,
                              color: Theme.of(context).colorScheme.primary,
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
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              user?.name ?? 'Guest User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              user?.email ?? 'Sign in to view your profile',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem(context, '${user?.projectsCount ?? 0}', 'Projects'),
                SizedBox(width: 24),
                _buildStatItem(context, '${user?.wishlistCount ?? 0}', 'Wishlist'),
                SizedBox(width: 24),
                _buildStatItem(context, '${user?.purchasesCount ?? 0}', 'Purchases'),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildActivityStats(BuildContext context, DecorProvider decorProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Activity Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 10,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 7,
                          color: Colors.blue,
                          width: 20,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 4,
                          color: Colors.green,
                          width: 20,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 8,
                          color: Colors.orange,
                          width: 20,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(
                          toY: 5,
                          color: Colors.purple,
                          width: 20,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                      showingTooltipIndicators: [0],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          String text = '';
                          switch (value.toInt()) {
                            case 0:
                              text = 'Views';
                              break;
                            case 1:
                              text = 'Saves';
                              break;
                            case 2:
                              text = 'Likes';
                              break;
                            case 3:
                              text = 'Shares';
                              break;
                          }
                          return Text(
                            text,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  gridData: FlGridData(
                    show: true,
                    horizontalInterval: 2,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAppSettings(BuildContext context, ThemeProvider themeProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.settings,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            SwitchListTile(
              title: Text('Dark Theme'),
              subtitle: Text('Switch between light and dark theme'),
              value: themeProvider.isDarkMode,
              onChanged: (value) {
                themeProvider.toggleTheme();
              },
              secondary: Icon(
                themeProvider.isDarkMode ? Icons.nightlight_round : Icons.wb_sunny,
                color: themeProvider.isDarkMode ? Colors.amber : Colors.orange,
              ),
            ),
            SwitchListTile(
              title: Text('Push Notifications'),
              subtitle: Text('Receive push notifications for updates'),
              value: true,
              onChanged: (value) {
                // Implement notification toggle
              },
              secondary: Icon(Icons.notifications),
            ),
            SwitchListTile(
              title: Text('Email Notifications'),
              subtitle: Text('Receive email updates and promotions'),
              value: false,
              onChanged: (value) {
                // Implement email notification toggle
              },
              secondary: Icon(Icons.email),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAccountSettings(BuildContext context, UserModel? user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Account Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit Profile'),
              subtitle: Text('Update your personal information'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showEditProfileDialog(context, user),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.cloud_sync),
              title: Text('Sync Data'),
              subtitle: Text('Sync your data with the cloud'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Syncing your data...'),
                    duration: Duration(seconds: 2),
                  ),
                );
                
                // Actually perform the sync
                final decorProvider = Provider.of<DecorProvider>(context, listen: false);
                decorProvider.forceSyncData().then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data synced successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error syncing data: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.delete_outline, color: Colors.red),
              title: Text('Delete Account', style: TextStyle(color: Colors.red)),
              subtitle: Text('Permanently delete your account and data'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.red),
              onTap: () => _showDeleteAccountConfirmation(context),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSecuritySettings(BuildContext context, UserModel? user) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Security',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.password),
              title: Text('Change Password'),
              subtitle: Text('Update your account password'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _showChangePasswordDialog(context),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.fingerprint),
              title: Text('Biometric Login'),
              subtitle: Text('Use fingerprint or face recognition'),
              trailing: Switch(
                value: false,
                onChanged: (value) {
                  // Implement biometric toggle
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('This feature is coming soon!'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showEditProfileDialog(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final formKey = GlobalKey<FormState>();
    
    showDialog(
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
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate() && user != null) {
                // Update user name
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                authProvider.updateUserName(user.uid!, nameController.text).then((_) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Profile updated successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }).catchError((error) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating profile: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }
  
  void _showChangePasswordDialog(BuildContext context) {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Change Password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentPasswordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                // Change password logic
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                
                // Show loading
                Navigator.pop(context);
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => Center(child: CircularProgressIndicator()),
                );
                
                // Execute password change
                authProvider.changePassword(
                  currentPassword: currentPasswordController.text,
                  newPassword: newPasswordController.text,
                ).then((_) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password changed successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }).catchError((error) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error changing password: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                });
              }
            },
            child: Text('Change Password'),
          ),
        ],
      ),
    );
  }
  
  void _showDeleteAccountConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Account?'),
        content: Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently lost.',
          style: TextStyle(color: Colors.red[700]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('This feature is not yet implemented'),
                ),
              );
            },
            child: Text(
              'Delete Account',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfileImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      try {
        // Show loading dialog
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: CircularProgressIndicator(),
          ),
        );
        
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final user = authProvider.user;
        
        if (user != null) {
          // Upload image to Firebase Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('profile_images')
              .child('${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');
          
          await storageRef.putFile(File(image.path));
          final downloadUrl = await storageRef.getDownloadURL();
          
          // Update user profile
          await authProvider.updateProfileImage(user.uid!, downloadUrl);
          
          // Explicitly refresh the user data
          authProvider.refreshUser();
          
          // Close loading dialog
          Navigator.of(context).pop();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile image updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        // Close loading dialog if open
        if (Navigator.canPop(context)) {
          Navigator.of(context).pop();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
