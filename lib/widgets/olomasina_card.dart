import 'dart:io';

import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';

/// Karatra fintina mampiseho ny sarin'ny Olomasina, ny anarany
/// sy ny daty fankalazana azy. Raha tsindriana dia mankany amin'ny
/// pejy antsipirihany.
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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _buatraSary(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      olomasina.anarana,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      olomasina.fanoharana,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.deepPurple),
                        const SizedBox(width: 4),
                        Text(
                          olomasina.datyFankalazana,
                          style: const TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
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
      ),
    );
  }

  /// Mampiseho ny sarin'ny Olomasina; raha tsy misy sary na tsy hita
  /// ilay rakitra, dia mampiseho tandindona (icon) solon'izany.
  Widget _buatraSary() {
    const double taille = 64;

    if (olomasina.sary == null || olomasina.sary!.isEmpty) {
      return _tandindonaSolo(taille);
    }

    final String sary = olomasina.sary!;

    // URL avy amin'ny internet
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

    // Sary voarakitra ao anaty fitehirizana lokaly an'ny finday
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

    // Sary ao anaty assets/images/ (bundle miaraka amin'ny app)
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
    return Container(
      width: taille,
      height: taille,
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.church, color: Colors.deepPurple, size: 30),
    );
  }
}
