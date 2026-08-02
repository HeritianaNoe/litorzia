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
          : ListView.builder(
              itemCount: _lisitra.length,
              itemBuilder: (context, index) {
                final olomasina = _lisitra[index];
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
              },
            ),
    );
  }
}
