// Make sure the admin schedule controller provider is properly defined
final adminScheduleControllerProvider = StateNotifierProvider<AdminScheduleController, AdminScheduleState>((ref) {
  final scheduleService = ref.watch(scheduleServiceProvider);
  return AdminScheduleController(scheduleService);
}); 