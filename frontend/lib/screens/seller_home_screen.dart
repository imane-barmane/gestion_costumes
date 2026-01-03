import 'package:flutter/material.dart';
import '../models/costume.dart';
import '../services/api_service.dart';
import 'user_type_selection_screen.dart';
import 'add_edit_costume_screen.dart';
import 'reservation_form_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  State<SellerHomeScreen> createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final _apiService = ApiService();
  List<Costume> _costumes = [];
  bool _isLoading = true;
  String? _errorMessage;

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
      final sellerId = await _apiService.getCurrentUserId();
      if (sellerId != null) {
        final costumes = await _apiService.getCostumesBySeller(sellerId);
        setState(() {
          _costumes = costumes;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Costumes'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _apiService.signOut();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const UserTypeSelectionScreen(),
                  ),
                );
              }
            },
            tooltip: 'Déconnexion',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
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
              : _costumes.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Aucun costume ajouté',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
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
                        itemCount: _costumes.length,
                        itemBuilder: (context, index) {
                          final costume = _costumes[index];
                          return _buildCostumeCard(costume);
                        },
                      ),
                    ),
          // Boutons flottants
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.extended(
                  onPressed: () async {
                    if (_costumes.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Veuillez d\'abord ajouter un costume'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }
                    // Afficher un dialogue pour sélectionner le costume à réserver
                    final selectedCostume = await _showCostumeSelectionDialog();
                    if (selectedCostume != null) {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReservationFormScreen(
                            costume: selectedCostume,
                          ),
                        ),
                      );
                      if (result == true) {
                        // Optionnel: recharger les costumes si nécessaire
                        _loadCostumes();
                      }
                    }
                  },
                  backgroundColor: Colors.orange,
                  icon: const Icon(Icons.bookmark),
                  label: const Text('Réserver'),
                  heroTag: 'reserver',
                ),
                const SizedBox(width: 16),
                FloatingActionButton.extended(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditCostumeScreen(),
                      ),
                    );
                    if (result == true) {
                      _loadCostumes();
                    }
                  },
                  backgroundColor: Colors.deepPurple,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter'),
                  heroTag: 'ajouter',
                ),
              ],
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
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl: costume.imageUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => const Icon(
                      Icons.error,
                      color: Colors.red,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddEditCostumeScreen(
                                costume: costume,
                              ),
                            ),
                          );
                          if (result == true) {
                            _loadCostumes();
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _showDeleteDialog(costume),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  decoration: BoxDecoration(
                    color: costume.isReserved ? Colors.red : Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    costume.isReserved ? 'Réservé' : 'Disponible',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Costume costume) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le costume'),
        content: Text('Êtes-vous sûr de vouloir supprimer "${costume.description}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _apiService.deleteCostume(costume.id!);

                if (mounted) {
                  // 🔥 SUPPRESSION DIRECTE DANS LA LISTE
                  setState(() {
                    _costumes.removeWhere((c) => c.id == costume.id);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Costume supprimé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erreur: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }


  Future<Costume?> _showCostumeSelectionDialog() async {
    if (_costumes.isEmpty) {
      return null;
    }

    return showDialog<Costume>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélectionner un costume'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _costumes.length,
            itemBuilder: (context, index) {
              final costume = _costumes[index];
              final formatter = NumberFormat.currency(locale: 'fr_FR', symbol: '€');
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(costume.imageUrl),
                  backgroundColor: Colors.grey.shade300,
                ),
                title: Text(costume.description),
                subtitle: Text(formatter.format(costume.price)),
                onTap: () => Navigator.pop(context, costume),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );
  }
}

