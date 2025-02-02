import 'package:excel/excel.dart';
import 'dart:io';

Future<List<Map<String, dynamic>>> parseExcelFile(File file) async {
  var bytes = file.readAsBytesSync();
  var excel = Excel.decodeBytes(bytes);
  List<Map<String, dynamic>> data = [];

  var sheet = excel.tables.values.first; // Assuming the first sheet
  for (var row in sheet.rows.skip(1)) { // Skip the header row
    if (row.isNotEmpty) {
      data.add({
        'bib_number': row[0]?.value.toString() ?? '',
        'first_name': row[1]?.value.toString() ?? '',
        'last_name': row[2]?.value.toString() ?? '',
        'gender': row[3]?.value.toString() ?? '',
        'date_of_birth': row[4]?.value.toString() ?? '',
        'address': row[5]?.value.toString() ?? '',
        'city': row[6]?.value.toString() ?? '',
        'province': row[7]?.value.toString() ?? '',
        'country': row[8]?.value.toString() ?? '',
        'email': row[9]?.value.toString() ?? '',
        'cellphone': row[10]?.value.toString() ?? '',
        'category': row[11]?.value.toString() ?? '',
        'start_time': row[12]?.value.toString() ?? '',
        'finish_time': row[13]?.value.toString() ?? '',
        'average_pace': row[14]?.value.toString() ?? '',
        'splits': row[15]?.value.toString() ?? '',
      });
    }
  }
  return data;
}
