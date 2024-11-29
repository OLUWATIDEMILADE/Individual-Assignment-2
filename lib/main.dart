import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MovieApp(),
    );
  }
}

class MovieApp extends StatefulWidget {
  const MovieApp({super.key});

  @override
  _MovieAppState createState() => _MovieAppState();
}

class _MovieAppState extends State<MovieApp> {
  int _currentIndex = 0;

  final String _apiKey = "6b73431bd4f79d450354a0369ea9de69";
  final String _baseUrl = "https://api.themoviedb.org/3";

  Future<List<dynamic>> fetchMovies(String endpoint) async {
    final response =
        await http.get(Uri.parse("$_baseUrl/movie/$endpoint?api_key=$_apiKey"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception("Failed to load movies");
    }
  }

  Widget _buildMovieList(String category) {
    return FutureBuilder<List<dynamic>>(
      future: fetchMovies(category),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final movies = snapshot.data!;
        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) {
            final movie = movies[index];
            return ListTile(
              leading: movie['backdrop_path'] != null
                  ? Image.network(
                      "https://image.tmdb.org/t/p/w200/${movie['backdrop_path']}",
                      fit: BoxFit.cover,
                    )
                  : const SizedBox(
                      width: 50, height: 50, child: Icon(Icons.image)),
              title: Text(movie['title'] ?? 'No Title'),
              subtitle: Text("Release Date: ${movie['release_date'] ?? 'N/A'}"),
            );
          },
        );
      },
    );
  }

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const Center(
        child: Text(
          "Welcome to the Movie App!\nExplore Now Showing, Upcoming, and Popular Movies.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
      _buildMovieList('now_playing'),
      _buildMovieList('upcoming'),
      _buildMovieList('popular'),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Movie App"),
        centerTitle: true,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.movie), label: 'Now Showing'),
          BottomNavigationBarItem(
              icon: Icon(Icons.upcoming), label: 'Upcoming'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: 'Popular'),
        ],
      ),
    );
  }
}
