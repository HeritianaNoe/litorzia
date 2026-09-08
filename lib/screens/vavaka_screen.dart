import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

import '../theme/app_colors.dart';

class VavakaModel {
  final String id;
  final String titre;
  final String kategoria;
  final String teksta;

  VavakaModel({
    required this.id,
    required this.titre,
    required this.kategoria,
    required this.teksta,
  });

  factory VavakaModel.fromJson(Map<String, dynamic> json) {
    return VavakaModel(
      id: json['id']?.toString() ?? '',
      titre: json['titre'] ?? '',
      kategoria: json['kategoria'] ?? 'Tsy misy sokajy',
      teksta: json['teksta'] ?? '',
    );
  }
}

class VavakaScreen extends StatefulWidget {
  const VavakaScreen({super.key});

  @override
  State<VavakaScreen> createState() => _VavakaScreenState();
}

class _VavakaScreenState extends State<VavakaScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<VavakaModel> _vavakaRehetra = [];
  List<VavakaModel> _vavakaFiltered = [];
  List<String> _kategoriaList = ["Rehetra"];
  String _selectedKategoria = "Rehetra";

  bool _isLoading = true;
  String? _error;
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    _loadVavakaFromJsonAsset();
    _getAppVersion();
  }

  Future<void> _getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = packageInfo.version;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadVavakaFromJsonAsset() async {
    try {
      final String response =
          await rootBundle.loadString('assets/json/vavaka.json');
      final dynamic decodedData = json.decode(response);

      List<dynamic> dataList = [];

      if (decodedData is Map<String, dynamic> &&
          decodedData.containsKey('vavaka_katolika')) {
        dataList = decodedData['vavaka_katolika'] as List<dynamic>;
      } else if (decodedData is List<dynamic>) {
        dataList = decodedData;
      }

      final list = dataList
          .map((e) => VavakaModel.fromJson(e as Map<String, dynamic>))
          .toList();

      final categories = <String>{"Rehetra"};
      for (var item in list) {
        if (item.kategoria.isNotEmpty) {
          categories.add(item.kategoria);
        }
      }

      setState(() {
        _vavakaRehetra = list;
        _vavakaFiltered = list;
        _kategoriaList = categories.toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Tsy voavaky ny assets/json/vavaka.json!\n\n$e";
        _isLoading = false;
      });
    }
  }

  void _filterVavaka() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _vavakaFiltered = _vavakaRehetra.where((vavaka) {
        final matchesQuery = vavaka.titre.toLowerCase().contains(query) ||
            vavaka.teksta.toLowerCase().contains(query);
        final matchesCategory = _selectedKategoria == "Rehetra" ||
            vavaka.kategoria == _selectedKategoria;
        return matchesQuery && matchesCategory;
      }).toList();
    });
  }

  void _copyVavaka(VavakaModel vavaka) {
    final textToCopy = "${vavaka.titre}\n\n${vavaka.teksta}";
    Clipboard.setData(ClipboardData(text: textToCopy)).then((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Voakapy ny vavaka!"),
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _shareVavaka(VavakaModel vavaka) {
    final textToShare = "${vavaka.titre}\n\n${vavaka.teksta}";
    Share.share(textToShare, subject: vavaka.titre);
  }

  void _showVavakaDetail(VavakaModel vavaka) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.65,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (_, controller) {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView(
                controller: controller,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    vavaka.titre,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.vavakaPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Chip(
                      label: Text(
                        vavaka.kategoria,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppColors.vavakaLight,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    vavaka.teksta,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _copyVavaka(vavaka),
                        icon: const Icon(Icons.copy, size: 18),
                        label: const Text("Adikao"),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _shareVavaka(vavaka),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.vavakaPrimary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text("Hizara"),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
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
                    backgroundColor: AppColors.vavakaPrimary,
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
                      'Version $_appVersion',
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
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.vavakaPrimary,
        foregroundColor: AppColors.vavakaOnPrimary,
        title: const Text("Vavaka"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Momba ny app',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _filterVavaka(),
              decoration: InputDecoration(
                hintText: "Karohy vavaka...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterVavaka();
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
          if (_kategoriaList.length > 1)
            SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _kategoriaList.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final kat = _kategoriaList[index];
                  final isSelected = kat == _selectedKategoria;
                  return ChoiceChip(
                    label: Text(kat),
                    selected: isSelected,
                    selectedColor: AppColors.vavakaPrimary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedKategoria = kat;
                        });
                        _filterVavaka();
                      }
                    },
                  );
                },
              ),
            ),
          const SizedBox(height: 12),
          Expanded(
            child: _vavakaFiltered.isEmpty
                ? const Center(child: Text("Tsy nisy vavaka hita."))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _vavakaFiltered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = _vavakaFiltered[index];
                      return Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppColors.vavakaPrimary,
                            child: Icon(Icons.auto_stories,
                                color: Colors.white, size: 20),
                          ),
                          title: Text(
                            item.titre,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            item.teksta,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => _showVavakaDetail(item),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}