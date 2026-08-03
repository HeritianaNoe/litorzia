import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';
import '../services/olomasina_service.dart';
import 'sokajy_olomasina_screen.dart';

/// Pejy grid mampiseho ny sokajin'ny Olomasina rehetra (Masina, Apostoly,
/// Mpampianatra ny Fiangonana, sns.) miaraka amin'ny sary mifandraika aminy.
/// Mety tsara amin'ny ecran rehetra (Mobile, Tablet, Desktop).
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
          : LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;

                // Responsive Breakpoints ho an'ny Sokajy
                int crossAxisCount = 2; // Mobile tery
                if (width >= 1200) {
                  crossAxisCount = 6; // Desktop lehibe
                } else if (width >= 900) {
                  crossAxisCount = 5; // Desktop / Tablet lehibe
                } else if (width >= 600) {
                  crossAxisCount = 4; // Tablet
                } else if (width >= 400) {
                  crossAxisCount = 3; // Mobile midadasika
                }

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: GridView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: width > 600 ? 24 : 16,
                        vertical: 16,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: width > 600 ? 16 : 12,
                        mainAxisSpacing: width > 600 ? 16 : 12,
                        childAspectRatio: 0.85,
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
                                builder: (_) =>
                                    SokajyOlomasinaScreen(category: category),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      color: Colors.deepPurple.shade100,
                      alignment: Alignment.center,
                      child: Icon(
                        category.icon,
                        color: Colors.deepPurple,
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  category.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$isa Olomasina',
                style: TextStyle(fontSize: 11, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}