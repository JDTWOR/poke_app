import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
        final category =
            speciesData['genera'].firstWhere(
              (g) => g['language']['name'] == 'es',
              orElse: () => {'genus': 'Desconocido'},
            )['genus'];

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
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
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
                                Image.network(
                                  _pokemonData['sprites']['front_default'],
                                  width: 100,
                                  height: 100,
                                  errorBuilder:
                                      (context, error, stackTrace) =>
                                          const Text('Imagen no disponible'),
                                ),
                                const SizedBox(height: 12),
                                const Divider(thickness: 2),
                                Text('Nombre: ${_pokemonData['name']}'),
                                Text('Altura: ${_pokemonData['height']}'),
                                Text('Peso: ${_pokemonData['weight']}'),
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
  }
}
