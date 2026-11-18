import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/vavaka_category.dart';
import '../models/vavaka_model.dart';
import '../services/vavaka_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_about_dialog.dart';
import 'sokajy_vavaka_screen.dart';

class VavakaScreen extends StatefulWidget {
  const VavakaScreen({super.key});

  @override
  State<VavakaScreen> createState() => _VavakaScreenState();
}

class _VavakaScreenState extends State<VavakaScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Angona efa ao anaty RAM (jereo AppData.init): tsy misy "loading".
  final List<VavakaModel> _vavakaRehetra = VavakaService.instance.rehetra;
  late List<VavakaModel> _vavakaFiltered = _vavakaRehetra;

  void _filterVavaka() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _vavakaFiltered = _vavakaRehetra.where((vavaka) {
        return vavaka.titre.toLowerCase().contains(query) ||
            vavaka.teksta.toLowerCase().contains(query) ||
            vavaka.kategoria.toLowerCase().contains(query);
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
  SharePlus.instance.share(
    ShareParams(
      text: textToShare,
      subject: vavaka.titre,
    ),
  );
}

  void _showVavakaDetail(VavakaModel vavaka) {
    final cat = findVavakaCategory(vavaka.kategoria);
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
                      avatar: cat != null
                          ? Icon(cat.icon, size: 16)
                          : null,
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog() {
    showAppAboutDialog(
      context,
      accentColor: AppColors.vavakaPrimary,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.vavakaPrimary,
        foregroundColor: AppColors.vavakaOnPrimary,
        title: const Text("Vavakin'ny mpianakavy"),
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
          // Search + button Sokajy mitovy ligne
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Button Sokajy — icon fotsiny (mitovy amin'ny Olomasina)
                Material(
                  color: AppColors.vavakaPrimary,
                  borderRadius: BorderRadius.circular(30),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SokajyVavakaScreen(),
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
          const SizedBox(height: 4),
          Expanded(
            child: _vavakaFiltered.isEmpty
                ? const Center(child: Text("Tsy nisy vavaka hita."))
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _vavakaFiltered.length,
                    separatorBuilder: (_, __) => const Divider(
                      height: 1,
                      thickness: 1,
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      final item = _vavakaFiltered[index];
                      final cat = findVavakaCategory(item.kategoria);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: AppColors.vavakaPrimary,
                          child: Icon(
                            cat?.icon ?? Icons.auto_stories,
                            color: Colors.white,
                            size: 20,
                          ),
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
