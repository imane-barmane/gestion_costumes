import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/costume.dart';

class ApiService {
  // TODO: Remplacez par l'URL de votre API Laravel
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  
  // Récupérer le token d'authentification
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Sauvegarder le token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Supprimer le token
  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Récupérer l'ID de l'utilisateur connecté
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  // Sauvegarder l'ID de l'utilisateur
  Future<void> _saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', userId);
  }

  // Supprimer l'ID de l'utilisateur
  Future<void> _removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
  }

  // Headers avec authentification
  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  // Authentication
  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        await _saveUserId(data['user']['id'].toString());
        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur de connexion');
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: await _getHeaders(includeAuth: false),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _saveToken(data['token']);
        await _saveUserId(data['user']['id'].toString());
        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur d\'inscription');
      }
    } catch (e) {
      throw Exception('Erreur d\'inscription: $e');
    }
  }

  Future<void> signOut() async {
    try {
      final token = await _getToken();
      if (token != null) {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: await _getHeaders(),
        );
      }
    } catch (e) {
      // Ignorer les erreurs de déconnexion
    } finally {
      await _removeToken();
      await _removeUserId();
    }
  }

  // Upload d'image
  Future<String> uploadImage(File imageFile) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('Non authentifié');
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload-image'),
      );

      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath('image', imageFile.path),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'];
      } else {
        throw Exception('Erreur lors de l\'upload de l\'image');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // CRUD Costumes
  Future<void> addCostume(Costume costume) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/costumes'),
        headers: await _getHeaders(),
        body: jsonEncode(costume.toMap()),
      );

      if (response.statusCode != 201 && response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de l\'ajout du costume');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du costume: $e');
    }
  }

  Future<void> updateCostume(String costumeId, Costume costume) async {
    try {
      final costumeData = costume.toMap();
      costumeData['updatedAt'] = DateTime.now().toIso8601String();

      final response = await http.put(
        Uri.parse('$baseUrl/costumes/$costumeId'),
        headers: await _getHeaders(),
        body: jsonEncode(costumeData),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la mise à jour du costume');
      }
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du costume: $e');
    }
  }

  Future<void> deleteCostume(String costumeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/costumes/$costumeId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la suppression du costume');
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression du costume: $e');
    }
  }

  Future<List<Costume>> getCostumes() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/costumes'),
        headers: await _getHeaders(includeAuth: false),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> costumes = data['data'] ?? data;
        print("costumes $costumes");
        return costumes.map((json) => Costume.fromMap(json['id'].toString(), json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des costumes');
      }
    } catch (e) {
        print(e);
      throw Exception('Erreur lors de la récupération des costumes: $e');
    }
  }

  Future<List<Costume>> searchCostumes(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/costumes/search?q=$query'),
        headers: await _getHeaders(includeAuth: false),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> costumes = data['data'] ?? data;
        return costumes.map((json) => Costume.fromMap(json['id'].toString(), json)).toList();
      } else {
        // Si la recherche n'est pas disponible, récupérer tous les costumes et filtrer
        final allCostumes = await getCostumes();
        if (query.isEmpty) {
          return allCostumes;
        }
        final lowerQuery = query.toLowerCase();
        return allCostumes.where((costume) {
          return costume.description.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    } catch (e) {
      // En cas d'erreur, récupérer tous les costumes et filtrer côté client
      final allCostumes = await getCostumes();
      if (query.isEmpty) {
        return allCostumes;
      }
      final lowerQuery = query.toLowerCase();
      return allCostumes.where((costume) {
        return costume.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }
  }

  Future<List<Costume>> getCostumesBySeller(String sellerId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/costumes/seller/$sellerId'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> costumes = data['data'] ?? data;
        return costumes.map((json) => Costume.fromMap(json['id'].toString(), json)).toList();
      } else {
        throw Exception('Erreur lors de la récupération des costumes');
      }
    } catch (e) {
      throw Exception('Erreur lors de la récupération des costumes: $e');
    }
  }
  Future<bool> createReservation({
    required String costumeId,
    required String phone,
    required File? imageFile,
    required String borrowDate,
    required String returnDate,
  }) async {
    try {
      /*final response = await http.post(
        Uri.parse('$baseUrl/reservations'),
        headers: await _getHeaders(), // inclut token
        body: jsonEncode({
          'costume_id': costumeId,
          'client_phone': phone,
          'cin_url': idCardUrl,
          'start_date': borrowDate,
          'end_date': returnDate,
        }),
      );*/

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/reservations'),
      );
      final token = await _getToken();
// headers
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

// champs simples
      request.fields['costume_id']   = costumeId.toString();
      request.fields['client_phone'] = phone;
      request.fields['start_date']   = borrowDate;
      request.fields['end_date']     = returnDate;

// fichier CIN
      if(imageFile != null){
        request.files.add(
          await http.MultipartFile.fromPath(
            'cin_url',
            imageFile.path ?? "",
          ),
        );
      }else {
        return false;
      }


      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);


      if (response.statusCode == 201) {
        return true; // succès
      } else {
        print(response.body);
        return false;
      }
    } catch (e) {
      print("Erreur: $e");
      return false;
    }
  }
  Future<void> reserveCostume(String costumeId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/costumes/$costumeId/reserve'),
        headers: await _getHeaders(),
        body: jsonEncode({'is_reserved': true}),
      );

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Erreur lors de la réservation');
      }
    } catch (e) {
      throw Exception('Erreur lors de la réservation: $e');
    }
  }

}

