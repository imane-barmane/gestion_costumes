import 'package:flutter/material.dart';
import '../models/costume.dart';
import '../services/api_service.dart';
import 'user_type_selection_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final _apiService = ApiService();
  List<Costume> _costumes = [];
  List<Costume> _filteredCostumes = [];
  bool _isLoading = true;
  String? _errorMessage;
  double _minPrice = 0.0;
  double _maxPrice = 1000.0;
  double _selectedMinPrice = 0.0;
  double _selectedMaxPrice = 1000.0;

  @override
  void initState() {
    super.initState();
    _loadCostumes();
  }

  Future<void> _loadCostumes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final costumes = await _apiService.getCostumes();
      setState(() {
        _costumes = costumes;
        // Calculer le prix min et max automatiquement
        if (costumes.isNotEmpty) {
          _minPrice = costumes.map((c) => c.price).reduce((a, b) => a < b ? a : b);
          _maxPrice = costumes.map((c) => c.price).reduce((a, b) => a > b ? a : b);
          _selectedMinPrice = _minPrice;
          _selectedMaxPrice = _maxPrice;
        }
        _filterCostumes();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterCostumes() {
    setState(() {
      _filteredCostumes = _costumes.where((costume) {
        return costume.price >= _selectedMinPrice && costume.price <= _selectedMaxPrice;
      }).toList();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Costumes Disponibles'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserTypeSelectionScreen(),
                ),
              );
            },
            tooltip: 'Retour',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtre de prix
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.filter_alt, color: Colors.deepPurple),
                    const SizedBox(width: 8),
                    const Text(
                      'Filtre de prix',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedMinPrice = _minPrice;
                          _selectedMaxPrice = _maxPrice;
                        });
                        _filterCostumes();
                      },
                      child: const Text('Réinitialiser'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Prix: ${_selectedMinPrice.toStringAsFixed(2)} € - ${_selectedMaxPrice.toStringAsFixed(2)} €',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                RangeSlider(
                  values: RangeValues(_selectedMinPrice, _selectedMaxPrice),
                  min: _minPrice,
                  max: _maxPrice > _minPrice ? _maxPrice : _minPrice + 1,
                  divisions: _maxPrice > _minPrice ? 100 : null,
                  labels: RangeLabels(
                    '${_selectedMinPrice.toStringAsFixed(2)} €',
                    '${_selectedMaxPrice.toStringAsFixed(2)} €',
                  ),
                  onChanged: (RangeValues values) {
                    setState(() {
                      _selectedMinPrice = values.start;
                      _selectedMaxPrice = values.end;
                    });
                    _filterCostumes();
                  },
                  activeColor: Colors.deepPurple,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Min: ${_minPrice.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      'Max: ${_maxPrice.toStringAsFixed(2)} €',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Erreur: $_errorMessage',
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _loadCostumes,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      )
                    : _filteredCostumes.isEmpty
                        ? const Center(
                            child: Text(
                              'Aucun costume disponible dans cette gamme de prix',
                              style: TextStyle(fontSize: 18),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadCostumes,
                            child: GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.75,
                              ),
                              itemCount: _filteredCostumes.length,
                              itemBuilder: (context, index) {
                                final costume = _filteredCostumes[index];
                                return _buildCostumeCard(costume);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostumeCard(Costume costume) {
    final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: CachedNetworkImage(
                imageUrl: costume.imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => const Center(
                  child: CircularProgressIndicator(),
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.error,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  costume.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  formatter.format(costume.price),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

