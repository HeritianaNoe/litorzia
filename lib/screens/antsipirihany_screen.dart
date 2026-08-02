import 'dart:io';

import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';

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
                        avatar: const Icon(Icons.category, size: 16, color: Colors.white),
                        label: Text(olomasina.sokajy),
                        backgroundColor: Colors.deepPurple,
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                      Chip(
                        avatar: const Icon(Icons.calendar_today, size: 16, color: Colors.white),
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
                          const Icon(Icons.history_edu, color: Colors.deepPurple),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Nateraka: ${olomasina.taonaNahaterahana?.isNotEmpty == true ? olomasina.taonaNahaterahana : '—'}"
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

  Widget _buatraSaryLehibe() {
    if (olomasina.sary == null || olomasina.sary!.isEmpty) {
      return Container(
        color: Colors.deepPurple.shade100,
        child: const Icon(Icons.church, size: 90, color: Colors.deepPurple),
      );
    }

    final String sary = olomasina.sary!;

    if (sary.startsWith('http')) {
      return Image.network(
        sary,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.deepPurple.shade100),
      );
    }
    if (sary.startsWith('/')) {
      return Image.file(
        File(sary),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.deepPurple.shade100),
      );
    }
    return Image.asset(
      'assets/$sary',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: Colors.deepPurple.shade100,
        child: const Icon(Icons.church, size: 90, color: Colors.deepPurple),
      ),
    );
  }
}
