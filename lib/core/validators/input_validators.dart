class InputValidators {
  static String? validateFullName(String value) {
    if (value.trim().isEmpty) {
      return 'Full name is required';
    }
    return null;
  }

  static String? validateSteps(int value) {
    final steps = value;

    if (steps < 500) {
      return 'Minimum 500 steps';
    }

    if (steps > 50000) {
      return 'Slow Down,Speedster';
    }
    return null;
  }

  static String? validateEmail(String value) {
    final email = value.trim();

    if (email.isEmpty) {
      return 'Email is required';
    }

    if (email.contains(' ')) {
      return 'Email cannot contain spaces';
    }

    if (email != email.toLowerCase()) {
      return 'Email cannot contain capital letters';
    }

    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email';
    }

    return null;
  }

  static String? validateUsername(String value) {
    value = value.trim();

    if (value.isEmpty) {
      return 'Username cannot be empty';
    }

    if (value.contains(' ')) {
      return 'Username cannot contain spaces';
    }

    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }

    if (value.length > 15) {
      return 'Username cannot exceed 15 characters';
    }

    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty) {
      return 'Password is required';
    }

    if (value.contains(' ')) {
      return 'Password cannot contain spaces';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    return null;
  }
}