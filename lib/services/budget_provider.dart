import 'package:flutter/material.dart';
import 'package:decor_home/models/budget_model.dart';
import 'package:decor_home/services/budget_service.dart';

class BudgetProvider extends ChangeNotifier {
  final BudgetService _budgetService = BudgetService();
  
  List<BudgetModel> _budgets = [];
  BudgetModel? _currentBudget;
  bool _isLoading = false;
  String _error = '';
  
  // Getters
  List<BudgetModel> get budgets => _budgets;
  BudgetModel? get currentBudget => _currentBudget;
  bool get isLoading => _isLoading;
  String get error => _error;
  
  // Initialize user budgets stream
  Stream<List<BudgetModel>> getUserBudgetsStream(String userId) {
    return _budgetService.getUserBudgets(userId);
  }
  
  // Set current budget
  void setCurrentBudget(BudgetModel budget) {
    _currentBudget = budget;
    notifyListeners();
  }
  
  // Fetch user budgets
  Future<void> fetchUserBudgets(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      _budgetService.getUserBudgets(userId).listen((budgets) {
        _budgets = budgets;
        _setLoading(false);
        notifyListeners();
      }, onError: (e) {
        _setError(e.toString());
        _setLoading(false);
      });
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
    }
  }
  
  // Create new budget
  Future<bool> createBudget(BudgetModel budget) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _budgetService.createBudget(budget);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Update budget
  Future<bool> updateBudget(BudgetModel budget) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _budgetService.updateBudget(budget);
      
      // Update current budget if it's the one being updated
      if (_currentBudget != null && _currentBudget!.id == budget.id) {
        _currentBudget = budget;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Delete budget
  Future<bool> deleteBudget(String budgetId) async {
    _setLoading(true);
    _clearError();
    
    try {
      await _budgetService.deleteBudget(budgetId);
      
      // Clear current budget if it's the one being deleted
      if (_currentBudget != null && _currentBudget!.id == budgetId) {
        _currentBudget = null;
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  // Get budget distribution
  Map<String, double> getBudgetDistribution() {
    if (_currentBudget == null || _currentBudget!.categories.isEmpty) {
      return {
        'Food': 40,
        'Ingredients': 30,
        'Equipment': 30,
      };
    }
    
    return _currentBudget!.categories;
  }
  
  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  // Set error
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  // Clear error
  void _clearError() {
    _error = '';
    notifyListeners();
  }
} 
