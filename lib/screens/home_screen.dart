import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../services/olomasina_service.dart';
import '../widgets/olomasina_card.dart';
import 'antsipirihany_screen.dart';
import 'sokajy_screen.dart';

/// Pejy voalohany: mampiseho ny lisitry ny Olomasina rehetra, misy
/// tsipika fikarohana ary lisitry ny mankalaza ny "Olomasina anio".
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Soloina OlomasinaJsonService ilay DatabaseHelper teo aloha
  final OlomasinaJsonService _jsonService = OlomasinaJsonService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Olomasina> _lisitra = [];
  bool _mbolaMiandry = true;
  String _tenyKarohina = "";
  String? _hadisoana;

  @override
  void initState() {
    super.initState();
    _alaoAngona();
  }

  Future<void> _alaoAngona() async {
    setState(() {
      _mbolaMiandry = true;
      _hadisoana = null;
    });
    try {
      final data = await _jsonService.getOlomasinaRehetra();
      setState(() {
        _lisitra = data;
        _mbolaMiandry = false;
      });
    } catch (e) {
      setState(() {
        _mbolaMiandry = false;
        _hadisoana = 'Tsy voavaky ny rakitra JSON!\n\n$e';
      });
    }
  }

  Future<void> _karohy(String teny) async {
    setState(() => _tenyKarohina = teny);
    if (teny.trim().isEmpty) {
      _alaoAngona();
      return;
    }
    setState(() {
      _mbolaMiandry = true;
      _hadisoana = null;
    });
    try {
      final data = await _jsonService.karohyOlomasina(teny.trim());
      setState(() {
        _lisitra = data;
        _mbolaMiandry = false;
      });
    } catch (e) {
      setState(() {
        _mbolaMiandry = false;
        _hadisoana = 'Tsy voavaky ny rakitra JSON!\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rakitry ny Olomasina"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Mombamomba ny app',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _karohy,
                    decoration: InputDecoration(
                      hintText: "Karohy anarana na sokajin'Olomasina...",
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _tenyKarohina.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _karohy("");
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: Colors.deepPurple,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SokajyScreen()),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(12),
                      child: Icon(Icons.grid_view_rounded, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _mbolaMiandry
                ? const Center(child: CircularProgressIndicator())
                : _hadisoana != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 42,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _hadisoana!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.red),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _alaoAngona,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Andramo indray'),
                          ),
                        ],
                      ),
                    ),
                  )
                : _lisitra.isEmpty
                ? const Center(child: Text("Tsy nisy hita."))
                : RefreshIndicator(
                    onRefresh: () async {
                      // Fafana ny cache rehefa "Pull-to-refresh" ny mpampiasa
                      _jsonService.clearCache();
                      await _alaoAngona();
                    },
                    child: ListView.builder(
                      itemCount: _lisitra.length,
                      itemBuilder: (context, index) {
                        final olomasina = _lisitra[index];
                        return OlomasinaCard(
                          olomasina: olomasina,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AntsipirihanyScreen(olomasina: olomasina),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  /// Mampiseho ny fanazavana momba ny app (AboutDialog)
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Litorjika Katolika',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/ic_launcher.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const CircleAvatar(
            backgroundColor: Colors.deepPurple,
            radius: 24,
            child: Icon(Icons.church, color: Colors.white),
          ),
        ),
      ),
      applicationLegalese: '© ${DateTime.now().year} Litorzia',
      children: const [
        SizedBox(height: 16),
        Text(
          'Ity app ity dia mirakitra ny tantaran\'ny Olomasina Katolika '
          'sy ny alimanaka litorjika (vakiteny isan\'alahady sy fety) '
          'ho fanampiana ny fiainam-panahin\'ny kristiana Katolika.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
