import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:decor_home/models/decor_item_model.dart';
import 'package:decor_home/models/project_model.dart';
import 'package:decor_home/models/category_model.dart';
import 'package:decor_home/util/decor_items.dart';
import 'package:decor_home/util/decor_projects.dart';
import 'package:decor_home/util/categories.dart';
import 'package:decor_home/util/const.dart';

class DecorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Data lists
  List<DecorItemModel> _decorItems = [];
  List<ProjectModel> _projects = [];
  List<Category> _categories = [];
  List<String> _styles = ["Modern", "Minimalist", "Rustic", "Scandinavian", "Industrial", "Bohemian", "Contemporary"];
  
  // Selected filters
  String _selectedRoom = "All";
  String _selectedStyle = "All";
  double _minPrice = 0;
  double _maxPrice = 10000;
  
  // Search query
  String _searchQuery = "";
  
  // Initialization status
  bool _isDataInitialized = false;
  bool _isSyncing = false;
  
  // Getters
  List<DecorItemModel> get decorItems => _searchQuery.isEmpty 
      ? _decorItems 
      : _decorItems.where((item) => 
          item.title!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description!.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
  
  List<ProjectModel> get projects => _projects;
  List<Category> get categories => _categories;
  List<String> get styles => _styles;
  String get selectedRoom => _selectedRoom;
  String get selectedStyle => _selectedStyle;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get searchQuery => _searchQuery;
  bool get isDataInitialized => _isDataInitialized;
  bool get isSyncing => _isSyncing;
  
  // Get the current user ID
  String? get userId => _auth.currentUser?.uid;
  
  // Initialize data
  DecorProvider() {
    initializeData();
  }
  
  Future<void> initializeData() async {
    try {
      print("Initializing decor data...");
      
      // First load local data for quick display
      await loadLocalData();
      
      // Listen for auth state changes to sync data with the correct user
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          // User is signed in, fetch their data
          _syncWithFirestore();
        } else {
          // User is signed out, use local data
          loadLocalData();
        }
      });
      
      _isDataInitialized = true;
      notifyListeners();
    } catch (e) {
      print('Error in initializeData: $e');
      // Ensure we at least have local data if Firestore fails
      if (_decorItems.isEmpty) {
        await loadLocalData();
      }
      _isDataInitialized = true;
      notifyListeners();
    }
  }
  
  // Load data from local sources initially
  Future<void> loadLocalData() async {
    try {
      print("Loading local decor data...");
      
      // Load categories from the imported 'categories' list
      _categories = [];
      for (int i = 0; i < categories.length; i++) {
        var cat = categories[i] as Map<String, dynamic>;
        _categories.add(Category(
          name: cat['name'] ?? '',
          icon: cat['icon'] != null 
              ? IconData(int.parse(cat['icon'].toString().replaceAll('0x', '')), fontFamily: 'MaterialIcons') 
              : Icons.category,
          color: cat['color1'] as Color? ?? Colors.grey[200]!,
          imageUrl: cat['img'] ?? '',
          itemCount: 0, // We'll populate this later
        ));
      }
      
      print("Loaded ${_categories.length} categories");
      
      // Load decor items from the utility file
      _decorItems = [];
      for (int i = 0; i < decorItems.length; i++) {
        var item = decorItems[i] as Map<String, dynamic>;
        _decorItems.add(DecorItemModel(
          id: UniqueKey().toString(),
          title: item['title'] as String,
          description: item['address'] as String,
          category: _getCategoryForItem(item['title'] as String),
          room: _getRoomForItem(item['title'] as String),
          imageUrl: item['img'] as String,
          price: _generateRandomPrice(),
          rating: double.parse(item['rating'] as String),
        ));
      }
      print("Loaded ${_decorItems.length} decor items");
      
      // Load projects with explicit types
      _projects = [];
      for (int i = 0; i < decorProjects.length; i++) {
        var project = decorProjects[i] as Map<String, dynamic>;
        _projects.add(ProjectModel(
          id: UniqueKey().toString(),
          name: project['name'] as String,
          description: project['description'] as String,
          room: project['room'] as String,
          imageUrl: project['img'] as String,
          progress: project['progress'] as double,
          items: List<String>.from(project['items'] as List),
          budget: _generateRandomBudget(),
        ));
      }
      print("Loaded ${_projects.length} projects");
      
      // Notify listeners to update UI
      notifyListeners();
    } catch (e) {
      print('Error loading local data: $e');
    }
  }
  
  // Sync with Firestore if available
  Future<void> _syncWithFirestore() async {
    if (_isSyncing) return;
    
    _isSyncing = true;
    notifyListeners();
    
    try {
      final String? currentUserId = userId;
      
      if (currentUserId == null) {
        print('Cannot sync with Firestore: No user logged in');
        _isSyncing = false;
        notifyListeners();
        return;
      }
      
      print('Syncing with Firestore for user: $currentUserId');
      
      // Check if user has data
      final userProjectsRef = _firestore.collection('users').doc(currentUserId).collection('projects');
      final userDecorItemsRef = _firestore.collection('users').doc(currentUserId).collection('decor_items');
      
      final projectsSnapshot = await userProjectsRef.get();
      final decorItemsSnapshot = await userDecorItemsRef.get();
      
      if (projectsSnapshot.docs.isEmpty && decorItemsSnapshot.docs.isEmpty) {
        // New user, initialize their data
        print('Initializing data for new user');
        await _uploadSampleDataToFirestore(currentUserId);
      } else {
        // Existing user, fetch their data
        print('Fetching existing user data');
        await _fetchDataFromFirestore(currentUserId);
      }
      
      print('Firestore sync complete');
    } catch (e) {
      print('Error syncing with Firestore: $e');
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
  
  // Upload sample data to Firestore for a new user
  Future<void> _uploadSampleDataToFirestore(String userId) async {
    try {
      print('Uploading sample data to Firestore for user: $userId');
      
      final batch = _firestore.batch();
      final userRef = _firestore.collection('users').doc(userId);
      
      // Create user document if it doesn't exist
      batch.set(userRef, {
        'userId': userId,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Upload decor items
      for (var item in _decorItems) {
        final itemWithUserId = DecorItemModel(
          id: item.id,
          title: item.title,
          description: item.description,
          category: item.category,
          room: item.room,
          imageUrl: item.imageUrl,
          price: item.price,
          rating: item.rating,
        );
        
        final itemRef = userRef.collection('decor_items').doc(item.id);
        batch.set(itemRef, itemWithUserId.toMap());
      }
      
      // Upload projects
      for (var project in _projects) {
        final projectWithUserId = ProjectModel(
          id: project.id,
          name: project.name,
          description: project.description,
          room: project.room,
          imageUrl: project.imageUrl,
          progress: project.progress,
          items: project.items,
          budget: project.budget,
          userId: userId,
        );
        
        final projectRef = userRef.collection('projects').doc(project.id);
        batch.set(projectRef, projectWithUserId.toMap());
      }
      
      await batch.commit();
      print('Sample data uploaded to Firestore for user: $userId');
    } catch (e) {
      print('Error uploading sample data: $e');
    }
  }
  
  // Fetch data from Firestore for a specific user
  Future<void> _fetchDataFromFirestore(String userId) async {
    try {
      print('Fetching data from Firestore for user: $userId');
      
      // Fetch decor items
      final itemsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('decor_items')
          .get();
      
      _decorItems = itemsSnapshot.docs
          .map((doc) => DecorItemModel.fromMap(doc.data()))
          .toList();
      
      print('Fetched ${_decorItems.length} decor items');
      
      // Fetch projects
      final projectsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('projects')
          .get();
      
      _projects = projectsSnapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.data()))
          .toList();
      
      print('Fetched ${_projects.length} projects');
      
      notifyListeners();
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }
  
  // Add a new decor item
  Future<void> addDecorItem(DecorItemModel item) async {
    try {
      final currentUserId = userId;
      
      if (currentUserId == null) {
        print('Cannot add decor item: No user logged in');
        return;
      }
      
      final id = UniqueKey().toString();
      final newItem = DecorItemModel(
        id: id,
        title: item.title,
        description: item.description,
        category: item.category,
        room: item.room,
        imageUrl: item.imageUrl ?? Constants.placeholderImage,
        price: item.price,
        rating: item.rating ?? 5.0,
      );
      
      // Add to local list
      _decorItems.add(newItem);
      
      // Add to Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('decor_items')
          .doc(id)
          .set(newItem.toMap());
      
      // Update lastUpdated timestamp
      await _firestore.collection('users').doc(currentUserId).update({
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
    } catch (e) {
      print('Error adding decor item: $e');
    }
  }
  
  // Add a new project
  Future<void> addProject(ProjectModel project) async {
    try {
      final currentUserId = userId;
      
      if (currentUserId == null) {
        print('Cannot add project: No user logged in');
        return;
      }
      
      final id = UniqueKey().toString();
      final newProject = ProjectModel(
        id: id,
        name: project.name,
        description: project.description,
        room: project.room,
        imageUrl: project.imageUrl ?? Constants.placeholderImage,
        progress: project.progress ?? 0.0,
        items: project.items ?? [],
        budget: project.budget,
        userId: currentUserId,
      );
      
      // Add to local list
      _projects.add(newProject);
      
      // Add to Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('projects')
          .doc(id)
          .set(newProject.toMap());
      
      // Update lastUpdated timestamp
      await _firestore.collection('users').doc(currentUserId).update({
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
    } catch (e) {
      print('Error adding project: $e');
    }
  }
  
  // Update a project
  Future<void> updateProject(ProjectModel project) async {
    try {
      final currentUserId = userId;
      
      if (currentUserId == null) {
        print('Cannot update project: No user logged in');
        return;
      }
      
      // Update in local list
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
      }
      
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('projects')
          .doc(project.id)
          .update(project.toMap());
      
      // Update lastUpdated timestamp
      await _firestore.collection('users').doc(currentUserId).update({
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
    } catch (e) {
      print('Error updating project: $e');
    }
  }
  
  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      final currentUserId = userId;
      
      if (currentUserId == null) {
        print('Cannot delete project: No user logged in');
        return;
      }
      
      // Remove from local list
      _projects.removeWhere((p) => p.id == projectId);
      
      // Delete from Firestore
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('projects')
          .doc(projectId)
          .delete();
      
      // Update lastUpdated timestamp
      await _firestore.collection('users').doc(currentUserId).update({
        'lastUpdated': FieldValue.serverTimestamp(),
      });
      
      notifyListeners();
    } catch (e) {
      print('Error deleting project: $e');
    }
  }
  
  // Add item to project
  Future<void> addItemToProject(String projectId, String itemName) async {
    try {
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final project = _projects[index];
        final items = List<String>.from(project.items ?? []);
        items.add(itemName);
        
        final updatedProject = ProjectModel(
          id: project.id,
          name: project.name,
          description: project.description,
          room: project.room,
          imageUrl: project.imageUrl,
          progress: project.progress,
          items: items,
          budget: project.budget,
          userId: project.userId,
        );
        
        await updateProject(updatedProject);
      }
    } catch (e) {
      print('Error adding item to project: $e');
    }
  }
  
  // Remove item from project
  Future<void> removeItemFromProject(String projectId, String itemName) async {
    try {
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final project = _projects[index];
        final items = List<String>.from(project.items ?? []);
        items.remove(itemName);
        
        final updatedProject = ProjectModel(
          id: project.id,
          name: project.name,
          description: project.description,
          room: project.room,
          imageUrl: project.imageUrl,
          progress: project.progress,
          items: items,
          budget: project.budget,
          userId: project.userId,
        );
        
        await updateProject(updatedProject);
      }
    } catch (e) {
      print('Error removing item from project: $e');
    }
  }
  
  // Force sync data (can be called after login)
  Future<void> forceSyncData() async {
    await _syncWithFirestore();
  }
  
  // Set search query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
  
  // Set filter by room
  void setRoomFilter(String room) {
    _selectedRoom = room;
    notifyListeners();
  }
  
  // Set filter by style
  void setStyleFilter(String style) {
    _selectedStyle = style;
    notifyListeners();
  }
  
  // Set price range
  void setPriceRange(double min, double max) {
    _minPrice = min;
    _maxPrice = max;
    notifyListeners();
  }
  
  // Add a method to update categories
  void updateCategories(List<Category> newCategories) {
    // Create a map to avoid duplicates based on name
    final Map<String, Category> categoryMap = {};
    
    // First add existing categories
    for (var category in _categories) {
      categoryMap[category.name] = category;
    }
    
    // Then update or add new ones
    for (var category in newCategories) {
      categoryMap[category.name] = category;
    }
    
    // Convert map back to list
    _categories = categoryMap.values.toList();
    notifyListeners();
  }
  
  // Get filtered decor items
  List<DecorItemModel> getFilteredDecorItems() {
    return _decorItems.where((item) {
      // Apply room filter
      if (_selectedRoom != "All" && item.room != _selectedRoom) {
        return false;
      }
      
      // Apply style filter
      if (_selectedStyle != "All" && item.category != _selectedStyle) {
        return false;
      }
      
      // Apply price filter
      if (item.price! < _minPrice || item.price! > _maxPrice) {
        return false;
      }
      
      // Apply search query
      if (_searchQuery.isNotEmpty) {
        return item.title!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               item.description!.toLowerCase().contains(_searchQuery.toLowerCase());
      }
      
      return true;
    }).toList();
  }
  
  // Get projects by room
  List<ProjectModel> getProjectsByRoom(String room) {
    if (room == "All") {
      return _projects;
    }
    return _projects.where((project) => project.room == room).toList();
  }
  
  // Helper methods
  String _getCategoryForItem(String title) {
    if (title.contains('Sofa') || title.contains('Chair') || title.contains('Table') || title.contains('Shelf')) {
      return 'Furniture';
    } else if (title.contains('Lamp') || title.contains('Light')) {
      return 'Lighting';
    } else if (title.contains('Rug') || title.contains('Curtain') || title.contains('Vase')) {
      return 'Decor';
    } else if (title.contains('Bed') || title.contains('Mattress')) {
      return 'Bedding';
    } else if (title.contains('Kitchen') || title.contains('Dining')) {
      return 'Kitchen';
    } else if (title.contains('Bath') || title.contains('Shower')) {
      return 'Bathroom';
    } else {
      return 'Other';
    }
  }
  
  String _getRoomForItem(String title) {
    String itemText = title.toLowerCase();
    
    if (itemText.contains('living')) {
      return 'Living Room';
    } else if (itemText.contains('bed')) {
      return 'Bedroom';
    } else if (itemText.contains('kitchen')) {
      return 'Kitchen';
    } else if (itemText.contains('bath')) {
      return 'Bathroom';
    } else if (itemText.contains('office')) {
      return 'Office';
    } else if (itemText.contains('dining')) {
      return 'Dining Room';
    } else if (itemText.contains('outdoor') || itemText.contains('garden') || itemText.contains('patio')) {
      return 'Outdoor';
    } else {
      // Look at specific keywords for common items
      if (itemText.contains('sofa') || itemText.contains('chair') || itemText.contains('coffee table')) {
        return 'Living Room';
      } else if (itemText.contains('dresser') || itemText.contains('mattress')) {
        return 'Bedroom';
      } else if (itemText.contains('sink') || itemText.contains('stove') || itemText.contains('refrigerator')) {
        return 'Kitchen';
      } else if (itemText.contains('vanity') || itemText.contains('toilet') || itemText.contains('shower')) {
        return 'Bathroom';
      } else if (itemText.contains('desk') || itemText.contains('bookshelf')) {
        return 'Office';
      } else {
        return 'All'; // Default
      }
    }
  }
  
  double _generateRandomPrice() {
    return 50 + (DateTime.now().millisecondsSinceEpoch % 1950);
  }
  
  double _generateRandomBudget() {
    return 1000 + (DateTime.now().millisecondsSinceEpoch % 9000);
  }
} 
