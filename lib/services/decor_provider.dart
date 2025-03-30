import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_foodybite/models/decor_item_model.dart';
import 'package:flutter_foodybite/models/project_model.dart';
import 'package:flutter_foodybite/util/decor_items.dart';
import 'package:flutter_foodybite/util/decor_projects.dart';
import 'package:flutter_foodybite/util/categories.dart';
import 'package:flutter_foodybite/util/const.dart';

class DecorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Data lists
  List<DecorItemModel> _decorItems = [];
  List<ProjectModel> _projects = [];
  List<Map<String, dynamic>> _categories = [];
  List<String> _styles = ["Modern", "Minimalist", "Rustic", "Scandinavian", "Industrial", "Bohemian", "Contemporary"];
  
  // Selected filters
  String _selectedRoom = "All";
  String _selectedStyle = "All";
  double _minPrice = 0;
  double _maxPrice = 10000;
  
  // Search query
  String _searchQuery = "";
  
  // Getters
  List<DecorItemModel> get decorItems => _searchQuery.isEmpty 
      ? _decorItems 
      : _decorItems.where((item) => 
          item.title!.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description!.toLowerCase().contains(_searchQuery.toLowerCase())
        ).toList();
  
  List<ProjectModel> get projects => _projects;
  List<Map<String, dynamic>> get categories => _categories;
  List<String> get styles => _styles;
  String get selectedRoom => _selectedRoom;
  String get selectedStyle => _selectedStyle;
  double get minPrice => _minPrice;
  double get maxPrice => _maxPrice;
  String get searchQuery => _searchQuery;
  
  // Initialize data
  DecorProvider() {
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    await _loadLocalData();
    _syncWithFirestore();
  }
  
  // Load data from local sources initially
  Future<void> _loadLocalData() async {
    try {
      // Load categories
      _categories = List<Map<String, dynamic>>.from(categories);
      
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
      
      notifyListeners();
    } catch (e) {
      print('Error loading local data: $e');
    }
  }
  
  // Sync with Firestore if available
  Future<void> _syncWithFirestore() async {
    try {
      // Check if collections exist
      final itemsCollection = await _firestore.collection('decor_items').get();
      final projectsCollection = await _firestore.collection('projects').get();
      
      if (itemsCollection.docs.isEmpty) {
        // Upload sample data to Firestore
        _uploadSampleDataToFirestore();
      } else {
        // Fetch data from Firestore
        await _fetchDataFromFirestore();
      }
    } catch (e) {
      print('Error syncing with Firestore: $e');
    }
  }
  
  // Upload sample data to Firestore
  Future<void> _uploadSampleDataToFirestore() async {
    try {
      // Upload decor items
      for (var item in _decorItems) {
        await _firestore.collection('decor_items').doc(item.id).set(item.toMap());
      }
      
      // Upload projects
      for (var project in _projects) {
        await _firestore.collection('projects').doc(project.id).set(project.toMap());
      }
      
      print('Sample data uploaded to Firestore');
    } catch (e) {
      print('Error uploading sample data: $e');
    }
  }
  
  // Fetch data from Firestore
  Future<void> _fetchDataFromFirestore() async {
    try {
      // Fetch decor items
      final itemsSnapshot = await _firestore.collection('decor_items').get();
      _decorItems = itemsSnapshot.docs
          .map((doc) => DecorItemModel.fromMap(doc.data()))
          .toList();
      
      // Fetch projects
      final projectsSnapshot = await _firestore.collection('projects').get();
      _projects = projectsSnapshot.docs
          .map((doc) => ProjectModel.fromMap(doc.data()))
          .toList();
      
      notifyListeners();
    } catch (e) {
      print('Error fetching data from Firestore: $e');
    }
  }
  
  // Add a new decor item
  Future<void> addDecorItem(DecorItemModel item) async {
    try {
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
      await _firestore.collection('decor_items').doc(id).set(newItem.toMap());
      
      notifyListeners();
    } catch (e) {
      print('Error adding decor item: $e');
    }
  }
  
  // Add a new project
  Future<void> addProject(ProjectModel project) async {
    try {
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
      );
      
      // Add to local list
      _projects.add(newProject);
      
      // Add to Firestore
      await _firestore.collection('projects').doc(id).set(newProject.toMap());
      
      notifyListeners();
    } catch (e) {
      print('Error adding project: $e');
    }
  }
  
  // Update a project
  Future<void> updateProject(ProjectModel project) async {
    try {
      // Update in local list
      final index = _projects.indexWhere((p) => p.id == project.id);
      if (index != -1) {
        _projects[index] = project;
      }
      
      // Update in Firestore
      await _firestore.collection('projects').doc(project.id).update(project.toMap());
      
      notifyListeners();
    } catch (e) {
      print('Error updating project: $e');
    }
  }
  
  // Delete a project
  Future<void> deleteProject(String projectId) async {
    try {
      // Remove from local list
      _projects.removeWhere((p) => p.id == projectId);
      
      // Delete from Firestore
      await _firestore.collection('projects').doc(projectId).delete();
      
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
  
  // Update project progress
  Future<void> updateProjectProgress(String projectId, double progress) async {
    try {
      final index = _projects.indexWhere((p) => p.id == projectId);
      if (index != -1) {
        final project = _projects[index];
        
        final updatedProject = ProjectModel(
          id: project.id,
          name: project.name,
          description: project.description,
          room: project.room,
          imageUrl: project.imageUrl,
          progress: progress,
          items: project.items,
          budget: project.budget,
          userId: project.userId,
        );
        
        await updateProject(updatedProject);
      }
    } catch (e) {
      print('Error updating project progress: $e');
    }
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
    if (title.contains("Sofa") || title.contains("Chair")) return "Furniture";
    if (title.contains("Table")) return "Furniture";
    if (title.contains("Bed")) return "Furniture";
    if (title.contains("Shelf") || title.contains("Bookshelf")) return "Storage";
    if (title.contains("Kitchen")) return "Appliances";
    if (title.contains("Bathroom")) return "Fixtures";
    if (title.contains("Patio")) return "Outdoor";
    return "Décor";
  }
  
  String _getRoomForItem(String title) {
    if (title.contains("Sofa") || title.contains("Living")) return "Living Room";
    if (title.contains("Bed") || title.contains("Bedroom")) return "Bedroom";
    if (title.contains("Kitchen")) return "Kitchen";
    if (title.contains("Bathroom")) return "Bathroom";
    if (title.contains("Office")) return "Office";
    if (title.contains("Dining")) return "Dining Room";
    if (title.contains("Patio") || title.contains("Garden")) return "Outdoor";
    return "Other";
  }
  
  double _generateRandomPrice() {
    return (50 + (950 * (DateTime.now().millisecond / 1000))).roundToDouble();
  }
  
  double _generateRandomBudget() {
    return (1000 + (9000 * (DateTime.now().millisecond / 1000))).roundToDouble();
  }
} 