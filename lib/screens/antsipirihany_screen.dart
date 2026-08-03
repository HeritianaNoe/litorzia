import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';

/// Pejy mampiseho ny tantara feno sy ny antsipirihan'ny Olomasina
/// iray voafidy avy amin'ny lisitra.
class AntsipirihanyScreen extends StatelessWidget {
  final Olomasina olomasina;

  const AntsipirihanyScreen({super.key, required this.olomasina});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            actions: [
              // Icon fanaovana Copy
              IconButton(
                icon: const Icon(Icons.copy_rounded),
                tooltip: 'Adikao',
                onPressed: () => _copyOlomasina(context),
              ),
              // Icon fanaovana Partage
              Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Partage',
                  onPressed: () => _partageOlomasina(context),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                olomasina.anarana,
                style: const TextStyle(
                  fontSize: 15,
                  shadows: [Shadow(color: Colors.black87, blurRadius: 6)],
                ),
              ),
              background: _buatraSaryLehibe(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: const Icon(Icons.category,
                            size: 16, color: Colors.white),
                        label: Text(olomasina.sokajy),
                        backgroundColor: Colors.deepPurple,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      Chip(
                        avatar: const Icon(Icons.calendar_today,
                            size: 16, color: Colors.white),
                        label: Text("Fankalazana: ${olomasina.datyFankalazana}"),
                        backgroundColor: Colors.orange[700],
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if ((olomasina.taonaNahaterahana?.isNotEmpty ?? false) ||
                      (olomasina.taonaNahafatesana?.isNotEmpty ?? false))
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.history_edu,
                              color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Teraka: ${olomasina.taonaNahaterahana?.isNotEmpty == true ? olomasina.taonaNahaterahana : '—'}"
                              "   |   Maty: ${olomasina.taonaNahafatesana?.isNotEmpty == true ? olomasina.taonaNahafatesana : '—'}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    olomasina.fanoharana,
                    style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const Divider(height: 30),
                  const Text(
                    "Tantara",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    olomasina.tantara,
                    style: const TextStyle(fontSize: 15.5, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sarin'ny lohan'ny pejy: ny icon Flutter mifandraika amin'ny sokajin'ny
  /// Olomasina no aseho eo amin'ny lamosina.
  Widget _buatraSaryLehibe() {
    final SokajyCategory? category = findSokajyCategory(olomasina.sokajy);

    return Container(
      color: Colors.deepPurple.shade100,
      child: Icon(
        category?.icon ?? Icons.church,
        size: 90,
        color: Colors.deepPurple,
      ),
    );
  }

  /// Mampiditra ny rakitra sy ny tantara amin'ny Clipboard (Copy)
  Future<void> _copyOlomasina(BuildContext context) async {
    final buffer = StringBuffer()
      ..writeln(olomasina.anarana)
      ..writeln(olomasina.fanoharana)
      ..writeln()
      ..writeln("Fankalazana: ${olomasina.datyFankalazana}")
      ..writeln("Sokajy: ${olomasina.sokajy}");

    if ((olomasina.taonaNahaterahana?.isNotEmpty ?? false) ||
        (olomasina.taonaNahafatesana?.isNotEmpty ?? false)) {
      buffer.writeln(
          "Teraka: ${olomasina.taonaNahaterahana ?? '—'} | Maty: ${olomasina.taonaNahafatesana ?? '—'}");
    }

    buffer.writeln();
    buffer.writeln("TANTARA:");
    buffer.writeln(olomasina.tantara);

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voaadikay tsara ny tantaran\'i ${olomasina.anarana} (Copied)! 📋'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Manokatra ny "share sheet" mba hizarana ny anaran'ny Olomasina,
  /// ny fanoharana ary ny daty fankalazana azy.
  Future<void> _partageOlomasina(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;

    final String hafatra = "${olomasina.anarana}\n"
        "${olomasina.fanoharana}\n\n"
        "Fankalazana: ${olomasina.datyFankalazana}\n"
        "Sokajy: ${olomasina.sokajy}\n\n"
        "Nozaraina avy amin'ny app Litorjika Katolika 🙏";

    await SharePlus.instance.share(
      ShareParams(
        text: hafatra,
        subject: olomasina.anarana,
        sharePositionOrigin:
            box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
      ),
    );
  }
}