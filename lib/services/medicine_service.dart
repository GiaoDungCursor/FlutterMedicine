import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medicine.dart';
import '../utils/constants.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // SELECT - Get all medicines
  Stream<List<Medicine>> getAllMedicines() {
    return _firestore
        .collection(AppConstants.medicinesCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Medicine.fromMap(doc.id, doc.data()))
            .toList());
  }

  // SELECT - Get medicine by ID
  Future<Medicine?> getMedicineById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.medicinesCollection)
          .doc(id)
          .get();

      if (doc.exists) {
        return Medicine.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      throw Exception('Failed to get medicine: $e');
    }
  }

  // SELECT - Search medicines by name
  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.medicinesCollection)
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return snapshot.docs
          .map((doc) => Medicine.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to search medicines: $e');
    }
  }

  // SELECT - Get medicines by category
  Stream<List<Medicine>> getMedicinesByCategory(String category) {
    return _firestore
        .collection(AppConstants.medicinesCollection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) {
          final medicines = snapshot.docs
              .map((doc) => Medicine.fromMap(doc.id, doc.data() as Map<String, dynamic>))
              .toList();
          // Sort by createdAt descending on client side to avoid needing composite index
          medicines.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return medicines;
        });
  }

  // INSERT - Add new medicine
  Future<String> addMedicine(Medicine medicine) async {
    try {
      DocumentReference docRef = await _firestore
          .collection(AppConstants.medicinesCollection)
          .add(medicine.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add medicine: $e');
    }
  }

  // UPDATE - Update existing medicine
  Future<void> updateMedicine(String id, Medicine medicine) async {
    try {
      Medicine updatedMedicine = medicine.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.medicinesCollection)
          .doc(id)
          .update(updatedMedicine.toMap());
    } catch (e) {
      throw Exception('Failed to update medicine: $e');
    }
  }

  // DELETE - Delete medicine
  Future<void> deleteMedicine(String id) async {
    try {
      await _firestore
          .collection(AppConstants.medicinesCollection)
          .doc(id)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete medicine: $e');
    }
  }

  // Seed sample data
  Future<void> seedSampleData() async {
    final sampleMedicines = [
      {
        'name': 'Paracetamol 500mg',
        'price': 15000.0,
        'description': 'Thuốc giảm đau, hạ sốt. Dùng cho người lớn và trẻ em trên 12 tuổi.',
        'category': 'Giảm đau',
        'stock': 100,
        'manufacturer': 'Traphaco',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Amoxicillin 500mg',
        'price': 25000.0,
        'description': 'Kháng sinh điều trị nhiễm khuẩn đường hô hấp, tiết niệu.',
        'category': 'Kháng sinh',
        'stock': 80,
        'manufacturer': 'Hậu Giang Pharma',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Vitamin C 1000mg',
        'price': 30000.0,
        'description': 'Bổ sung vitamin C, tăng cường sức đề kháng.',
        'category': 'Vitamin',
        'stock': 150,
        'manufacturer': 'Domesco',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Ibuprofen 400mg',
        'price': 20000.0,
        'description': 'Thuốc chống viêm, giảm đau, hạ sốt.',
        'category': 'Giảm đau',
        'stock': 90,
        'manufacturer': 'Pharmedic',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Cefuroxime 250mg',
        'price': 45000.0,
        'description': 'Kháng sinh phổ rộng điều trị nhiễm khuẩn.',
        'category': 'Kháng sinh',
        'stock': 60,
        'manufacturer': 'Traphaco',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Vitamin D3 2000IU',
        'price': 35000.0,
        'description': 'Bổ sung vitamin D3, hỗ trợ hấp thu canxi.',
        'category': 'Vitamin',
        'stock': 120,
        'manufacturer': 'Domesco',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Dextromethorphan 15mg',
        'price': 18000.0,
        'description': 'Thuốc giảm ho, điều trị ho khan.',
        'category': 'Thuốc ho',
        'stock': 110,
        'manufacturer': 'Hậu Giang Pharma',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Pseudoephedrine 60mg',
        'price': 22000.0,
        'description': 'Thuốc thông mũi, giảm nghẹt mũi do cảm cúm.',
        'category': 'Thuốc cảm',
        'stock': 95,
        'manufacturer': 'Pharmedic',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Omeprazole 20mg',
        'price': 28000.0,
        'description': 'Thuốc điều trị viêm loét dạ dày, trào ngược dạ dày.',
        'category': 'Thuốc tiêu hóa',
        'stock': 85,
        'manufacturer': 'Traphaco',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      {
        'name': 'Amlodipine 5mg',
        'price': 40000.0,
        'description': 'Thuốc điều trị tăng huyết áp, đau thắt ngực.',
        'category': 'Thuốc tim mạch',
        'stock': 70,
        'manufacturer': 'Domesco',
        'imageUrl': '',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
    ];

    for (var medicineData in sampleMedicines) {
      try {
        await _firestore
            .collection(AppConstants.medicinesCollection)
            .add(medicineData);
      } catch (e) {
        throw Exception('Failed to seed data: $e');
      }
    }
  }
}

