import '../services/medicine_service.dart';

// Helper function to seed data - can be called from anywhere in the app
Future<void> runSeedData() async {
  final medicineService = MedicineService();
  await medicineService.seedSampleData();
}

