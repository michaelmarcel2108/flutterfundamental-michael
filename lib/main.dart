import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

const String studentName = 'Michael Marcel Hartono';
const String studentId = '2455011003';

final List<Map<String, dynamic>> topics = [
  {'title': 'Git & GitHub', 'subtitle': 'Version control', 'done': true},
  {'title': 'Dart Fundamentals', 'subtitle': 'Language basics', 'done': true},
  {
    'title': 'Flutter UI Fundamentals',
    'subtitle': 'Widgets & layout',
    'done': false,
  },
  {
    'title': '$studentId - $studentName',
    'subtitle': 'Pemilik aplikasi',
    'done': false,
  },
];

Future<Map<String, dynamic>> loadStudentData() async {
  final jsonString = await rootBundle.loadString(
    'assets/data/student_data.json',
  );
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
      home: Tahap11Page(),
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
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
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
              return Center(
                child: Text('Gagal memuat data: ${snapshot.error}'),
              );
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
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
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
          ),
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
    final totalCredits = courses.fold<int>(
      0,
      (sum, course) => sum + ((course['credits'] as int?) ?? 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Total Topik',
              totalCourses.toString(),
              Icons.menu_book,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildSummaryCard(
              'Total SKS',
              totalCredits.toString(),
              Icons.star,
            ),
          ),
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
          ),
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
          backgroundColor: statusColor.withValues(alpha: 0.1),
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

/// Halaman demonstrasi praktikum Tahap 1:
/// Mengamati Masalah Layout yang Tidak Responsif dan Perbaikannya.
class Tahap1Page extends StatefulWidget {
  const Tahap1Page({super.key});

  @override
  State<Tahap1Page> createState() => _Tahap1PageState();
}

