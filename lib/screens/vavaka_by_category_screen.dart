import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/vavaka_category.dart';
import '../models/vavaka_model.dart';
import '../services/vavaka_service.dart';
import '../theme/app_colors.dart';

/// Pejy mampiseho ny lisitry ny vavaka mifanaraka amin'ny sokajy voafidy.
class VavakaByCategoryScreen extends StatelessWidget {
  final VavakaCategory category;

  const VavakaByCategoryScreen({super.key, required this.category});

  List<VavakaModel> get _lisitra => VavakaService.instance.rehetra
      .where((v) => v.kategoria == category.label)
      .toList();

  Future<void> _copyVavaka(BuildContext context, VavakaModel vavaka) async {
  final textToCopy = "${vavaka.titre}\n\n${vavaka.teksta}";
  await Clipboard.setData(ClipboardData(text: textToCopy));

  if (!context.mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Voakapy ny vavaka!"),
      duration: Duration(seconds: 2),
    ),
  );
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

  void _showVavakaDetail(BuildContext context, VavakaModel vavaka) {
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
                      avatar: Icon(category.icon, size: 16),
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
                        onPressed: () => _copyVavaka(context, vavaka),
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

  @override
  Widget build(BuildContext context) {
    final lisitra = _lisitra;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.vavakaPrimary,
        foregroundColor: AppColors.vavakaOnPrimary,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(category.icon, size: 22),
            const SizedBox(width: 8),
            Flexible(child: Text(category.label)),
          ],
        ),
        centerTitle: true,
      ),
      body: lisitra.isEmpty
          ? const Center(
              child: Text('Tsy misy vavaka hita amin\'ity sokajy ity.'),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: lisitra.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                thickness: 1,
                indent: 72,
              ),
              itemBuilder: (context, index) {
                final item = lisitra[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppColors.vavakaPrimary,
                    child: Icon(
                      category.icon,
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
                  onTap: () => _showVavakaDetail(context, item),
                );
              },
            ),
    );
  }
}
