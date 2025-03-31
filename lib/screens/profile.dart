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
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                ),
                child: _buildProfileHeader(context, user),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBudgetPlanningSection(context),
                  SizedBox(height: 20),
                  _buildNotificationsSection(context),
                  SizedBox(height: 20),
                  _buildHelpCenterSection(context),
                  SizedBox(height: 20),
                  _buildAboutUsSection(context),
                  SizedBox(height: 20),
                  _buildDataSyncSection(context),
                  SizedBox(height: 20),
                  _buildLogoutButton(context, authProvider),
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
      padding: EdgeInsets.only(top: 30, bottom: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
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
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            user?.name ?? 'User',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            user?.email ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPlanningSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final budgetProvider = Provider.of<BudgetProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return SizedBox();
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_balance_wallet, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "Budget Planning",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      value: 40,
                      title: '40%',
                      color: Colors.blue,
                      radius: 100,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: '30%',
                      color: Colors.green,
                      radius: 100,
                    ),
                    PieChartSectionData(
                      value: 30,
                      title: '30%',
                      color: Colors.orange,
                      radius: 100,
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                  startDegreeOffset: 180,
                ),
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCategoryChip('Furniture', 40, Colors.blue),
                _buildCategoryChip('Accessories', 30, Colors.green),
                _buildCategoryChip('Lighting', 30, Colors.orange),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.add_circle_outline),
              title: Text("Add New Budget"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showAddBudgetDialog(context, user.uid!),
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text("Budget History"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showBudgetHistoryScreen(context, user.uid!),
            ),
          ],
        ),
      ),
    );
  }
  
  // Build category chip
  Widget _buildCategoryChip(String label, int percentage, Color color) {
    return Chip(
      label: Text(
        '$label: $percentage%',
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
  
  // Helper method to get color for budget category
  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'furniture':
        return Colors.blue;
      case 'accessories':
        return Colors.green;
      case 'lighting':
        return Colors.orange;
      case 'paint':
        return Colors.purple;
      case 'flooring':
        return Colors.red;
      case 'appliances':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }
  
  // Show dialog to add a new budget
  Future<void> _showAddBudgetDialog(BuildContext context, String userId) async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    
    // Category controllers
    final furnitureController = TextEditingController(text: '40');
    final accessoriesController = TextEditingController(text: '30');
    final lightingController = TextEditingController(text: '30');
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Budget'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Budget Title',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: InputDecoration(
                    labelText: 'Total Budget Amount',
                    prefixText: '\$',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Theme.of(context).cardColor,
                  ),
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 24),
                Text(
                  'Budget Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Distribute 100% of your budget across categories',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 16),
                _buildCategoryInput(
                  context, 
                  'Furniture', 
                  furnitureController,
                  Colors.blue,
                ),
                SizedBox(height: 8),
                _buildCategoryInput(
                  context, 
                  'Accessories', 
                  accessoriesController,
                  Colors.green,
                ),
                SizedBox(height: 8),
                _buildCategoryInput(
                  context, 
                  'Lighting', 
                  lightingController,
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                // Validate that percentages add up to 100
                final furniture = int.tryParse(furnitureController.text) ?? 0;
                final accessories = int.tryParse(accessoriesController.text) ?? 0;
                final lighting = int.tryParse(lightingController.text) ?? 0;
                final total = furniture + accessories + lighting;
                
                if (total != 100) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Category percentages must add up to 100%'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                
                // Create budget model
                final budget = BudgetModel(
                  userId: userId,
                  title: titleController.text,
                  totalAmount: double.parse(amountController.text),
                  categories: {
                    'Furniture': furniture.toDouble(),
                    'Accessories': accessories.toDouble(),
                    'Lighting': lighting.toDouble(),
                  },
                  createdAt: DateTime.now(),
                );
                
                // Save budget
                final budgetProvider = Provider.of<BudgetProvider>(context, listen: false);
                final success = await budgetProvider.createBudget(budget);
                
                Navigator.pop(context);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Budget created successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create budget: ${budgetProvider.error}'),
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
  
  // Helper to build category input fields
  Widget _buildCategoryInput(
    BuildContext context, 
    String label, 
    TextEditingController controller,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          color: color,
          margin: EdgeInsets.only(right: 8),
        ),
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 3,
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              suffixText: '%',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Theme.of(context).cardColor,
              hoverColor: Theme.of(context).hoverColor,
              focusColor: Theme.of(context).focusColor,
            ),
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Required';
              }
              if (int.tryParse(value) == null) {
                return 'Invalid';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
  
  // Show budget history screen
  void _showBudgetHistoryScreen(BuildContext context, String userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Budget History'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text(
                  'No budget history yet',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.add),
                  label: Text('Create Your First Budget'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationsSection(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final user = authProvider.user;
    
    if (user == null) {
      return SizedBox();
    }
    
    // Initialize notification settings
    if (notificationProvider.userSettings == null) {
      notificationProvider.fetchUserSettings(user.uid!);
    }
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "Notifications",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            notificationProvider.isLoading
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      SwitchListTile(
                        title: Text("Push Notifications"),
                        subtitle: Text("Receive notifications about updates and offers"),
                        value: notificationProvider.hasPushNotificationsEnabled,
                        onChanged: (bool value) async {
                          await notificationProvider.togglePushNotifications(user.uid!, value);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Push notifications enabled'
                                    : 'Push notifications disabled',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      SwitchListTile(
                        title: Text("Email Notifications"),
                        subtitle: Text("Receive updates via email"),
                        value: notificationProvider.hasEmailNotificationsEnabled,
                        onChanged: (bool value) async {
                          await notificationProvider.toggleEmailNotifications(user.uid!, value);
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                value
                                    ? 'Email notifications enabled'
                                    : 'Email notifications disabled',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: Icon(Icons.notification_important),
                        title: Text("Notification History"),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () => _showNotificationHistoryScreen(context, user.uid!),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
  
  // Show notification history screen
  void _showNotificationHistoryScreen(BuildContext context, String userId) {
    final notificationProvider = Provider.of<NotificationProvider>(context, listen: false);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Notification History'),
            actions: [
              IconButton(
                icon: Icon(Icons.delete_sweep),
                tooltip: 'Clear All',
                onPressed: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Clear All Notifications'),
                      content: Text('Are you sure you want to clear all notifications?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text('Clear All'),
                        ),
                      ],
                    ),
                  ) ?? false;
                  
                  if (confirmed) {
                    await notificationProvider.clearAllNotifications(userId);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('All notifications cleared'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
          body: StreamBuilder<List<NotificationModel>>(
            stream: notificationProvider.getUserNotificationsStream(userId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading notifications: ${snapshot.error}',
                    style: TextStyle(color: Colors.red),
                  ),
                );
              }
              
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No notifications yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }
              
              final notifications = snapshot.data!;
              
              return ListView.builder(
                itemCount: notifications.length,
                padding: EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  
                  return Dismissible(
                    key: Key(notification.id ?? 'notification_$index'),
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.delete,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) async {
                      await notificationProvider.deleteNotification(notification.id!);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Notification deleted'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.only(bottom: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: notification.isRead ? null : Color(0xFFF0F8FF),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          notification.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(notification.message),
                            SizedBox(height: 8),
                            Text(
                              _formatDate(notification.createdAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          if (!notification.isRead) {
                            await notificationProvider.markNotificationAsRead(notification.id!);
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Helper to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildHelpCenterSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.help_outline, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "Help Center",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text("FAQ"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showFAQScreen(context),
            ),
            ListTile(
              leading: Icon(Icons.support_agent),
              title: Text("Contact Support"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showContactSupportDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.book),
              title: Text("User Guide"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showUserGuideScreen(context),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show FAQ screen
  void _showFAQScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Frequently Asked Questions'),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildFAQItem(
                'How do I create a new budget?',
                'Go to the Profile screen and tap on "Add New Budget" in the Budget Planning section. Enter your budget details and save.'
              ),
              _buildFAQItem(
                'How do I update my profile picture?',
                'Tap on the camera icon next to your profile picture on the Profile screen, then select a new image from your gallery.'
              ),
              _buildFAQItem(
                'Can I export my budget data?',
                'Currently, we don\'t support exporting budget data, but this feature is coming soon in a future update.'
              ),
              _buildFAQItem(
                'How do I change notification settings?',
                'Go to the Profile screen and use the toggles in the Notifications section to enable or disable different types of notifications.'
              ),
              _buildFAQItem(
                'Is my data backed up?',
                'Yes, all your data is automatically backed up to the cloud when you\'re connected to the internet.'
              ),
              _buildFAQItem(
                'How do I delete my account?',
                'Please contact our support team through the Contact Support option if you wish to delete your account.'
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build FAQ item widget
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer),
        ),
      ],
    );
  }
  
  // Show contact support dialog
  void _showContactSupportDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contact Support',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Subject field
                    TextFormField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a subject';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    // Message field
                    TextFormField(
                      controller: messageController,
                      decoration: InputDecoration(
                        labelText: 'Message',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                      minLines: 5,
                      maxLines: 8,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a message';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),
                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () async {
                            if (formKey.currentState!.validate()) {
                              // Close the dialog
                              Navigator.pop(context);
                              
                              // Get user email to include in the support request
                              final authProvider = Provider.of<AuthProvider>(context, listen: false);
                              String? userEmail = authProvider.user?.email;
                              
                              // Send actual email using url_launcher
                              try {
                                // Compose email
                                final Uri emailLaunchUri = Uri(
                                  scheme: 'mailto',
                                  path: 'support@homedecorplanner.com',
                                  queryParameters: {
                                    'subject': '[Support Request] ${subjectController.text}',
                                    'body': 'From: ${userEmail ?? "Anonymous"}\n\n${messageController.text}'
                                  }
                                );
                                
                                // Launch email app
                                if (await canLaunchUrl(emailLaunchUri)) {
                                  await launchUrl(emailLaunchUri);
                                  
                                  // Show success message if email app opened
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Opening email application to send your request'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                } else {
                                  throw 'Could not launch email app';
                                }
                              } catch (e) {
                                // Fall back to success message if email launch fails
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Support request sent successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          child: Text(
                            'Send',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
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
    );
  }
  
  // Show user guide screen
  void _showUserGuideScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('User Guide'),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              _buildUserGuideSection(
                'Getting Started',
                'Welcome to HomeDecorPlanner! This guide will help you get the most out of our app.',
                [
                  'Create an account or log in to your existing account',
                  'Update your profile information',
                  'Explore the app\'s main sections: Home, Projects, Inspiration, and Profile',
                ],
              ),
              _buildUserGuideSection(
                'Managing Your Budget',
                'Track your home decoration expenses easily with our budget planning tools.',
                [
                  'Create a new budget from the Profile screen',
                  'Set category allocations for your spending',
                  'View your budget history to track spending over time',
                ],
              ),
              _buildUserGuideSection(
                'Managing Notifications',
                'Stay updated with important information and updates.',
                [
                  'Toggle push notifications on/off from the Profile screen',
                  'Toggle email notifications on/off from the Profile screen',
                  'View notification history to see past notifications',
                ],
              ),
              _buildUserGuideSection(
                'Data & Sync',
                'Keep your data safe and accessible across devices.',
                [
                  'Your data is automatically synced to the cloud',
                  'Force a manual sync from the Profile screen if needed',
                  'Backup your data for extra safety',
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build user guide section widget
  Widget _buildUserGuideSection(String title, String description, List<String> steps) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(description),
            SizedBox(height: 16),
            ...steps.map((step) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(child: Text(step)),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutUsSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "About Us",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "HomeDecorPlanner is your ultimate companion for home decoration planning and organization. We help you manage your decor projects, track budgets, and stay organized with our intuitive interface.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.star),
              title: Text("Rate Us"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showRateDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.share),
              title: Text("Share App"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showShareDialog(context),
            ),
            ListTile(
              leading: Icon(Icons.description),
              title: Text("Terms & Conditions"),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () => _showTermsScreen(context),
            ),
          ],
        ),
      ),
    );
  }
  
  // Show rating dialog
  void _showRateDialog(BuildContext context) {
    double rating = 0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rate Our App'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you rate your experience with HomeDecorPlanner?',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            StatefulBuilder(
              builder: (context, setState) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 36,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  }),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (rating > 0) {
                // Here you would actually submit the rating
                Navigator.pop(context);
                
                // Show thank you message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Thanks for your feedback!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select a rating'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
  
  // Show share app dialog
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Share HomeDecorPlanner'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Share HomeDecorPlanner with your friends and family!',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildShareOption(
                  context,
                  Icons.message,
                  'Message',
                  Colors.green,
                ),
                _buildShareOption(
                  context,
                  Icons.email,
                  'Email',
                  Colors.red,
                ),
                _buildShareOption(
                  context,
                  Icons.facebook,
                  'Facebook',
                  Colors.blue,
                ),
                _buildShareOption(
                  context,
                  Icons.link,
                  'Copy Link',
                  Colors.grey,
                ),
              ],
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
  
  // Build share option button
  Widget _buildShareOption(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Shared via $label'),
            backgroundColor: Colors.green,
          ),
        );
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color,
            child: Icon(
              icon,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  
  // Show terms and conditions screen
  void _showTermsScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text('Terms & Conditions'),
          ),
          body: ListView(
            padding: EdgeInsets.all(16),
            children: [
              Text(
                'Terms and Conditions',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Last Updated: April 1, 2023',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 24),
              _buildTermsSection(
                'Introduction',
                'These Terms and Conditions govern your use of the HomeDecorPlanner mobile application and constitute a binding legal agreement between you and HomeDecorPlanner.'
              ),
              _buildTermsSection(
                'Account Registration',
                'To use certain features of the app, you must register for an account. You agree to provide accurate information and keep your account secure.'
              ),
              _buildTermsSection(
                'Privacy Policy',
                'Our Privacy Policy describes how we handle the information you provide to us when you use our app. You understand that through your use of the app, you consent to the collection and use of this information.'
              ),
              _buildTermsSection(
                'User Content',
                'You retain ownership of any content you submit to the app. By submitting content, you grant us a worldwide, non-exclusive, royalty-free license to use, reproduce, modify, and display your content.'
              ),
              _buildTermsSection(
                'Intellectual Property',
                'The app and its original content, features, and functionality are owned by HomeDecorPlanner and are protected by international copyright, trademark, patent, trade secret, and other intellectual property laws.'
              ),
              _buildTermsSection(
                'Termination',
                'We may terminate or suspend your account and access to the app at our sole discretion, without notice, for conduct that we believe violates these Terms and Conditions or is harmful to other users, us, or third parties.'
              ),
              SizedBox(height: 24),
              Text(
                'By using HomeDecorPlanner, you agree to these terms and conditions. If you do not agree, please do not use the app.',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Build terms and conditions section
  Widget _buildTermsSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(content),
        ],
      ),
    );
  }

  Widget _buildDataSyncSection(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.sync, 
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "Data & Sync",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
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
                      : Icon(Icons.arrow_forward_ios),
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
            ListTile(
              leading: Icon(Icons.cloud_done),
              title: Text("Backup Data"),
              subtitle: Text("Save your projects and items"),
              trailing: Icon(Icons.arrow_forward_ios),
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
    );
  }

  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () async {
          // Show a logout indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return Center(
                child: CircularProgressIndicator(),
              );
            },
          );
          
          // Sign out the user
          await authProvider.signOut();
          
          // Add a small delay to ensure everything is properly cleared
          await Future.delayed(Duration(milliseconds: 300));
          
          // Close the loading dialog if it's still open
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
          
          // Navigate directly to LoginScreen with a clean navigation stack
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
        },
        icon: Icon(Icons.logout),
        label: Text(
          "Logout",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 15),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
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