class _Tahap1PageState extends State<Tahap1Page> {
  bool isResponsive = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentTahap: 1),
      appBar: AppBar(
        title: const Text('Tahap 1: Pengamatan Layout'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitas Mahasiswa
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nama: $studentName\nNIM: $studentId',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol Switch Mode untuk Uji Coba
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isResponsive ? 'Mode: RESPONTIF' : 'Mode: HARD-CODED',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isResponsive ? Colors.green : Colors.red,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isResponsive = !isResponsive;
                    });
                  },
                  icon: Icon(isResponsive ? Icons.replay : Icons.check_circle),
                  label: Text(
                    isResponsive ? 'Uji Hard-coded (500)' : 'Uji Responsif',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isResponsive
                        ? Colors.orange
                        : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(height: 30),

            // 1. KONDISI HARD-CODED (width: 500)
            if (!isResponsive) ...[
              const Text(
                '1. Container dengan width: 500 (Hard-coded di dalam Row):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              const Text(
                'Perhatikan strip kuning-hitam di kanan (overflow) pada mode portrait HP:',
                style: TextStyle(color: Colors.red, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    width: 500,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade200,
                      border: Border.all(
                        color: Colors.amber.shade800,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$studentId - $studentName',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ]
            // 2. KONDISI RESPONSIF (Expanded / double.infinity)
            else ...[
              const Text(
                '2. Container Responsif (Menggunakan Expanded di dalam Row):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ukuran menyesuaikan 100% lebar layar secara fleksibel tanpa overflow:',
                style: TextStyle(color: Colors.green, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        border: Border.all(
                          color: Colors.green.shade800,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$studentId - $studentName',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Text(
                '3. Atau Menggunakan width: double.infinity:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  border: Border.all(color: Colors.blue.shade600, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$studentId - $studentName',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Halaman demonstrasi praktikum Tahap 2:
/// MediaQuery: Membaca Karakteristik Layar
class Tahap2Page extends StatelessWidget {
  const Tahap2Page({super.key});

  @override
  Widget build(BuildContext context) {
    // 6. Membaca ukuran layar dan orientasi menggunakan MediaQuery
    final size = MediaQuery.of(context).size;
    final orientation = MediaQuery.of(context).orientation;

    // 9. Kondisi: jika width < 600 'Compact', selain itu 'Wide'
    final isCompact = size.width < 600;

    return Scaffold(
      drawer: const AppDrawer(currentTahap: 2),
      appBar: AppBar(
        title: const Text('Tahap 2: MediaQuery'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Identitas Mahasiswa (Nama & NIM)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.indigo.shade200),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Nama: $studentName\nNIM: $studentId',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Card Karakteristik Layar
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Karakteristik Layar (MediaQuery):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Divider(height: 20),
                    Text(
                      'Width: ${size.width.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Height: ${size.height.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Orientation: $orientation',
                      style: const TextStyle(fontSize: 15),
                    ),
                    const Divider(height: 24),
                    // Kondisi: jika width < 600 tampilkan teks 'Compact', selain itu 'Wide'
                    Row(
                      children: [
                        const Text(
                          'Tampilan: ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isCompact
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isCompact ? Colors.orange : Colors.green,
                            ),
                          ),
                          child: Text(
                            isCompact ? 'Compact' : 'Wide',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCompact
                                  ? Colors.orange.shade900
                                  : Colors.green.shade900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Halaman demonstrasi praktikum Tahap 3:
/// LayoutBuilder dan Breakpoint
class Tahap3Page extends StatelessWidget {
  const Tahap3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentTahap: 3),
      appBar: AppBar(
        title: const Text('Tahap 3: LayoutBuilder & Breakpoint'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return const CompactLayout();
          } else if (constraints.maxWidth < 840) {
            return const MediumLayout();
          } else {
            return const ExpandedLayout();
          }
        },
      ),
    );
  }
}

/// 10. Widget CompactLayout (< 600 dp) - Tampilan Phone
/// 11. Menampilkan Nama, NIM, Kategori Layout, dan Perbedaan Visual (1 Kolom Vertikal)
class CompactLayout extends StatelessWidget {
  const CompactLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 11. Kategori Layout Card
            Card(
              color: Colors.deepOrange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.phone_android, color: Colors.white, size: 36),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori: Compact Layout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Lebar: < 600 dp (Phone)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 11. Identitas Mahasiswa (Nama & NIM)
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.deepOrange,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Identitas Mahasiswa',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              studentName,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'NIM:',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          studentId,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrange,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 11. Perbedaan Visual: Tata Letak 1 Kolom Vertikal
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: Colors.deepOrange.shade200, width: 1.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.view_agenda,
                          color: Colors.deepOrange.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Perbedaan Visual: 1 Kolom (Vertikal)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.deepOrange.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Pada mode Compact, seluruh elemen ditata dalam 1 kolom vertikal (Column). Cocok untuk layar ponsel sempit agar konten dapat digulir dengan mudah tanpa horizontal overflow.',
                      style: TextStyle(fontSize: 13, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Komponen Tambahan (Vertikal List)
            _buildSampleCard(
              title: 'Materi LayoutBuilder',
              subtitle: 'Constraints berbasis ukuran widget parent',
              icon: Icons.layers,
              color: Colors.deepOrange,
            ),
            const SizedBox(height: 12),
            _buildSampleCard(
              title: 'Status Breakpoint',
              subtitle: 'Compact Mode Aktif (< 600 dp)',
              icon: Icons.check_circle,
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

/// 10. Widget MediumLayout (600–839 dp) - Tampilan Large Phone / Small Tablet
/// 11. Menampilkan Nama, NIM, Kategori Layout, dan Perbedaan Visual (2 Kolom Berdampingan)
class MediumLayout extends StatelessWidget {
  const MediumLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 11. Kategori Layout Card
            Card(
              color: Colors.teal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.tablet_android, color: Colors.white, size: 40),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori: Medium Layout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Lebar: 600–839 dp (Large phone / small tablet)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 11. Perbedaan Visual: TATA LETAK 2 KOLOM (Row dengan 2 Expanded)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom Kiri (Profil & Identitas Mahasiswa)
                Expanded(
                  flex: 5,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              CircleAvatar(
                                radius: 26,
                                backgroundColor: Colors.teal,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Identitas Mahasiswa',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            'Nama Lengkap:',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            studentName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'NIM:',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            studentId,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Mode: Tablet Portabel (2 Kolom)',
                              style: TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Kolom Kanan (Perbedaan Visual & Konten)
                Expanded(
                  flex: 7,
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.teal.shade200,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.dashboard_customize,
                                    color: Colors.teal.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Perbedaan Visual: 2 Kolom (Berdampingan)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.teal.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Pada mode Medium, layout menggunakan 2 kolom horizontal (Row dengan Expanded). Profil ditempatkan di sisi kiri dan konten materi di sisi kanan.',
                                style: TextStyle(fontSize: 13, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSampleCard(
                        title: 'Materi LayoutBuilder',
                        subtitle: 'Multi-screen Breakpoint Adaptivity',
                        icon: Icons.devices,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 12),
                      _buildSampleCard(
                        title: 'Status Breakpoint',
                        subtitle: 'Medium Mode Aktif (600–839 dp)',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 10. Widget ExpandedLayout (>= 840 dp) - Tampilan Tablet / Desktop
/// 11. Menampilkan Nama, NIM, Kategori Layout, dan Perbedaan Visual (3 Kolom Dashboard)
class ExpandedLayout extends StatelessWidget {
  const ExpandedLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo.shade50,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 11. Kategori Layout Card
            Card(
              color: Colors.indigo,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18.0),
                child: Row(
                  children: [
                    Icon(Icons.desktop_windows, color: Colors.white, size: 44),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kategori: Expanded Layout',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Lebar: >= 840 dp (Tablet / Desktop)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 11. Perbedaan Visual: TATA LETAK 3 KOLOM DASHBOARD DESKTOP
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Kolom 1 (Kiri): Profil & Sidebar Info
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.indigo,
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            studentName,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'NIM: $studentId',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                              fontSize: 14,
                            ),
                          ),
                          Divider(height: 28),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.badge, color: Colors.indigo),
                            title: Text('Mahasiswa TRPL'),
                            subtitle: Text('Undiksha'),
                          ),
                          ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.laptop, color: Colors.indigo),
                            title: Text('Perangkat'),
                            subtitle: Text('Desktop / Tablet Luas'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Kolom 2 (Tengah): Penjelasan Perbedaan Visual & Konten Utama
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      Card(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Colors.indigo.shade200,
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.view_column,
                                    color: Colors.indigo.shade700,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Perbedaan Visual: 3 Kolom Dashboard',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Colors.indigo.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'Pada mode Expanded, tampilan memanfaatkan ruang layar lebar dengan membagi UI ke dalam 3 kolom (Sidebar Kiri, Konten Utama Tengah, dan Panel Statistik Kanan). Whitespace terisi optimal dan nyaman dipandang pada desktop/tablet.',
                                style: TextStyle(fontSize: 13, height: 1.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSampleCard(
                        title: 'Materi LayoutBuilder',
                        subtitle: 'Tahap 3 - LayoutBuilder & Breakpoint',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _buildSampleCard(
                        title: 'Multi-window Adaptivity',
                        subtitle:
                            'Dapat diuji dengan resize window desktop/browser',
                        icon: Icons.open_in_full,
                        color: Colors.indigo,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Kolom 3 (Kanan): Panel Ringkasan / Detail Statistik
                Expanded(
                  flex: 3,
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.analytics, color: Colors.indigo),
                              SizedBox(width: 8),
                              Text(
                                'Panel Statistik',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),
                          _buildMiniStat('Breakpoint', '>= 840 dp'),
                          const SizedBox(height: 10),
                          _buildMiniStat('Target Device', 'Desktop / Tablet'),
                          const SizedBox(height: 10),
                          _buildMiniStat('Kolom UI', '3 Kolom Dashboard'),
                          const SizedBox(height: 10),
                          _buildMiniStat('Status', 'Expanded Active'),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET HELPER UNTUK TAHAP 3
// ==========================================

Widget _buildSampleCard({
  required String title,
  required String subtitle,
  required IconData icon,
  required Color color,
}) {
  return Card(
    elevation: 1,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.15),
        child: Icon(icon, color: color),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
    ),
  );
}

Widget _buildMiniStat(String label, String value) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: Colors.grey.shade100,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.indigo,
          ),
        ),
      ],
    ),
  );
}

// ============================================================================
// APP DRAWER (NAVIGASI SELURUH TAHAP PRAKTIKUM)
// ============================================================================

class AppDrawer extends StatelessWidget {
  final int currentTahap;
  const AppDrawer({super.key, required this.currentTahap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.teal.shade800, Colors.indigo.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.school, color: Colors.indigo, size: 28),
                ),
                const SizedBox(height: 10),
                Text(
                  studentName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  'NIM: $studentId',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'TRPL Undiksha - Mobile',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(
              Icons.warning_amber_rounded,
              color: currentTahap == 1 ? Colors.blue : Colors.grey,
            ),
            title: const Text('Tahap 1: Pengamatan Layout'),
            subtitle: const Text('Overflow & Scrollable Fix'),
            selected: currentTahap == 1,
            selectedTileColor: Colors.blue.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap1Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.screen_search_desktop,
              color: currentTahap == 2 ? Colors.indigo : Colors.grey,
            ),
            title: const Text('Tahap 2: MediaQuery'),
            subtitle: const Text('Screen Size & Orientation'),
            selected: currentTahap == 2,
            selectedTileColor: Colors.indigo.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap2Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.view_quilt,
              color: currentTahap == 3 ? Colors.indigo : Colors.grey,
            ),
            title: const Text('Tahap 3: LayoutBuilder & Breakpoint'),
            subtitle: const Text('Compact, Medium, & Expanded'),
            selected: currentTahap == 3,
            selectedTileColor: Colors.indigo.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap3Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.view_week,
              color: currentTahap == 4 ? Colors.teal : Colors.grey,
            ),
            title: const Text('Tahap 4: Expanded, Flexible, & Wrap'),
            subtitle: const Text('Flex 2:1, Wrap Chips, & Overflow Analysis'),
            selected: currentTahap == 4,
            selectedTileColor: Colors.teal.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap4Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.grid_view_rounded,
              color: currentTahap == 5 ? Colors.deepOrange : Colors.grey,
            ),
            title: const Text('Tahap 5: GridView Responsif'),
            subtitle: const Text('1, 2, & 3 Kolom Berdasarkan Lebar Layar'),
            selected: currentTahap == 5,
            selectedTileColor: Colors.deepOrange.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 5) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap5Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.phonelink_setup_rounded,
              color: currentTahap == 6 ? Colors.purple : Colors.grey,
            ),
            title: const Text('Tahap 6: Scrollable & Keyboard'),
            subtitle: const Text('SingleChildScrollView & Keyboard Handling'),
            selected: currentTahap == 6,
            selectedTileColor: Colors.purple.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 6) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap6Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.navigation_rounded,
              color: currentTahap == 7 ? Colors.indigo : Colors.grey,
            ),
            title: const Text('Tahap 7: Navigator (Push & Pop)'),
            subtitle: const Text('Route Stack & AppBar Back Button'),
            selected: currentTahap == 7,
            selectedTileColor: Colors.indigo.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 7) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomePage()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.send_and_archive_rounded,
              color: currentTahap == 8 ? Colors.teal : Colors.grey,
            ),
            title: const Text('Tahap 8: Passing Data ke Detail'),
            subtitle: const Text('Constructor Passing & CourseDetailPage'),
            selected: currentTahap == 8,
            selectedTileColor: Colors.teal.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 8) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap8Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.keyboard_return_rounded,
              color: currentTahap == 9 ? Colors.pink : Colors.grey,
            ),
            title: const Text('Tahap 9: Returning Data (Pop Result)'),
            subtitle: const Text('Await Navigator.push & Pop Result true'),
            selected: currentTahap == 9,
            selectedTileColor: Colors.pink.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 9) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap9Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.tab_rounded,
              color: currentTahap == 10 ? Colors.indigo : Colors.grey,
            ),
            title: const Text('Tahap 10: NavigationBar (Bottom Nav)'),
            subtitle: const Text('Home, Courses, & Profile Destinations'),
            selected: currentTahap == 10,
            selectedTileColor: Colors.indigo.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 10) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap10Page()),
                );
              }
            },
          ),
          ListTile(
            leading: Icon(
              Icons.splitscreen_rounded,
              color: currentTahap == 11 ? Colors.teal : Colors.grey,
            ),
            title: const Text('Tahap 11: Adaptive Navigation'),
            subtitle: const Text('NavigationBar vs NavigationRail (< / >= 840 dp)'),
            selected: currentTahap == 11,
            selectedTileColor: Colors.teal.withValues(alpha: 0.1),
            onTap: () {
              Navigator.pop(context);
              if (currentTahap != 11) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const Tahap11Page()),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAHAP 4: EXPANDED, FLEXIBLE, DAN WRAP
// ============================================================================

/// Halaman demonstrasi praktikum Tahap 4:
/// - 14. Dua panel dalam Row menggunakan Expanded dengan flex 2:1.
/// - 15. Ubah ukuran layar dan amati pembagian ruang.
/// - 16. Minimal enam Chip skill menggunakan Wrap.
/// - 17. Bandingkan dengan Row biasa ketika ruang tidak cukup.
class Tahap4Page extends StatefulWidget {
  const Tahap4Page({super.key});

  @override
  State<Tahap4Page> createState() => _Tahap4PageState();
}

class _Tahap4PageState extends State<Tahap4Page> {
  // 16. Minimal enam Chip skill menggunakan Wrap (disediakan 8 skill)
  final List<String> skills = const [
    'Flutter',
    'Dart',
    'Git & GitHub',
    'REST API',
    'Responsive UI',
    'State Management',
    'Firebase',
    'Clean Architecture',
  ];

  // 15. State untuk pengujian perubahan ukuran layar/container secara interaktif
  bool _enableSimulatedResize = false;
  double _simulatedContainerWidth = 420.0;

  // 17. View mode untuk perbandingan Wrap vs Row biasa
  // 0: Wrap (Auto multiline), 1: Row Biasa (Overflow demo), 2: Berdampingan (Side-by-side)
  int _comparisonMode = 0;

  // State demonstrasi perbedaan Flexible vs Expanded
  bool _useExpandedOverFlexible = true;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      drawer: const AppDrawer(currentTahap: 4),
      appBar: AppBar(
        title: const Text('Tahap 4: Expanded, Flexible, & Wrap'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.blueGrey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================================
              // HEADER & IDENTITAS MAHASISWA
              // ==========================================================
              Card(
                color: Colors.teal.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.teal, size: 32),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Praktikum Mobile - Tahap 4',
                              style: TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'NIM: $studentId',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================================
              // KARTU MATERI INTI TAHAP 4
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.menu_book, color: Colors.teal.shade800),
                          const SizedBox(width: 8),
                          Text(
                            'Materi: Expanded, Flexible, dan Wrap',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.teal.shade900,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      _buildMateriPoint(
                        title: 'Expanded',
                        description:
                            'Mengambil sisa ruang pada sumbu utama (main axis) secara ketat (tight fit) sesuai proporsi bobot `flex`.',
                        icon: Icons.unfold_more,
                        color: Colors.deepPurple,
                      ),
                      const SizedBox(height: 10),
                      _buildMateriPoint(
                        title: 'Flexible',
                        description:
                            'Memberi ruang yang lebih longgar (loose fit); child hanya menggunakan ruang sebesar kontennya maksimal sebesar porsi flex.',
                        icon: Icons.open_in_full,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      _buildMateriPoint(
                        title: 'Wrap',
                        description:
                            'Mengalirkan child secara berurutan dan otomatis memindahkannya ke baris/kolom berikutnya (new run) ketika ruang tidak cukup.',
                        icon: Icons.wrap_text,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================================
              // BUTIR 14 & 15: DUA PANEL DALAM ROW DENGAN EXPANDED FLEX 2:1
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.deepPurple.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.view_column_rounded,
                              color: Colors.deepPurple.shade800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '14 & 15. Dua Panel Row (Expanded Flex 2:1)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Rasio pembagian ruang: Panel A = 2 bagian (66.7%), Panel B = 1 bagian (33.3%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Code Snippet Box
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Row(\n'
                          '  children: [\n'
                          '    Expanded(flex: 2, child: buildBox(\'A\')),\n'
                          '    const SizedBox(width: 8),\n'
                          '    Expanded(child: buildBox(\'B\')),\n'
                          '  ],\n'
                          ')',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF89DDFF),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Fitur Interaktif Butir 15: Kontrol Simulasi Resize Layar
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.tune,
                                      size: 18,
                                      color: Colors.teal,
                                    ),
                                    SizedBox(width: 6),
                                    Text(
                                      '15. Amati Pembagian Ruang:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: Colors.teal,
                                      ),
                                    ),
                                  ],
                                ),
                                Switch(
                                  value: _enableSimulatedResize,
                                  activeColor: Colors.teal,
                                  onChanged: (val) {
                                    setState(() {
                                      _enableSimulatedResize = val;
                                      if (val) {
                                        _simulatedContainerWidth =
                                            (screenWidth * 0.85).clamp(
                                              280.0,
                                              700.0,
                                            );
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                            Text(
                              _enableSimulatedResize
                                  ? 'Mode Simulasi Ukuran Aktif: Geser slider di bawah atau ubah ukuran jendela desktop/browser untuk mengamati pembagian ruang proporsional.'
                                  : 'Menggunakan lebar layar penuh (${screenWidth.toStringAsFixed(1)} dp). Aktifkan switch untuk menguji simulasi slider ukuran layar.',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                            if (_enableSimulatedResize) ...[
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    'Lebar: ${_simulatedContainerWidth.toStringAsFixed(0)} dp',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                  Expanded(
                                    child: Slider(
                                      value: _simulatedContainerWidth,
                                      min: 260.0,
                                      max: screenWidth > 320
                                          ? screenWidth
                                          : 320.0,
                                      divisions: 30,
                                      label:
                                          '${_simulatedContainerWidth.toStringAsFixed(0)} dp',
                                      activeColor: Colors.teal,
                                      onChanged: (val) {
                                        setState(() {
                                          _simulatedContainerWidth = val;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Implementasi Butir 14: Dua panel dalam Row menggunakan Expanded dengan flex 2:1
                      Center(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: _enableSimulatedResize
                              ? _simulatedContainerWidth
                              : double.infinity,
                          decoration: BoxDecoration(
                            border: _enableSimulatedResize
                                ? Border.all(color: Colors.teal, width: 2)
                                : null,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: _enableSimulatedResize
                              ? const EdgeInsets.all(8)
                              : EdgeInsets.zero,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (_enableSimulatedResize) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  color: Colors.teal.shade100,
                                  child: Text(
                                    'Container Terbatas: ${_simulatedContainerWidth.toStringAsFixed(1)} dp',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade900,
                                    ),
                                  ),
                                ),
                              ],

                              // 14. Row dengan Expanded flex 2:1
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: buildBox('A', flex: 2),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1, // default Expanded adalah flex: 1
                                    child: buildBox('B', flex: 1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Catatan Pengamatan Pembagian Ruang (Butir 15)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 18,
                                  color: Colors.indigo,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Hasil Observasi Pembagian Ruang (Butir 15):',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.indigo,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            _buildBullet(
                              'Total bobot flex adalah 2 + 1 = 3 bagian.',
                            ),
                            _buildBullet(
                              'Panel A (flex: 2) selalu menerima 2/3 (sekitar 66.7%) dari sisa lebar setelah dipotong SizedBox 8 dp.',
                            ),
                            _buildBullet(
                              'Panel B (flex: 1) selalu menerima 1/3 (sekitar 33.3%) dari sisa lebar.',
                            ),
                            _buildBullet(
                              'Saat layar diubah (resize), kedua panel secara otomatis dan proporsional menyesuaikan lebarnya tanpa menyebabkan overflow.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================================
              // MATERI PENDUKUNG: PERBEDAAN EXPANDED VS FLEXIBLE
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.compare_arrows,
                            color: Colors.deepPurple.shade700,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Eksplorasi Materi: Expanded vs Flexible',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Expanded menggunakan FlexFit.tight (memaksa child selebar alokasi flex), sedangkan Flexible menggunakan FlexFit.loose secara default (child hanya selebar kontennya jika konten lebih kecil).',
                        style: TextStyle(fontSize: 12.5, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text('Gunakan Expanded (Tight Fit)'),
                            selected: _useExpandedOverFlexible,
                            selectedColor: Colors.deepPurple.shade100,
                            onSelected: (val) {
                              if (val)
                                setState(() => _useExpandedOverFlexible = true);
                            },
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('Gunakan Flexible (Loose Fit)'),
                            selected: !_useExpandedOverFlexible,
                            selectedColor: Colors.indigo.shade100,
                            onSelected: (val) {
                              if (val)
                                setState(
                                  () => _useExpandedOverFlexible = false,
                                );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            if (_useExpandedOverFlexible)
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.deepPurple.shade200,
                                  child: const Text(
                                    'Expanded: Mengisi penuh porsi flex 2',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              )
                            else
                              Flexible(
                                flex: 2,
                                fit: FlexFit.loose,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  color: Colors.indigo.shade200,
                                  child: const Text(
                                    'Flexible: Hanya selebar teks ini',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 1,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                color: Colors.grey.shade300,
                                child: const Text(
                                  'Panel Pendamping',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================================
              // BUTIR 16: MINIMAL ENAM CHIP SKILL MENGGUNAKAN WRAP
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.loyalty_rounded,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '16. Minimal Enam Chip Skill (Wrap)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Terdapat ${skills.length} skills (>= 6) dengan spacing: 8 dan runSpacing: 8',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Code Snippet Box Sesuai Perintah
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Wrap(\n'
                          '  spacing: 8,\n'
                          '  runSpacing: 8,\n'
                          '  children: skills.map((e) => Chip(label: Text(e))).toList(),\n'
                          ')',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF89DDFF),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 16. Implementasi Nyata Sesuai Format Tugas
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.teal.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 16,
                                  color: Colors.teal,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Tampilan Hasil Widget Wrap:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: Colors.teal,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // Implementasi Wrap
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: skills
                                  .map(
                                    (e) => Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: Colors.teal.shade700,
                                        child: Text(
                                          e[0],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      label: Text(
                                        e,
                                        style: TextStyle(
                                          color: Colors.teal.shade900,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      backgroundColor: Colors.white,
                                      side: BorderSide(
                                        color: Colors.teal.shade300,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================================
              // BUTIR 17: BANDINGKAN DENGAN ROW BIASA KETIKA RUANG TIDAK CUKUP
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.compare,
                              color: Colors.red.shade800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '17. Bandingkan dengan Row Biasa (Overflow)',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  'Analisis perilaku ketika ruang horizontal terbatas',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Filter Segmented / Pilihan Perbandingan
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(
                            value: 0,
                            label: Text('Wrap (Rapi)'),
                            icon: Icon(Icons.check_circle_outline),
                          ),
                          ButtonSegment(
                            value: 1,
                            label: Text('Row (Overflow)'),
                            icon: Icon(Icons.warning_amber_rounded),
                          ),
                          ButtonSegment(
                            value: 2,
                            label: Text('Berdampingan'),
                            icon: Icon(Icons.splitscreen),
                          ),
                        ],
                        selected: {_comparisonMode},
                        onSelectionChanged: (val) {
                          setState(() {
                            _comparisonMode = val.first;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Tampilan Berdasarkan Pilihan
                      if (_comparisonMode == 0 || _comparisonMode == 2) ...[
                        _buildComparisonCard(
                          title: '1. Menggunakan Wrap (Solusi Responsif)',
                          subtitle:
                              'Chip otomatis pindah ke baris berikutnya (multiline). Bebas dari overflow error.',
                          isPositive: true,
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: skills
                                .map((e) => Chip(label: Text(e)))
                                .toList(),
                          ),
                        ),
                      ],

                      if (_comparisonMode == 2) const SizedBox(height: 16),

                      if (_comparisonMode == 1 || _comparisonMode == 2) ...[
                        _buildComparisonCard(
                          title: '2. Menggunakan Row Biasa (Masalah Layout)',
                          subtitle:
                              'Row memaksa seluruh child berada dalam 1 baris tak terbatas. Menyebabkan RenderFlex Overflowed.',
                          isPositive: false,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Container simulasi dengan batas lebar tertentu agar overflow teramati jelas
                              Container(
                                width: double.infinity,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red.shade300,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      child: Row(
                                        children: skills
                                            .map(
                                              (e) => Padding(
                                                padding: const EdgeInsets.only(
                                                  right: 8,
                                                ),
                                                child: Chip(label: Text(e)),
                                              ),
                                            )
                                            .toList(),
                                      ),
                                    ),
                                    // Visual Overflow Warning khas Flutter (Yellow-Black Striped Banner)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      bottom: 0,
                                      width: 44,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.yellow.shade700,
                                              Colors.black,
                                              Colors.yellow.shade700,
                                              Colors.black,
                                              Colors.yellow.shade700,
                                            ],
                                            stops: const [
                                              0.0,
                                              0.25,
                                              0.5,
                                              0.75,
                                              1.0,
                                            ],
                                            tileMode: TileMode.repeated,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: Colors.red.shade200,
                                  ),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 16,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'A RenderFlex overflowed by 186 pixels on the right.',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 11.5,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),

                      // Tabel Komparasi Komprehensif
                      _buildComparisonTable(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGET HELPER BUILD BOX (SESUAI PERINTAH MATERI 14)
  // ==========================================================================
  Widget buildBox(String label, {Color? color, String? subtitle, int? flex}) {
    final bool isA = label == 'A';
    final Color primaryColor = isA ? Colors.deepPurple : Colors.amber.shade800;
    final Color bgColor = isA
        ? Colors.deepPurple.shade50
        : Colors.amber.shade50;
    final Color borderColor = isA
        ? Colors.deepPurple.shade300
        : Colors.amber.shade300;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double currentWidth = constraints.maxWidth;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: primaryColor,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Panel $label',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isA ? 'flex: 2 (2/3 ~66.7%)' : 'flex: 1 (1/3 ~33.3%)',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Text(
                  '${currentWidth.toStringAsFixed(1)} dp',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================
  Widget _buildMateriPoint({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: color,
                ),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 12, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String subtitle,
    required bool isPositive,
    required Widget child,
  }) {
    final Color themeColor = isPositive ? Colors.teal : Colors.red;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isPositive
            ? Colors.teal.shade50.withValues(alpha: 0.4)
            : Colors.red.shade50.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: themeColor.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive ? Icons.check_circle : Icons.error,
                size: 18,
                color: themeColor,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: themeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Table(
      border: TableBorder.all(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(8),
      ),
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(3),
        2: FlexColumnWidth(3),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: const [
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Parameter',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Row Biasa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.red,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Wrap Widget',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.teal,
                ),
              ),
            ),
          ],
        ),
        _buildTableRow(
          'Jumlah Baris',
          'Tepat 1 baris horizontal',
          'Dinamis (banyak baris / multiline)',
        ),
        _buildTableRow(
          'Jika Ruang Kurang',
          'Overflow (RenderFlex error)',
          'Otomatis wrap ke baris baru',
        ),
        _buildTableRow(
          'Pengaturan Spacing',
          'Perlu SizedBox / Spacer manual',
          'Otomatis lewat spacing & runSpacing',
        ),
        _buildTableRow(
          'Skenario Terbaik',
          'Navigasi, Icon + Teks tetap',
          'Daftar Chip, Tag, Kategori, Filter',
        ),
      ],
    );
  }

  TableRow _buildTableRow(String param, String rowVal, String wrapVal) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            param,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11.5),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            rowVal,
            style: const TextStyle(fontSize: 11.5, color: Colors.black87),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            wrapVal,
            style: const TextStyle(
              fontSize: 11.5,
              color: Colors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAHAP 5: GRIDVIEW RESPONSIF
// ============================================================================

/// Fungsi penentu jumlah kolom berdasarkan breakpoint lebar layar (Materi Tahap 5):
/// - Compact (< 600 dp)  : 1 Kolom
/// - Medium (600–839 dp) : 2 Kolom
/// - Expanded (>= 840 dp): 3 Kolom
int columnsFor(double width) {
  if (width < 600) return 1;
  if (width < 840) return 2;
  return 3;
}

/// Helper untuk menentukan rasio aspek kartu agar proporsional dan bebas overflow
double childAspectRatioFor(int columns) {
  if (columns == 1) return 2.6;
  if (columns == 2) return 1.55;
  return 1.4;
}

/// Fallback data jika JSON belum selesai dimuat atau terjadi kendala I/O
final List<Map<String, dynamic>> fallbackCourses = const [
  {'code': 'MOB01', 'title': 'Git & GitHub', 'credits': 2, 'status': 'done'},
  {
    'code': 'MOB02',
    'title': 'Dart Fundamentals',
    'credits': 2,
    'status': 'done',
  },
  {
    'code': 'MOB03',
    'title': 'Flutter UI Fundamentals',
    'credits': 3,
    'status': 'active',
  },
  {'code': 'MOB04', 'title': 'Navigation', 'credits': 2, 'status': 'planned'},
  {
    'code': 'MOB05',
    'title': 'State Management',
    'credits': 3,
    'status': 'planned',
  },
  {
    'code': 'MOB06',
    'title': 'Testing & Deployment',
    'credits': 2,
    'status': 'planned',
  },
];

/// Halaman demonstrasi praktikum Tahap 5: GridView Responsif
/// - 18. Gunakan data course dari collection/JSON pertemuan sebelumnya.
/// - 19. Tampilkan course sebagai GridView.
/// - 20. Atur 1 kolom pada compact, 2 pada medium, dan 3 pada expanded.
/// - 21. Pastikan Nama dan NIM tetap terlihat pada header.
class Tahap5Page extends StatefulWidget {
  const Tahap5Page({super.key});

  @override
  State<Tahap5Page> createState() => _Tahap5PageState();
}

class _Tahap5PageState extends State<Tahap5Page> {
  // Kontrol simulasi slider lebar layar untuk pengujian breakpoint secara dinamis
  bool _enableSimulatedResize = false;
  double _simulatedContainerWidth = 480.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final physicalWidth = mediaQuery.size.width;

    return Scaffold(
      drawer: const AppDrawer(currentTahap: 5),
      appBar: AppBar(
        title: const Text('Tahap 5: GridView Responsif'),
        backgroundColor: Colors.deepOrange.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade100,
        child: FutureBuilder<Map<String, dynamic>>(
          future: loadStudentData(),
          builder: (context, snapshot) {
            // 18. Mengambil data courses dan student dari JSON / Fallback
            List<dynamic> courses = fallbackCourses;
            String headerName = studentName;
            String headerNim = studentId;
            String headerMajor = 'Teknologi Rekayasa Perangkat Lunak';

            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              if (data['courses'] is List) {
                courses = data['courses'] as List<dynamic>;
              }
              if (data['student'] is Map) {
                final studentMap = data['student'] as Map<String, dynamic>;
                headerName = studentMap['name']?.toString() ?? studentName;
                headerNim = studentMap['nim']?.toString() ?? studentId;
                headerMajor = studentMap['major']?.toString() ?? headerMajor;
              }
            }

            final int totalCredits = courses.fold<int>(
              0,
              (sum, item) =>
                  sum + (((item as Map)['credits'] as num?)?.toInt() ?? 0),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ========================================================
                // 21. HEADER: NAMA DAN NIM TETAP TERLIHAT DI BAGIAN ATAS
                // ========================================================
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Kartu Identitas Mahasiswa
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepOrange.shade800,
                              Colors.deepOrange.shade600,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              radius: 26,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.person,
                                color: Colors.deepOrange,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Praktikum Mobile - Tahap 5',
                                    style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    headerName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'NIM: $headerNim  •  $headerMajor',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Ringkasan Statistik Singkat & Kontrol Breakpoint
                      Row(
                        children: [
                          Expanded(
                            child: _buildHeaderBadge(
                              icon: Icons.menu_book,
                              label: 'Mata Kuliah',
                              value: '${courses.length} Kursus',
                              color: Colors.deepOrange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildHeaderBadge(
                              icon: Icons.stars,
                              label: 'Total Beban',
                              value: '$totalCredits SKS',
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Tombol Slider Simulasi Ukuran Layar
                          IconButton.filledTonal(
                            tooltip: 'Simulasi Ukuran Layar / Breakpoint',
                            icon: Icon(
                              _enableSimulatedResize
                                  ? Icons.tune
                                  : Icons.tune_outlined,
                            ),
                            onPressed: () {
                              setState(() {
                                _enableSimulatedResize =
                                    !_enableSimulatedResize;
                                if (_enableSimulatedResize) {
                                  _simulatedContainerWidth = physicalWidth
                                      .clamp(320.0, 900.0);
                                }
                              });
                            },
                          ),
                        ],
                      ),

                      // Slider simulasi breakpoint responsif jika aktif
                      if (_enableSimulatedResize) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Simulasi Lebar: ${_simulatedContainerWidth.toStringAsFixed(0)} dp',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange.shade900,
                                    ),
                                  ),
                                  Text(
                                    _simulatedContainerWidth < 600
                                        ? 'Mode: Compact (1 Kolom)'
                                        : (_simulatedContainerWidth < 840
                                              ? 'Mode: Medium (2 Kolom)'
                                              : 'Mode: Expanded (3 Kolom)'),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.deepOrange.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Slider(
                                value: _simulatedContainerWidth,
                                min: 320.0,
                                max: physicalWidth > 900
                                    ? physicalWidth
                                    : 900.0,
                                divisions: 29,
                                activeColor: Colors.deepOrange,
                                onChanged: (val) {
                                  setState(() {
                                    _simulatedContainerWidth = val;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ========================================================
                // 19 & 20. GRIDVIEW RESPONSIF (1, 2, ATAU 3 KOLOM)
                // ========================================================
                Expanded(
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: _enableSimulatedResize
                          ? _simulatedContainerWidth
                          : double.infinity,
                      decoration: _enableSimulatedResize
                          ? BoxDecoration(
                              border: Border.symmetric(
                                vertical: BorderSide(
                                  color: Colors.deepOrange.shade300,
                                  width: 2,
                                ),
                              ),
                            )
                          : null,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          // 20. Penentuan jumlah kolom menggunakan columnsFor(constraints.maxWidth)
                          final double effectiveWidth = constraints.maxWidth;
                          final int columns = columnsFor(effectiveWidth);
                          final double aspectRatio = childAspectRatioFor(
                            columns,
                          );

                          String layoutCategory;
                          Color badgeColor;
                          if (columns == 1) {
                            layoutCategory = 'Compact (< 600 dp) → 1 Kolom';
                            badgeColor = Colors.orange.shade700;
                          } else if (columns == 2) {
                            layoutCategory = 'Medium (600–839 dp) → 2 Kolom';
                            badgeColor = Colors.teal.shade700;
                          } else {
                            layoutCategory = 'Expanded (>= 840 dp) → 3 Kolom';
                            badgeColor = Colors.indigo.shade700;
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Status Banner Breakpoint Saat Ini
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                color: badgeColor.withValues(alpha: 0.1),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.dashboard_customize,
                                          size: 16,
                                          color: badgeColor,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          layoutCategory,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: badgeColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      'Lebar: ${effectiveWidth.toStringAsFixed(1)} dp',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade700,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 19. GridView.builder Sesuai Perintah Praktikum
                              Expanded(
                                child: GridView.builder(
                                  padding: const EdgeInsets.all(12),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: columnsFor(
                                          effectiveWidth,
                                        ),
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: aspectRatio,
                                      ),
                                  itemCount: courses.length,
                                  itemBuilder: (context, index) {
                                    final courseMap =
                                        courses[index] as Map<String, dynamic>;
                                    return CourseCard(course: courseMap);
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeaderBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 10, color: Colors.grey.shade700),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// WIDGET COURSE CARD (UNTUK TAHAP 5 GRIDVIEW)
// ============================================================================

class CourseCard extends StatelessWidget {
  final Map<String, dynamic> course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final String code = course['code']?.toString() ?? 'MOB';
    final String title = course['title']?.toString() ?? 'Course Title';
    final int credits = (course['credits'] as num?)?.toInt() ?? 2;
    final String status = course['status']?.toString() ?? 'planned';

    Color statusColor;
    IconData statusIcon;
    String statusLabel;

    switch (status.toLowerCase()) {
      case 'done':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        statusLabel = 'Selesai';
        break;
      case 'active':
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_fill_rounded;
        statusLabel = 'Aktif';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        statusLabel = 'Rencana';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: statusColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.white, statusColor.withValues(alpha: 0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Baris Atas: Kode Kursus & Badge Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    code,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 11.5,
                      color: statusColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Judul Kursus
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),

            // Baris Bawah: Info SKS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.credit_card,
                      size: 13,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$credits SKS',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAHAP 6: SCROLLABLE CONTENT DAN KEYBOARD
// ============================================================================

/// Halaman demonstrasi praktikum Tahap 6:
/// - 22. Buat halaman profil/form sederhana yang lebih tinggi dari layar.
/// - 23. Uji tanpa SingleChildScrollView lalu tambahkan widget tersebut.
/// - 24. Buka keyboard dengan TextField dan amati apakah UI masih dapat di-scroll.
/// - 25. Jelaskan kapan ListView lebih tepat daripada SingleChildScrollView.
class Tahap6Page extends StatefulWidget {
  const Tahap6Page({super.key});

  @override
  State<Tahap6Page> createState() => _Tahap6PageState();
}

class _Tahap6PageState extends State<Tahap6Page> {
  // 23. State toggle pengujian dengan atau tanpa SingleChildScrollView
  bool _useScrollView = true;

  // Form Controllers untuk Butir 22
  late final TextEditingController _nameController;
  late final TextEditingController _nimController;
  late final TextEditingController _prodiController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _bioController;
  late final TextEditingController _notesController;

  // 24. FocusNode untuk menguji pembukaan keyboard pada field bawah
  final FocusNode _notesFocusNode = FocusNode();
  final FocusNode _bioFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: studentName);
    _nimController = TextEditingController(text: studentId);
    _prodiController = TextEditingController(
      text: 'Teknologi Rekayasa Perangkat Lunak',
    );
    _emailController = TextEditingController(
      text: 'michael.marcel@undiksha.ac.id',
    );
    _phoneController = TextEditingController(text: '081234567890');
    _addressController = TextEditingController(
      text: 'Singaraja, Buleleng, Bali',
    );
    _bioController = TextEditingController(
      text:
          'Tertarik pada Mobile Application Development, Flutter UI Engineering, dan Reactive State Management.',
    );
    _notesController = TextEditingController(
      text:
          'Praktikum Tahap 6: Menguji SingleChildScrollView saat keyboard virtual muncul.',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nimController.dispose();
    _prodiController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _bioController.dispose();
    _notesController.dispose();
    _notesFocusNode.dispose();
    _bioFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;

    return Scaffold(
      drawer: const AppDrawer(currentTahap: 6),
      appBar: AppBar(
        title: const Text('Tahap 6: Scroll & Keyboard'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: isKeyboardOpen ? 'Tutup Keyboard' : 'Fokus Field Bawah',
            icon: Icon(isKeyboardOpen ? Icons.keyboard_hide : Icons.keyboard),
            onPressed: () {
              if (isKeyboardOpen) {
                FocusScope.of(context).unfocus();
              } else {
                _notesFocusNode.requestFocus();
              }
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: Column(
          children: [
            // ==========================================================
            // CONTROL BAR: TOGGLE SCROLLVIEW & STATUS KEYBOARD
            // ==========================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 23. Header Mode Pengujian Scroll
                  const Row(
                    children: [
                      Icon(Icons.swap_vert, size: 20, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        '23. Mode Pengujian Scroll:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // 23. SegmentedButton Responsive Full-Width
                  SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<bool>(
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: true,
                          label: Text(
                            'Dengan ScrollView',
                            style: TextStyle(fontSize: 12),
                          ),
                          icon: Icon(Icons.check_circle, size: 15),
                        ),
                        ButtonSegment(
                          value: false,
                          label: Text(
                            'Tanpa Scroll',
                            style: TextStyle(fontSize: 12),
                          ),
                          icon: Icon(Icons.warning_amber_rounded, size: 15),
                        ),
                      ],
                      selected: {_useScrollView},
                      onSelectionChanged: (val) {
                        setState(() {
                          _useScrollView = val.first;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 24. Live Keyboard Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isKeyboardOpen
                          ? Colors.purple.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isKeyboardOpen
                            ? Colors.purple.shade300
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isKeyboardOpen
                              ? Icons.keyboard
                              : Icons.keyboard_outlined,
                          size: 16,
                          color: isKeyboardOpen
                              ? Colors.purple.shade800
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isKeyboardOpen
                                ? 'Keyboard Terbuka (${keyboardHeight.toStringAsFixed(0)} dp)'
                                : 'Keyboard Tertutup (0 dp)',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isKeyboardOpen
                                  ? Colors.purple.shade900
                                  : Colors.grey.shade800,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _useScrollView
                                ? Colors.green.shade100
                                : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _useScrollView ? 'Bisa Di-scroll' : 'Overflow!',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: _useScrollView
                                  ? Colors.green.shade800
                                  : Colors.red.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================================
            // KONTEN FORM PROFIL (LEBIH TINGGI DARI LAYAR)
            // ==========================================================
            Expanded(
              child: _useScrollView
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: _buildFormContent(
                        isScrollEnabled: true,
                        isKeyboardOpen: isKeyboardOpen,
                      ),
                    )
                  : Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: _buildFormContent(
                            isScrollEnabled: false,
                            isKeyboardOpen: isKeyboardOpen,
                          ),
                        ),
                        // Visual Simulasi RenderFlex Overflow Bar khas Flutter di bagian bawah
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.yellow.shade700,
                                  Colors.black,
                                  Colors.yellow.shade700,
                                  Colors.black,
                                  Colors.yellow.shade700,
                                ],
                                stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                                tileMode: TileMode.repeated,
                              ),
                              boxShadow: const [
                                BoxShadow(color: Colors.black38, blurRadius: 4),
                              ],
                            ),
                            alignment: Alignment.center,
                            child: Container(
                              color: Colors.black87,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              child: const Text(
                                'A RenderFlex overflowed by 264 pixels on the bottom.',
                                style: TextStyle(
                                  color: Colors.yellow,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGET KONTEN FORMULIR PROFIL (BUTIR 22)
  // Sesuai kode materi praktikum:
  // SingleChildScrollView(
  //   padding: const EdgeInsets.all(16),
  //   child: Column(
  //     children: [
  //       Text('$studentId - $studentName'),
  //       // form / cards
  //     ],
  //   ),
  // )
  // ==========================================================================
  Widget _buildFormContent({
    required bool isScrollEnabled,
    required bool isKeyboardOpen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Identitas Mahasiswa Sesuai Materi
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade800, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.purple, size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Identitas Pemilik Form',
                      style: TextStyle(
                        color: Colors.purpleAccent,
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$studentId - $studentName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Teknologi Rekayasa Perangkat Lunak',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Catatan Observasi Butir 23 & 24
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: isScrollEnabled
                  ? Colors.green.shade200
                  : Colors.red.shade200,
            ),
          ),
          color: isScrollEnabled ? Colors.green.shade50 : Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isScrollEnabled
                      ? Icons.check_circle
                      : Icons.warning_amber_rounded,
                  color: isScrollEnabled
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isScrollEnabled
                            ? '23. Dengan SingleChildScrollView (Aman)'
                            : '23. Tanpa SingleChildScrollView (Uji Masalah)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isScrollEnabled
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isScrollEnabled
                            ? 'Konten formulir yang melebihi tinggi layar dapat digulir dengan lancar. Ketika keyboard terbuka, viewport secara cerdas digulir agar TextField tetap terlihat.'
                            : 'Column memiliki batas constraint tinggi setinggi layar. Konten yang melebihi tinggi layar memicu RenderFlex Overflow pada sisi bawah, dan keyboard akan menutupi field bawah!',
                        style: TextStyle(
                          fontSize: 12,
                          color: isScrollEnabled
                              ? Colors.green.shade900
                              : Colors.red.shade900,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ==========================================================
        // 22. FORMULIR PROFIL MAHASISWA LENGKAP
        // ==========================================================
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.edit_note_rounded, color: Colors.purple),
                    SizedBox(width: 8),
                    Text(
                      'Formulir Profil Mahasiswa',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),

                // Field 1: Nama Lengkap
                _buildTextField(
                  label: 'Nama Lengkap Mahasiswa',
                  controller: _nameController,
                  icon: Icons.badge,
                ),
                const SizedBox(height: 12),

                // Field 2: NIM
                _buildTextField(
                  label: 'Nomor Induk Mahasiswa (NIM)',
                  controller: _nimController,
                  icon: Icons.numbers,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 12),

                // Field 3: Program Studi
                _buildTextField(
                  label: 'Program Studi',
                  controller: _prodiController,
                  icon: Icons.school,
                ),
                const SizedBox(height: 12),

                // Field 4: Email Kampus
                _buildTextField(
                  label: 'Email Undiksha',
                  controller: _emailController,
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // Field 5: Nomor HP / WhatsApp
                _buildTextField(
                  label: 'Nomor HP / WhatsApp',
                  controller: _phoneController,
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                // Field 6: Alamat Domisili (Multiline)
                _buildTextField(
                  label: 'Alamat Domisili',
                  controller: _addressController,
                  icon: Icons.home,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),

                // Field 7: Bio & Minat (Multiline)
                _buildTextField(
                  label: 'Bio & Minat Keahlian',
                  controller: _bioController,
                  focusNode: _bioFocusNode,
                  icon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),

                // Field 8: Catatan Praktikum (Field Bawah untuk Butir 24)
                _buildTextField(
                  label: 'Catatan Praktikum (Uji Keyboard Butir 24)',
                  controller: _notesController,
                  focusNode: _notesFocusNode,
                  icon: Icons.keyboard_alt_outlined,
                  maxLines: 3,
                  helperText:
                      'Klik field ini untuk membuka keyboard dan mengamati kemampuan scroll!',
                ),
                const SizedBox(height: 16),

                // Tombol Aksi Formulir
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.save),
                        label: const Text('Simpan Profil'),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data profil berhasil disimpan!'),
                              backgroundColor: Colors.purple,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          _nameController.text = studentName;
                          _nimController.text = studentId;
                        });
                      },
                      child: const Text('Reset'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ==========================================================
        // 25. PENJELASAN KAPAN LISTVIEW LEBIH TEPAT DIBANDING SINGLECHILDSCROLLVIEW
        // ==========================================================
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.analytics_outlined,
                        color: Colors.indigo.shade800,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        '25. Kapan ListView Lebih Tepat daripada SingleChildScrollView?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                const Text(
                  'Meskipun keduanya menyediakan fungsionalitas scroll, arsitektur internal keduanya sangat berbeda:',
                  style: TextStyle(fontSize: 12.5, height: 1.4),
                ),
                const SizedBox(height: 12),

                // Poin SingleChildScrollView
                _buildPointCard(
                  title: 'Gunakan SingleChildScrollView Ketika:',
                  color: Colors.purple,
                  points: const [
                    'Konten halaman memiliki struktur tetap dan pendek (hanya sedikit melebihi layar), seperti formulir pendaftaran, profil, dialog, atau kartu detail.',
                    'Child berupa widget heterogen (kombinasi Card, Text, Form, Button, Image) yang dibungkus dalam Column.',
                    'Semua widget perlu tetap ada di memori agar state (seperti input form dan validasi) tidak ter-reset saat digulir.',
                  ],
                ),
                const SizedBox(height: 12),

                // Poin ListView
                _buildPointCard(
                  title: 'Gunakan ListView (ListView.builder) Ketika:',
                  color: Colors.indigo,
                  points: const [
                    'Data berjumlah banyak, dinamis, atau tidak terbatas (puluhan hingga ribuan item, misal: feed berita, daftar chat, katalog produk).',
                    'Memerlukan optimasi memori melalui "Lazy Loading / Viewport Recycling", di mana hanya widget yang terlihat di layar yang dibuat dan dirender.',
                    'Mencegah aplikasi mengalami jank, lag, atau out-of-memory saat data terus bertambah.',
                  ],
                ),
                const SizedBox(height: 14),

                // Tabel Ringkasan
                Table(
                  border: TableBorder.all(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  columnWidths: const {
                    0: FlexColumnWidth(2.2),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(color: Colors.grey.shade200),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Kriteria',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'SingleChildScrollView',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.purple,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'ListView.builder',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.indigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    _buildTableRowItem(
                      'Mekanisme Rendering',
                      'Eager Loading (semua child dibuat sekaligus)',
                      'Lazy Loading (on-demand saat masuk viewport)',
                    ),
                    _buildTableRowItem(
                      'Konsumsi Memori',
                      'Tinggi jika item bertambah banyak',
                      'Rendah & konstan (mendaur ulang elemen)',
                    ),
                    _buildTableRowItem(
                      'Kasus Penggunaan',
                      'Formulir, Profil, Detail Statis',
                      'Daftar Kursus, Feed, Pesan Chat',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ==========================================================================
  // HELPER WIDGETS
  // ==========================================================================
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    FocusNode? focusNode,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? helperText,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.purple.shade700, size: 20),
        helperText: helperText,
        helperMaxLines: 2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildPointCard({
    required String title,
    required Color color,
    required List<String> points,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          const SizedBox(height: 6),
          ...points.map(
            (pt) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(color: color, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Text(
                      pt,
                      style: const TextStyle(fontSize: 12, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRowItem(String param, String scVal, String lvVal) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            param,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            scVal,
            style: const TextStyle(fontSize: 11, color: Colors.black87),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            lvVal,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.indigo,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAHAP 7: NAVIGATOR.PUSH() DAN NAVIGATOR.POP()
// ============================================================================

/// Alias untuk fleksibilitas pemanggilan halaman Tahap 7
typedef Tahap7Page = HomePage;

/// 26. HomePage untuk Tahap 7
/// 27. Menampilkan Nama, NIM, dan tombol 'Buka Detail'
/// 28. Menggunakan Navigator.push() untuk membuka DetailPage
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentTahap: 7),
      appBar: AppBar(
        title: const Text('Tahap 7: Navigator (HomePage)'),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.indigo.shade50.withValues(alpha: 0.4),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================================
              // 27. HEADER: MENAMPILKAN NAMA DAN NIM
              // ==========================================================
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                color: Colors.indigo.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.person,
                          color: Colors.indigo,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Praktikum Mobile - Tahap 7',
                              style: TextStyle(
                                color: Colors.indigoAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            Text(
                              'NIM: $studentId',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const Text(
                              'Teknologi Rekayasa Perangkat Lunak',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================================
              // KARTU MATERI INTI NAVIGASI
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.layers_rounded,
                            color: Colors.indigo.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Konsep Stack Navigator di Flutter',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.indigo.shade900,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      const Text(
                        'Navigasi di Flutter bekerja seperti struktur data Tumpukan (Stack - LIFO / Last In First Out):',
                        style: TextStyle(fontSize: 12.5, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      _buildNavConceptPoint(
                        title: 'Navigator.push(context, route)',
                        description:
                            'Mendorong (menambahkan) halaman baru ke bagian teratas navigation stack di atas HomePage.',
                        icon: Icons.arrow_upward_rounded,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      _buildNavConceptPoint(
                        title: 'Navigator.pop(context)',
                        description:
                            'Mengeluarkan (menghapus) halaman teratas dari stack dan kembali ke halaman sebelumnya.',
                        icon: Icons.arrow_downward_rounded,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================================
              // 27 & 28. TOMBOL 'BUKA DETAIL' DENGAN NAVIGATOR.PUSH()
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.indigo.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.touch_app_rounded,
                        size: 44,
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Navigasi Menuju DetailPage',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tekan tombol di bawah untuk membuka halaman detail menggunakan kode Navigator.push():',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12.5, color: Colors.black54),
                      ),
                      const SizedBox(height: 14),

                      // Cuplikan Kode Sesuai Perintah
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Navigator.push(\n'
                          '  context,\n'
                          '  MaterialPageRoute(\n'
                          '    builder: (context) => const DetailPage(),\n'
                          '  ),\n'
                          ');',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF89DDFF),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 27 & 28. Tombol 'Buka Detail'
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo.shade800,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.open_in_new_rounded),
                          label: const Text(
                            'Buka Detail',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            // 28. Navigator.push() menuju DetailPage
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DetailPage(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Visual Status Navigation Stack
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.indigo,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Status Navigation Stack Saat Ini:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.indigo.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              '[HomePage] ← Teratas di Stack (Root)',
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavConceptPoint({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 26. DETAIL PAGE
// 29. Menambahkan tombol kembali menggunakan Navigator.pop()
// 30. Mengamati tombol back bawaan AppBar
// ============================================================================

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 30. AppBar dengan tombol back otomatis bawaan Flutter
      appBar: AppBar(
        title: const Text('DetailPage (Tahap 7)'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.teal.shade50.withValues(alpha: 0.3),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Identitas Mahasiswa di DetailPage
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.teal.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.school, color: Colors.teal, size: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Halaman Detail Mahasiswa',
                              style: TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'NIM: $studentId',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================================
              // 30. KARTU PENGAMATAN TOMBOL BACK BAWAAN APPBAR
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.amber.shade400, width: 1.5),
                ),
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.arrow_back,
                            color: Colors.amber.shade900,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '30. Pengamatan: Tombol Back Bawaan AppBar',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.5,
                                color: Colors.amber.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      const Text(
                        'Perhatikan pojok kiri atas pada AppBar halaman ini (←):',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildObservationItem(
                        'Tombol panah kembali (BackButton) muncul secara otomatis tanpa perlu didefinisikan secara manual pada properti leading di AppBar.',
                      ),
                      _buildObservationItem(
                        'Hal ini terjadi karena Flutter memeriksa Navigator.canPop(context). Karena halaman ini di-push di atas HomePage, canPop bernilai true.',
                      ),
                      _buildObservationItem(
                        'Menekan tombol back di AppBar tersebut akan secara otomatis memanggil Navigator.maybePop() / Navigator.pop(context).',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================================
              // 29. TOMBOL KEMBALI MENGGUNAKAN NAVIGATOR.POP()
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.keyboard_return_rounded,
                        size: 40,
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        '29. Kembali Menggunakan Navigator.pop()',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Anda juga dapat memicu aksi kembali melalui tombol kustom di dalam body menggunakan kode Navigator.pop(context):',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                      const SizedBox(height: 14),

                      // Cuplikan Kode Sesuai Perintah
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '// kembali ke halaman sebelumnya\n'
                          'Navigator.pop(context);',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF89DDFF),
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 29. Tombol Kembali
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade800,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text(
                            'Kembali (Navigator.pop)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            // 29. Memanggil Navigator.pop()
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Visual Status Navigation Stack saat di DetailPage
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.teal.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.layers, color: Colors.teal, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Struktur Stack Navigasi Sekarang:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Colors.teal,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '1. [DetailPage] ← Halaman Teratas (Aktif)',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: const Text(
                        '2. [HomePage]   ← Tertumpuk di Bawahnya',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11.5,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildObservationItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check, size: 16, color: Colors.amber.shade900),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 12, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// TAHAP 8: PASSING DATA DARI LIST KE DETAIL PAGE
// ============================================================================

/// Halaman demonstrasi praktikum Tahap 8:
/// - 31. Gunakan list course dari pertemuan sebelumnya.
/// - 32. Setiap ListTile/Card dapat ditekan.
/// - 33. Kirim Map course ke CourseDetailPage via constructor.
/// - 34. Tampilkan title, code, credits/status, serta Nama dan NIM mahasiswa pada detail.
class Tahap8Page extends StatelessWidget {
  const Tahap8Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentTahap: 8),
      appBar: AppBar(
        title: const Text('Tahap 8: Passing Data ke Detail'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.teal.shade50.withValues(alpha: 0.25),
        child: FutureBuilder<Map<String, dynamic>>(
          future: loadStudentData(),
          builder: (context, snapshot) {
            // 31. Mengambil list course dari JSON pertemuan sebelumnya (fallback jika loading)
            List<dynamic> courses = fallbackCourses;
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              if (data['courses'] is List) {
                courses = data['courses'] as List<dynamic>;
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // ========================================================
                // HEADER IDENTITAS MAHASISWA & PENJELASAN TAHAP 8
                // ========================================================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: Colors.teal.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(
                            Icons.school,
                            color: Colors.teal,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Praktikum Mobile - Tahap 8',
                                style: TextStyle(
                                  color: Colors.tealAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                ),
                              ),
                              Text(
                                'NIM: $studentId  •  TRPL Undiksha',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Kartu Penjelasan Singkat Konsep Constructor Passing
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.teal.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.teal.shade800,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Materi: Passing Data via Constructor',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Screen detail menerima data melalui constructor, sehingga satu widget CourseDetailPage dapat digunakan ulang untuk menampilkan detail mata kuliah apapun secara dinamis.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header List Materi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.list_alt_rounded,
                          color: Colors.teal.shade800,
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '31. Daftar Kursus (Ketuk untuk Detail)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${courses.length} Kursus',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ========================================================
                // 31, 32, & 33. LIST COURSE (CARD/LISTTILE DAPAT DITEKAN)
                // ========================================================
                ...courses.map((item) {
                  final Map<String, dynamic> course = Map<String, dynamic>.from(
                    item as Map,
                  );
                  final String code = course['code']?.toString() ?? 'MOB';
                  final String title = course['title']?.toString() ?? 'Course';
                  final int credits = (course['credits'] as num?)?.toInt() ?? 2;
                  final String status =
                      course['status']?.toString().toLowerCase() ?? 'planned';

                  Color statusColor;
                  IconData statusIcon;
                  String statusLabel;
                  switch (status) {
                    case 'done':
                      statusColor = Colors.green;
                      statusIcon = Icons.check_circle_rounded;
                      statusLabel = 'Selesai';
                      break;
                    case 'active':
                      statusColor = Colors.blue;
                      statusIcon = Icons.play_circle_fill_rounded;
                      statusLabel = 'Aktif';
                      break;
                    default:
                      statusColor = Colors.orange;
                      statusIcon = Icons.schedule_rounded;
                      statusLabel = 'Rencana';
                  }

                  // 32. Card/ListTile dapat ditekan (onTap)
                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      // 32 & 33. Mengirim Map course ke CourseDetailPage
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseDetailPage(course: course),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            // Avatar Kode Kursus
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: statusColor.withValues(alpha: 0.3),
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                code,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: statusColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Informasi Kursus
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                        ),
                                        child: Text(
                                          '$credits SKS',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 7,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusColor.withValues(
                                            alpha: 0.12,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              statusIcon,
                                              size: 11,
                                              color: statusColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              statusLabel,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: statusColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Ikon Navigasi Panah
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 15,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ============================================================================
// MATERI TAHAP 8: COURSE DETAIL PAGE
// - Menerima data melalui constructor: final Map<String, dynamic> course;
// - 34. Menampilkan title, code, credits/status, serta Nama dan NIM mahasiswa.
// ============================================================================

class CourseDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailPage({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    final String code = course['code']?.toString() ?? 'MOB';
    final String title = course['title']?.toString() ?? 'Judul Kursus';
    final int credits = (course['credits'] as num?)?.toInt() ?? 2;
    final String status =
        course['status']?.toString().toLowerCase() ?? 'planned';

    Color statusColor;
    IconData statusIcon;
    String statusLabel;
    String statusDescription;

    switch (status) {
      case 'done':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_rounded;
        statusLabel = 'Telah Selesai (Done)';
        statusDescription =
            'Mata kuliah / topik ini telah dipelajari dan diselesaikan pada pertemuan sebelumnya.';
        break;
      case 'active':
        statusColor = Colors.blue;
        statusIcon = Icons.play_circle_fill_rounded;
        statusLabel = 'Sedang Berlangsung (Active)';
        statusDescription =
            'Topik ini sedang dipelajari pada modul praktikum saat ini.';
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.schedule_rounded;
        statusLabel = 'Direncanakan (Planned)';
        statusDescription =
            'Materi ini dijadwalkan untuk dipelajari pada pertemuan praktikum berikutnya.';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: $code'),
        backgroundColor: Colors.teal.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ==========================================================
              // 34. IDENTITAS MAHASISWA PADA DETAIL PAGE
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.teal.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.teal, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mahasiswa TRPL Undiksha',
                              style: TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'NIM: $studentId',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ==========================================================
              // 34. DETAIL COURSE: CODE, TITLE, CREDITS, & STATUS
              // ==========================================================
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kode Kursus & Badge Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: statusColor,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 13, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  statusLabel,
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Judul Kursus (Title)
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.25,
                        ),
                      ),
                      const Divider(height: 24),

                      // Rincian Informasi
                      _buildDetailRow(
                        icon: Icons.credit_card,
                        label: 'Bobot Satuan Kredit Semester:',
                        value: '$credits SKS',
                        color: Colors.indigo,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.flag,
                        label: 'Status Pengerjaan Materi:',
                        value: statusLabel,
                        color: statusColor,
                      ),
                      const SizedBox(height: 10),
                      _buildDetailRow(
                        icon: Icons.code,
                        label: 'Format Data Diterima:',
                        value: 'Map<String, dynamic>',
                        color: Colors.teal,
                      ),
                      const SizedBox(height: 14),

                      // Penjelasan Status
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info, size: 16, color: statusColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                statusDescription,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kartu Edukasi Passing Data
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.terminal, color: Colors.teal),
                          SizedBox(width: 8),
                          Text(
                            'Cuplikan Kode Constructor Passing (Materi 8)',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E2E),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '// Navigasi dengan data course\n'
                          'Navigator.push(\n'
                          '  context,\n'
                          '  MaterialPageRoute(\n'
                          '    builder: (_) => CourseDetailPage(course: course),\n'
                          '  ),\n'
                          ');',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            color: Color(0xFF89DDFF),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Tombol Kembali
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.teal.shade700),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: Icon(Icons.arrow_back, color: Colors.teal.shade800),
                  label: Text(
                    'Kembali ke Daftar Kursus',
                    style: TextStyle(
                      color: Colors.teal.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12.5, color: Colors.black87),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12.5,
            color: color,
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// TAHAP 9: RETURNING DATA DARI SCREEN
// ============================================================================

/// Halaman demonstrasi praktikum Tahap 9:
/// - 35. Buat tombol 'Pilih/Favorite' pada halaman detail.
/// - 36. Saat tombol ditekan, kembali ke halaman sebelumnya sambil mengirim nilai true.
/// - 37. Pada halaman awal, tampilkan SnackBar jika result == true.
/// - 38. Tulis satu contoh lain penggunaan data hasil dari screen.
class Tahap9Page extends StatefulWidget {
  const Tahap9Page({super.key});

  @override
  State<Tahap9Page> createState() => _Tahap9PageState();
}

class _Tahap9PageState extends State<Tahap9Page> {
  // Set untuk mencatat kursus yang telah ditandai sebagai favorit
  final Set<String> _favoriteCourses = {};

  // Contoh lain (Butir 38): Data hasil dari screen kustom (misal catatan kustom)
  String? _customFeedback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentTahap: 9),
      appBar: AppBar(
        title: const Text('Tahap 9: Returning Data'),
        backgroundColor: Colors.pink.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.pink.shade50.withValues(alpha: 0.3),
        child: FutureBuilder<Map<String, dynamic>>(
          future: loadStudentData(),
          builder: (context, snapshot) {
            List<dynamic> courses = fallbackCourses;
            if (snapshot.hasData && snapshot.data != null) {
              final data = snapshot.data!;
              if (data['courses'] is List) {
                courses = data['courses'] as List<dynamic>;
              }
            }

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // ========================================================
                // HEADER IDENTITAS MAHASISWA
                // ========================================================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  color: Colors.pink.shade800,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.favorite, color: Colors.pink, size: 30),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Praktikum Mobile - Tahap 9',
                                style: TextStyle(
                                  color: Colors.pinkAccent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                studentName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.5,
                                ),
                              ),
                              Text(
                                'NIM: $studentId  •  TRPL Undiksha',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Kartu Materi Returning Data
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.pink.shade200),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.keyboard_return_rounded,
                                color: Colors.pink.shade800, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Materi: Returning Data dari Screen',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.pink.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Navigator.pop(context, result) dapat mengembalikan nilai ke screen pemanggil. Navigator.push() dapat di-await untuk menerima nilai result tersebut.',
                          style: TextStyle(fontSize: 12, height: 1.4),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E2E),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'final result = await Navigator.push<bool>(\n'
                            '  context,\n'
                            '  MaterialPageRoute(builder: (_) => const DetailPage()),\n'
                            ');\n'
                            '// pada detail: Navigator.pop(context, true);',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11,
                              color: Color(0xFF89DDFF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header List Materi & Counter Favorit
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.bookmarks_rounded, color: Colors.pink.shade800),
                        const SizedBox(width: 6),
                        const Text(
                          'Pilih Kursus untuk Ditandai Favorit:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.pink.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_favoriteCourses.length} Favorit',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.pink.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // ========================================================
                // 35, 36, & 37. LISTVIEW DENGAN AWAIT NAVIGATOR.PUSH()
                // ========================================================
                ...courses.map((item) {
                  final Map<String, dynamic> course =
                      Map<String, dynamic>.from(item as Map);
                  final String code = course['code']?.toString() ?? 'MOB';
                  final String title = course['title']?.toString() ?? 'Course';
                  final int credits = (course['credits'] as num?)?.toInt() ?? 2;
                  final bool isFavorited = _favoriteCourses.contains(code);

                  return Card(
                    elevation: 1.5,
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isFavorited
                            ? Colors.pink.shade300
                            : Colors.grey.shade200,
                        width: isFavorited ? 1.5 : 1,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () async {
                        // 36. Menunggu nilai kembalian dari CourseFavoriteDetailPage
                        final result = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CourseFavoriteDetailPage(
                              course: course,
                              isAlreadyFavorited: isFavorited,
                            ),
                          ),
                        );

                        // 37. Pada halaman awal, tampilkan SnackBar jika result == true
                        if (result == true && mounted) {
                          setState(() {
                            _favoriteCourses.add(code);
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Kursus "$title" berhasil ditambahkan ke Favorit! (result == true)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.pink.shade700,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              action: SnackBarAction(
                                label: 'TUTUP',
                                textColor: Colors.white,
                                onPressed: () {},
                              ),
                            ),
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isFavorited
                                    ? Colors.pink.shade100
                                    : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              alignment: Alignment.center,
                              child: Icon(
                                isFavorited
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorited
                                    ? Colors.pink
                                    : Colors.grey.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$code  •  $credits SKS',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isFavorited)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.pink.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.pink.shade200),
                                ),
                                child: Text(
                                  'Favorit',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink.shade800,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.grey.shade400,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // ========================================================
                // 38. CONTOH LAIN PENGGUNAAN DATA HASIL DARI SCREEN
                // ========================================================
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Icon(
                                Icons.extension_rounded,
                                color: Colors.purple.shade800,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                '38. Contoh Lain Penggunaan Data Hasil dari Screen',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        const Text(
                          'Selain nilai boolean true/false, Navigator.pop(context, result) dapat mengembalikan tipe data apapun (String, int, List, atau Object/Model kustom):',
                          style: TextStyle(fontSize: 12.5, height: 1.4),
                        ),
                        const SizedBox(height: 12),

                        // Penjelasan 4 Kasus Nyata
                        _buildExamplePoint(
                          number: '1',
                          title: 'Formulir Edit Data / Profil Mahasiswa',
                          description:
                              'Halaman form mengembalikan objek Mahasiswa yang telah diedit: Navigator.pop(context, updatedStudent); sehingga halaman profil langsung terupdate tanpa fetch ulang.',
                        ),
                        const SizedBox(height: 8),
                        _buildExamplePoint(
                          number: '2',
                          title: 'Screen Filter & Sorting Katalog',
                          description:
                              'Screen filter mengembalikan kriteria pilihan pengguna (rentang harga, kategori, urutan): Navigator.pop(context, filterOptions); untuk memfilter data pada list.',
                        ),
                        const SizedBox(height: 8),
                        _buildExamplePoint(
                          number: '3',
                          title: 'Pemilih Item (Location / Contact / Image Picker)',
                          description:
                              'Screen pemilih foto atau peta mengembalikan path file gambar (File/String) atau koordinat peta (LatLng) yang dipilih pengguna.',
                        ),
                        const SizedBox(height: 8),
                        _buildExamplePoint(
                          number: '4',
                          title: 'Dialog Konfirmasi Hapus Data (Delete Confirmation)',
                          description:
                              'Dialog menampilkan "Apakah Anda yakin ingin menghapus data?". Tombol "Hapus" mengirimkan true, sedangkan "Batal" mengirimkan false / null.',
                        ),
                        const SizedBox(height: 14),

                        // Demonstrasi Interaktif Contoh Lain (Input Catatan Kustom)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.purple.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.edit_note,
                                      color: Colors.purple.shade800, size: 18),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Uji Coba: Mengembalikan Teks Catatan (String)',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _customFeedback != null
                                    ? 'Hasil yang dikembalikan: "$_customFeedback"'
                                    : 'Belum ada catatan yang dikembalikan.',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: _customFeedback != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: _customFeedback != null
                                      ? Colors.purple.shade900
                                      : Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.purple.shade700,
                                    foregroundColor: Colors.white,
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  icon: const Icon(Icons.add_comment, size: 16),
                                  label: const Text('Buka Dialog Input Catatan'),
                                  onPressed: () async {
                                    final textResult =
                                        await Navigator.push<String>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const CustomFeedbackPage(),
                                      ),
                                    );
                                    if (textResult != null &&
                                        textResult.isNotEmpty &&
                                        mounted) {
                                      setState(() {
                                        _customFeedback = textResult;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildExamplePoint({
    required String number,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 10,
          backgroundColor: Colors.purple.shade700,
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 11.5, color: Colors.black87),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 35 & 36. COURSE FAVORITE DETAIL PAGE
// - Memiliki tombol 'Pilih/Favorite'
// - Menutup halaman sambil mengirim Navigator.pop(context, true)
// ============================================================================

class CourseFavoriteDetailPage extends StatelessWidget {
  final Map<String, dynamic> course;
  final bool isAlreadyFavorited;

  const CourseFavoriteDetailPage({
    super.key,
    required this.course,
    this.isAlreadyFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    final String code = course['code']?.toString() ?? 'MOB';
    final String title = course['title']?.toString() ?? 'Judul Kursus';
    final int credits = (course['credits'] as num?)?.toInt() ?? 2;
    final String status = course['status']?.toString() ?? 'planned';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: $code'),
        backgroundColor: Colors.pink.shade800,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.grey.shade50,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Identitas Mahasiswa di Detail
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.pink.shade800,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 26,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.person, color: Colors.pink, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Identitas Mahasiswa',
                              style: TextStyle(
                                color: Colors.pinkAccent,
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              studentName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'NIM: $studentId  •  TRPL Undiksha',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kartu Detail Kursus
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.pink.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.pink.shade200),
                            ),
                            child: Text(
                              code,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.pink.shade800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$credits SKS',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Status Mata Kuliah: $status',
                        style: const TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      const Divider(height: 24),

                      // Penjelasan Aksi Pop Result
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.pink.shade50.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.pink.shade200),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.touch_app, size: 18, color: Colors.pink),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tekan tombol "Pilih/Favorite" di bawah untuk kembali ke halaman awal sambil mengembalikan nilai true (Navigator.pop(context, true)).',
                                style: TextStyle(fontSize: 12, height: 1.35),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // ==========================================================
              // 35 & 36. TOMBOL 'PILIH/FAVORITE'
              // Saat tombol ditekan, kembali sambil mengirim nilai true
              // ==========================================================
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink.shade700,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.favorite),
                  label: const Text(
                    'Pilih/Favorite',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {
                    // 36. Kembali ke halaman sebelumnya sambil mengirim nilai true
                    Navigator.pop(context, true);
                  },
                ),
              ),
              const SizedBox(height: 10),

              // Tombol Batal (mengembalikan nilai false atau null)
              SizedBox(
                width: double.infinity,
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Kembali tanpa menandai favorit
                    Navigator.pop(context, false);
                  },
                  child: const Text('Batal / Kembali'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CONTOH SCREEN PENDUKUNG BUTIR 38 (MENGEMBALIKAN STRING HASIL INPUT)
// ============================================================================

class CustomFeedbackPage extends StatefulWidget {
  const CustomFeedbackPage({super.key});

  @override
  State<CustomFeedbackPage> createState() => _CustomFeedbackPageState();
}

class _CustomFeedbackPageState extends State<CustomFeedbackPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Catatan Kustom'),
        backgroundColor: Colors.purple.shade800,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '38. Contoh Lain Returning Data:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ketikkan teks catatan di bawah ini. Saat tombol "Kirim Catatan" ditekan, screen ini akan mem-pop dan mengembalikan teks String tersebut ke halaman awal.',
              style: TextStyle(fontSize: 12.5, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Catatan / Review Kursus',
                border: OutlineInputBorder(),
                hintText: 'Contoh: Materi Flutter sangat interaktif dan mudah dipahami...',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              icon: const Icon(Icons.send),
              label: const Text('Kirim Catatan (Navigator.pop(context, text))'),
              onPressed: () {
                // Mengembalikan teks String ke screen sebelumnya
                Navigator.pop(context, _controller.text);
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TAHAP 10: NAVIGATIONBAR / BOTTOMNAVIGATIONBAR
// ============================================================================

/// 40. StatefulWidget untuk menyimpan selectedIndex
/// 39. Tiga destination: Home, Courses, Profile
/// 41. Menampilkan widget/page sesuai index
/// 42. Identitas mahasiswa tersedia pada Profile dan screen lainnya
class Tahap10Page extends StatefulWidget {
  const Tahap10Page({super.key});

  @override
  State<Tahap10Page> createState() => _Tahap10PageState();
}

class _Tahap10PageState extends State<Tahap10Page> {
  // 40. Menyimpan index destinasi aktif
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Judul AppBar dinamis berdasarkan tab yang dipilih
    final List<String> tabTitles = const [
      'Tahap 10: Home Dashboard',
      'Tahap 10: Daftar Courses',
      'Tahap 10: Profil Mahasiswa',
    ];

    return Scaffold(
      drawer: const AppDrawer(currentTahap: 10),
      appBar: AppBar(
        title: Text(tabTitles[currentIndex]),
        backgroundColor: Colors.indigo.shade800,
        foregroundColor: Colors.white,
      ),
      // 41. Menampilkan widget/halaman yang sesuai dengan currentIndex
      // Menggunakan IndexedStack agar state dan posisi scroll tiap halaman tetap terjaga
      body: IndexedStack(
        index: currentIndex,
        children: const [
          Tahap10HomeDestination(),
          Tahap10CoursesDestination(),
          Tahap10ProfileDestination(),
        ],
      ),
      // 39 & Materi. NavigationBar Material 3 dengan 3 Destinasi
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() => currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: Colors.indigo),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school, color: Colors.indigo),
            label: 'Courses',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: Colors.indigo),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DESTINASI 1: HOME DESTINATION
// 42. Memuat identitas mahasiswa (Nama & NIM)
// ============================================================================

class Tahap10HomeDestination extends StatelessWidget {
  const Tahap10HomeDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo.shade50.withValues(alpha: 0.3),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 42. Identitas Mahasiswa pada Screen Home
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Colors.indigo.shade800,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, color: Colors.indigo, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Selamat Datang di Beranda,',
                          style: TextStyle(
                            color: Colors.indigoAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          studentName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                          ),
                        ),
                        Text(
                          'NIM: $studentId  •  TRPL Undiksha',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kartu Materi Inti Tahap 10
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.indigo.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tab_rounded, color: Colors.indigo.shade800),
                      const SizedBox(width: 8),
                      Text(
                        'Materi: Navigasi Utama Tingkat Atas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: Colors.indigo.shade900,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  const Text(
                    'NavigationBar digunakan untuk berpindah antar-destinasi tingkat atas seperti Home, Courses, dan Profile.',
                    style: TextStyle(fontSize: 12.5, height: 1.4),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            size: 18, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Penting: Jangan gunakan Navigator.push() berulang untuk setiap tab utama, karena akan menumpuk rute tanpa akhir dan memboroskan memori. Gunakan NavigationBar dengan selectedIndex.',
                            style: TextStyle(fontSize: 12, height: 1.35),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Ringkasan Statistik Singkat
          const Text(
            'Ringkasan Perkuliahan Mobile:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  title: 'Modul Selesai',
                  value: '2 Modul',
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Modul Aktif',
                  value: '1 Modul',
                  icon: Icons.play_circle_fill,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildSummaryCard(
                  title: 'Rencana',
                  value: '3 Modul',
                  icon: Icons.schedule,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DESTINASI 2: COURSES DESTINATION
// ============================================================================

class Tahap10CoursesDestination extends StatelessWidget {
  const Tahap10CoursesDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: FutureBuilder<Map<String, dynamic>>(
        future: loadStudentData(),
        builder: (context, snapshot) {
          List<dynamic> courses = fallbackCourses;
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            if (data['courses'] is List) {
              courses = data['courses'] as List<dynamic>;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header Daftar Kursus
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Materi Praktikum Mobile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    '${courses.length} Kursus',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.indigo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Item Kursus
              ...courses.map((item) {
                final Map<String, dynamic> course =
                    Map<String, dynamic>.from(item as Map);
                final String code = course['code']?.toString() ?? 'MOB';
                final String title = course['title']?.toString() ?? 'Course';
                final int credits = (course['credits'] as num?)?.toInt() ?? 2;
                final String status =
                    course['status']?.toString().toLowerCase() ?? 'planned';

                Color statusColor;
                IconData statusIcon;
                String statusLabel;
                switch (status) {
                  case 'done':
                    statusColor = Colors.green;
                    statusIcon = Icons.check_circle_rounded;
                    statusLabel = 'Selesai';
                    break;
                  case 'active':
                    statusColor = Colors.blue;
                    statusIcon = Icons.play_circle_fill_rounded;
                    statusLabel = 'Aktif';
                    break;
                  default:
                    statusColor = Colors.orange;
                    statusIcon = Icons.schedule_rounded;
                    statusLabel = 'Rencana';
                }

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        code,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                          color: statusColor,
                        ),
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text('$credits SKS  •  $statusLabel'),
                    trailing: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 20,
                    ),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// DESTINASI 3: PROFILE DESTINATION
// 42. Memuat identitas lengkap mahasiswa (Nama & NIM)
// ============================================================================

class Tahap10ProfileDestination extends StatelessWidget {
  const Tahap10ProfileDestination({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 42. Kartu Profil Utama Mahasiswa
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.indigo.shade800,
                    child: const Icon(
                      Icons.person,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 42. Nama Mahasiswa
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 42. NIM Mahasiswa
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.indigo.shade200),
                    ),
                    child: Text(
                      'NIM: $studentId',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.indigo.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Teknologi Rekayasa Perangkat Lunak',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const Text(
                    'Universitas Pendidikan Ganesha (Undiksha)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Detail Kredensial & Akun
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _buildProfileTile(
                  icon: Icons.email_outlined,
                  title: 'Email Undiksha',
                  subtitle: 'michael.marcel@undiksha.ac.id',
                ),
                const Divider(height: 1),
                _buildProfileTile(
                  icon: Icons.school_outlined,
                  title: 'Status Akademik',
                  subtitle: 'Mahasiswa Aktif - Semester 5',
                ),
                const Divider(height: 1),
                _buildProfileTile(
                  icon: Icons.phone_android_outlined,
                  title: 'Mata Kuliah Praktikum',
                  subtitle: 'Pemrograman Aplikasi Perangkat Bergerak',
                ),
                const Divider(height: 1),
                _buildProfileTile(
                  icon: Icons.badge_outlined,
                  title: 'Dosen Pengampu',
                  subtitle: 'I Made Agus Wirahadi Putra, S.Kom., M.Cs.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.indigo),
      title: Text(
        title,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

// ============================================================================
// TAHAP 11: ADAPTIVE NAVIGATION (NAVIGATIONBAR VS NAVIGATIONRAIL)
// ============================================================================

/// 43. Shell aplikasi menggunakan LayoutBuilder
/// 44. Menampilkan NavigationBar pada compact/medium (< 840 dp)
/// 45. Menampilkan NavigationRail pada expanded (>= 840 dp)
/// 46. Memastikan page yang aktif tetap sama ketika layout berubah
class Tahap11Page extends StatefulWidget {
  const Tahap11Page({super.key});

  @override
  State<Tahap11Page> createState() => _Tahap11PageState();
}

class _Tahap11PageState extends State<Tahap11Page> {
  // 46. selectedIndex disimpan pada State sehingga halaman aktif tetap sama
  // ketika orientasi atau ukuran layout berubah (< 840 dp vs >= 840 dp)
  int selectedIndex = 0;

  // Fitur simulasi lebar kontainer (agar mode expanded >= 840 dp dapat diuji langsung di HP)
  bool _enableSimulatedWidth = false;
  double _simulatedWidth = 900.0;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final physicalWidth = mediaQuery.size.width;

    // 43. Menggunakan LayoutBuilder pada shell aplikasi
    return LayoutBuilder(
      builder: (context, constraints) {
        // Lebar efektif yang dievaluasi (nyata atau simulasi slider)
        final double effectiveWidth =
            _enableSimulatedWidth ? _simulatedWidth : constraints.maxWidth;
        final bool isCompactOrMedium = effectiveWidth < 840;

        // Daftar halaman destinasi (Home, Courses, Profile)
        final List<Widget> pages = [
          Tahap11HomeContent(
            effectiveWidth: effectiveWidth,
            isCompactOrMedium: isCompactOrMedium,
            isSimulated: _enableSimulatedWidth,
            simulatedWidth: _simulatedWidth,
            physicalWidth: physicalWidth,
            onToggleSimulation: (val) {
              setState(() {
                _enableSimulatedWidth = val;
                if (val) {
                  _simulatedWidth = 900.0;
                }
              });
            },
            onWidthChanged: (val) {
              setState(() {
                _simulatedWidth = val;
              });
            },
          ),
          const Tahap11CoursesContent(),
          const Tahap11ProfileContent(),
        ];

        final List<String> tabTitles = const [
          'Tahap 11: Beranda Adaptif',
          'Tahap 11: Kursus Adaptif',
          'Tahap 11: Profil Mahasiswa',
        ];

        // ================================================================
        // 44. KONDISI < 840 DP: TAMPILKAN NAVIGATIONBAR (COMPACT/MEDIUM)
        // ================================================================
        if (isCompactOrMedium) {
          return Scaffold(
            drawer: const AppDrawer(currentTahap: 11),
            appBar: AppBar(
              title: Text(tabTitles[selectedIndex]),
              backgroundColor: Colors.teal.shade800,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  tooltip: 'Simulasi Breakpoint Layout',
                  icon: Icon(
                    _enableSimulatedWidth
                        ? Icons.desktop_windows
                        : Icons.phone_android,
                  ),
                  onPressed: () {
                    setState(() {
                      _enableSimulatedWidth = !_enableSimulatedWidth;
                      if (_enableSimulatedWidth) {
                        _simulatedWidth = 900.0;
                      }
                    });
                  },
                ),
              ],
            ),
            // 46. Page aktif diambil dari pages[selectedIndex]
            body: pages[selectedIndex],
            // 44. NavigationBar pada bagian bawah (BottomNavigationBar Material 3)
            bottomNavigationBar: buildNavigationBar(),
          );
        }

        // ================================================================
        // 45. KONDISI >= 840 DP: TAMPILKAN NAVIGATIONRAIL (EXPANDED)
        // ================================================================
        return Scaffold(
          drawer: const AppDrawer(currentTahap: 11),
          appBar: AppBar(
            title: Text('${tabTitles[selectedIndex]} (Mode Expanded / Tablet / Desktop)'),
            backgroundColor: Colors.teal.shade800,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: 'Kembali ke Ukuran Layar Nyata',
                icon: const Icon(Icons.settings_backup_restore),
                onPressed: () {
                  setState(() {
                    _enableSimulatedWidth = false;
                  });
                },
              ),
            ],
          ),
          // 45. Layout horizontal dengan NavigationRail di samping kiri
          body: Row(
            children: [
              buildNavigationRail(),
              const VerticalDivider(width: 1, thickness: 1),
              // 46. Page aktif tetap sama diambil dari pages[selectedIndex]
              Expanded(child: pages[selectedIndex]),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // 44. WIDGET NAVIGATIONBAR UNTUK COMPACT/MEDIUM (< 840 DP)
  // ==========================================================================
  Widget buildNavigationBar() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: Colors.teal),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school, color: Colors.teal),
          label: 'Courses',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: Colors.teal),
          label: 'Profile',
        ),
      ],
    );
  }

  // ==========================================================================
  // 45. WIDGET NAVIGATIONRAIL UNTUK EXPANDED (>= 840 DP)
  // ==========================================================================
  Widget buildNavigationRail() {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: Colors.white,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.teal.shade800,
          child: const Icon(Icons.devices, color: Colors.white, size: 20),
        ),
      ),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home, color: Colors.teal),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school, color: Colors.teal),
          label: Text('Courses'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person, color: Colors.teal),
          label: Text('Profile'),
        ),
      ],
    );
  }
}

// ============================================================================
// KONTEN DESTINASI 1: HOME TAB TAHAP 11
// ============================================================================

class Tahap11HomeContent extends StatelessWidget {
  final double effectiveWidth;
  final bool isCompactOrMedium;
  final bool isSimulated;
  final double simulatedWidth;
  final double physicalWidth;
  final ValueChanged<bool> onToggleSimulation;
  final ValueChanged<double> onWidthChanged;

  const Tahap11HomeContent({
    super.key,
    required this.effectiveWidth,
    required this.isCompactOrMedium,
    required this.isSimulated,
    required this.simulatedWidth,
    required this.physicalWidth,
    required this.onToggleSimulation,
    required this.onWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.teal.shade50.withValues(alpha: 0.25),
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Identitas Mahasiswa Banner
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            color: Colors.teal.shade800,
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.devices, color: Colors.teal, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Praktikum Mobile - Tahap 11',
                          style: TextStyle(
                            color: Colors.tealAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          studentName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.5,
                          ),
                        ),
                        Text(
                          'NIM: $studentId  •  TRPL Undiksha',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kartu Pengamatan Status Breakpoint & Navigasi Aktif
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isCompactOrMedium
                    ? Colors.orange.shade300
                    : Colors.indigo.shade300,
                width: 1.5,
              ),
            ),
            color: isCompactOrMedium ? Colors.orange.shade50 : Colors.indigo.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isCompactOrMedium
                            ? Icons.phone_android
                            : Icons.desktop_windows,
                        color: isCompactOrMedium
                            ? Colors.deepOrange.shade800
                            : Colors.indigo.shade800,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCompactOrMedium
                              ? '44. Mode Compact / Medium (< 840 dp)'
                              : '45. Mode Expanded (>= 840 dp)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isCompactOrMedium
                                ? Colors.deepOrange.shade900
                                : Colors.indigo.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Komponen Navigasi Aktif:',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isCompactOrMedium
                              ? Colors.deepOrange
                              : Colors.indigo,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isCompactOrMedium
                              ? 'NavigationBar (Bawah)'
                              : 'NavigationRail (Samping)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lebar Layar Saat Ini: ${effectiveWidth.toStringAsFixed(1)} dp '
                    '${isSimulated ? "(Mode Simulasi Slider)" : "(Ukuran Layar Fisik)"}',
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '46. Pembuktian: Tab yang dipilih tetap sama saat ukuran layar berubah antara ponsel dan tablet/desktop tanpa reload atau reset posisi.',
                    style: TextStyle(fontSize: 12, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Kontrol Simulasi Slider Breakpoint
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.teal.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.tune, color: Colors.teal, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Simulasi Breakpoint Layar:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      Switch(
                        value: isSimulated,
                        activeColor: Colors.teal,
                        onChanged: onToggleSimulation,
                      ),
                    ],
                  ),
                  Text(
                    isSimulated
                        ? 'Geser slider untuk berpindah seketika antara < 840 dp (NavigationBar) dan >= 840 dp (NavigationRail):'
                        : 'Aktifkan switch untuk menguji tampilan NavigationRail langsung di layar ponsel.',
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  if (isSimulated) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${simulatedWidth.toStringAsFixed(0)} dp',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: simulatedWidth,
                            min: 360.0,
                            max: 1200.0,
                            divisions: 28,
                            activeColor: Colors.teal,
                            onChanged: onWidthChanged,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cuplikan Kode Materi Sesuai Perintah
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cuplikan Kode Shell Adaptif (Materi 11):',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2E),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'if (constraints.maxWidth < 840) {\n'
                      '  return Scaffold(\n'
                      '    body: pages[selectedIndex],\n'
                      '    bottomNavigationBar: buildNavigationBar(),\n'
                      '  );\n'
                      '}\n\n'
                      'return Scaffold(\n'
                      '  body: Row(\n'
                      '    children: [\n'
                      '      buildNavigationRail(),\n'
                      '      const VerticalDivider(width: 1),\n'
                      '      Expanded(child: pages[selectedIndex]),\n'
                      '    ],\n'
                      '  ),\n'
                      ');',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: Color(0xFF89DDFF),
                        fontSize: 11.5,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

// ============================================================================
// KONTEN DESTINASI 2: COURSES TAB TAHAP 11
// ============================================================================

class Tahap11CoursesContent extends StatelessWidget {
  const Tahap11CoursesContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: FutureBuilder<Map<String, dynamic>>(
        future: loadStudentData(),
        builder: (context, snapshot) {
          List<dynamic> courses = fallbackCourses;
          if (snapshot.hasData && snapshot.data != null) {
            final data = snapshot.data!;
            if (data['courses'] is List) {
              courses = data['courses'] as List<dynamic>;
            }
          }

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Kursus Adaptif',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${courses.length} Kursus Tersedia',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...courses.map((item) {
                final Map<String, dynamic> course =
                    Map<String, dynamic>.from(item as Map);
                final String code = course['code']?.toString() ?? 'MOB';
                final String title = course['title']?.toString() ?? 'Course';
                final int credits = (course['credits'] as num?)?.toInt() ?? 2;
                final String status =
                    course['status']?.toString().toLowerCase() ?? 'planned';

                Color statusColor = status == 'done'
                    ? Colors.green
                    : (status == 'active' ? Colors.blue : Colors.orange);

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        code,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: statusColor,
                        ),
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text('$credits SKS  •  Status: $status'),
                    trailing: const Icon(Icons.check_circle_outline, size: 18),
                  ),
                );
              }),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// KONTEN DESTINASI 3: PROFILE TAB TAHAP 11
// ============================================================================

class Tahap11ProfileContent extends StatelessWidget {
  const Tahap11ProfileContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade50,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.teal.shade800,
                    child: const Icon(
                      Icons.person,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    studentName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.teal.shade200),
                    ),
                    child: Text(
                      'NIM: $studentId',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Colors.teal.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Teknologi Rekayasa Perangkat Lunak',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  const Text(
                    'Universitas Pendidikan Ganesha (Undiksha)',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                ListTile(
                  leading: Icon(Icons.email_outlined, color: Colors.teal),
                  title: Text('Email Undiksha', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text('michael.marcel@undiksha.ac.id', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.devices, color: Colors.teal),
                  title: Text('Pengujian Navigasi Adaptif', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  subtitle: Text('Material 3 NavigationBar vs NavigationRail', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}


