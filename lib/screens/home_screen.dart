import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/olomasina_model.dart';
import '../services/olomasina_service.dart';
import '../theme/app_colors.dart';
import '../widgets/olomasina_androany_banner.dart';
import '../widgets/olomasina_card.dart';
import 'antsipirihany_screen.dart';
import 'sokajy_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String appVersion = '...';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OlomasinaJsonService _jsonService = OlomasinaJsonService.instance;
  final TextEditingController _searchController = TextEditingController();

  List<Olomasina> _lisitra = [];
  List<Olomasina> _olomasinaAndroany = [];
  bool _mbolaMiandry = true;
  String _tenyKarohina = "";
  String? _hadisoana;

  @override
  void initState() {
    super.initState();
    _alaoAngona();
  }

  Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  Future<void> _alaoAngona() async {
    final version = await getAppVersion();
    if (mounted) {
      setState(() {
        HomeScreen.appVersion = version;
      });
    }
    setState(() {
      _mbolaMiandry = true;
      _hadisoana = null;
    });
    try {
      final data = await _jsonService.getOlomasinaRehetra();
      final androany = await _jsonService.getOlomasinaAndroany();
      if (!mounted) return;
      setState(() {
        _lisitra = data;
        _olomasinaAndroany = androany;
        _mbolaMiandry = false;
      });
    } catch (e) {
      if (!mounted) return;
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
      if (!mounted) return;
      setState(() {
        _lisitra = data;
        _mbolaMiandry = false;
      });
    } catch (e) {
      if (!mounted) return;
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
        backgroundColor: AppColors.olomasinaPrimary,
        foregroundColor: AppColors.olomasinaOnPrimary,
        title: const Text("Olomasina"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Mombamomba ny app',
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
              if (_hadisoana == null &&
                  _tenyKarohina.isEmpty &&
                  _olomasinaAndroany.isNotEmpty)
                OlomasinaAndroanyBanner(
                  olomasinaAndroany: _olomasinaAndroany,
                  datyAnio: OlomasinaJsonService.formatoDaty(DateTime.now()),
                  onTap: _mankanyAntsipirihany,
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
                                  _jsonService.clearCache();
                                  await _alaoAngona();
                                },
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
        final double sakany = constraints.maxWidth;

        if (sakany < 600) {
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: _lisitra.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final olomasina = _lisitra[index];
              return OlomasinaCard(
                olomasina: olomasina,
                onTap: () => _mankanyAntsipirihany(olomasina),
              );
            },
          );
        }

        final int tsanganana = sakany >= 1200
            ? 4
            : sakany >= 900
                ? 3
                : 2;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: tsanganana,
            mainAxisExtent: 145,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _lisitra.length,
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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  'assets/images/ic_launcher.png',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const CircleAvatar(
                    backgroundColor: AppColors.olomasinaPrimary,
                    radius: 24,
                    child: Icon(Icons.church, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Alimanaka Katolika',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Version ${HomeScreen.appVersion}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ity app ity dia mampiseho ny alimanaka Katolika '
                  '(Fiaviana, Krismasy, Karemy, Paka, Alahady tsotra, sns.) '
                  'miaraka amin\'ny vakiteny '
                  'mifandraika amin\'ny alahady sy fety '
                  'tsirairay, araka ny taona litorjika A, B na C. '
                  'Mirakitra ihany koa ny tantaran\'ny Olomasina sy ireo vavaka katolika '
                  'ho fanampiana ny fiainam-panahin\'ny kristiana Katolika.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
                Text(
                  '© ${DateTime.now().year} RASOLOMANANA Heritiana Noe',
                  style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Akatona'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}