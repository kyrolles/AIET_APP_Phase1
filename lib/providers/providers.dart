import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/admin_schedule_controller.dart';
import '../services/schedule_service.dart';

// Define schedule service provider
final scheduleServiceProvider = Provider<ScheduleService>((ref) {
  return ScheduleService();
});

// Make sure the admin schedule controller provider is properly defined
final adminScheduleControllerProvider = StateNotifierProvider<AdminScheduleController, AdminScheduleState>((ref) {
  final scheduleService = ref.watch(scheduleServiceProvider);
  return AdminScheduleController(scheduleService);
}); 