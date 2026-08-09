import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';
import '../services/olomasina_service.dart';
import '../theme/app_colors.dart';
import '../widgets/olomasina_card.dart';
import 'antsipirihany_screen.dart';

/// Pejy mampiseho ny lisitry ny Olomasina mifanaraka amin'ny sokajy voafidy.
/// Mampifanaraka ny layout ho an'ny Mobile (ListView) ary Tablet/Desktop (GridView).
class SokajyOlomasinaScreen extends StatefulWidget {
  final SokajyCategory category;

  const SokajyOlomasinaScreen({super.key, required this.category});

  @override
  State<SokajyOlomasinaScreen> createState() => _SokajyOlomasinaScreenState();
}

class _SokajyOlomasinaScreenState extends State<SokajyOlomasinaScreen> {
  final OlomasinaJsonService _jsonService = OlomasinaJsonService.instance;

  List<Olomasina> _lisitra = [];
  bool _mbolaMiandry = true;
  String? _hadisoana;

  @override
  void initState() {
    super.initState();
    _alaoAngona();
  }

  Future<void> _alaoAngona() async {
    setState(() {
      _mbolaMiandry = true;
      _hadisoana = null;
    });
    try {
      final rehetra = await _jsonService.getOlomasinaRehetra();
      final voasivana = rehetra
          .where((o) => widget.category.sokajyValues.contains(o.sokajy))
          .toList();
      setState(() {
        _lisitra = voasivana;
        _mbolaMiandry = false;
      });
    } catch (e) {
      setState(() {
        _mbolaMiandry = false;
        _hadisoana = 'Tsy voavaky ny rakitra JSON!\n\n$e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.olomasinaPrimary,
        foregroundColor: AppColors.olomasinaOnPrimary,
        title: Text(widget.category.label),
        centerTitle: true,
      ),
      body: _mbolaMiandry
          ? const Center(child: CircularProgressIndicator())
          : _hadisoana != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      _hadisoana!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : _lisitra.isEmpty
                  ? const Center(
                      child: Text('Tsy misy Olomasina hita amin\'ity sokajy ity.'),
                    )
                  : _lisitraMultiscreen(),
    );
  }

  /// Mamerina ny layout mifanaraka amin'ny haben'ny ecran
  Widget _lisitraMultiscreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double sakany = constraints.maxWidth;

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: _buildAdaptiveLayout(sakany),
          ),
        );
      },
    );
  }

  Widget _buildAdaptiveLayout(double sakany) {
    // 1. MOBILE (< 600px): ListView.builder
    // Tsy asiana mainAxisExtent/haavo raikitra mba handray ny soratra lava rehetra (tsy hisy overflow).
    if (sakany < 600) {
      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: _lisitra.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: _karatra(_lisitra[index]),
        ),
      );
    }

    // 2. TABLET SY DESKTOP (>= 600px): GridView.builder
    final int tsanganana = sakany >= 1200
        ? 4 // Desktop lehibe
        : sakany >= 900
            ? 3 // Desktop / Tablet lehibe
            : 2; // Tablet midadasika

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: tsanganana,
        mainAxisExtent: 140, // Haavo ampy tsara ho an'ny Tablet/Desktop
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _lisitra.length,
      itemBuilder: (context, index) => _karatra(_lisitra[index]),
    );
  }

  Widget _karatra(Olomasina olomasina) {
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