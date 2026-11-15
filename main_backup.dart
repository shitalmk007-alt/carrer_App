import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'video_player_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jdrxzabhhtdyrbuhjqxx.supabase.co',
    publishableKey: 'sb_publishable_bBCBY8IIxTHvWSILpknWSA_OhAGKUAE',
  );

  runApp(const CareerApp());
}

final supabase = Supabase.instance.client;
class CareerApp extends StatelessWidget {
  const CareerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Career App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}

// ======================================================
// AUTH GATE
// ======================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session != null) {
          return const HomePage();
        }

        return const LoginPage();
      },
    );
  }
}

// ======================================================
// LOGIN PAGE - MAGIC LINK
// ======================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  bool loading = false;
  bool emailSent = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool validEmail(String email) {
    return RegExp(
      r'^[\w\.-]+@[\w\.-]+\.\w+$',
    ).hasMatch(email);
  }

  Future<void> sendMagicLink() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      showMessage('Please enter your name');
      return;
    }

    if (email.isEmpty || !validEmail(email)) {
      showMessage('Please enter a valid email');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await supabase.auth.signInWithOtp(
        email: email,
        shouldCreateUser: true,

        // Android deep link
        emailRedirectTo: 'io.supabase.flutter://signin-callback/',

        data: {
          'name': name,
        },
      );

      if (!mounted) return;

      setState(() {
        emailSent = true;
      });

      showMessage(
        'Magic link sent! Check your email and tap "Sign in".',
      );
    } on AuthException catch (e) {
      showMessage(e.message);
    } catch (e) {
      showMessage('Something went wrong');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.work_outline,
                  size: 80,
                  color: Colors.blue,
                ),

                const SizedBox(height: 20),

                const Text(
                  'Career App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Build your career with confidence',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 40),

                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : sendMagicLink,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Send Magic Link',
                            style: TextStyle(fontSize: 17),
                          ),
                  ),
                ),

                if (emailSent) ...[
                  const SizedBox(height: 25),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                     color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.mark_email_read,
                          color: Colors.blue,
                          size: 40,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Check your email',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Open the email from Supabase and tap "Sign in".',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ======================================================
// HOME PAGE
// ======================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Career> careers = [
  Career(
    title: 'Software Developer',
    description:
        'Software developers design, build, test and maintain applications and software systems.',
    skills: [
      'Programming',
      'Problem Solving',
      'Data Structures',
      'Algorithms',
      'Git',
    ],
    salary: '₹4 LPA - ₹12 LPA',
    education: 'B.E / B.Tech in Computer Science or related field',
    jobRoles: [
      'Software Developer',
      'Application Developer',
      'Backend Developer',
      'Frontend Developer',
    ],
    growth:
        'With experience, you can become a Senior Developer, Tech Lead or Software Architect.',
    videoId: 'rfscVS0vtbw',
  ),

  Career(
    title: 'Data Scientist',
    description:
        'Data scientists analyze data and use statistics, programming and machine learning to solve business problems.',
    skills: [
      'Python',
      'Statistics',
      'Machine Learning',
      'SQL',
      'Data Analysis',
    ],
    salary: '₹5 LPA - ₹18 LPA',
    education: 'B.E / B.Tech in CSE, Data Science or related field',
    jobRoles: [
      'Data Scientist',
      'Data Analyst',
      'Machine Learning Analyst',
      'Data Engineer',
    ],
    growth:
        'You can progress to Senior Data Scientist, Data Science Lead or Machine Learning Manager.',
    videoId: 'ua-CiDNNj30',
  ),

  Career(
    title: 'AI Engineer',
    description:
        'AI engineers develop intelligent systems using artificial intelligence and machine learning technologies.',
    skills: [
      'Python',
      'Machine Learning',
      'Deep Learning',
      'Artificial Intelligence',
      'Problem Solving',
    ],
    salary: '₹6 LPA - ₹20 LPA',
    education: 'B.E / B.Tech in CSE, AI/ML or related field',
    jobRoles: [
      'AI Engineer',
      'Machine Learning Engineer',
      'Deep Learning Engineer',
      'AI Developer',
    ],
    growth:
        'You can grow into Senior AI Engineer, AI Architect or AI/ML Lead roles.',
    videoId: 'i_LwzRVP7bg',
  ),

  Career(
    title: 'Web Developer',
    description:
        'Web developers create and maintain websites and web applications for different types of users and organizations.',
    skills: [
      'HTML',
      'CSS',
      'JavaScript',
      'Responsive Design',
      'Web Development',
    ],
    salary: '₹3 LPA - ₹10 LPA',
    education: 'B.E / B.Tech in CSE or related field',
    jobRoles: [
      'Frontend Developer',
      'Backend Developer',
      'Full Stack Developer',
      'Web Developer',
    ],
    growth:
        'With experience, you can become a Senior Web Developer, Full Stack Developer or Technical Lead.',
    videoId: 'pQN-pnXPaVg',
  ),

  Career(
    title: 'Cyber Security',
    description:
        'Cyber security professionals protect computer systems, networks and data from security threats.',
    skills: [
      'Networking',
      'Cyber Security',
      'Linux',
      'Ethical Hacking',
      'Problem Solving',
    ],
    salary: '₹4 LPA - ₹15 LPA',
    education: 'B.E / B.Tech in CSE, Cyber Security or related field',
    jobRoles: [
      'Cyber Security Analyst',
      'Security Engineer',
      'Ethical Hacker',
      'Security Consultant',
    ],
    growth:
        'You can progress to Senior Security Analyst, Security Architect or Cyber Security Manager.',
    videoId: 'inWWhr5tnEA',
  ),
];

  @override
  Widget build(BuildContext context) {
    final pages = [
      buildHome(),
      const SavedPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget buildHome() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Find Your Career',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Explore career opportunities and required skills.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Career Options',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          ...careers.map(
            (career) => CareerCard(career: career),
          ),

          const SizedBox(height: 10),

        ],
      ),
    );
  }
}

