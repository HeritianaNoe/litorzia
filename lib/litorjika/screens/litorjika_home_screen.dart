import 'package:flutter/material.dart';

import '../models/liturgical_data.dart';
import '../services/comments_service.dart';
import '../services/liturgical_readings_service.dart';

/// Pejy mampiseho ny Alimanaka Litorjika Katolika (fisehoan-javatra litorjika
/// + vakiteny + commentaire manokana). Nafindra avy amin'ny app "Alimanaka
/// Litorjika Katolika" mba hampidirina ao anaty app iray miaraka amin'ny
/// "Rakitry ny Olomasina".
class LitorjikaHomeScreen extends StatefulWidget {
  const LitorjikaHomeScreen({super.key});

  @override
  State<LitorjikaHomeScreen> createState() => _LitorjikaHomeScreenState();
}

class _LitorjikaHomeScreenState extends State<LitorjikaHomeScreen> {
  List<MergedLiturgicalDay> allDays = [];
  MergedLiturgicalDay? lastSunday; // ny "alahady farany teo"
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAndMerge();
  }

  /// 1) Mamaky ny JSON. 2) Mikajy ny daty (LiturgicalCalendar).
  /// 3) Mampifandray ny roa tonta. 4) Mikaroka ny alahady farany teo.
  Future<void> _loadAndMerge() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final readings = await LiturgicalReadingsService.loadReadings();

      final today = DateTime.now();
      // Mikajy ny taon'ny litorjika roa (io taona io sy ny farany teo)
      // mba tsy hisy banga manodidina ny fiovan-taona.
      final merged = LiturgicalReadingsService.buildCalendarSpanningYears(
        today.year - 1,
        today.year + 1,
        readings,
      );

      final last = LiturgicalReadingsService.findLastEventUpTo(merged, today);

      setState(() {
        allDays = merged;
        lastSunday = last;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Tsy hita na nisy diso ny rakitra JSON!\nJereo tsara ny pubspec.yaml sy ny lalana (assets/json/litorjika.json)\n\n$e';
      });
    }
  }

  Future<void> _showEventDetails(MergedLiturgicalDay event) async {
    final String id = CommentsService.buildId(event.code, event.date);
    String? currentComment = await CommentsService.getComment(id);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.75,
              maxChildSize: 0.95,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.purple,
                            radius: 20,
                            child: Text(
                              '${event.date.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event.title,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${event.date.day} ${_getMalagasyMonth(event.date.month)} ${event.date.year}',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            tooltip: 'Hidina',
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      _buildDetailRow('Kaody (Code):', event.code),
                      if (event.readings != null) ...[
                        const SizedBox(height: 8),
                        _buildDetailRow('Taona (Cycle):', event.readings!.taona),
                      ],
                      const SizedBox(height: 16),
                      if (!event.hasReadings)
                        Text(
                          'Tsy misy vakiteny mifandraika amin\'ity daty ity ao amin\'ny JSON.',
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                            color: Colors.grey.shade600,
                          ),
                        )
                      else
                        ...event.readings!.vakyTeny.map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${r.karazany} — ${r.reference}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  r.andininy,
                                  style: const TextStyle(fontSize: 14, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      const Divider(height: 24),
                      if (currentComment != null && currentComment!.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hevitrao (commentaire):',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(currentComment!,
                                  style: const TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.mode_comment_outlined),
                          onPressed: () async {
                            final String? newComment =
                                await _openCommentDialog(event, currentComment);
                            if (newComment != null) {
                              setModalState(() {
                                currentComment = newComment;
                              });
                            }
                          },
                          label: const Text('Hatsahatra'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  /// Manokatra dialog fampidirana commentaire ho an'ny fisehoan-javatra iray,
  /// dia mitahiry azy (maharitra) rehefa "Tahiry" no tsindriana.
  /// Mamerina ny commentaire vao voatahiry (na banga raha nofafana), na null
  /// raha nofoanana ny dialog.
  Future<String?> _openCommentDialog(
    MergedLiturgicalDay event,
    String? existing,
  ) async {
    final String id = CommentsService.buildId(event.code, event.date);
    final controller = TextEditingController(text: existing ?? '');

    final bool? saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Hevitrao momba ny "${event.title}"'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Soraty eto ny commentaire...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Aoka'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Tahiry'),
            ),
          ],
        );
      },
    );

    if (saved != true) return null;

    await CommentsService.saveComment(id, controller.text);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voatahiry ny commentairenao ✅')),
      );
    }
    return controller.text.trim();
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text(
          '$label ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alimanaka Litorjika Katolika'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'Momba ny app',
            onPressed: _showAboutDialog,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : Column(
                  children: [
                    if (lastSunday != null) _buildLastSundayCard(lastSunday!),
                    Container(
                      padding: const EdgeInsets.all(12.0),
                      color: Colors.purple.shade50,
                      width: double.infinity,
                      child: Center(
                        child: Text(
                          'Isan\'ny fisehoan-javatra litorjika: ${allDays.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allDays.length,
                        itemBuilder: (context, index) {
                          final event = allDays[index];
                          final isLast = event == lastSunday;

                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            elevation: isLast ? 4 : 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: isLast
                                  ? const BorderSide(
                                      color: Colors.purple,
                                      width: 2,
                                    )
                                  : BorderSide.none,
                            ),
                            child: ListTile(
                              onTap: () => _showEventDetails(event),
                              leading: CircleAvatar(
                                backgroundColor: event.hasReadings
                                    ? Colors.purple
                                    : Colors.grey,
                                child: Text(
                                  '${event.date.day}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                event.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${_getMalagasyMonth(event.date.month)} ${event.date.year} • [${event.code}]'
                                '${event.hasReadings ? '' : ' • tsy misy vakiteny'}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  /// Kandra manokana eo an-tampony, maneho ny "Alahady farany teo"
  Widget _buildLastSundayCard(MergedLiturgicalDay event) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade600,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => _showEventDetails(event),
        borderRadius: BorderRadius.circular(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ALAHADY FARANY TEO',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              event.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${event.date.day} ${_getMalagasyMonth(event.date.month)} ${event.date.year}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            if (event.hasReadings)
              Text(
                'Vakiteny: ${event.readings!.vakyTeny.map((r) => r.karazany).join(' • ')}',
                style: const TextStyle(color: Colors.white, fontSize: 13),
              )
            else
              const Text(
                'Tsy misy vakiteny mifandraika ao amin\'ny JSON',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
            const SizedBox(height: 4),
            const Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Tsindrio hijerena ny antsipiriany  →',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mampiseho ny fanazavana momba ny app (AboutDialog)
  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Alimanaka Litorjika Katolika',
      applicationVersion: '1.0.0',
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/images/ic_launcher.png',
          width: 48,
          height: 48,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const CircleAvatar(
            backgroundColor: Colors.purple,
            radius: 24,
            child: Icon(Icons.church, color: Colors.white),
          ),
        ),
      ),
      applicationLegalese: '© ${DateTime.now().year} Litorzia',
      children: [
        const SizedBox(height: 16),
        const Text(
          'Ity app ity dia mampiseho ny alimanaka litorjika Katolika '
          '(Advento, Krismasy, Karemy, Paka, Fotoana mahazatra, sns.) '
          'miaraka amin\'ny vakiteny (Vakiteny voalohany, Salamo, Vakiteny '
          'faharoa ary Filazantsara) mifandraika amin\'ny alahady sy fety '
          'tsirairay, araka ny taona litorjika A, B na C.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 12),
        Text(
          'Isan\'ny fisehoan-javatra novokarina: ${allDays.length}',
          style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
        ),
      ],
    );
  }

  String _getMalagasyMonth(int month) {
    const months = [
      '',
      'Janoary',
      'Febroary',
      'Marsi',
      'Aprily',
      'Mey',
      'Jona',
      'Jolay',
      'Aogositra',
      'Septambra',
      'Oktobra',
      'Novambra',
      'Desambra'
    ];
    return months[month];
  }
}
