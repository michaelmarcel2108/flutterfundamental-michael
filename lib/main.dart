import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Michael Marcel Hartono';
const String studentId = '2455011003';

final List<Map<String, dynamic>> topics = [
  {'title': 'Git & GitHub', 'subtitle': 'Version control', 'done': true},
  {'title': 'Dart Fundamentals', 'subtitle': 'Language basics', 'done': true},
  {'title': 'Flutter UI Fundamentals', 'subtitle': 'Widgets & layout', 'done': false},
  {'title': '$studentId - $studentName', 'subtitle': 'Pemilik aplikasi', 'done': false},
];

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString('assets/data/student_data.json');
  return jsonDecode(jsonString) as Map<String, dynamic>;
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DashboardPage(),
    );
  }

  Widget buildStatCard(String value, String label, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

class GreetingCard extends StatefulWidget {
  const GreetingCard({super.key});

  @override
  State<GreetingCard> createState() => _GreetingCardState();
}

class _GreetingCardState extends State<GreetingCard> {
  final TextEditingController controller = TextEditingController();
  String message = 'Belum ada pesan';

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '$studentId - $studentName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Ketik pesan di sini...',
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () {
            setState(() {
              message = controller.text.trim().isEmpty
                  ? 'Input masih kosong'
                  : controller.text.trim();
            });
          },
          child: const Text('Tampilkan'),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late Future<Map<String, dynamic>> studentFuture;

  @override
  void initState() {
    super.initState();
    studentFuture = loadStudentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Dashboard'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: studentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
            }

            final data = snapshot.data!;
            final student = data['student'] as Map<String, dynamic>;
            final courses = data['courses'] as List<dynamic>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                ProfileHeader(student: student),
                SummaryRow(courses: courses),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Daftar Materi',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final course = courses[index] as Map<String, dynamic>;
                      return CourseItemWidget(course: course);
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final Map<String, dynamic> student;
  const ProfileHeader({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/images/profile.jpeg'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text('NIM: ${student['nim']}'),
                const SizedBox(height: 4),
                Text(
                  'Program Studi: ${student['major'] ?? '-'}',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class SummaryRow extends StatelessWidget {
  final List<dynamic> courses;
  const SummaryRow({super.key, required this.courses});

  @override
  Widget build(BuildContext context) {
    final totalCourses = courses.length;
    final totalCredits = courses.fold<int>(0, (sum, course) => sum + ((course['credits'] as int?) ?? 0));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(child: _buildSummaryCard('Total Topik', totalCourses.toString(), Icons.menu_book)),
          const SizedBox(width: 16),
          Expanded(child: _buildSummaryCard('Total SKS', totalCredits.toString(), Icons.star)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class CourseItemWidget extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseItemWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final status = course['status'];
    Color statusColor;
    IconData statusIcon;
    String statusText;

    switch (status) {
      case 'done':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        statusText = 'Selesai';
        break;
      case 'active':
        statusColor = Colors.orange;
        statusIcon = Icons.play_circle_fill;
        statusText = 'Berjalan';
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.schedule;
        statusText = 'Direncanakan';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          course['title'] ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${course['code']} • ${course['credits']} SKS'),
        trailing: Text(
          statusText,
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
