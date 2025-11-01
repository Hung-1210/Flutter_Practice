import 'package:flutter/material.dart';
import 'project1_profile.dart';
import 'project2_todo.dart';
import 'project3_news.dart';
import 'project4_chat.dart';
import 'project5_notes.dart';
import 'project6_weather.dart';
import 'project7_expense.dart';
import 'project8_gallery.dart';
import 'project9_reminder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Projects',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ProjectLauncher(),
    );
  }
}

class ProjectLauncher extends StatelessWidget {
  const ProjectLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Projects'),
        centerTitle: true,
      ),
      body: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              ProjectCard(
                title: '🧱 Project 1: Personal Profile',
                description: 'Learn basic layout and responsive UI',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PersonalProfileApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '📚 Project 2: Todo App',
                description: 'Manage tasks with local state',
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TodoApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '🧭 Project 3: News Reader',
                description: 'Work with REST APIs',
                color: Colors.orange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NewsReaderApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '💬 Project 4: Chat UI Clone',
                description: 'Create complex layouts with scrolling',
                color: Colors.teal,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatUIApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '🎨 Project 5: Note App',
                description: 'Manage app-wide state using Provider',
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NoteApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '🌦 Project 6: Weather App',
                description: 'Fetch and display live weather data',
                color: Colors.lightBlue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WeatherApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '💾 Project 7: Expense Tracker',
                description: 'Save and visualize local data',
                color: Colors.amber,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ExpenseTrackerApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '📸 Project 8: Photo Gallery',
                description: 'Integrate native device features',
                color: Colors.pink,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PhotoGalleryApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              ProjectCard(
                title: '🔔 Project 9: Reminder App',
                description: 'Work with local notifications',
                color: Colors.deepOrange,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReminderApp(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectCard extends StatelessWidget {
  final String title;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const ProjectCard({
    super.key,
    required this.title,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}