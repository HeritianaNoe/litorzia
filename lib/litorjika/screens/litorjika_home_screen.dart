import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/liturgical_data.dart';
import '../services/comments_service.dart';
import '../services/liturgical_readings_service.dart';

/// Pejy mampiseho ny Alimanaka Litorjika Katolika.
/// Ampiasaina eto ny fikajiana ny Taona Litorjika marina (Fiaviana -> Kristy Mpanjaka)
/// izay mandray taona 2 amin'ny alimanaka sivilizasiona.
class LitorjikaHomeScreen extends StatefulWidget {
  const LitorjikaHomeScreen({super.key});

  static String appVersion = '...';

  @override
  State<LitorjikaHomeScreen> createState() => _LitorjikaHomeScreenState();
}

class _LitorjikaHomeScreenState extends State<LitorjikaHomeScreen> {
  List<MergedLiturgicalDay> allDays = [];
  MergedLiturgicalDay? lastSunday; // Ny "alahady farany teo"
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAndMerge();
  }

// Azonao atao ao amin'ny initState na ao anatin'ny FutureBuilder
  Future<String> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();

    // packageInfo.version -> "1.6.9"
    // packageInfo.buildNumber -> "1"
    return packageInfo.version;
  }

  /// Mikajy ny daty nanombohan'ny Fiaviana (Alahady voalohany amin'ny Fiaviana)
  /// ho an'ny taona sivilizasiona iray (civilYear).
  /// Ny Krismasy dia 25 Desambra foana; ny Fiaviana dia 4 Alahady alohan'ny Krismasy.
  DateTime _getStartOfLiturgicalYear(int civilYear) {
    final christmas = DateTime(civilYear, 12, 25);
    // 21 andro (3 herinandro) + ny andro sisa hahatongavana amin'ny Alahady alohan'ny Krismasy
    final daysToSubtract = (christmas.weekday % 7) + 21;
    final startAdvent = christmas.subtract(Duration(days: daysToSubtract));
    return DateTime(startAdvent.year, startAdvent.month, startAdvent.day);
  }

  /// 1) Mamaky ny JSON. 2) Mikajy ny daty.
  /// 3) Manivana ny andro amin'ny Taona Litorjika ankehitriny (Fiaviana -> Kristy Mpanjaka).
  Future<void> _loadAndMerge() async {
    final version = await getAppVersion();
    if (mounted) {
      // Halavirana ny error raha efa niala amin'ilay pejy ny mpampiasa
      setState(() {
        LitorjikaHomeScreen.appVersion = version;
      });
    }
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final readings = await LiturgicalReadingsService.loadReadings();
      final today = DateTime.now();
      final todayOnly = DateTime(today.year, today.month, today.day);

      // Mikajy ny taon'ny litorjika roa mba hahazoana antoka fa feno ny angona
      final merged = LiturgicalReadingsService.buildCalendarSpanningYears(
        today.year - 1,
        today.year + 1,
        readings,
      );

      final last =
          LiturgicalReadingsService.findLastEventUpTo(merged, todayOnly);

      // --- FIKAJIANA NY TAONA LITORJIKA ANKEHITRINY ---
      // Jereo raha efa lasa ny Alahady 1st Fiaviana amin'ity taona ity
      final adventThisYear = _getStartOfLiturgicalYear(today.year);

      final DateTime currentLiturgicalStart;
      if (todayOnly.isBefore(adventThisYear)) {
        // Mbola ao anatin'ny taona litorjika natomboka tamin'ny taon-dasa isika
        currentLiturgicalStart = _getStartOfLiturgicalYear(today.year - 1);
      } else {
        // Efa niditra amin'ny taona litorjika vaovao natomboka tamin'ity taona ity isika
        currentLiturgicalStart = adventThisYear;
      }

      // Ny taona litorjika manaraka dia manomboka amin'ny Fiaviana taona aoriana
      final nextLiturgicalStart =
          _getStartOfLiturgicalYear(currentLiturgicalStart.year + 1);

      // Sivano ny andro rehetra hitantsika ao anatin'ity Taona Litorjika ity ihany
      final currentLiturgicalDays = merged.where((event) {
        final eventDate =
            DateTime(event.date.year, event.date.month, event.date.day);
        return (eventDate.isAfter(currentLiturgicalStart) ||
                eventDate.isAtSameMomentAs(currentLiturgicalStart)) &&
            eventDate.isBefore(nextLiturgicalStart);
      }).toList();

      setState(() {
        allDays = currentLiturgicalDays;
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

  /// Mampihaingo sy mandika ny kaody litorjika hahazoana anarana mazava amin'ny teny Malagasy
  String _formatLiturgicalCode(String code) {
    if (code.startsWith('ORDINARY_SUNDAY_')) {
      final number = code.replaceAll('ORDINARY_SUNDAY_', '');
      return 'Alahady faha-$number Tsotra mandavantaona';
    }
    if (code.startsWith('ADVENT_SUNDAY_')) {
      final number = code.replaceAll('ADVENT_SUNDAY_', '');
      return 'Alahady faha-$number amin\'ny Fiaviana';
    }
    if (code.startsWith('LENT_SUNDAY_')) {
      final number = code.replaceAll('LENT_SUNDAY_', '');
      return 'Alahady faha-$number amin\'ny Karemy';
    }
    if (code.startsWith('EASTER_SUNDAY_')) {
      final number = code.replaceAll('EASTER_SUNDAY_', '');
      return 'Alahady faha-$number amin\'ny Paka';
    }

    switch (code) {
      case 'EASTER':
        return 'Alahady ny Paka';
      case 'PALM_SUNDAY':
        return 'Alahady ny Sampankazo';
      case 'CHRIST_THE_KING':
        return 'Kristy Mpanjaka';
      case 'PENTECOST':
        return 'Pantekoty';
      case 'ASCENSION':
        return 'Ny Fiakaran\'ny Tompo';
      case 'TRINITY':
        return 'Trinite Masina';
      case 'CORPUS_CHRISTI':
        return 'Ny Vatana sy Ran\'ny Kristy';
      case 'HOLY_FAMILY':
        return 'Ny Fianakaviana Masina';
      case 'MARY_MOTHER_OF_GOD':
        return 'Maria Reny Masin\'Andriamanitra';
      case 'SACRED_HEART_OF_JESUS':
        return 'Ny Fo Masin\'i Jesoa';
      default:
        return code;
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
                            icon: const Icon(Icons.copy_rounded),
                            tooltip: 'Adikao',
                            onPressed: () => _copyLitorjika(event),
                          ),
                          Builder(
                            builder: (context) => IconButton(
                              icon: const Icon(Icons.share),
                              tooltip: 'Partage',
                              onPressed: () =>
                                  _partageLitorjika(context, event),
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
                      _buildDetailRow(
                        'Kaody (Code):',
                        _formatLiturgicalCode(event.code),
                      ),
                      if (event.readings != null) ...[ 
                        const SizedBox(height: 6),
                        _buildDetailRow(
                            'Taona (Cycle):', event.readings!.taona),
                        const SizedBox(height: 6),
                        _buildDetailRow(
                            'Lohahevitra:', event.readings!.lohahevitra),
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
                                  style: const TextStyle(
                                      fontSize: 14, height: 1.4),
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
                          label: const Text('Toriteny'),
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

  Future<void> _copyLitorjika(MergedLiturgicalDay event) async {
    final buffer = StringBuffer()
      ..writeln(event.title)
      ..writeln(
          '${event.date.day} ${_getMalagasyMonth(event.date.month)} ${event.date.year}');

    if (event.hasReadings) {
      buffer.writeln();
      buffer.writeln('Vaky teny:');
      for (final r in event.readings!.vakyTeny) {
        buffer.writeln('• ${r.karazany} — ${r.reference}');
        if (r.andininy.isNotEmpty) {
          buffer.writeln(r.andininy);
        }
      }
    }

    await Clipboard.setData(ClipboardData(text: buffer.toString()));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voadika tsara (Copied)! 📋'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

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
          title: Text('Toriteny momba ny "${event.title}"'),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 4,
            minLines: 3,
            decoration: const InputDecoration(
              hintText: 'Soraty eto ny toriteny...',
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
        const SnackBar(content: Text('Voatahiry ny Toriteny ✅')),
      );
    }
    return controller.text.trim();
  }

  Future<void> _partageLitorjika(
    BuildContext context,
    MergedLiturgicalDay event,
  ) async {
    final box = context.findRenderObject() as RenderBox?;

    final buffer = StringBuffer()
      ..writeln(event.title)
      ..writeln(
          '${event.date.day} ${_getMalagasyMonth(event.date.month)} ${event.date.year}');

    if (event.hasReadings) {
      buffer.writeln();
      buffer.writeln('Vaky teny:');
      for (final r in event.readings!.vakyTeny) {
        buffer.writeln('• ${r.karazany} — ${r.reference}');
      }
    }

    buffer.writeln();
    buffer.write("Nozaraina avy amin'ny app Alimanaka Katolika 🙏");

    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: event.title,
        sharePositionOrigin:
            box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
      ),
    );
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
        title: const Text('Litorjika Katolika'),
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
                          'Isan\'ny fisehoan-javatra: ${allDays.length}',
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
                                '${_getMalagasyMonth(event.date.month)} ${event.date.year}'
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

  Widget _buildLastSundayCard(MergedLiturgicalDay event) {
    // Makà ny taona litorjika (A, B, na C) raha misy
    final taonaLitorjika = event.readings?.taona;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      decoration: BoxDecoration(
        color: Colors.purple.shade600,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showEventDetails(event),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(16),
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

                // --- ROW HO AN'NY LOHATENY SY NY TAONA LITORJIKA ---
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // ---------------------------------------------------

                const SizedBox(height: 6),
                Text(
                  '${event.date.day} ${_getMalagasyMonth(event.date.month)} ${event.date.year} - Taona $taonaLitorjika',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                if (event.hasReadings)
                  Text(
                    '${event.readings!.lohahevitra}',
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
        ),
      ),
    );
  }

  void _showAboutDialog() {
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
                  errorBuilder: (_, __, ___) => const CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    radius: 24,
                    child: Icon(Icons.church, color: Colors.white),
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
                      'Version ${LitorjikaHomeScreen.appVersion}', // ✅ Works properly now
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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
                Text(
                  'Ity app ity dia mampiseho ny alimanaka Katolika '
                  '(Fiaviana, Krismasy, Karemy, Paka, Alahady tsotra, sns.) '
                  'miaraka amin\'ny vakiteny (Vakiteny voalohany, Salamo, Vakiteny '
                  'faharoa ary Evanjely) mifandraika amin\'ny alahady sy fety '
                  'tsirairay, araka ny taona litorjika A, B na C. '
                  'Mirakitra ihany koa ny tantaran\'ny Olomasina '
                  'ho fanampiana ny fiainam-panahin\'ny kristiana Katolika.',
                  style: const TextStyle(fontSize: 14, height: 1.4),
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

  String _getMalagasyMonth(int month) {
    const months = [
      '',
      'Janoary',
      'Febroary',
      'Marsa',
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
