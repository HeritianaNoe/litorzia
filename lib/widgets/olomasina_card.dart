import 'dart:io';

import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';
import '../theme/app_colors.dart';

/// Ligne lisitra Olomasina (tsy misy Card — tsipika/divider ihany).
class OlomasinaCard extends StatelessWidget {
  final Olomasina olomasina;
  final VoidCallback onTap;

  const OlomasinaCard({
    super.key,
    required this.olomasina,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buatraSary(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    olomasina.anarana,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    olomasina.fanoharana,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 12,
                        color: AppColors.olomasinaPrimaryDark,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          olomasina.datyFankalazana,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.olomasinaPrimaryDark,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buatraSary() {
    const double taille = 56;

    if (olomasina.sary == null || olomasina.sary!.isEmpty) {
      return _tandindonaSolo(taille);
    }

    final String sary = olomasina.sary!;

    if (sary.startsWith('http')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          sary,
          width: taille,
          height: taille,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _tandindonaSolo(taille),
        ),
      );
    }

    if (sary.startsWith('/')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(sary),
          width: taille,
          height: taille,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _tandindonaSolo(taille),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/$sary',
        width: taille,
        height: taille,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _tandindonaSolo(taille),
      ),
    );
  }

  Widget _tandindonaSolo(double taille) {
    final SokajyCategory? category = findSokajyCategory(olomasina.sokajy);

    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: AppColors.olomasinaLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        category?.icon ?? Icons.church,
        color: AppColors.olomasinaPrimary,
        size: 28,
      ),
    );
  }
}
