import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PokemonDetails extends StatefulWidget {
  final Map<String, dynamic> pokemon;

  const PokemonDetails({super.key, required this.pokemon});

  @override
  State<PokemonDetails> createState() => _PokemonDetailsState();
}

class _PokemonDetailsState extends State<PokemonDetails> {
  List<String> weaknesses = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchWeaknesses();
  }

  Future<void> fetchWeaknesses() async {
    Set<String> result = {};

    for (var type in widget.pokemon['types']) {
      final typeName = type['type']['name'];
      try {
        final response = await http.get(Uri.parse('https://pokeapi.co/api/v2/type/$typeName'));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List<dynamic> weakTypes = data['damage_relations']['double_damage_from'];
          for (var t in weakTypes) {
            result.add(t['name']);
          }
        } else {
          setState(() {
            errorMessage = 'Error al obtener debilidades de tipo $typeName';
          });
          return;
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error de conexión. Intenta nuevamente.';
        });
        return;
      }
    }

    setState(() {
      weaknesses = result.toList();
      isLoading = false;
    });
  }

  Color getColorForType(String type) {
    final Map<String, Color> typeColors = {
      'fire': Colors.redAccent,
      'water': Colors.blueAccent,
      'grass': Colors.green,
      'electric': Colors.yellow.shade700,
      'ice': Colors.lightBlue,
      'flying': Colors.blueGrey,
      'psychic': Colors.pinkAccent,
      'fighting': Colors.brown,
      'ground': Colors.orange,
      'poison': Colors.purple,
      'rock': Colors.grey,
      'ghost': Colors.indigo,
      'dragon': Colors.indigoAccent,
      'dark': Colors.black54,
      'steel': Colors.blueGrey.shade300,
      'fairy': Colors.pink.shade200,
      'bug': Colors.lightGreen,
      'normal': Colors.grey.shade400,
    };

    return typeColors[type.toLowerCase()] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final pokemon = widget.pokemon;

    return Scaffold(
      appBar: AppBar(
        title: Text('${pokemon['name']} N.º ${pokemon['id']}'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Imagen
            Image.network(
              pokemon['sprite'],
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),

            // Ficha técnica
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoTile('Altura', '${(pokemon['height'] / 10).toStringAsFixed(1)} m'),
                      _infoTile('Peso', '${(pokemon['weight'] / 10).toStringAsFixed(1)} kg'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _infoTile('Habilidad', _capitalize(pokemon['abilities'][0]['ability']['name'])),
                      _infoTile('Género', '♂ ♀'), // Puedes personalizarlo si tienes datos
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tipos
            _sectionTitle('Tipo'),
            Wrap(
              spacing: 10,
              children: pokemon['types'].map<Widget>((typeData) {
                final type = _capitalize(typeData['type']['name']);
                return Chip(label: Text(type));
              }).toList(),
            ),

            const SizedBox(height: 20),

            // Debilidades
            _sectionTitle('Debilidad'),
            isLoading
                ? const CircularProgressIndicator()
                : errorMessage.isNotEmpty
                    ? Text(errorMessage, style: TextStyle(color: Colors.red))
                    : weaknesses.isEmpty
                        ? const Text('No se encontraron debilidades.')
                        : Wrap(
                            spacing: 10,
                            children: weaknesses.map((type) {
                              return Chip(
                                label: Text(type[0].toUpperCase() + type.substring(1)),
                                backgroundColor: getColorForType(type),
                              );
                            }).toList(),
                          ),

            const SizedBox(height: 20),

            // Estadísticas base
            _sectionTitle('Puntos de Base'),
            ...pokemon['stats'].map((stat) {
              final name = _capitalize(stat['stat']['name']);
              final value = stat['base_stat'];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(width: 100, child: Text(name)),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: value / 200,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade300,
                        color: Colors.blueAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(value.toString()),
                  ],
                ),
              );
            }),

          ],
        ),
      ),
    );
  }

  Widget _infoTile(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
