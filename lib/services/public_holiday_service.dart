import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/public_holiday.dart';

class PublicHolidayService {
  static const String baseUrl = 'https://date.nager.at/api/v3';

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _getFileForYear(int year) async {
    final path = await _localPath;
    return File('$path/holidays_$year.json');
  }

  Future<List<PublicHoliday>> getHolidays([int? year]) async {
    final targetYear = year ?? DateTime.now().year;

    try {
      // Try to read from local file first
      final file = await _getFileForYear(targetYear);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        return jsonList.map((json) => PublicHoliday.fromJson(json)).toList();
      }
    } catch (e) {
      print('Error reading local file: $e');
    }

    // If local file doesn't exist or there's an error, fetch from API
    return _fetchHolidaysFromApi(targetYear);
  }

  Future<List<PublicHoliday>> _fetchHolidaysFromApi(int year) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/PublicHolidays/$year/HK'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final holidays =
            jsonList.map((json) => PublicHoliday.fromJson(json)).toList();

        // Save to local file
        await _saveToFile(jsonList, year);

        return holidays;
      } else {
        throw Exception('Failed to load holidays');
      }
    } catch (e) {
      print('Error fetching from API: $e');
      rethrow;
    }
  }

  Future<void> _saveToFile(List<dynamic> data, int year) async {
    try {
      final file = await _getFileForYear(year);
      await file.writeAsString(json.encode(data));
    } catch (e) {
      print('Error saving to file: $e');
    }
  }

  Future<bool> isCacheValidForYear(int year) async {
    try {
      final file = await _getFileForYear(year);
      if (await file.exists()) {
        final contents = await file.readAsString();
        final List<dynamic> jsonList = json.decode(contents);
        if (jsonList.isNotEmpty) {
          final firstHoliday = PublicHoliday.fromJson(jsonList.first);
          return firstHoliday.date.year == year;
        }
      }
    } catch (e) {
      print('Error checking cache validity: $e');
    }
    return false;
  }

  Future<List<PublicHoliday>> refreshHolidaysForYear(int year) async {
    final file = await _getFileForYear(year);
    if (await file.exists()) {
      await file.delete();
    }
    return getHolidays(year);
  }
}
