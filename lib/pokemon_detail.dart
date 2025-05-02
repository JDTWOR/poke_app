import 'package:flutter/material.dart';

class PokemonDetails extends StatelessWidget {
  final Map<String, dynamic> pokemon;

  const PokemonDetails({super.key, required this.pokemon});

  String _capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  @override
  Widget build(BuildContext context) {
    final types = pokemon['types'];
    final abilities = pokemon['abilities'] ?? [];
    final stats = pokemon['stats'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text('${_capitalize(pokemon['name'])} N.º ${pokemon['id'].toString().padLeft(3, '0')}'),
        backgroundColor: Colors.green.shade700,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen
            Image.network(
              pokemon['sprite'],
              height: 180,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 24),

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
                      _infoTile('Habilidad', _capitalize(abilities[0]['ability']['name'])),
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
              children: types.map<Widget>((typeData) {
                final type = _capitalize(typeData['type']['name']);
                return Chip(label: Text(type));
              }).toList(),
            ),

            const SizedBox(height: 10),

            // Estadísticas base
            _sectionTitle('Puntos de Base'),
            ...stats.map((stat) {
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

            const SizedBox(height: 24),

            // Debilidades (puedes implementarlo después con más lógica)
            _sectionTitle('Debilidad'),
            Wrap(
              spacing: 10,
              children: const [
                Chip(label: Text('Fuego'), backgroundColor: Colors.redAccent),
                Chip(label: Text('Hielo'), backgroundColor: Colors.lightBlue),
                Chip(label: Text('Volador'), backgroundColor: Colors.blueGrey),
                Chip(label: Text('Psíquico'), backgroundColor: Colors.pinkAccent),
              ],
            ),
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
}
