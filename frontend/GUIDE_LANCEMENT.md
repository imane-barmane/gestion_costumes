# Guide de Lancement du Projet

Ce guide vous explique comment lancer l'application complète (Backend Laravel + Frontend Flutter).

## 📋 Prérequis

Avant de commencer, assurez-vous d'avoir :

- ✅ PHP >= 8.1 installé
- ✅ Composer installé
- ✅ MySQL installé et démarré
- ✅ Flutter SDK installé
- ✅ Un éditeur de code (VS Code, Android Studio, etc.)

## 🚀 Étape 1 : Lancer le Backend Laravel

### 1.1 Aller dans le dossier backend

```bash
cd backend_laravel
```

### 1.2 Installer les dépendances (si pas déjà fait)

```bash
composer install
```

### 1.3 Configurer l'environnement

```bash
# Copier le fichier .env.example
cp .env.example .env

# Générer la clé d'application
php artisan key:generate
```

### 1.4 Configurer la base de données

1. **Ouvrez le fichier `.env`** et modifiez :
```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=costume_manager
DB_USERNAME=root
DB_PASSWORD=votre_mot_de_passe
```

2. **Créez la base de données dans MySQL** :
```sql
CREATE DATABASE costume_manager;
```

Ou via phpMyAdmin : créez une nouvelle base de données nommée `costume_manager`

### 1.5 Exécuter les migrations

```bash
php artisan migrate
```

### 1.6 Créer le lien de stockage (pour les images)

```bash
php artisan storage:link
```

### 1.7 Installer Laravel Sanctum (authentification)

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

### 1.8 Démarrer le serveur Laravel

```bash
php artisan serve
```

✅ **Le serveur Laravel est maintenant accessible sur :** `http://localhost:8000`

**Gardez ce terminal ouvert !** Le serveur doit rester en cours d'exécution.

---

## 📱 Étape 2 : Lancer l'Application Flutter

### 2.1 Ouvrir un nouveau terminal

Ouvrez un **nouveau terminal** (gardez celui de Laravel ouvert).

### 2.2 Aller dans le dossier du projet Flutter

```bash
cd C:\Users\pc\Desktop\mobile_project
```

### 2.3 Installer les dépendances Flutter

```bash
flutter pub get
```

### 2.4 Configurer l'URL de l'API

Ouvrez le fichier `lib/services/api_service.dart` et vérifiez l'URL :

```dart
static const String baseUrl = 'http://localhost:8000/api';
```

**Important selon votre plateforme :**

- **Android (émulateur)** : `http://10.0.2.2:8000/api`
- **iOS (simulateur)** : `http://localhost:8000/api`
- **Appareil physique** : Utilisez l'IP de votre machine (ex: `http://192.168.1.100:8000/api`)

Pour trouver votre IP :
- Windows : `ipconfig` (cherchez "IPv4 Address")
- Mac/Linux : `ifconfig` ou `ip addr`

### 2.5 Lancer l'application Flutter

```bash
# Voir les appareils disponibles
flutter devices

# Lancer sur un appareil spécifique
flutter run

# Ou lancer sur un appareil spécifique
flutter run -d <device-id>
```

**Exemples :**
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Windows
flutter run -d windows
```

---

## ✅ Vérification

### Vérifier que le backend fonctionne

1. Ouvrez votre navigateur
2. Allez sur : `http://localhost:8000/api/costumes`
3. Vous devriez voir : `{"data":[]}` (liste vide, c'est normal)

### Vérifier que Flutter fonctionne

1. L'application devrait se lancer sur votre appareil/émulateur
2. Vous devriez voir l'écran de sélection "Client" ou "Vendeur"

---

## 🔧 Dépannage

### Erreur : "Connection refused" dans Flutter

**Problème :** Flutter ne peut pas se connecter à Laravel

**Solutions :**
1. Vérifiez que Laravel est bien démarré (`php artisan serve`)
2. Vérifiez l'URL dans `api_service.dart`
3. Pour Android émulateur, utilisez `10.0.2.2` au lieu de `localhost`
4. Pour appareil physique, utilisez l'IP de votre machine

### Erreur : "Database connection failed"

**Solution :**
1. Vérifiez que MySQL est démarré
2. Vérifiez les identifiants dans `.env`
3. Vérifiez que la base de données existe

### Erreur : "CORS policy"

**Solution :**
1. Videz le cache Laravel :
```bash
php artisan config:clear
php artisan cache:clear
```
2. Redémarrez le serveur Laravel

### Erreur : "Port 8000 already in use"

**Solution :**
```bash
# Utiliser un autre port
php artisan serve --port=8001
```

Puis modifiez l'URL dans `api_service.dart` :
```dart
static const String baseUrl = 'http://localhost:8001/api';
```

---

## 📝 Résumé des Commandes

### Terminal 1 - Backend Laravel
```bash
cd backend_laravel
composer install
cp .env.example .env
php artisan key:generate
# Modifier .env avec vos paramètres DB
php artisan migrate
php artisan storage:link
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
php artisan serve
```

### Terminal 2 - Frontend Flutter
```bash
cd C:\Users\pc\Desktop\mobile_project
flutter pub get
# Modifier api_service.dart si nécessaire
flutter run
```

---

## 🎯 Ordre de Lancement

1. ✅ **D'abord** : Lancer le backend Laravel (`php artisan serve`)
2. ✅ **Ensuite** : Lancer l'application Flutter (`flutter run`)

**Important :** Le backend doit être démarré avant Flutter !

---

## 🆘 Besoin d'aide ?

Si vous rencontrez des problèmes :

1. Vérifiez que tous les prérequis sont installés
2. Vérifiez les logs d'erreur dans les terminaux
3. Consultez les fichiers README :
   - `INSTALLATION_LARAVEL.md` pour le backend
   - `README.md` pour le projet général

Bon développement ! 🚀

