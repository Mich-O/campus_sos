class CloudinaryConfig {
  CloudinaryConfig._();
  // These are public identifiers. Never put a Cloudinary API secret in the app.
  static const cloudName = 'px7mja9s';
  static const unsignedUploadPreset = 'campus_sos_mobile';
  static bool get isConfigured =>
      cloudName.isNotEmpty &&
      unsignedUploadPreset.isNotEmpty;
}