// ======================================================
// CAREER CARD
// ======================================================

class CareerCard extends StatefulWidget {
  final Career career;

  const CareerCard({
    super.key,
    required this.career,
  });

  @override
  State<CareerCard> createState() => _CareerCardState();
}

class _CareerCardState extends State<CareerCard> {
  bool saved = false;

  @override
  void initState() {
    super.initState();
    loadSaved();
  }

  Future<void> loadSaved() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      saved = prefs.getBool(
            'saved_${widget.career.title}',
          ) ??
          false;
    });
  }

  Future<void> toggleSaved() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      saved = !saved;
    });

    await prefs.setBool(
      'saved_${widget.career.title}',
      saved,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 25,
                  child: Icon(Icons.work),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    widget.career.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: toggleSaved,
                  icon: Icon(
                    saved
                        ? Icons.bookmark
                        : Icons.bookmark_border,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(widget.career.description),

            const SizedBox(height: 10),

            Text(
              'Salary: ${widget.career.salary}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: widget.career.skills
                  .map(
                    (skill) => Chip(
                      label: Text(skill),
                    ),
                  )
                  .toList(),
            ),

            const SizedBox(height: 10),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CareerDetailsPage(
                        career: widget.career,
                      ),
                    ),
                  );
                },
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// CAREER DETAILS
// ======================================================

class CareerDetailsPage extends StatefulWidget {
  final Career career;

  const CareerDetailsPage({
    super.key,
    required this.career,
  });

  @override
  State<CareerDetailsPage> createState() => _CareerDetailsPageState();
}

