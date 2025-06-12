import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:graduation_project/components/kbutton.dart';
import 'package:graduation_project/constants.dart';
import 'package:graduation_project/controllers/announcement_controller.dart'; // Import controller
import 'package:graduation_project/screens/announcement/share_olnly_bottomsheet.dart';
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Add PDFView dependency
import '../../components/my_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Convert to ConsumerStatefulWidget
class AnnouncementScreen extends ConsumerStatefulWidget {
  const AnnouncementScreen({super.key});

  @override
  ConsumerState<AnnouncementScreen> createState() => _AnnouncementScreenState();
}

// Convert to ConsumerState
class _AnnouncementScreenState extends ConsumerState<AnnouncementScreen>
    with TickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();

  List<String> _selectedYears = [];
  List<String> _selectedDepartments = [];

  // Animation controller for image viewer blur effect
  late AnimationController _blurController;
  late Animation<double> _blurAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller
    _blurController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Define the blur animation
    _blurAnimation = Tween<double>(begin: 0, end: 10).animate(_blurController);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _blurController.dispose();
    _descriptionFocusNode.dispose(); // Make sure to dispose the focus node
    super.dispose();
  }

  // Function to check if text is likely Arabic (keep if needed for text direction)
  bool _isArabic(String text) {
    if (text.isEmpty) return false; // Default to LTR if empty
    // Basic check: Look for characters in the Arabic Unicode range
    final arabicRegex = RegExp(r'[؀-ۿ]');
    return arabicRegex.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the controller state
    final localizations = AppLocalizations.of(context);
    final AnnouncementState state = ref.watch(announcementControllerProvider);
    final AnnouncementController controller =
        ref.read(announcementControllerProvider.notifier);

    // Listen for errors or success to show Snackbars and navigate
    ref.listen<AnnouncementState>(announcementControllerProvider,
        (previous, next) {
      // Show error message
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context)
            .removeCurrentSnackBar(); // Remove previous snackbar if any
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(next.errorMessage!),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              // Optional: Allow dismissing the error
              label: localizations?.dismiss ?? 'Dismiss',
              onPressed: () => controller.clearError(),
            ),
          ),
        );
      }
      // Show success message and navigate back
      if (next.postSuccess && previous?.postSuccess == false) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(localizations?.announcementPostedSuccessfully ??
                'Announcement posted successfully!'),
            duration: const Duration(seconds: 2),
          ),
        );
        // Clear text fields after successful post
        _titleController.clear();
        _descriptionController.clear();
        // Use WidgetsBinding to ensure build is complete before navigation
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            Navigator.pop(context, true); // Navigate back, indicating success
          }
        });
      }
    });
    return Scaffold(
      appBar: MyAppBar(
        title: localizations?.createAnnouncement ?? 'Create Announcement',
        actions: [
          // Show loading indicator or send icon
          state.isLoading
              ? const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Center(
                      child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.0))),
                )
              : IconButton(
                  icon: const Icon(Icons.send),
                  color: kBlue,
                  // Call controller's post method
                  onPressed: () {
                    // Ensure keyboard is dismissed
                    FocusScope.of(context).unfocus();
                    controller.postAnnouncement(
                      title: _titleController.text,
                      description: _descriptionController.text,
                      years: _selectedYears,
                      departments: _selectedDepartments,
                    );
                  },
                ),
        ],
        onpressed: () {
          if (!state.isLoading) {
            // Prevent popping while loading
            Navigator.pop(context);
          }
        },
      ),
      body: ReusableOffline(
        // Keep ReusableOffline wrapper if needed
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Title input field (unchanged structure)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16.0, 16, 16.0, 0), // Adjust padding
                child: TextField(
                  controller: _titleController,
                  enabled: !state.isLoading, // Disable when loading
                  textDirection: _isArabic(_titleController.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                  onChanged: (value) {
                    setState(() {}); // Keep for text direction updates
                  },
                  decoration: InputDecoration(
                    labelText:
                        '  ${localizations?.title ?? 'Title'}', // Use labelText
                    labelStyle: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.w400,
                        color: kGrey),
                    hintText: localizations?.enterAnnouncementTitle ??
                        'Enter announcement title',
                    hintStyle: const TextStyle(
                      fontSize: 18,
                      color: kGrey,
                    ),
                    hintTextDirection: _isArabic(_titleController.text)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    filled: true, // Add fill color for better visuals
                    fillColor:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                            Colors.white,
                    border: InputBorder.none, // Remove border
                  ),
                ),
              ),
              // Description input field with tap-to-focus capability
              GestureDetector(
                onTap: () {
                  // Request focus when tapping anywhere in this area
                  _descriptionFocusNode.requestFocus();
                },
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 16.0, right: 16, bottom: 8.0),
                  child: Container(
                    constraints: BoxConstraints(
                      minHeight: 200,
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).inputDecorationTheme.fillColor ??
                          Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: TextField(
                        controller: _descriptionController,
                        focusNode:
                            _descriptionFocusNode, // Add this line to connect the focus node
                        enabled: !state.isLoading,
                        maxLines: null,
                        keyboardType: TextInputType.multiline,
                        textDirection: _isArabic(_descriptionController.text)
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.5,
                        ),
                        decoration: InputDecoration(
                          labelText:
                              localizations?.description ?? 'Description',
                          alignLabelWithHint: true,
                          hintText: localizations?.writeAnnouncementHere ??
                              'Write your announcement here...',
                          hintStyle: const TextStyle(
                            fontSize: 18,
                            color: kGrey,
                          ),
                          hintTextDirection:
                              _isArabic(_descriptionController.text)
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                          border: InputBorder.none,
                          labelStyle:
                              const TextStyle(fontSize: 20, color: kGrey),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            bottom: 16,
                          ),
                        ),
                        scrollPhysics: const NeverScrollableScrollPhysics(),
                      ),
                    ),
                  ),
                ),
              ),
              // File Attachment Previews Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image Preview (if selected)
                    if (state.image != null)
                      _buildAttachmentPreview(
                        context: context,
                        file: state.image!,
                        onRemove: state.isLoading
                            ? null
                            : () => controller.clearImage(),
                        onTap: state.isLoading
                            ? null
                            : () => _viewImage(context, state.image!),
                        icon: Icons.image,
                      ),
                    // PDF Preview (if selected)
                    if (state.pdfFile != null)
                      _buildAttachmentPreview(
                        context: context,
                        file: state.pdfFile!,
                        onRemove: state.isLoading
                            ? null
                            : () => controller.clearPdf(),
                        onTap: state.isLoading
                            ? null
                            : () => _viewPdf(context, state.pdfFile!),
                        icon: Icons.picture_as_pdf,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Add Image button
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed:
                      state.isLoading ? null : () => controller.pickImage(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: const CircleBorder(),
                  ),
                  child: Icon(
                    state.image == null ? Icons.image_outlined : Icons.edit,
                    size: 30, // Bigger icon
                    color: kBlue,
                  ),
                ),
              ),

              // Add/Change PDF button - Icon only
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed:
                      state.isLoading ? null : () => controller.pickPDF(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(12),
                    shape: const CircleBorder(),
                  ),
                  child: Icon(
                    state.pdfFile == null ? Icons.attach_file : Icons.edit,
                    size: 30, // Bigger icon
                    color: kBlue,
                  ),
                ),
              ), // Share Only To button - Icon only
              Expanded(
                flex: 2,
                child: KButton(
                  text: localizations?.shareOnlyTo ?? 'Share Only To',
                  fontSize: 16,
                  borderColor: kBlue,
                  textColor: kBlue,
                  backgroundColor: Colors.white,
                  borderWidth: 1,
                  height: 45, // Match height with other buttons
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => SharingOptionsBottomSheet(
                        initialSelectedYears: _selectedYears,
                        initialSelectedDepartments: _selectedDepartments,
                        onApply: (years, departments) {
                          setState(() {
                            _selectedYears = years;
                            _selectedDepartments = departments;
                          });
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget to display attached file preview
  Widget _buildAttachmentPreview({
    required BuildContext context,
    required File file,
    required VoidCallback? onRemove,
    required VoidCallback? onTap,
    required IconData icon,
  }) {
    final String fileName = file.path.split(Platform.pathSeparator).last;
    final bool isImage = icon == Icons.image;

    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBlue.withOpacity(0.3), width: 1),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // File Type Visualization
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: isImage
                        ? kPrimaryColor.withOpacity(0.1)
                        : kBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: isImage && file.existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            file,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                              icon,
                              size: 30,
                              color: isImage ? kPrimaryColor : kBlue,
                            ),
                          ),
                        )
                      : Icon(
                          icon,
                          size: 30,
                          color: isImage ? kPrimaryColor : kBlue,
                        ),
                ),

                const SizedBox(width: 16),

                // File Information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isImage
                            ? 'Image file - Tap to view'
                            : 'PDF document - Tap to open',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

                // Remove Button
                if (onRemove != null)
                  Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    child: InkWell(
                      onTap: onRemove,
                      borderRadius: BorderRadius.circular(50),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          Icons.close,
                          size: 24,
                          color: Colors.red[400],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show full-screen image dialog (adapted from UploadImage)
  Future<void> _viewImage(BuildContext context, File imageFile) async {
    // Read file bytes and encode on the fly
    late final String imageBase64;
    try {
      final bytes = await imageFile.readAsBytes();
      imageBase64 = base64Encode(bytes);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reading image file: $e')));
      return;
    }

    _blurController.forward();
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing by tapping outside initially
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          child: AnimatedBuilder(
            animation: _blurAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  // Blurred background
                  Positioned.fill(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: _blurAnimation.value,
                        sigmaY: _blurAnimation.value,
                      ),
                      child: Container(
                          // Use GestureDetector on background to close
                          child: GestureDetector(
                        onTap: () {
                          _blurController.reverse().then((_) {
                            if (Navigator.canPop(context)) {
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: Container(color: Colors.black.withOpacity(0.6)),
                      )),
                    ),
                  ),
                  // Interactive Image Viewer
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: InteractiveViewer(
                      panEnabled: true,
                      boundaryMargin: const EdgeInsets.all(20), // Add margin
                      minScale: 0.8, // Allow zooming out slightly
                      maxScale: 4.0,
                      child: Center(
                        child: Padding(
                          padding:
                              const EdgeInsets.all(8.0), // Padding around image
                          child: Image.memory(
                            base64Decode(imageBase64),
                            fit: BoxFit.contain,
                            // Add error builder for safety
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Text('Could not load image',
                                        style: TextStyle(color: Colors.white))),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Close button (optional, as background tap also closes)
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 30),
                      onPressed: () {
                        _blurController.reverse().then((_) {
                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop();
                          }
                        });
                      },
                    ),
                  )
                ],
              );
            },
          ),
        );
      },
    );
  }

  // Navigate to view PDF using flutter_pdfview
  void _viewPdf(BuildContext context, File pdfFile) {
    if (!pdfFile.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: PDF file not found')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(pdfFile.path
                .split(Platform.pathSeparator)
                .last), // Show filename in AppBar
          ),
          body: PDFView(
            filePath: pdfFile.path,
            onError: (error) {
              print(error.toString());
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error loading PDF: $error')));
              });
            },
            onPageError: (page, error) {
              print('$page: ${error.toString()}');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error on PDF page $page: $error')));
              });
            },
          ),
        ),
      ),
    );
  }
}

