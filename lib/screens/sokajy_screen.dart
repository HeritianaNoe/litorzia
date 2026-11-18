import 'package:flutter/material.dart';

import '../models/sokajy_category.dart';
import '../services/olomasina_service.dart';
import '../theme/app_colors.dart';
import 'sokajy_olomasina_screen.dart';

/// Pejy grid mampiseho ny sokajin'ny Olomasina rehetra (Masina, Apostoly,
/// Mpampianatra ny Fiangonana, sns.) miaraka amin'ny sary mifandraika aminy.
/// Mety tsara amin'ny ecran rehetra (Mobile, Tablet, Desktop).
///
/// StatelessWidget: ny isan'ny Olomasina isaky ny sokajy dia efa kajy ao amin'ny
/// [OlomasinaService] (RAM), ka tsy misy spinner na fanavaozana rehefa sokafana ny pejy.
class SokajyScreen extends StatelessWidget {
  const SokajyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = OlomasinaService.instance;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.olomasinaPrimary,
        foregroundColor: AppColors.olomasinaOnPrimary,
        title: const Text('Sokajin\'ny Olomasina'),
        centerTitle: true,
      ),
      body: LayoutBuilder(
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
                  return _SokajyTile(
                    category: category,
                    isa: service.isaAmin(category),
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
      color: AppColors.olomasinaLight,
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
                      color: AppColors.olomasinaLight,
                      alignment: Alignment.center,
                      child: Icon(
                        category.icon,
                        color: AppColors.olomasinaPrimary,
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
                    color: AppColors.olomasinaPrimaryDark,
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
