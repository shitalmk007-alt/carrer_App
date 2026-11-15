import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
    color: Colors.blue,
    icon: Icons.code,
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
    color: Colors.purple,
    icon: Icons.analytics,
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
    color: Colors.teal,
    icon: Icons.smart_toy,
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
    color: Colors.orange,
    icon: Icons.language,
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
    color: Colors.green,
    icon: Icons.security,
  ),
];

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

  final List<Widget> pages = const [
    HomeCareerContent(),
    SavedPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.star_border),
            selectedIcon: Icon(Icons.star),
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
}


class HomeCareerContent extends StatefulWidget {
  const HomeCareerContent({super.key});

  @override
  State<HomeCareerContent> createState() =>
      _HomeCareerContentState();
}

class _HomeCareerContentState
    extends State<HomeCareerContent> {
  final TextEditingController searchController =
      TextEditingController();

  String searchQuery = '';
  String selectedCategory = 'All Careers';
  String selectedSort = 'Name: A-Z';
  // Dashboard data
String dashboardName = 'User';
List<String> dashboardSkills = [];
int savedCareerCount = 0;

@override
void initState() {
  super.initState();
  loadDashboardData();
}

Future<void> loadDashboardData() async {
  final prefs = await SharedPreferences.getInstance();

  final loadedName = prefs.getString('profile_name') ?? 'User';
  final loadedSkills = prefs.getStringList('skills') ?? [];
  final savedCareers = prefs.getStringList('savedCareers') ?? [];

  if (!mounted) return;

  setState(() {
    dashboardName =
        loadedName.trim().isEmpty ? 'User' : loadedName.trim();
    dashboardSkills = loadedSkills;
    savedCareerCount = savedCareers.length;
  });
}

  final List<String> categories = [
    'All Careers',
    'Programming',
    'Data & AI',
    'Security',
  ];

  final List<String> sortOptions = [
    'Name: A-Z',
    'Name: Z-A',
  ];

  // Search careers and apply category filters.
  List<Career> get filteredCareers {
    final query = searchQuery.trim().toLowerCase();

    final results = careers.where((career) {
      final matchesSearch = query.isEmpty ||
          career.title.toLowerCase().contains(query) ||
          career.description.toLowerCase().contains(query) ||
          career.skills.any(
            (skill) => skill.toLowerCase().contains(query),
          ) ||
          career.jobRoles.any(
            (role) => role.toLowerCase().contains(query),
          ) ||
          career.education.toLowerCase().contains(query);

      bool matchesCategory;

      switch (selectedCategory) {
        case 'Programming':
          matchesCategory =
              career.title == 'Software Developer' ||
              career.title == 'Web Developer';
          break;

        case 'Data & AI':
          matchesCategory =
              career.title == 'Data Scientist' ||
              career.title == 'AI Engineer';
          break;

        case 'Security':
          matchesCategory =
              career.title == 'Cyber Security';
          break;

        default:
          matchesCategory = true;
      }

      return matchesSearch && matchesCategory;
    }).toList();

    // Sort careers alphabetically.
    results.sort((a, b) {
      final comparison = a.title
          .toLowerCase()
          .compareTo(b.title.toLowerCase());

      return selectedSort == 'Name: Z-A'
          ? -comparison
          : comparison;
    });

    return results;
  }
// Recommend careers based on profile skills.
List<Career> get recommendedCareers {
  final matchedCareers = careers.where((career) {
    return career.skills.any((careerSkill) {
      return dashboardSkills.any((userSkill) {
        return userSkill.trim().toLowerCase() ==
            careerSkill.trim().toLowerCase();
      });
    });
  }).toList();

  final suggestions =
      matchedCareers.isNotEmpty ? matchedCareers : careers;

  return suggestions.take(3).toList();
}
  // Reset the search field and filters.
  void clearSearchAndFilters() {
    searchController.clear();

    setState(() {
      searchQuery = '';
      selectedCategory = 'All Careers';
      selectedSort = 'Name: A-Z';
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
  Widget _buildDashboardStat({
  required IconData icon,
  required String title,
  required String value,
  required Color color,
}) {
  return Card(
    elevation: 1,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 6,
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final results = filteredCareers;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar(
            expandedHeight: 170,
            pinned: true,
            backgroundColor: Colors.blue,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Career App',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.indigo,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.work_outline,
                    size: 70,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),

          // Page heading
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(
                'Explore Career Opportunities',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Description
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Discover careers, required skills, education, '
                'salary and job opportunities.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
          // ======================================================
// PROFESSIONAL DASHBOARD
// ======================================================

// Welcome banner
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Colors.blue,
            Colors.indigo,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.waving_hand,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome, $dashboardName!',
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover your strengths and find a career '
            'that matches your interests and skills.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    ),
  ),
),

// Dashboard statistics
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Your Dashboard',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDashboardStat(
                icon: Icons.work_outline,
                title: 'Careers',
                value: careers.length.toString(),
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDashboardStat(
                icon: Icons.bookmark_outline,
                title: 'Saved',
                value: savedCareerCount.toString(),
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildDashboardStat(
                icon: Icons.psychology_outlined,
                title: 'Skills',
                value: dashboardSkills.length.toString(),
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    ),
  ),
),

// Recommended careers
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recommended For You',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Explore careers based on your profile skills.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),

        ...recommendedCareers.map(
          (career) => Card(
            margin: const EdgeInsets.only(bottom: 10),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: CircleAvatar(
                backgroundColor: career.color.withValues(
                  alpha: 0.15,
                ),
                child: Icon(
                  career.icon,
                  color: career.color,
                ),
              ),
              title: Text(
                career.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                career.skills.take(3).join(', '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CareerDetailsPage(
                      career: career,
                    ),
                  ),
                ).then((_) => loadDashboardData());
              },
            ),
          ),
        ),
      ],
    ),
  ),
),
// Career Aptitude Quiz button
SliverToBoxAdapter(
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.psychology,
              size: 38,
              color: Colors.indigo,
            ),
            const SizedBox(height: 10),
            const Text(
              'Discover Your Career Path',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Answer a few questions about your interests '
              'and discover careers worth exploring.',
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.quiz_outlined),
                label: const Text('Start Aptitude Quiz'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CareerAptitudeQuizPage(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ),
),
          // Search field
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                12,
              ),
              child: TextField(
                controller: searchController,
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search careers or skills...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            searchController.clear();

                            setState(() {
                              searchQuery = '';
                            });
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest
                      .withAlpha(100),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),

          // Category filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 48,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected =
                      selectedCategory == category;

                  return ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    selectedColor: Colors.blue,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context)
                              .colorScheme
                              .onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
          ),

          // Sort dropdown
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                0,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sort,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Sort by:',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedSort,
                      isExpanded: true,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                      items: sortOptions.map((option) {
                        return DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setState(() {
                          selectedSort = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Results count
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                12,
              ),
              child: Text(
                '${results.length} '
                '${results.length == 1 ? 'career' : 'careers'} found',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          // Career cards
          if (results.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    child: _CareerCard(
                      career: results[index],
                    ),
                  );
                },
                childCount: results.length,
              ),
            )
          else
            // No results message
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 60,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No careers found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Try another career name or select '
                      'a different filter.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: clearSearchAndFilters,
                      icon: const Icon(Icons.refresh),
                      label: const Text(
                        'Clear Search & Filters',
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }
}




