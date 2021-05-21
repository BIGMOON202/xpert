
extension StringExtensions on String {
  bool containsIgnoreCase(String secondString) => this.toLowerCase().contains(secondString.toLowerCase());

  String capitalizeFirst() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}