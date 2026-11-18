import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../services/olomasina_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_about_dialog.dart';
import '../widgets/olomasina_androany_banner.dart';
import '../widgets/olomasina_card.dart';
import 'antsipirihany_screen.dart';
import 'sokajy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OlomasinaService _service = OlomasinaService.instance;
  final TextEditingController _searchController = TextEditingController();

  // Angona efa ao anaty RAM (jereo AppData.init): tsy misy "loading", ka
  // tsy misy spinner na fanavaozana hita rehefa miova pejy na mitaipa.
  late List<Olomasina> _lisitra = _service.rehetra;
  late List<Olomasina> _olomasinaAndroany = _service.androany();
  String _tenyKarohina = '';

  /// Fikarohana SYNCHRONE (RAM): tsy mamadika ny lisitra ho spinner isaky ny litera.
  void _karohy(String teny) {
    setState(() {
      _tenyKarohina = teny;
      _lisitra = _service.karohy(teny);
    });
  }

  /// Mamerina manisa ny "Olomasina androany" (oh: raha niova ny andro).
  Future<void> _havaozina() async {
    setState(() {
      _olomasinaAndroany = _service.androany();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.olomasinaPrimary,
        foregroundColor: AppColors.olomasinaOnPrimary,
        title: const Text("Rakitrin'ny Olomasina"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Momba ny app',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _karohy,
                        decoration: InputDecoration(
                          hintText: "Karohy anarana...",
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Material(
                      color: AppColors.olomasinaPrimary,
                      borderRadius: BorderRadius.circular(30),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SokajyScreen(),
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(
                            Icons.grid_view_rounded,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_tenyKarohina.isEmpty && _olomasinaAndroany.isNotEmpty)
                OlomasinaAndroanyBanner(
                  olomasinaAndroany: _olomasinaAndroany,
                  datyAnio: OlomasinaService.formatoDaty(DateTime.now()),
                  onTap: _mankanyAntsipirihany,
                ),
              Expanded(
                child: _lisitra.isEmpty
                    ? const Center(child: Text("Tsy nisy hita."))
                    : RefreshIndicator(
                        onRefresh: _havaozina,
                        child: _buildAdaptiveList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdaptiveList() {
    return LayoutBuilder(
      builder: (context, constraints) {
        //final double sakany = constraints.maxWidth;

        // Lisitra tsotra miaraka amin'ny tsipika (Divider) — tsy misy Card
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: _lisitra.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            thickness: 1,
            indent: 84,
          ),
          itemBuilder: (context, index) {
            final olomasina = _lisitra[index];
            return OlomasinaCard(
              olomasina: olomasina,
              onTap: () => _mankanyAntsipirihany(olomasina),
            );
          },
        );
      },
    );
  }

  void _mankanyAntsipirihany(Olomasina olomasina) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AntsipirihanyScreen(olomasina: olomasina),
      ),
    );
  }

  void _showAboutDialog() {
    showAppAboutDialog(
      context,
      accentColor: AppColors.olomasinaPrimary,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
