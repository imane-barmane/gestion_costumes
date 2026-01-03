# Guide de Configuration Firebase

Ce guide vous aidera à configurer Firebase pour votre application de gestion de costumes.

## Étapes de Configuration

### 1. Créer un Projet Firebase

1. Allez sur [Firebase Console](https://console.firebase.google.com/)
2. Cliquez sur "Ajouter un projet"
3. Entrez un nom de projet (ex: "costume-manager")
4. Suivez les étapes pour créer le projet

### 2. Configurer Authentication

1. Dans votre projet Firebase, allez dans **Authentication**
2. Cliquez sur "Commencer"
3. Activez la méthode **Email/Password**
4. Cliquez sur "Enregistrer"

### 3. Configurer Firestore Database

**Important :** Si vous voyez une erreur concernant la facturation, suivez ces étapes :

1. **Vérifiez votre plan Firebase :**
   - En bas du menu de gauche, vous devriez voir "Spark" (plan gratuit)
   - Si vous voyez "Blaze" (plan payant), vous pouvez rester dessus (il y a un quota gratuit)

2. **Créer la base de données :**
   - Allez dans **Firestore Database**
   - Cliquez sur "Créer une base de données"
   - Choisissez le mode **Test** (pour le développement)
   - Sélectionnez une région (ex: europe-west)
   - Cliquez sur "Activer"

3. **Si l'erreur persiste (facturation requise) :**
   - Cliquez sur le lien fourni dans l'erreur pour activer la facturation
   - **Ne vous inquiétez pas** : Le plan Spark/Blaze offre un quota gratuit généreux
   - Vous ne serez pas facturé tant que vous restez dans les limites gratuites
   - Pour Firestore en mode test, vous avez 1 Go de stockage gratuit et 50K lectures/jour

#### Règles de Sécurité Firestore

Dans l'onglet "Règles", remplacez le contenu par :

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /costumes/{costumeId} {
      // Tout le monde peut lire les costumes
      allow read: if true;
      // Seuls les utilisateurs authentifiés peuvent écrire
      allow write: if request.auth != null;
    }
  }
}
```

Cliquez sur "Publier" pour sauvegarder les règles.

### 4. Configurer Storage

1. Allez dans **Storage**
2. Cliquez sur "Commencer"
3. Acceptez les règles par défaut
4. Choisissez une région (ex: europe-west)
5. Cliquez sur "Terminé"

#### Règles de Sécurité Storage

Dans l'onglet "Règles", remplacez le contenu par :

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /costumes/{allPaths=**} {
      // Tout le monde peut lire les images
      allow read: if true;
      // Seuls les utilisateurs authentifiés peuvent uploader
      allow write: if request.auth != null;
    }
  }
}
```

Cliquez sur "Publier" pour sauvegarder les règles.

### 5. Configuration Android

1. Dans Firebase Console, cliquez sur l'icône Android
2. Entrez le nom du package : `com.example.costume_manager`
3. Téléchargez le fichier `google-services.json`
4. Placez-le dans `android/app/google-services.json`

### 6. Configuration iOS (Optionnel)

Si vous développez pour iOS :

1. Dans Firebase Console, cliquez sur l'icône iOS
2. Entrez l'ID du bundle (ex: `com.example.costumeManager`)
3. Téléchargez le fichier `GoogleService-Info.plist`
4. Placez-le dans `ios/Runner/GoogleService-Info.plist`

### 7. Vérification

Après avoir configuré Firebase :

1. Exécutez `flutter pub get`
2. Vérifiez que `google-services.json` est bien dans `android/app/`
3. Lancez l'application avec `flutter run`

## Structure des Données Firestore

La collection `costumes` contiendra des documents avec la structure suivante :

```json
{
  "description": "Costume de super-héros",
  "price": 29.99,
  "imageUrl": "https://firebasestorage.googleapis.com/...",
  "sellerId": "user_id_here",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z"
}
```

## Notes Importantes

- ⚠️ Les règles de sécurité en mode "Test" expirent après 30 jours
- 🔒 Pour la production, configurez des règles de sécurité plus strictes
- 📱 Assurez-vous d'avoir une connexion Internet pour utiliser l'application
- 🖼️ Les images sont stockées dans Firebase Storage sous `/costumes/`

## Dépannage

### Erreur "Default FirebaseApp is not initialized"
- Vérifiez que `google-services.json` est bien dans `android/app/`
- Exécutez `flutter clean` puis `flutter pub get`

### Erreur de permissions
- Vérifiez que les règles Firestore et Storage sont correctement configurées
- Assurez-vous que Authentication est activé

### Erreur lors de l'upload d'images
- Vérifiez les permissions dans `AndroidManifest.xml`
- Vérifiez les règles Storage dans Firebase Console

