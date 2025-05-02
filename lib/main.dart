import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:poke_app/pokedex.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeAPI Schedule 1',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Schedule 1 PokéAPI'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _pokemonData = {};
  bool _isLoading = false;
  List<String> _pokemonRecommendations = [];
  String _currentSearchText = '';

  Future<void> _fetchPokemonData(String pokemonName) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final pokemonResponse = await http.get(
        Uri.parse('https://pokeapi.co/api/v2/pokemon/$pokemonName'),
      );

      if (pokemonResponse.statusCode == 200) {
        final pokemonData = jsonDecode(pokemonResponse.body);

        final speciesResponse = await http.get(
          Uri.parse(pokemonData['species']['url']),
        );
        final speciesData = jsonDecode(speciesResponse.body);
        String category = 'Desconocido';
        try {
          final englishGenus = speciesData['genera'].firstWhere(
            (g) => g['language']['name'] == 'en',
            orElse: () => null,
          );
          if (englishGenus != null) {
            category = englishGenus['genus'];
          }
        } catch (e) {
          // Fallback si hay algún error
          category = 'Desconocido';
        }

        final typeUrl = pokemonData['types'][0]['type']['url'];
        final typeResponse = await http.get(Uri.parse(typeUrl));
        final typeData = jsonDecode(typeResponse.body);

        final weaknesses =
            typeData['damage_relations']['double_damage_from']
                .map<String>((e) => e['name'] as String)
                .toList();

        setState(() {
          _pokemonData = {
            ...pokemonData,
            'category': category,
            'weaknesses': weaknesses,
          };
          _isLoading = false;
        });
      } else {
        setState(() {
          _pokemonData = {'error': 'Pokemon no encontrado'};
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _pokemonData = {'error': 'Error al obtener los datos'};
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPokemonRecommendations(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        _pokemonRecommendations = [];
      });
      return;
    }

    final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=10000'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List<String> allPokemonNames = List<String>.from(
        data['results'].map((pokemon) => pokemon['name']),
      );

      final List<String> recommendations = allPokemonNames
          .where((name) => name.startsWith(searchText.toLowerCase()))
          .toList();

      setState(() {
        _pokemonRecommendations = recommendations;
      });
    } else {
      setState(() {
        _pokemonRecommendations = ['Error al cargar recomendaciones'];
      });
    }
  }



  /*void _incrementCounter() {
    setState(() { 
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    var scaffold = Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            ListTile(
              title: const Text('Pokédex'),

              onTap:
                  () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Pokedex()),
                  ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        flexibleSpace: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.red,
                        Colors.red,
                        Colors.white,
                        Colors.white,
                      ],
                      stops: [0.0, 0.5, 0.5, 1.0],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.black, width: 2),
                    ),
                  ),
                ),
                Center(
                  child: Container(
                    width: constraints.maxHeight * 0.5,
                    height: constraints.maxHeight * 0.5,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                ),
                Positioned(
                  left: constraints.maxHeight * 0.7,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.yellow, width: 3),
                        borderRadius: BorderRadius.circular(8),
                        // Opcional: añadir un fondo si quieres que el borde destaque más
                        // ignore: deprecated_member_use
                        color: Colors.white.withOpacity(0.7),
                      ),
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          // Opcional: añadir sombra al texto para mayor legibilidad
                          shadows: [
                            Shadow(
                              blurRadius: 2.0,
                              color: Color.fromARGB(120, 0, 0, 0),
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: TextField(
                    onChanged: (text) {
                      _currentSearchText = text;
                      _fetchPokemonRecommendations(text);
                    },
                    controller: _controller,
                    style: const TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: 'Busca tu Pokémon...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/pokeball_icon.png', // Asegúrate de tener esta imagen en assets
                          width: 24,
                          height: 24,
                        ),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 14.0,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade100,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(
                          color: Colors.deepPurple.shade300,
                          width: 2,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.search,
                          color: Colors.deepPurple,
                        ),
                        onPressed: () {
                          _fetchPokemonData(_controller.text.toLowerCase());
                        },
                      ),
                    ),
                  ),
                ),
              ),
              if (_pokemonRecommendations.isNotEmpty)
              SizedBox(
                height: 100, 
                child: ListView.builder(
                  itemCount: _pokemonRecommendations.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _controller.text = _pokemonRecommendations[index];
                          _currentSearchText = _pokemonRecommendations[index];
                          _pokemonRecommendations = []; // Clear recommendations after selection
                        });
                        _fetchPokemonData(_controller.text.toLowerCase());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 5),
                        child: Text(
                          _pokemonRecommendations[index],
                          style: TextStyle(
                              fontSize: 16,
                              color: Colors.black,
                              fontWeight: FontWeight.w500
                              ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  _fetchPokemonData(_controller.text.toLowerCase());
                },
                child: const Text('Search Pokemon'),
              ),
              if (_isLoading)
                const CircularProgressIndicator()
              else
                _pokemonData.containsKey('error')
                    ? Text(
                      _pokemonData['error'],
                      style: const TextStyle(
                        color: Color.fromARGB(255, 102, 35, 30),
                      ),
                    )
                    : _pokemonData.isNotEmpty
                    ? Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Card(
                          elevation: 8,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: const BorderSide(color: Colors.black),
                          ),
                          margin: const EdgeInsets.all(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                               SizedBox(
                                  width: 270, 
                                  height: 160,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // sprite del suelo(grass)
                                      Positioned(
                                        left: -30,
                                        bottom: 0,
                                        child: Transform.scale(
                                          scaleY: 1.8,
                                          scaleX: 1.8, // Escala horizontal
                                          child: Image.asset(
                                            'assets/battle_grass.png',
                                            width: 300, 
                                            height: 110,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      // Sprite del Pokémon
                                      Positioned(
                                        bottom: 25,
                                        child: Image.network(
                                          _pokemonData['sprites']['front_default'],
                                          width: 190, 
                                          height: 130,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) =>
                                            const Text('Imagen no disponible'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                 const Divider(thickness: 2),
                                 Text('Generacion: ${() {
                                      switch (_pokemonData['id']) {
                                        case int id when id >= 1 && id <= 151:
                                          return 'Kanto';
                                        case int id when id >= 152 && id <= 251:
                                          return 'Johto';
                                        case int id when id >= 252 && id <= 386:
                                          return 'Hoenn';
                                        case int id when id >= 387 && id <= 493:
                                          return 'Sinnoh';
                                        case int id when id >= 494 && id <= 649:
                                          return 'Unova';
                                        case int id when id >= 650 && id <= 721:
                                          return 'Kalos';
                                        case int id when id >= 722 && id <= 809:
                                          return 'Alola';
                                        case int id when id >= 899 && id <= 905:
                                          return 'Galar';
                                        case int id when id >= 906 && id <= 1025:
                                          return 'Paldea';
                                        default:
                                          return 'Desconocida';
                                      }
                                    }()}'),

                                
                                Text('Generacion: ${_pokemonData['id']}'),
                                
                                Text('Nombre: ${_pokemonData['name']}'),
                                Text('Altura: ${_pokemonData['height']}'),
                                Text('Peso: ${_pokemonData['weight']}'),
                                const Text('estadisticas:'),
                                Column(
                                  children: List.generate(_pokemonData['stats'].length, (index) {
                                    return Text(
                                        '- ${_pokemonData['stats'][index]['stat']['name']}: ${_pokemonData['stats'][index]['base_stat']}');
                                      }),
                                ),
                                const SizedBox(height: 8),
                                const Divider(thickness: 2),
                                const Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Habilidades:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: List.generate(
                                    _pokemonData['abilities'].length,
                                    (index) {
                                      final abilityName =
                                          _pokemonData['abilities'][index]['ability']['name'];
                                      return Chip(
                                        label: Text(abilityName),
                                        backgroundColor:
                                            Colors.deepPurple.shade100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          side: const BorderSide(
                                            color: Color.fromARGB(
                                              255,
                                              73,
                                              58,
                                              183,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Divider(thickness: 2),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Categoría: ${_pokemonData['category']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tipo(s):',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        children:
                                            (_pokemonData['types'] as List).map(
                                              (type) {
                                                return Chip(
                                                  label: Text(
                                                    type['type']['name'],
                                                  ),
                                                  backgroundColor:
                                                      Colors.lightBlue.shade100,
                                                );
                                              },
                                            ).toList(),
                                      ),
                                      const SizedBox(height: 8),
                                      const Divider(thickness: 2),
                                      Text(
                                        'Debilidades:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Wrap(
                                        spacing: 8,
                                        children:
                                            (_pokemonData['weaknesses'] as List)
                                                .map((w) {
                                                  return Chip(
                                                    label: Text(w),
                                                    backgroundColor:
                                                        Colors.red.shade100,
                                                  );
                                                })
                                                .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    : const SizedBox(),
            ],
          ),
        ),
      ),
    );
    return scaffold;
  }
}
