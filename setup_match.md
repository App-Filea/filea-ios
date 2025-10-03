# Configuration de Fastlane Match

## Étapes à suivre pour configurer Match :

### 1. Créer un repository Git privé pour les certificats

1. Va sur GitHub dans ton organisation **App-Filea** et crée un nouveau repository **PRIVÉ** nommé `filea-certificates`
2. Le repository doit être privé car il contiendra tes certificats Apple
3. URL du repo : `git@github.com:App-Filea/filea-certificates.git`

### 2. Trouver ton Team ID Apple Developer

1. Va sur [Apple Developer](https://developer.apple.com/account)
2. Connecte-toi avec ton compte Apple ID : `nicolas.barb.pro@gmail.com`
3. Dans la section "Membership", tu trouveras ton **Team ID** (10 caractères)
4. Note ce Team ID, il faut l'ajouter dans le Matchfile

### 3. Créer l'App ID sur Apple Developer

1. Va dans Apple Developer > Certificates, Identifiers & Profiles
2. Clique sur "Identifiers" > "+"
3. Sélectionne "App IDs" > "App"
4. Bundle ID : `come.nicolasbarb.filea`
5. Description : "Filea App"
6. Capabilities : selon tes besoins de l'app

### 4. Configuration dans App Store Connect

1. Va sur [App Store Connect](https://appstoreconnect.apple.com)
2. Créer une nouvelle app avec :
   - Bundle ID : `come.nicolasbarb.filea`
   - Nom : `Filea`
   - Langue principale : Français

### 5. Mettre à jour le Matchfile

Édite le fichier `fastlane/Matchfile` et ajoute ton Team ID :
```ruby
team_id("TON_TEAM_ID_ICI")
```

### 6. Générer les certificats avec Match

Une fois que tout est configuré, exécute :

```bash
# Première fois - génère et stocke les certificats
fastlane match appstore --force

# Ensuite pour l'utiliser
fastlane ios beta
```

## Notes importantes :

- ⚠️ Le repository de certificats DOIT être privé
- 🔐 Match va générer automatiquement tes certificats de distribution
- 📱 Les provisioning profiles seront créés automatiquement
- 🔄 Match synchronise tout dans le repository Git

## En cas de problème :

- Si les certificats existent déjà, utilise `--force` pour les régénérer
- Pour nettoyer : `fastlane match nuke distribution`
- Pour vérifier : `fastlane match development --readonly`