// Remove these if they were defined locally and not imported
// class ImageViewScreen extends StatelessWidget { ... }
// class PdfViewScreen extends StatelessWidget { ... }

// Keep the UploadImage and UploadPdf widgets if they are separate components used elsewhere,
// otherwise, their functionality is now integrated or handled by the controller/preview.
// Consider deleting upload_image.dart and upload_pdf.dart if they are no longer needed.

// The widgets all_announcement_appear_on_one_screen.dart, announcement_item.dart,
// and announcement_list.dart are likely for displaying announcements and are not
// directly affected by this refactoring of the creation screen, unless they
// need to be updated to use a new way of fetching announcements (e.g., via a provider).

// Helper function to get the month name - Keep if needed elsewhere, maybe move to utils
String _getMonthName(int month) {
  switch (month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}

// Helper function to format the timestamp - Keep if needed elsewhere, maybe move to utils
String _formatTimestamp(DateTime dateTime) {
  final hour = dateTime.hour > 12 ? dateTime.hour - 12 : dateTime.hour;
  final hourString = hour == 0 ? '12' : hour.toString(); // Handle midnight/noon
  final period = dateTime.hour >= 12 ? 'PM' : 'AM';
  final month = _getMonthName(dateTime.month);
  return '$hourString:${dateTime.minute.toString().padLeft(2, '0')} $period · $month ${dateTime.day}, ${dateTime.year}';
}
