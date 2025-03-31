import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:decor_home/models/budget_model.dart';

class BudgetService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Collection reference
  CollectionReference get _budgetsCollection => _firestore.collection('budgets');
  
  // Get user budgets stream
  Stream<List<BudgetModel>> getUserBudgets(String userId) {
    return _budgetsCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return BudgetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();
        });
  }
  
  // Create new budget
  Future<String> createBudget(BudgetModel budget) async {
    try {
      DocumentReference docRef = await _budgetsCollection.add(budget.toMap());
      return docRef.id;
    } catch (e) {
      print('Error creating budget: $e');
      throw e;
    }
  }
  
  // Update budget
  Future<void> updateBudget(BudgetModel budget) async {
    try {
      if (budget.id == null) {
        throw Exception('Budget ID cannot be null for update operation');
      }
      
      await _budgetsCollection.doc(budget.id).update(budget.toMap());
    } catch (e) {
      print('Error updating budget: $e');
      throw e;
    }
  }
  
  // Delete budget
  Future<void> deleteBudget(String budgetId) async {
    try {
      await _budgetsCollection.doc(budgetId).delete();
    } catch (e) {
      print('Error deleting budget: $e');
      throw e;
    }
  }
  
  // Get single budget
  Future<BudgetModel?> getBudget(String budgetId) async {
    try {
      DocumentSnapshot doc = await _budgetsCollection.doc(budgetId).get();
      
      if (!doc.exists) {
        return null;
      }
      
      return BudgetModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      print('Error getting budget: $e');
      throw e;
    }
  }
} 
