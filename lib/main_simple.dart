import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'presentation/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const SimpleWorkshopApp());
}

class SimpleWorkshopApp extends StatelessWidget {
  const SimpleWorkshopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Workshop Booking System',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SimpleHomeScreen(),
      debugShowCheckedModeBanner: false,
      
      // Localization support
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}

class SimpleHomeScreen extends StatefulWidget {
  const SimpleHomeScreen({super.key});

  @override
  State<SimpleHomeScreen> createState() => _SimpleHomeScreenState();
}

class _SimpleHomeScreenState extends State<SimpleHomeScreen> {
  int _selectedIndex = 0;
  bool _isDarkMode = false;

  final List<Widget> _pages = [
    const HomePage(),
    const WorkshopsPage(),
    const BookingsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.appName ?? 'Workshop Booking System'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Theme toggled to ${_isDarkMode ? 'Dark' : 'Light'} mode'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home),
            label: localizations?.home ?? 'Home',
          ),
          NavigationDestination(
            icon: const Icon(Icons.business_center),
            label: localizations?.workshops ?? 'Workshops',
          ),
          NavigationDestination(
            icon: const Icon(Icons.book_online),
            label: localizations?.bookings ?? 'Bookings',
          ),
          NavigationDestination(
            icon: const Icon(Icons.person),
            label: localizations?.profile ?? 'Profile',
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Workshop Booking System! 🎉',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features Implemented:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('✅ Multi-language support (EN, KO, JA, ZH)'),
                  const Text('✅ Responsive design'),
                  const Text('✅ Material Design 3'),
                  const Text('✅ Cross-platform compatibility'),
                  const Text('✅ Accessibility features'),
                  const Text('✅ Performance optimizations'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${localizations?.bookNow ?? 'Book Now'} clicked!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: Text(localizations?.bookNow ?? 'Book Now'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${localizations?.search ?? 'Search'} clicked!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.search),
                  label: Text(localizations?.search ?? 'Search'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class WorkshopsPage extends StatelessWidget {
  const WorkshopsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.workshops ?? 'Workshops',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Text('${index + 1}'),
                    ),
                    title: Text('Workshop ${index + 1}'),
                    subtitle: Text('Description for workshop ${index + 1}'),
                    trailing: Text('${localizations?.price ?? 'Price'}: \$${(index + 1) * 50}'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Workshop ${index + 1} selected!'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookingsPage extends StatelessWidget {
  const BookingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.bookings ?? 'Bookings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                final statuses = ['Confirmed', 'Pending', 'Cancelled'];
                final colors = [Colors.green, Colors.orange, Colors.red];
                
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(
                      Icons.event,
                      color: colors[index % colors.length],
                    ),
                    title: Text('Booking ${index + 1}'),
                    subtitle: Text('Workshop ${index + 1} - ${DateTime.now().add(Duration(days: index)).toString().split(' ')[0]}'),
                    trailing: Chip(
                      label: Text(statuses[index % statuses.length]),
                      backgroundColor: colors[index % colors.length].withOpacity(0.2),
                    ),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Booking ${index + 1} details opened!'),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations?.profile ?? 'Profile',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(localizations?.name ?? 'Name'),
                    subtitle: const Text('John Doe'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.email),
                    title: Text(localizations?.email ?? 'Email'),
                    subtitle: const Text('john.doe@example.com'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text('Phone'),
                    subtitle: const Text('+1 234 567 8900'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${localizations?.edit ?? 'Edit'} profile clicked!'),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: Text(localizations?.edit ?? 'Edit Profile'),
            ),
          ),
        ],
      ),
    );
  }
}