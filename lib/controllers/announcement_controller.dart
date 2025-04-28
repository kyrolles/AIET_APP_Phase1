import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:graduation_project/data/repositories/announcement_repository.dart';
import 'package:graduation_project/data/repositories/auth_repository.dart';
import 'package:graduation_project/models/app_user.dart';

// Define the state for the announcement creation process
class AnnouncementState {
  final File? image;
  final File? pdfFile;
  final bool isLoading;
  final String? errorMessage;
  final bool postSuccess; // Flag to indicate successful posting

  AnnouncementState({
    this.image,
    this.pdfFile,
    this.isLoading = false,
    this.errorMessage,
    this.postSuccess = false,
  });

  AnnouncementState copyWith({
    File? image,
    File? pdfFile,
    bool? isLoading,
    String? errorMessage,
    bool? postSuccess,
    bool clearImage = false, // Flags to explicitly handle nulling
    bool clearPdf = false,
    bool clearError = false,
  }) {
    return AnnouncementState(
      image: clearImage ? null : image ?? this.image,
      pdfFile: clearPdf ? null : pdfFile ?? this.pdfFile,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      postSuccess: postSuccess ?? this.postSuccess,
    );
  }
}

// Create the StateNotifier
class AnnouncementController extends StateNotifier<AnnouncementState> {
  final AnnouncementRepository _announcementRepository;
  final AuthRepository _authRepository;
  final ImagePicker _picker = ImagePicker();

  AnnouncementController(this._announcementRepository, this._authRepository)
      : super(AnnouncementState());

  Future<void> pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        state = state.copyWith(image: File(pickedFile.path), clearError: true);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pick image: $e');
    }
  }

  void clearImage() {
    state = state.copyWith(clearImage: true);
  }

  Future<void> pickPDF() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        state = state.copyWith(pdfFile: File(result.files.single.path!), clearError: true);
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to pick PDF: $e');
    }
  }

  void clearPdf() {
     state = state.copyWith(clearPdf: true);
  }

  Future<void> postAnnouncement({
    required String title,
    required String description,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, postSuccess: false, clearError: true);

    if (title.isEmpty || description.isEmpty) {
      state = state.copyWith(isLoading: false, errorMessage: 'Title and description cannot be empty.');
      return;
    }

    try {
      // 1. Get current user details
      final AppUser? currentUser = await _authRepository.getCurrentAppUser();
      if (currentUser == null) {
        throw Exception('User not logged in or details not found.');
      }

       // 2. Check permissions (Simplified - adapt based on actual roles)
      final bool hasPermission = _checkPermission(currentUser.role);
      if (!hasPermission) {
         throw Exception('You do not have permission to post announcements.');
      }


      // 3. Prepare announcement data
      final AnnouncementData announcementData = AnnouncementData(
        title: title,
        description: description,
        authorName: '${currentUser.firstName} ${currentUser.lastName}',
        authorEmail: currentUser.email,
        authorRole: currentUser.role,
        imageFile: state.image,
        pdfFile: state.pdfFile,
      );

      // 4. Call repository to post
      await _announcementRepository.postAnnouncement(announcementData);

      // 5. Update state on success
      state = state.copyWith(
        isLoading: false,
        postSuccess: true,
        clearImage: true, // Clear files after successful post
        clearPdf: true,
      );
        // Reset success flag after a short delay or navigation
        Future.delayed(const Duration(milliseconds: 100), () {
           if (mounted) {
              state = state.copyWith(postSuccess: false);
           }
        });


    } catch (e) {
      // 6. Update state on error
      state = state.copyWith(isLoading: false, errorMessage: 'Error posting announcement: ${e.toString()}', postSuccess: false);
    }
  }

   // Example permission check - adjust according to your actual roles
   bool _checkPermission(String role) {
      const List<String> allowedRoles = [
          'Admin',
          'IT',
          'Professor',
          'Assistant',
          'Secretary',
          'Training Unit',
          'Student Affair'
      ];
       return allowedRoles.contains(role);
   }


  // Method to clear the error message
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(clearError: true);
    }
  }
}

// Define the Provider for the controller
// Assume getIt is configured elsewhere to provide repository instances
// final authRepositoryProvider = Provider<AuthRepository>((ref) => getIt<AuthRepository>());
// final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) => getIt<AnnouncementRepository>());

// Example using placeholder providers if getIt isn't fully set up yet:
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository()); // Placeholder
final announcementRepositoryProvider = Provider<AnnouncementRepository>((ref) => AnnouncementRepository()); // Placeholder


final announcementControllerProvider = StateNotifierProvider<AnnouncementController, AnnouncementState>((ref) {
  final announcementRepository = ref.watch(announcementRepositoryProvider);
  final authRepository = ref.watch(authRepositoryProvider);
  return AnnouncementController(announcementRepository, authRepository);
});

// Helper provider to easily access the postSuccess flag
final announcementPostSuccessProvider = Provider<bool>((ref) {
  return ref.watch(announcementControllerProvider).postSuccess;
});

// Helper provider for the loading state
final announcementIsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(announcementControllerProvider).isLoading;
});

// Helper provider for the error message
final announcementErrorProvider = Provider<String?>((ref) {
  return ref.watch(announcementControllerProvider).errorMessage;
}); 