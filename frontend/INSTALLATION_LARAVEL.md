# Guide d'Installation de Laravel

Ce guide vous explique comment installer Laravel pour le backend de l'application.

## Prérequis

Avant d'installer Laravel, assurez-vous d'avoir :

1. **PHP >= 8.1** installé
2. **Composer** installé (gestionnaire de dépendances PHP)
3. **MySQL** ou **PostgreSQL** installé
4. **Git** (optionnel mais recommandé)

## Étape 1 : Vérifier PHP

Ouvrez un terminal et vérifiez la version de PHP :

```bash
php -v
```

Vous devez avoir PHP 8.1 ou supérieur. Si ce n'est pas le cas, téléchargez PHP depuis [php.net](https://www.php.net/downloads.php)

## Étape 2 : Installer Composer

Composer est le gestionnaire de dépendances pour PHP.

### Windows

1. Téléchargez Composer depuis [getcomposer.org](https://getcomposer.org/download/)
2. Exécutez l'installateur `Composer-Setup.exe`
3. Suivez les instructions d'installation
4. Vérifiez l'installation :

```bash
composer --version
```

### Mac/Linux

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
composer --version
```

## Étape 3 : Installer Laravel

### Option A : Créer un nouveau projet Laravel (Recommandé)

Si vous n'avez pas encore de projet Laravel, créez-en un nouveau :

```bash
composer create-project laravel/laravel backend_laravel
cd backend_laravel
```

### Option B : Utiliser les fichiers fournis

Si vous avez déjà les fichiers dans `backend_laravel/`, installez simplement les dépendances :

```bash
cd backend_laravel
composer install
```

## Étape 4 : Configuration de l'environnement

1. **Copier le fichier .env**

```bash
cp .env.example .env
```

2. **Générer la clé d'application**

```bash
php artisan key:generate
```

3. **Configurer la base de données dans `.env`**

Ouvrez le fichier `.env` et modifiez :

```env
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=costume_manager
DB_USERNAME=root
DB_PASSWORD=votre_mot_de_passe
```

## Étape 5 : Créer la base de données

### Avec MySQL

1. Ouvrez MySQL (phpMyAdmin, MySQL Workbench, ou ligne de commande)
2. Créez une nouvelle base de données :

```sql
CREATE DATABASE costume_manager;
```

### Avec la ligne de commande MySQL

```bash
mysql -u root -p
CREATE DATABASE costume_manager;
exit;
```

## Étape 6 : Exécuter les migrations

Les migrations créent les tables dans la base de données :

```bash
php artisan migrate
```

## Étape 7 : Configurer le stockage des images

Créez un lien symbolique pour le stockage :

```bash
php artisan storage:link
```

## Étape 8 : Installer Laravel Sanctum (Authentification)

Laravel Sanctum est nécessaire pour l'authentification par token :

```bash
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate
```

## Étape 9 : Démarrer le serveur

```bash
php artisan serve
```

Le serveur sera accessible sur : `http://localhost:8000`

## Vérification

Testez l'API en ouvrant dans votre navigateur :
- `http://localhost:8000/api/costumes` (devrait retourner `[]` ou une erreur CORS, c'est normal)

## Installation rapide (Résumé)

```bash
# 1. Installer Composer (si pas déjà installé)
# Télécharger depuis https://getcomposer.org/download/

# 2. Créer le projet Laravel
composer create-project laravel/laravel backend_laravel
cd backend_laravel

# 3. Configurer
cp .env.example .env
php artisan key:generate

# 4. Modifier .env avec vos paramètres de base de données

# 5. Créer la base de données (dans MySQL)
CREATE DATABASE costume_manager;

# 6. Installer les dépendances et migrer
composer install
php artisan migrate
php artisan storage:link

# 7. Installer Sanctum
php artisan vendor:publish --provider="Laravel\Sanctum\SanctumServiceProvider"
php artisan migrate

# 8. Démarrer le serveur
php artisan serve
```

## Dépannage

### Erreur "composer: command not found"
- Assurez-vous que Composer est installé et dans votre PATH
- Redémarrez le terminal après l'installation

### Erreur de connexion à la base de données
- Vérifiez que MySQL est démarré
- Vérifiez les identifiants dans `.env`
- Assurez-vous que la base de données existe

### Erreur "Class 'PDO' not found"
- Installez l'extension PDO pour PHP
- Sur Windows : décommentez `extension=pdo_mysql` dans `php.ini`

### Port 8000 déjà utilisé
```bash
php artisan serve --port=8001
```

## Prochaines étapes

Une fois Laravel installé et démarré :

1. Copiez les fichiers fournis dans `backend_laravel/` :
   - `routes/api.php`
   - `app/Http/Controllers/`
   - `app/Models/Costume.php`
   - `database/migrations/`

2. Configurez CORS dans `config/cors.php`

3. Testez l'API avec Postman ou votre application Flutter

## Ressources

- [Documentation Laravel](https://laravel.com/docs)
- [Documentation Composer](https://getcomposer.org/doc/)
- [Laravel Sanctum](https://laravel.com/docs/sanctum)

