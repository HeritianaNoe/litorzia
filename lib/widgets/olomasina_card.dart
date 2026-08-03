import 'dart:io';

import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';

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
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            // Voahitsy eto: CrossAxisAlignment (misy Axis)
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
                        const Icon(Icons.calendar_today, size: 12, color: Colors.deepPurple),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            olomasina.datyFankalazana,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.deepPurple,
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
      ),
    );
  }

  Widget _buatraSary() {
    const double taille = 60;

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
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        category?.icon ?? Icons.church,
        color: Colors.deepPurple,
        size: 28,
      ),
    );
  }
}