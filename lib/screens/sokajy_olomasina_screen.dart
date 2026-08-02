import 'package:flutter/material.dart';

import '../models/olomasina_model.dart';
import '../models/sokajy_category.dart';
import '../services/olomasina_service.dart';
import '../widgets/olomasina_card.dart';
import 'antsipirihany_screen.dart';

/// Mampiseho ny lisitry ny Olomasina rehetra mifanaraka amin'ny
/// sokajy (SokajyCategory) voafidy avy amin'ny SokajyScreen.
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
          ? const Center(child: Text('Tsy misy Olomasina hita amin\'ity sokajy ity.'))
          : _lisitraMultiscreen(),
    );
  }

  /// Mamerina lisitra (ListView) raha efitrano finday tery, na grid
  /// (GridView) misy tsanganana maromaro raha efitrano midadasika kokoa
  /// (tablet/desktop), mba hampitovy tsara ny fampiasana ny habaka.
  Widget _lisitraMultiscreen() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double sakany = constraints.maxWidth;

        // Finday tery: lisitra tsotra iray tsanganana.
        if (sakany < 600) {
          return ListView.builder(
            itemCount: _lisitra.length,
            itemBuilder: (context, index) => _karatra(_lisitra[index]),
          );
        }

        // Tablet/desktop: grid misy tsanganana maro arakaraka ny sakan'ny efitrano.
        final int tsanganana = sakany >= 1200
            ? 4
            : sakany >= 900
            ? 3
            : 2;

        return GridView.builder(
          padding: const EdgeInsets.symmetric(vertical: 6),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: tsanganana,
            mainAxisExtent: 108,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
          ),
          itemCount: _lisitra.length,
          itemBuilder: (context, index) => _karatra(_lisitra[index]),
        );
      },
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
