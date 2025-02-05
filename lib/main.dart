import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:animate_do/animate_do.dart'; // Animation Package

class CourseSelectionScreen extends StatefulWidget {
  @override
  _CourseSelectionScreenState createState() => _CourseSelectionScreenState();
}

class _CourseSelectionScreenState extends State<CourseSelectionScreen> {
  List<List<dynamic>> csvData = [];
  String? selectedLevel;
  String? selectedSubject;
  String? selectedIsPaid;
  List<Map<String, dynamic>> filteredCourses = [];

  List<String> levels = [];
  List<String> subjects = [];
  List<String> isPaidOptions = [];

  @override
  void initState() {
    super.initState();
  }

  Future<void> loadCsvDataFromFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      try {
        File file = File(result.files.single.path!);
        String rawCsv = await file.readAsString();
        List<List<dynamic>> csvTable = CsvToListConverter().convert(rawCsv);

        if (csvTable.isEmpty) {
          showErrorDialog("The CSV file is empty.");
          return;
        }

        setState(() {
          csvData = csvTable.sublist(1); // Skip header row

          levels = csvData.map((row) => row[8].toString()).toSet().toList();
          subjects = csvData.map((row) => row[11].toString()).toSet().toList();
          isPaidOptions =
              csvData.map((row) => row[3].toString()).toSet().toList();
        });

        print("CSV Loaded: ${csvData.length} rows");
      } catch (e) {
        showErrorDialog("Error reading CSV file: $e");
      }
    } else {
      print("No file selected.");
    }
  }

  final List<String> selectedCategories = [
    'Business Finance',
    'Graphic Design',
    'Musical Instruments',
    'Web Development'
  ];
  // final List<String> selectedLevels2 = [
  //   'All Levels',
  //   'Beginner Level',
  //   'InterMediate Level',
  //   'Expert Level',
  // ];
  // final List<String> selectedcost = [
  //   'ree',
  //   'Paid',
  // ];

  void showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  void filterCourses() {
    setState(() {
      filteredCourses = csvData
          .where((row) =>
              (selectedLevel == null || row[8] == selectedLevel) &&
              (selectedSubject == null || row[11] == selectedSubject) &&
              (selectedIsPaid == null || row[3].toString() == selectedIsPaid))
          .map((row) => {
                "course_id": row[0],
                "course_title": row[1],
                "url": row[2],
                "is_paid": row[3],
                "price": row[4],
                "num_subscribers": row[5],
                "num_reviews": row[6],
                "num_lectures": row[7],
                "level": row[8],
                "content_duration": row[9],
                "published_timestamp": row[10],
                "subject": row[11],
                "profit": row[12],
                "published_date": row[13],
                "published_time": row[14],
                "year": row[15],
                "month": row[16],
                "day": row[17],
                "rating": row[18]
              })
          .toList();
    });
  }

  Widget buildStyledDropdown(String hint, String? selectedValue,
      List<String> options, Function(String?) onChanged) {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Container(
        width: 300,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              blurRadius: 8,
              offset: Offset(2, 4),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            hint: Text(hint,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            dropdownColor: Colors.purpleAccent,
            icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
            value: selectedValue,
            items: options.map((option) {
              return DropdownMenuItem(
                value: option,
                child:
                    Text(option, style: const TextStyle(color: Colors.white)),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Course Finder"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color.fromARGB(255, 237, 213, 175),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: loadCsvDataFromFile,
              child: Text("Upload CSV File"),
            ),
            if (csvData.isNotEmpty) ...[
              const SizedBox(height: 10),
              buildStyledDropdown(
                  "Select Subject", selectedSubject, selectedCategories,
                  (value) {
                setState(() {
                  selectedSubject = value;
                });
              }),
              const SizedBox(height: 10),
              buildStyledDropdown("Select Level", selectedLevel, levels,
                  (value) {
                setState(() {
                  selectedLevel = value;
                });
              }),
              const SizedBox(height: 10),
              buildStyledDropdown("Is Paid?", selectedIsPaid, isPaidOptions,
                  (value) {
                setState(() {
                  selectedIsPaid = value;
                });
              }),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: filterCourses,
                child: Text("Filter Courses"),
              ),
            ],
            Expanded(
              child: ListView.builder(
                itemCount: filteredCourses.length,
                itemBuilder: (context, index) {
                  var course = filteredCourses[index];
                  return FadeInLeft(
                    duration: Duration(milliseconds: 500),
                    child: Card(
                      elevation: 4,
                      child: ListTile(
                        title: Text(course["course_title"],
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                            "Subject: ${course["subject"]} | Level: ${course["level"]}"),
                        trailing: Text("⭐ ${course["rating"]}"),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: const Color.fromARGB(255, 233, 146, 146),
      primaryColor: Colors.blueAccent,
    ),
    home: CourseSelectionScreen(),
  ));
}
