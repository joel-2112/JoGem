import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  // Private constructor to prevent instantiation
  Config._();

  // Static method to load the .env file
  static Future<void> init() async {
    await dotenv.load(fileName: ".env");
  }

  // Static getters for environment variables
  static String get apiKey => dotenv.env['API_KEY'] ?? 'Not available';
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'Not available';

  // Add more getters as needed
}