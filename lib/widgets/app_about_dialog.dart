import 'package:flutter/material.dart';

import '../core/app_info.dart';

/// Dialog « Momba ny app » iray ihany — tsy miverimberina amin'ny pejy tsirairay.
void showAppAboutDialog(BuildContext context, {Color? accentColor}) {
  final Color avatarColor = accentColor ?? Colors.deepPurple;

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
                errorBuilder: (_, __, ___) => CircleAvatar(
                  backgroundColor: avatarColor,
                  radius: 24,
                  child: const Icon(Icons.church, color: Colors.white),
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
                    'Version ${AppInfo.version}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
