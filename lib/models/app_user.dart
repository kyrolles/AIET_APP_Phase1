class AppUser {
  final String id; // Firestore document ID
  final String firstName;
  final String lastName;
  final String email;
  final String role;
  // Add any other relevant user fields

  AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  // Factory constructor to create an AppUser from a Firestore document map
  factory AppUser.fromMap(Map<String, dynamic> data, String documentId) {
    return AppUser(
      id: documentId,
      firstName: data['firstName'] ?? '', // Provide default values or handle nulls
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '', 
      role: data['role'] ?? 'Unknown', // Default role if missing
    );
  }

  // Optional: Method to convert AppUser instance to a map (e.g., for updates)
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      // Don't include id as it's the document ID
    };
  }
} 