class _CareerDetailsPageState extends State<CareerDetailsPage> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    loadSavedStatus();
  }

  Future<void> loadSavedStatus() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isSaved = prefs.getBool('saved_${widget.career.title}') ?? false;
    });
  }

  Future<void> toggleSave() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      isSaved = !isSaved;
    });

    await prefs.setBool(
      'saved_${widget.career.title}',
      isSaved,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved
              ? '${widget.career.title} saved'
              : '${widget.career.title} removed from saved',
        ),
      ),
    );
  }

  Future<void> findJobs() async {
    final careerName = Uri.encodeComponent(widget.career.title);

    final url = Uri.parse(
      'https://www.linkedin.com/jobs/search/?keywords=$careerName',
    );

    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open LinkedIn'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open LinkedIn'),
        ),
      );
    }
  }

  Widget sectionTitle(
    IconData icon,
    String title,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget informationCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sectionTitle(icon, title),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final career = widget.career;

    return Scaffold(
      appBar: AppBar(
        title: Text(career.title),
        actions: [
          IconButton(
            onPressed: toggleSave,
            tooltip: 'Save Career',
            icon: Icon(
              isSaved ? Icons.star : Icons.star_border,
              color: isSaved ? Colors.amber : null,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Career Title
            Text(
              career.title,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // Career Overview
            informationCard(
              icon: Icons.info_outline,
              title: 'Career Overview',
              child: Text(
                career.description,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            // Job Roles
            informationCard(
              icon: Icons.work_outline,
              title: 'Job Roles',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: career.jobRoles.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '• ',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            role,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            // Required Skills
            informationCard(
              icon: Icons.build_outlined,
              title: 'Required Skills',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: career.skills.map((skill) {
                  return Chip(
                    label: Text(skill),
                  );
                }).toList(),
              ),
            ),

            // Education
            informationCard(
              icon: Icons.school_outlined,
              title: 'Education',
              child: Text(
                career.education,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            // Salary
            informationCard(
              icon: Icons.currency_rupee,
              title: 'Salary Range',
              child: Text(
                career.salary,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Career Growth
            informationCard(
              icon: Icons.trending_up,
              title: 'Career Growth',
              child: Text(
                career.growth,
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),

            // Related Career Video
            informationCard(
              icon: Icons.video_library_outlined,
              title: 'Related Career Video',
              child: VideoCard(
                title: 'Learn ${career.title}',
                videoId: career.videoId,
              ),
            ),

            const SizedBox(height: 8),

            // Save Career Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: toggleSave,
                icon: Icon(
                  isSaved ? Icons.star : Icons.star_border,
                ),
                label: Text(
                  isSaved ? 'Career Saved' : 'Save Career',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Find Jobs on LinkedIn
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: findJobs,
                icon: const Icon(Icons.work),
                label: const Text(
                  'Find Jobs on LinkedIn',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// SAVED PAGE
// ======================================================

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  final List<String> careers = [
    'Software Developer',
    'Data Scientist',
    'AI Engineer',
    'Web Developer',
    'Cyber Security',
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<String>>(
        future: getSavedCareers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final saved = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Saved Careers',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              if (saved.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Text(
                      'No saved careers yet.',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

              ...saved.map(
                (career) => Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.work),
                    ),
                    title: Text(career),
                    trailing: const Icon(
                      Icons.bookmark,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<List<String>> getSavedCareers() async {
    final prefs = await SharedPreferences.getInstance();

    return careers
        .where(
          (career) =>
              prefs.getBool('saved_$career') ?? false,
        )
        .toList();
  }
}

// ======================================================
// PROFILE PAGE
// ======================================================

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String name = '';
  String email = '';

  final skillController = TextEditingController();

  List<String> skills = [];

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    skillController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      name =
          prefs.getString('profile_name') ??
          supabase.auth.currentUser?.userMetadata?['name'] ??
          'User';

      email =
          supabase.auth.currentUser?.email ??
          '';

      skills = prefs.getStringList('skills') ?? [];
    });
  }

  Future<void> saveSkill() async {
    final skill = skillController.text.trim();

    if (skill.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      skills.add(skill);
      skillController.clear();
    });

    await prefs.setStringList('skills', skills);
  }

  Future<void> editProfile() async {
    final controller = TextEditingController(text: name);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName =
                    controller.text.trim();

                if (newName.isNotEmpty) {
                  final prefs =
                      await SharedPreferences.getInstance();

                  await prefs.setString(
                    'profile_name',
                    newName,
                  );

                  setState(() {
                    name = newName;
                  });
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    controller.dispose();
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'My Profile',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 25),

          const CircleAvatar(
            radius: 50,
            child: Icon(
              Icons.person,
              size: 55,
            ),
          ),

          const SizedBox(height: 15),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          ElevatedButton.icon(
            onPressed: editProfile,
            icon: const Icon(Icons.edit),
            label: const Text('Edit Profile'),
          ),

          const SizedBox(height: 30),

          const Text(
            'My Skills',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: skillController,
                  decoration: const InputDecoration(
                    labelText: 'Add Skill',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: saveSkill,
                icon: const Icon(
                  Icons.add_circle,
                  size: 35,
                  color: Colors.blue,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: skills
                .map(
                  (skill) => Chip(
                    label: Text(skill),
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 40),

          OutlinedButton.icon(
            onPressed: logout,
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

// ======================================================
// VIDEO CARD
// ======================================================

class VideoCard extends StatelessWidget {
  final String title;
  final String videoId;

  const VideoCard({
    super.key,
    required this.title,
    required this.videoId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          child: Icon(Icons.play_arrow),
        ),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerPage(
                videoId: videoId,
                videoTitle: title,
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================================================
// CAREER MODEL
// ======================================================

class Career {
  final String title;
  final String description;
  final List<String> skills;
  final String salary;
  final String education;
  final List<String> jobRoles;
  final String growth;
  final String videoId;

  Career({
    required this.title,
    required this.description,
    required this.skills,
    required this.salary,
    required this.education,
    required this.jobRoles,
    required this.growth,
    required this.videoId,
  });
}