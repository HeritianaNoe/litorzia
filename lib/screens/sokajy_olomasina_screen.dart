import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';
import '../services/olomasina_service.dart';
import '../theme/app_colors.dart';
import '../widgets/olomasina_card.dart';
import 'antsipirihany_screen.dart';

/// Pejy mampiseho ny lisitry ny Olomasina mifanaraka amin'ny sokajy voafidy.
/// Mampifanaraka ny layout ho an'ny Mobile (ListView) ary Tablet/Desktop (GridView).
///
/// StatelessWidget: efa ao RAM ny lisitra ([OlomasinaService.olomasinaAmin]), ka
/// miseho avy hatrany ny votoatin'ny pejy (tsy misy spinner/fanavaozana hita).
class SokajyOlomasinaScreen extends StatelessWidget {
  final SokajyCategory category;

  const SokajyOlomasinaScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final List<Olomasina> lisitra = OlomasinaService.instance.olomasinaAmin(
      category,
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.olomasinaPrimary,
        foregroundColor: AppColors.olomasinaOnPrimary,
        title: Text(category.label),
        centerTitle: true,
      ),
      body: lisitra.isEmpty
          ? const Center(
              child: Text('Tsy misy Olomasina hita amin\'ity sokajy ity.'),
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: _buildAdaptiveLayout(
                      context,
                      lisitra,
                      constraints.maxWidth,
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAdaptiveLayout(
    BuildContext context,
    List<Olomasina> lisitra,
    double sakany,
  ) {
    // Lisitra tsotra + Divider (tsy misy Card)
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 4),
      itemCount: lisitra.length,
      separatorBuilder: (_, __) => const Divider(
        height: 1,
        thickness: 1,
        indent: 84,
      ),
      itemBuilder: (context, index) => _karatra(context, lisitra[index]),
    );
  }

  Widget _karatra(BuildContext context, Olomasina olomasina) {
    return OlomasinaCard(
      olomasina: olomasina,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AntsipirihanyScreen(olomasina: olomasina),
          ),
        );
      },
    );
  }
}
