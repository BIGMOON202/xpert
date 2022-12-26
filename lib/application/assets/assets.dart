class Assets {
  static _ImagesAsset images = const _ImagesAsset();
}

class _ImagesAsset {
  const _ImagesAsset();
  final String _path = 'assets/images';
  String get addPerson => '$_path/person_add-24px.png';
  String get circleSuccess => '$_path/circle_success.png';
  String get logoXpertfit => '$_path/logo_xpertfit.png';
}
