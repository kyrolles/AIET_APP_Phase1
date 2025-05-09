import 'dart:convert';
import 'dart:io';
import 'dart:ui'; // For ImageFilter

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:graduation_project/components/multiselect_widget.dart';
import 'package:graduation_project/controllers/announcement_controller.dart'; // Import controller
import 'package:graduation_project/screens/offline_feature/reusable_offline.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart'; // Add PDFView dependency
import '../../components/my_app_bar.dart';

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
    _blurController.dispose(); // Dispose animation controller
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
              label: 'Dismiss',
              onPressed: () => controller.clearError(),
            ),
          ),
        );
      }
      // Show success message and navigate back
      if (next.postSuccess && previous?.postSuccess == false) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('Announcement posted successfully!'),
            duration: Duration(seconds: 2),
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
        title: 'Create Announcement',
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
          padding:
              const EdgeInsets.only(bottom: 20), // Add padding for scroll ends
          child: Column(
            children: [
              // Title input field (unchanged structure)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    16.0, 16.0, 16.0, 8.0), // Adjust padding
                child: TextField(
                  controller: _titleController,
                  enabled: !state.isLoading, // Disable when loading
                  textDirection: _isArabic(_titleController.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onChanged: (value) {
                    setState(() {}); // Keep for text direction updates
                  },
                  decoration: InputDecoration(
                    labelText: 'Title', // Use labelText
                    hintText: 'Enter announcement title',
                    hintTextDirection: _isArabic(_titleController.text)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    border: const OutlineInputBorder(),
                    filled: true, // Add fill color for better visuals
                    fillColor:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                            Colors.grey.shade100,
                  ),
                ),
              ),
              // Description input field (unchanged structure)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _descriptionController,
                  enabled: !state.isLoading, // Disable when loading
                  maxLines: 5,
                  textDirection: _isArabic(_descriptionController.text)
                      ? TextDirection.rtl
                      : TextDirection.ltr,
                  onChanged: (value) {
                    setState(() {}); // Keep for text direction updates
                  },
                  decoration: InputDecoration(
                    labelText: 'Description', // Use labelText
                    hintText: 'Write your announcement here...',
                    hintTextDirection: _isArabic(_descriptionController.text)
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    border: const OutlineInputBorder(),
                    filled: true, // Add fill color
                    fillColor:
                        Theme.of(context).inputDecorationTheme.fillColor ??
                            Colors.grey.shade100,
                  ),
                ),
              ),
              // File Attachment Section
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment
                      .stretch, // Make buttons take full width
                  children: [
                    // Image Section
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
                      )
                    else
                      OutlinedButton.icon(
                        // Use OutlinedButton for visual consistency
                        onPressed: state.isLoading
                            ? null
                            : () => controller.pickImage(),
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Add Image'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                              double.infinity, 45), // Consistent height
                          padding: const EdgeInsets.symmetric(
                              vertical: 12), // Adjust padding
                        ),
                      ),

                    const SizedBox(height: 10),

                    // PDF Section
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
                      )
                    else
                      OutlinedButton.icon(
                        // Use OutlinedButton
                        onPressed:
                            state.isLoading ? null : () => controller.pickPDF(),
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Add PDF'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(
                              double.infinity, 45), // Consistent height
                          padding: const EdgeInsets.symmetric(
                              vertical: 12), // Adjust padding
                        ),
                      ),
                  ],
                ),
              ),
              MultiSelectWidget(
                options: const ['General', '1st', '2nd', '3rd', '4th'],
                title: 'Select Years',
                onSelectionChanged: (selectedYears) {
                  setState(() {
                    _selectedYears = selectedYears;
                  });
                },
              ),
              MultiSelectWidget(
                options: const ['CE', 'ECE', 'EME', 'IE'],
                title: 'Select Programs',
                onSelectionChanged: (selectedDepartments) {
                  setState(() {
                    _selectedDepartments = selectedDepartments;
                  });
                },
              ),

              const SizedBox(height: 20), // Add some spacing at the bottom
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
    return Card(
      elevation: 2, // Add slight elevation
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(fileName,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14)),
        onTap: onTap,
        trailing: IconButton(
          icon: const Icon(Icons.close,
              size: 20, color: Colors.redAccent), // Smaller, colored close icon
          onPressed: onRemove,
          tooltip: 'Remove',
          splashRadius: 20, // Smaller splash radius
        ),
        dense: true, // Make tile more compact
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
