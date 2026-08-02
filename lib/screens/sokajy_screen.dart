import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';
import '../services/olomasina_service.dart';
import 'sokajy_olomasina_screen.dart';

/// Pejy grid mampiseho ny sokajin'ny Olomasina rehetra (Masina, Apostoly,
/// Mpampianatra ny Fiangonana, sns.) miaraka amin'ny sary mifandraika
/// aminy. Tsindrio ny tile iray hijerena ny lisitry ny Olomasina ao
/// anatin'io sokajy io.
class SokajyScreen extends StatefulWidget {
  const SokajyScreen({super.key});

  @override
  State<SokajyScreen> createState() => _SokajyScreenState();
}

class _SokajyScreenState extends State<SokajyScreen> {
  final OlomasinaJsonService _jsonService = OlomasinaJsonService.instance;

  Map<String, int> _isanIsaSokajy = {};
  bool _mbolaMiandry = true;

  @override
  void initState() {
    super.initState();
    _alaoIsanIsaSokajy();
  }

  Future<void> _alaoIsanIsaSokajy() async {
    try {
      final List<Olomasina> rehetra = await _jsonService.getOlomasinaRehetra();
      final Map<String, int> isa = {};
      for (final o in rehetra) {
        isa[o.sokajy] = (isa[o.sokajy] ?? 0) + 1;
      }
      setState(() {
        _isanIsaSokajy = isa;
        _mbolaMiandry = false;
      });
    } catch (_) {
      setState(() => _mbolaMiandry = false);
    }
  }

  int _isaAmin(SokajyCategory category) {
    int total = 0;
    for (final v in category.sokajyValues) {
      total += _isanIsaSokajy[v] ?? 0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sokajin\'ny Olomasina'),
        centerTitle: true,
      ),
      body: _mbolaMiandry
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.95,
              ),
              itemCount: sokajyCategories.length,
              itemBuilder: (context, index) {
                final category = sokajyCategories[index];
                final isa = _isaAmin(category);
                return _SokajyTile(
                  category: category,
                  isa: isa,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SokajyOlomasinaScreen(category: category),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _SokajyTile extends StatelessWidget {
  final SokajyCategory category;
  final int isa;
  final VoidCallback onTap;

  const _SokajyTile({
    required this.category,
    required this.isa,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.deepPurple.shade50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/${category.imagePath}',
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 64,
                    height: 64,
                    color: Colors.deepPurple.shade100,
                    child: const Icon(Icons.church, color: Colors.deepPurple),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                category.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$isa Olomasina',
                style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
