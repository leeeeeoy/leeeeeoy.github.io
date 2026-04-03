abstract class AppEnv {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue:
        'https://leeeeeoy-portfolio-backend.leeeeeoy-cloudflare.workers.dev',
  );

  static const String assetsBaseUrl = String.fromEnvironment(
    'ASSETS_BASE_URL',
    defaultValue: 'https://assets.leeeeeoy.xyz',
  );

  static String assetUrl(String? relativePath) {
    if (relativePath == null || relativePath.isEmpty) return '';
    return '$assetsBaseUrl/$relativePath';
  }
}