class _CareerCard extends StatelessWidget {
  final Career career;

  const _CareerCard({
    required this.career,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shadowColor: career.color.withAlpha(70),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CareerDetailsPage(
                career: career,
              ),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: career.color,
                width: 6,
              ),
            ),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: career.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      career.icon,
                      size: 30,
                      color: career.color,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Text(
                      career.title,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: career.color,
                      ),
                    ),
                  ),

                  Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: career.color,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Text(
                career.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    size: 20,
                    color: career.color,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    career.salary,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: career.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CareerDetailsPage(
                          career: career,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: career.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'View Career Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
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
    final savedCareers = prefs.getStringList('savedCareers') ?? [];

    if (!mounted) return;

    setState(() {
      isSaved = savedCareers.contains(widget.career.title);
    });
  }

  Future<void> toggleSave() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCareers = prefs.getStringList('savedCareers') ?? [];

    if (isSaved) {
      savedCareers.remove(widget.career.title);
    } else {
      savedCareers.add(widget.career.title);
    }

    await prefs.setStringList('savedCareers', savedCareers);

    if (!mounted) return;

    setState(() {
      isSaved = !isSaved;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isSaved ? 'Career saved successfully' : 'Career removed from saved',
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

  @override
  Widget build(BuildContext context) {
    final career = widget.career;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          career.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: career.color,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: toggleSave,
            icon: Icon(
              isSaved ? Icons.star : Icons.star_border,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Career Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    career.color,
                    career.color.withAlpha(180),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: career.color.withAlpha(60),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      career.icon,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    career.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Explore this career opportunity',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withAlpha(220),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Career Overview
            _sectionTitle(
              'Career Overview',
              Icons.info_outline,
              career.color,
            ),
            const SizedBox(height: 10),
            _infoCard(
              child: Text(
                career.description,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 22),

            // Job Roles
            _sectionTitle(
              'Job Roles',
              Icons.work_outline,
              career.color,
            ),
            const SizedBox(height: 10),
            _infoCard(
              child: Column(
                children: career.jobRoles.map((role) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: career.color,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            role,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 22),

            // Required Skills
            _sectionTitle(
              'Required Skills',
              Icons.build_outlined,
              career.color,
            ),
            const SizedBox(height: 10),
            _infoCard(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: career.skills.map((skill) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: career.color.withAlpha(25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: career.color.withAlpha(80),
                      ),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(
                        color: career.color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 22),

            // Education
            _sectionTitle(
              'Education',
              Icons.school_outlined,
              career.color,
            ),
            const SizedBox(height: 10),
            _infoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.school,
                    color: career.color,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      career.education,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Salary
            _sectionTitle(
              'Salary Range',
              Icons.currency_rupee,
              career.color,
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: career.color.withAlpha(20),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: career.color.withAlpha(70),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: career.color,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.currency_rupee,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      career.salary,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: career.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Career Growth
            _sectionTitle(
              'Career Growth',
              Icons.trending_up,
              career.color,
            ),
            const SizedBox(height: 10),
            _infoCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: career.color,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      career.growth,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Video
            _sectionTitle(
              'Related Career Video',
              Icons.play_circle_outline,
              career.color,
            ),
            const SizedBox(height: 10),

            VideoCard(
              title: career.title,
              videoId: career.videoId,
            ),

            const SizedBox(height: 24),

            // Save Career
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: toggleSave,
                icon: Icon(
                  isSaved ? Icons.star : Icons.star_border,
                ),
                label: Text(
                  isSaved ? 'Saved Career' : 'Save Career',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: career.color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // LinkedIn Jobs
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: findJobs,
                icon: const Icon(Icons.work),
                label: const Text(
                  'Find Jobs on LinkedIn',
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: career.color,
                  side: BorderSide(
                    color: career.color,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 25,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _infoCard({
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
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
  List<String> savedCareerNames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSavedCareers();
  }

  Future<void> loadSavedCareers() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList('savedCareers') ?? [];

    if (!mounted) return;

    setState(() {
      savedCareerNames = saved;
      isLoading = false;
    });
  }

  Future<void> removeCareer(Career career) async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList('savedCareers') ?? [];

    saved.remove(career.title);

    await prefs.setStringList('savedCareers', saved);

    await loadSavedCareers();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${career.title} removed from saved careers',
        ),
      ),
    );
  }

  Career? getCareerByName(String name) {
    for (final career in careers) {
      if (career.title == name) {
        return career;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadSavedCareers,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  20,
                  16,
                  30,
                ),
                children: [
                  const Text(
                    'Saved Careers',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${savedCareerNames.length} career${savedCareerNames.length == 1 ? '' : 's'} saved',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 22),

                  if (savedCareerNames.isEmpty)
                    _emptyState(),

                  ...savedCareerNames.map((name) {
                    final career = getCareerByName(name);

                    if (career == null) {
                      return const SizedBox.shrink();
                    }

                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      child: _SavedCareerCard(
                        career: career,
                        onRemove: () {
                          removeCareer(career);
                        },
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CareerDetailsPage(
                                career: career,
                              ),
                            ),
                          );

                          loadSavedCareers();
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 45,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: Colors.amber.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_border,
              size: 48,
              color: Colors.amber,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No Saved Careers',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Save careers you are interested in and find them here later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedCareerCard extends StatelessWidget {
  final Career career;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _SavedCareerCard({
    required this.career,
    required this.onRemove,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: career.color.withAlpha(55),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: career.color,
                width: 6,
              ),
            ),
          ),
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: career.color.withAlpha(30),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      career.icon,
                      size: 30,
                      color: career.color,
                    ),
                  ),

                  const SizedBox(width: 13),

                  Expanded(
                    child: Text(
                      career.title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: career.color,
                      ),
                    ),
                  ),

                  IconButton(
                    onPressed: onRemove,
                    tooltip: 'Remove',
                    icon: Icon(
                      Icons.delete_outline,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Text(
                career.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.45,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Icon(
                    Icons.currency_rupee,
                    size: 19,
                    color: career.color,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    career.salary,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: career.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onTap,
                      icon: const Icon(
                        Icons.visibility_outlined,
                        size: 18,
                      ),
                      label: const Text(
                        'View Details',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: career.color,
                        side: BorderSide(
                          color: career.color,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(13),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: career.color,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
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
  String? profileImagePath;

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

    if (!mounted) return;

    setState(() {
      name =
          prefs.getString('profile_name') ??
          supabase.auth.currentUser?.userMetadata?['name'] ??
          'User';

      email = supabase.auth.currentUser?.email ?? '';

      skills = prefs.getStringList('skills') ?? [];

      profileImagePath =
          prefs.getString('profile_image');
    });
  }

  // ======================================================
  // CHANGE PROFILE IMAGE
  // ======================================================

  Future<void> changeProfileImage() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'profile_image',
      image.path,
    );

    if (!mounted) return;

    setState(() {
      profileImagePath = image.path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile photo updated successfully',
        ),
      ),
    );
  }

  // ======================================================
  // REMOVE PROFILE IMAGE
  // ======================================================

  Future<void> removeProfileImage() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('profile_image');

    if (!mounted) return;

    setState(() {
      profileImagePath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile photo removed',
        ),
      ),
    );
  }

  // ======================================================
  // SAVE SKILL
  // ======================================================

  Future<void> saveSkill() async {
    final skill = skillController.text.trim();

    if (skill.isEmpty) return;

    if (skills.contains(skill)) {
      skillController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This skill is already added',
          ),
        ),
      );

      return;
    }

    final prefs = await SharedPreferences.getInstance();

    setState(() {
      skills.add(skill);
      skillController.clear();
    });

    await prefs.setStringList(
      'skills',
      skills,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Skill added successfully',
        ),
      ),
    );
  }

  // ======================================================
  // REMOVE SKILL
  // ======================================================

  Future<void> removeSkill(String skill) async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      skills.remove(skill);
    });

    await prefs.setStringList(
      'skills',
      skills,
    );
  }

  // ======================================================
  // EDIT PROFILE
  // ======================================================

 

Future<void> editProfile() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => EditProfilePage(
        currentName: name,
        currentEmail: email,
        currentSkills: List<String>.from(skills),
        profileImagePath: profileImagePath,
      ),
    ),
  );

  if (result == null) return;

  final data = result as Map<String, dynamic>;

  final prefs = await SharedPreferences.getInstance();

  await prefs.setString(
    'profile_name',
    data['name'],
  );

  await prefs.setString(
    'profile_email',
    data['email'],
  );

  await prefs.setStringList(
    'profile_skills',
    List<String>.from(data['skills']),
  );

  if (data['profileImagePath'] != null) {
    await prefs.setString(
      'profile_image',
      data['profileImagePath'],
    );
  }

  if (!mounted) return;

  setState(() {
    name = data['name'];
    email = data['email'];
    skills = List<String>.from(data['skills']);

    if (data['profileImagePath'] != null) {
      profileImagePath = data['profileImagePath'];
    }
  });

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Profile updated successfully'),
    ),
  );
}




  // ======================================================
  // LOGOUT
  // ======================================================

  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  // ======================================================
  // PROFILE IMAGE WIDGET
  // ======================================================

  Widget profileImage() {
    final hasImage =
        profileImagePath != null &&
        profileImagePath!.isNotEmpty &&
        File(profileImagePath!).existsSync();

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(35),
        border: Border.all(
          color: Colors.white.withAlpha(120),
          width: 3,
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.file(
                File(profileImagePath!),
                fit: BoxFit.cover,
              )
            : const Icon(
                Icons.person,
                color: Colors.white,
                size: 58,
              ),
      ),
    );
  }

  // ======================================================
  // BUILD
  // ======================================================

  @override
  Widget build(BuildContext context) {
    final displayName =
        name.isEmpty ? 'User' : name;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          35,
        ),
        children: [
          // HEADER
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'My Profile',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Manage your career profile',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_outline,
                  color: Colors.blue,
                  size: 27,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // PROFILE CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.blue,
                  Colors.indigo,
                ],
              ),
              borderRadius:
                  BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withAlpha(45),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // PROFILE IMAGE
                GestureDetector(
                  onTap: changeProfileImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      profileImage(),

                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          size: 17,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  displayName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                if (email.isNotEmpty)
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          email,
                          textAlign: TextAlign.center,
                          overflow:
                              TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 10),

                TextButton(
                  onPressed: changeProfileImage,
                  child: const Text(
                    'Change Profile Photo',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (profileImagePath != null)
                  TextButton(
                    onPressed: removeProfileImage,
                    child: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ),

                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: editProfile,
                    icon: const Icon(
                      Icons.edit_outlined,
                    ),
                    label: const Text(
                      'Edit Profile',
                    ),
                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                      elevation: 0,
                      padding:
                          const EdgeInsets.symmetric(
                        vertical: 13,
                      ),
                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // SKILLS
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.psychology_outlined,
                  color: Colors.orange,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Skills',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Add skills to build your profile',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  borderRadius:
                      BorderRadius.circular(20),
                ),
                child: Text(
                  '${skills.length}',
                  style: const TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          // ADD SKILL
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius:
                  BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: skillController,
                    textCapitalization:
                        TextCapitalization.words,
                    onSubmitted: (_) => saveSkill(),
                    decoration:
                        const InputDecoration(
                      hintText:
                          'e.g. Python, Flutter, SQL',
                      prefixIcon: Icon(
                        Icons.add,
                        color: Colors.blue,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius:
                        BorderRadius.circular(13),
                  ),
                  child: IconButton(
                    onPressed: saveSkill,
                    icon: const Icon(
                      Icons.arrow_upward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          if (skills.isEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(
                vertical: 28,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius:
                    BorderRadius.circular(18),
                border: Border.all(
                  color: Colors.grey.shade200,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 42,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'No skills added yet',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return Container(
                  padding:
                      const EdgeInsets.only(
                    left: 13,
                    right: 5,
                    top: 5,
                    bottom: 5,
                  ),
                  decoration: BoxDecoration(
                    color:
                        Colors.blue.withAlpha(18),
                    borderRadius:
                        BorderRadius.circular(25),
                    border: Border.all(
                      color:
                          Colors.blue.withAlpha(45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 17,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        skill,
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          removeSkill(skill);
                        },
                        padding: EdgeInsets.zero,
                        constraints:
                            const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: const Icon(
                          Icons.close,
                          size: 17,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 28),

          // ACCOUNT
          const Text(
            'Account',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 5,
              ),
              leading: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.red.withAlpha(20),
                  borderRadius:
                      BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Colors.red,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'Sign out from your account',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey,
              ),
              onTap: logout,
            ),
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
  final Color color;
  final IconData icon;

  Career({
    required this.title,
    required this.description,
    required this.skills,
    required this.salary,
    required this.education,
    required this.jobRoles,
    required this.growth,
    required this.videoId,
    required this.color,
    required this.icon,
  });
}

class EditProfilePage extends StatefulWidget {
  final String currentName;
  final String currentEmail;
  final List<String> currentSkills;
  final String? profileImagePath;

  const EditProfilePage({
    super.key,
    required this.currentName,
    required this.currentEmail,
    required this.currentSkills,
    this.profileImagePath,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  late List<String> selectedSkills;

  String? selectedImagePath;

  final List<String> availableSkills = [
    'Flutter',
    'Dart',
    'Python',
    'Java',
    'C',
    'C++',
    'JavaScript',
    'HTML',
    'CSS',
    'SQL',
    'Machine Learning',
    'Data Science',
    'Cyber Security',
  ];

  @override
  void initState() {
    super.initState();

    nameController = TextEditingController(
      text: widget.currentName,
    );

    emailController = TextEditingController(
      text: widget.currentEmail,
    );

    selectedSkills = List<String>.from(
      widget.currentSkills,
    );

    selectedImagePath = widget.profileImagePath;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> changePhoto() async {
    final picker = ImagePicker();

    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image == null) return;

    if (!mounted) return;

    setState(() {
      selectedImagePath = image.path;
    });
  }

  void toggleSkill(String skill) {
    setState(() {
      if (selectedSkills.contains(skill)) {
        selectedSkills.remove(skill);
      } else {
        selectedSkills.add(skill);
      }
    });
  }

  void saveProfile() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
        ),
      );
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email'),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      {
        'name': name,
        'email': email,
        'skills': selectedSkills,
        'profileImagePath': selectedImagePath,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        selectedImagePath != null &&
        selectedImagePath!.isNotEmpty &&
        File(selectedImagePath!).existsSync();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: saveProfile,
            child: const Text(
              'SAVE',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          18,
          20,
          18,
          30,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ===============================
            // PROFILE PHOTO
            // ===============================

            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blue,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(20),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: hasImage
                              ? Image.file(
                                  File(selectedImagePath!),
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  color: Colors.blue.withAlpha(25),
                                  child: const Icon(
                                    Icons.person,
                                    size: 65,
                                    color: Colors.blue,
                                  ),
                                ),
                        ),
                      ),

                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          onPressed: changePhoto,
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextButton.icon(
                    onPressed: changePhoto,
                    icon: const Icon(
                      Icons.photo_camera_outlined,
                    ),
                    label: const Text(
                      'Change Profile Photo',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // ===============================
            // PERSONAL INFORMATION
            // ===============================

            const Text(
              'Personal Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Update your basic profile information',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            _buildTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your name',
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            _buildTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 30),

            // ===============================
            // SKILLS
            // ===============================

            const Text(
              'Your Skills',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Select the skills you currently have',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            Wrap(
              spacing: 9,
              runSpacing: 10,
              children: availableSkills.map((skill) {
                final isSelected =
                    selectedSkills.contains(skill);

                return GestureDetector(
                  onTap: () {
                    toggleSkill(skill);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(
                      milliseconds: 200,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : Colors.white,
                      borderRadius:
                          BorderRadius.circular(25),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors.grey.shade300,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    Colors.blue.withAlpha(30),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected
                              ? Icons.check
                              : Icons.add,
                          size: 17,
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade700,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          skill,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 35),

            // ===============================
            // SAVE BUTTON
            // ===============================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: saveProfile,
                icon: const Icon(
                  Icons.save_outlined,
                  color: Colors.white,
                ),
                label: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ===============================
            // CANCEL
            // ===============================

            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: Colors.blue,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(17),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
        ),
      ),
    );
  }
}

// ======================================================
// PROFESSIONAL HOME LOADING SCREEN
// ======================================================

class HomeLoadingPage extends StatefulWidget {
  const HomeLoadingPage({super.key});

  @override
  State<HomeLoadingPage> createState() => _HomeLoadingPageState();
}

class _HomeLoadingPageState extends State<HomeLoadingPage>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<double> scaleAnimation;
  late Animation<double> fadeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    )..repeat(reverse: true);

    scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.08,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    fadeAnimation = Tween<double>(
      begin: 0.55,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeInOut,
      ),
    );

    _openHome();
  }

  Future<void> _openHome() async {
    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeCareerContent(),
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // ===============================
            // APP ICON
            // ===============================

            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: scaleAnimation.value,
                  child: Opacity(
                    opacity: fadeAnimation.value,
                    child: Container(
                      width: 115,
                      height: 115,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF7C3AED),
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.blue.withAlpha(45),
                            blurRadius: 25,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 30),

            // ===============================
            // APP NAME
            // ===============================

            const Text(
              'Career App',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Find Your Career',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              'Build Your Future',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),

            const SizedBox(height: 40),

            // ===============================
            // LOADING INDICATOR
            // ===============================

            SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(
                  Color(0xFF2563EB),
                ),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'Preparing your career journey...',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AptitudeOption {
  final String label;
  final String careerArea;

  const _AptitudeOption(this.label, this.careerArea);
}

class _AptitudeQuestion {
  final String question;
  final List<_AptitudeOption> options;

  const _AptitudeQuestion(this.question, this.options);
}

class CareerAptitudeQuizPage extends StatefulWidget {
  const CareerAptitudeQuizPage({super.key});

  @override
  State<CareerAptitudeQuizPage> createState() =>
      _CareerAptitudeQuizPageState();
}

class _CareerAptitudeQuizPageState
    extends State<CareerAptitudeQuizPage> {
  final List<_AptitudeQuestion> questions = const [
    _AptitudeQuestion(
      'Which activity sounds most interesting to you?',
      [
        _AptitudeOption('Writing code to solve problems', 'Software Developer'),
        _AptitudeOption('Finding patterns in information', 'Data Scientist'),
        _AptitudeOption('Creating websites and interfaces', 'Web Developer'),
        _AptitudeOption('Protecting systems from threats', 'Cyber Security'),
        _AptitudeOption('Exploring intelligent computer systems', 'AI Engineer'),
      ],
    ),
    _AptitudeQuestion(
      'Which school or college task do you enjoy most?',
      [
        _AptitudeOption('Building a small program', 'Software Developer'),
        _AptitudeOption('Working with charts and numbers', 'Data Scientist'),
        _AptitudeOption('Designing a webpage', 'Web Developer'),
        _AptitudeOption('Investigating a security problem', 'Cyber Security'),
        _AptitudeOption('Experimenting with AI tools', 'AI Engineer'),
      ],
    ),
    _AptitudeQuestion(
      'What would you most like to create?',
      [
        _AptitudeOption('A useful mobile or desktop application', 'Software Developer'),
        _AptitudeOption('A report that reveals useful trends', 'Data Scientist'),
        _AptitudeOption('An attractive, easy-to-use website', 'Web Developer'),
        _AptitudeOption('A safer computer network', 'Cyber Security'),
        _AptitudeOption('A system that learns from examples', 'AI Engineer'),
      ],
    ),
    _AptitudeQuestion(
      'Which problem would you prefer to investigate?',
      [
        _AptitudeOption('Why a program is not working', 'Software Developer'),
        _AptitudeOption('Why a trend appears in a dataset', 'Data Scientist'),
        _AptitudeOption('Why a website is difficult to use', 'Web Developer'),
        _AptitudeOption('How an account was compromised', 'Cyber Security'),
        _AptitudeOption('Why a model makes a prediction', 'AI Engineer'),
      ],
    ),
    _AptitudeQuestion(
      'Which tool would you most like to learn?',
      [
        _AptitudeOption('Programming languages', 'Software Developer'),
        _AptitudeOption('Data analysis tools', 'Data Scientist'),
        _AptitudeOption('HTML, CSS and web frameworks', 'Web Developer'),
        _AptitudeOption('Security testing tools', 'Cyber Security'),
        _AptitudeOption('Machine learning frameworks', 'AI Engineer'),
      ],
    ),
    _AptitudeQuestion(
      'What kind of work environment appeals to you?',
      [
        _AptitudeOption('Developing and improving applications', 'Software Developer'),
        _AptitudeOption('Researching and interpreting data', 'Data Scientist'),
        _AptitudeOption('Building interactive digital experiences', 'Web Developer'),
        _AptitudeOption('Monitoring and securing systems', 'Cyber Security'),
        _AptitudeOption('Testing intelligent solutions', 'AI Engineer'),
      ],
    ),
    _AptitudeQuestion(
      'Which achievement would make you proudest?',
      [
        _AptitudeOption('Making a complicated program work', 'Software Developer'),
        _AptitudeOption('Discovering an important pattern', 'Data Scientist'),
        _AptitudeOption('Publishing a great website', 'Web Developer'),
        _AptitudeOption('Finding and fixing a vulnerability', 'Cyber Security'),
        _AptitudeOption('Improving a model with experiments', 'AI Engineer'),
      ],
    ),
    _AptitudeQuestion(
      'Which topic would you explore first?',
      [
        _AptitudeOption('Algorithms and programming', 'Software Developer'),
        _AptitudeOption('Statistics and data', 'Data Scientist'),
        _AptitudeOption('Web design and development', 'Web Developer'),
        _AptitudeOption('Networks and digital security', 'Cyber Security'),
        _AptitudeOption('Artificial intelligence and learning', 'AI Engineer'),
      ],
    ),
  ];

  final List<int?> answers = List<int?>.filled(8, null);

  Map<String, int> get scores {
    final result = <String, int>{};

    for (int i = 0; i < questions.length; i++) {
      final selectedIndex = answers[i];

      if (selectedIndex != null) {
        final area =
            questions[i].options[selectedIndex].careerArea;

        result[area] = (result[area] ?? 0) + 1;
      }
    }

    return result;
  }
  Map<String, double> get careerMatchPercentages {
  final totalAnswers = answers.where((a) => a != null).length;

  if (totalAnswers == 0) {
    return {};
  }

  final result = <String, double>{};

  scores.forEach((career, score) {
    result[career] = (score / totalAnswers) * 100;
  });

  return result;
}

  bool get allAnswered => answers.every((answer) => answer != null);

  bool showResults = false;
  double get quizPercentage {
  final answeredCount = answers.where((a) => a != null).length;
  return (answeredCount / answers.length) * 100;
}

  void calculateResults() {
    if (!allAnswered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please answer all questions first.'),
        ),
      );
      return;
    }

    setState(() {
      showResults = true;
    });
  }

  void restartQuiz() {
    setState(() {
      for (int i = 0; i < answers.length; i++) {
        answers[i] = null;
      }
      showResults = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final sortedScores = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topAreas = showResults
        ? sortedScores.take(3).toList()
        : <MapEntry<String, int>>[];
    final bestCareerTitle =
    topAreas.isNotEmpty ? topAreas.first.key : '';

final bestCareer = careers.where(
  (career) => career.title == bestCareerTitle,
).firstOrNull;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Career Aptitude Quiz'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Padding(
  padding: const EdgeInsets.only(bottom: 16),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Quiz Progress: ${answers.where((a) => a != null).length}/8',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      LinearProgressIndicator(
        value: answers.where((a) => a != null).length / 8,
        minHeight: 8,
        borderRadius: BorderRadius.circular(10),
      ),
    ],
  ),
),
          if (!showResults) ...[
            const Text(
              'Explore Your Interests',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose one answer for each question. '
              'There are no right or wrong preferences.',
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: answers.where((a) => a != null).length /
                  questions.length,
              minHeight: 6,
            ),
            const SizedBox(height: 20),

            ...List.generate(questions.length, (index) {
              final question = questions[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${index + 1}. ${question.question}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),

                     RadioGroup<int>(
  groupValue: answers[index],
  onChanged: (value) {
    setState(() {
      answers[index] = value;
    });
  },
  child: Column(
    children: List.generate(
      question.options.length,
      (optionIndex) {
        final option = question.options[optionIndex];

        return RadioListTile<int>(
          title: Text(option.label),
          value: optionIndex,
        );
      },
    ),
  ),
),
                    ],
                  ),
                ),
              );
            }),

            ElevatedButton.icon(
              onPressed: allAnswered ? calculateResults : null,
              icon: const Icon(Icons.insights),
              label: const Text('See My Career Results'),
            ),
          ] else ...[
            const Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Colors.amber,
            ),
            const SizedBox(height: 12),
            const Text(
              'Your Career Interest Results',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

Text(
  '${quizPercentage.toStringAsFixed(0)}%',
  style: const TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.indigo,
  ),
),

const Text(
  'Quiz Completion',
  style: TextStyle(
    fontSize: 15,
    color: Colors.grey,
  ),
),

const SizedBox(height: 20),
            const SizedBox(height: 8),
            const Text(
              'These results reflect your answers, not a fixed '
              'measure of your ability. Explore the options '
              'and choose what interests you most.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

if (bestCareer != null)
  Card(
    elevation: 4,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⭐ Your Top Career Match',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bestCareer.title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(bestCareer.description),
          const SizedBox(height: 12),
          const Text(
            'Skills to Develop',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(bestCareer.skills.join(', ')),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CareerDetailsPage(
                    career: bestCareer,
                  ),
                ),
              );
            },
            child: const Text('Explore This Career'),
          ),
        ],
      ),
    ),
  ),

const SizedBox(height: 16),

...topAreas.map((entry) {
              final career = careers.where(
                (item) => item.title == entry.key,
              ).firstOrNull;

              return Card(
  margin: const EdgeInsets.only(bottom: 12),
  child: ListTile(
    leading: const CircleAvatar(
      child: Icon(Icons.work_outline),
    ),
    title: Text(
      entry.key,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
      ),
    ),
    subtitle: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${careerMatchPercentages[entry.key]?.toStringAsFixed(0) ?? '0'}% Career Match',
            style: const TextStyle(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (careerMatchPercentages[entry.key] ?? 0) / 100,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 6),
          Text(
            '${entry.value} of ${questions.length} answers matched.',
          ),
        ],
      ),
    ),
    trailing: career == null
        ? null
        : const Icon(Icons.arrow_forward_ios, size: 16),
    onTap: career == null
        ? null
        : () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CareerDetailsPage(
                  career: career,
                ),
              ),
            );
          },
  ),
);
            }),

            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: restartQuiz,
              icon: const Icon(Icons.refresh),
              label: const Text('Retake Quiz'),
            ),
          ],
        ],
      ),
    );
  }
}



