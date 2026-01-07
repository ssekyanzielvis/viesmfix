extension StringExtensions on String {
  // Capitalization
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  // Validation
  bool get isEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(this);
  }

  bool get isValidPassword {
    return length >= 8;
  }

  bool get isValidUsername {
    return length >= 3 &&
        length <= 30 &&
        RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(this);
  }

  // Truncation
  String truncate(int maxLength, {String suffix = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - suffix.length)}$suffix';
  }

  // Remove HTML tags
  String removeHtmlTags() {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }

  // Parse release year from date string
  String? get releaseYear {
    if (isEmpty) return null;
    try {
      final date = DateTime.parse(this);
      return date.year.toString();
    } catch (e) {
      return null;
    }
  }

  // Format date
  String formatDate() {
    try {
      final date = DateTime.parse(this);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return this;
    }
  }
}

extension NullableStringExtensions on String? {
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  bool get isNotNullOrEmpty => !isNullOrEmpty;
}
