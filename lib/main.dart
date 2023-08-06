import 'package:flutter/material.dart';

void main() => runApp(NewsApp());

class NewsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'News App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CategoriesScreen(),
    );
  }
}

class CategoriesScreen extends StatelessWidget {
  final List<String> categories = [
    'general',
    'business',
    'technology',
    'entertainment',
    'health',
    'science',
    'sports',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('News Categories'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: SearchScreen());
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(categories[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SourceScreen(category: categories[index])),
              );
            },
          );
        },
      ),
    );
  }
}

class SourceScreen extends StatefulWidget {
  final String category;

  SourceScreen({required this.category});

  @override
  _SourceScreenState createState() => _SourceScreenState();
}

class _SourceScreenState extends State<SourceScreen> {
  int currentPage = 1;
  List articles = [];
  bool isLoading = false;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    fetchSources(widget.category);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        fetchSources(widget.category);
      }
    });
  }

  Future<void> fetchSources(String category) async {
    setState(() {
      isLoading = true;
    });
  
    try {
      final response = await http.get(Uri.parse('https://newsapi.org/v2/top-headlines?country=id&category=$category&page=$currentPage&pageSize=10&apiKey=eadcfcc940ee4e7e8a66578de0ca32a7'));

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        List newArticles = jsonResponse['articles'] ?? [];

        setState(() {
          isLoading = false;
          articles.addAll(newArticles);
          currentPage++;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Failed to load articles');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Error"),
            content: Text("Failed to load articles: $e"),
            actions: [
              TextButton(
                child: Text("Close"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.category} News'),
      ),
      body: ListView.builder(
        controller: _scrollController,
        itemCount: articles.length + 1,
        itemBuilder: (context, index) {
          if (index == articles.length) {
            return isLoading
                ? CircularProgressIndicator()
                : TextButton(
                    onPressed: () {
                      fetchSources(widget.category);
                    },
                    child: Text('Load More'),
                  );
          } else {
            return ListTile(
              title: Text(articles[index]['title']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ArticleScreen(articles[index]['url'])),
                );
              },
            );
          }
        },
      ),
    );
  }
}

