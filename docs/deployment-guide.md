# Guide de Déploiement - Holfy

**Projet :** Holfy (Filea)
**Version :** 1.0 (Build 5)
**Bundle ID :** com.nicolasbarb.filea
**Date :** 2026-01-11

## Table des Matières

1. [Vue d'ensemble](#vue-densemble)
2. [Configuration Initiale](#configuration-initiale)
3. [Gestion des Certificats (Match)](#gestion-des-certificats-match)
4. [Déploiement TestFlight](#déploiement-testflight)
5. [Déploiement App Store](#déploiement-app-store)
6. [Troubleshooting](#troubleshooting)

## Vue d'ensemble

Holfy utilise **Fastlane** pour automatiser l'ensemble du processus de déploiement, de la génération des certificats à la soumission sur l'App Store.

### Prérequis

- **Compte Apple Developer** actif
- **App Store Connect** configuré
- **Fastlane** installé
  ```bash
  gem install fastlane
  ```
- **Accès au repository de certificats** (Git privé)

### Structure Fastlane

```
fastlane/
├── Fastfile          # Actions disponibles
├── Matchfile         # Configuration Match (certificats)
├── Appfile           # Configuration app (Bundle ID, Team ID)
├── Deliverfile       # Configuration livraison App Store
├── Pluginfile        # Plugins Fastlane
├── rating_config.json # Configuration ratings
└── README.md         # Documentation Fastlane
```

## Configuration Initiale

### 1. Créer le Repository de Certificats

Les certificats Apple sont stockés dans un repository Git privé pour permettre le partage entre développeurs et machines CI/CD.

1. Créer un repository **PRIVÉ** sur GitHub :
   - Nom : `filea-certificates`
   - Organisation : `App-Filea` (ou votre organisation)
   - URL : `git@github.com:App-Filea/filea-certificates.git`

2. Ce repository contiendra :
   - Certificats de développement
   - Certificats de distribution
   - Profils de provisioning

⚠️ **Important** : Le repository DOIT être privé car il contient des certificats Apple sensibles.

### 2. Obtenir le Team ID

1. Aller sur [Apple Developer](https://developer.apple.com/account)
2. Se connecter avec : `nicolas.barb.pro@gmail.com`
3. Dans la section **Membership**, noter le **Team ID** (10 caractères)

### 3. Créer l'App ID

Si ce n'est pas déjà fait :

1. Aller dans **Certificates, Identifiers & Profiles**
2. Cliquer sur **Identifiers** → **+**
3. Sélectionner **App IDs** → **App**
4. Renseigner :
   - **Bundle ID** : `com.nicolasbarb.filea`
   - **Description** : `Filea App`
   - **Capabilities** : Selon les besoins (File Access, etc.)

### 4. Configurer App Store Connect

1. Aller sur [App Store Connect](https://appstoreconnect.apple.com)
2. Créer une nouvelle app :
   - **Bundle ID** : `com.nicolasbarb.filea`
   - **Nom** : `Filea`
   - **Langue principale** : Français
   - **SKU** : `filea-ios`
   - **Catégorie** : Productivité (ou selon choix)

### 5. Mettre à jour le Matchfile

Éditer `fastlane/Matchfile` :

```ruby
git_url("git@github.com:App-Filea/filea-certificates.git")
storage_mode("git")
type("appstore")
app_identifier(["com.nicolasbarb.filea"])
username("nicolas.barb.pro@gmail.com")
team_id("VOTRE_TEAM_ID")  # ← Remplacer par votre Team ID
```

### 6. Mettre à jour l'Appfile

Éditer `fastlane/Appfile` :

```ruby
app_identifier("com.nicolasbarb.filea")
apple_id("nicolas.barb.pro@gmail.com")
team_id("VOTRE_TEAM_ID")  # ← Remplacer par votre Team ID

# App Store Connect Team ID
itc_team_id("VOTRE_TEAM_ID")
```

## Gestion des Certificats (Match)

### Première Fois : Générer les Certificats

```bash
fastlane ios setup_match
```

Cette action :
1. Génère les certificats Development, Ad Hoc et App Store
2. Crée les profils de provisioning
3. Les stocke dans le repository Git privé
4. Les installe sur votre machine

⚠️ **Mot de passe** : Match demandera un mot de passe pour chiffrer les certificats. **Notez-le précieusement** - vous en aurez besoin sur chaque machine.

### Utiliser des Certificats Existants (Nouvelle Machine)

Sur une nouvelle machine ou pour un nouveau développeur :

```bash
fastlane match appstore --readonly
```

Entrer le mot de passe de chiffrement des certificats.

### Régénérer Tous les Certificats

Si les certificats sont expirés ou corrompus :

```bash
fastlane ios regenerate_certificates
```

⚠️ **Attention** : Cette action **révoque** tous les certificats existants et en génère de nouveaux.

### Vérifier les Certificats

```bash
fastlane match appstore
```

- Télécharge les certificats existants
- Les installe dans le Keychain
- Met à jour les profils de provisioning

## Déploiement TestFlight

### Build et Upload sur TestFlight

```bash
fastlane ios beta
```

Cette action exécute :
1. **Incrémente le build number** automatiquement
2. **Match** : Synchronise les certificats App Store
3. **Build** : Compile l'app en mode Release
4. **Upload** : Envoie le build sur TestFlight
5. **Métadonnées** : Met à jour les informations TestFlight

### Workflow Manuel

Si vous préférez contrôler chaque étape :

```bash
# 1. Synchroniser les certificats
fastlane match appstore

# 2. Build l'app
fastlane ios build

# 3. Upload manuellement via Xcode
# Ou via xcodebuild et altool
```

### Tester le Build

Après l'upload :
1. Aller sur [App Store Connect](https://appstoreconnect.apple.com)
2. Sélectionner l'app **Filea**
3. Onglet **TestFlight**
4. Le build apparaîtra après traitement (~5-10 minutes)
5. Ajouter des testeurs internes/externes
6. Distribuer le build

## Déploiement App Store

### Préparer la Soumission

1. **Métadonnées** : Renseigner dans App Store Connect
   - Description
   - Mots-clés
   - Screenshots (voir section Screenshots)
   - Icône de l'app

2. **Privacy Policy** : URL vers `privacy-policy.html`

3. **Support URL** : URL vers `support.html`

4. **Versions et Localisation**

### Générer les Screenshots

```bash
fastlane ios screenshots
```

Cette action génère automatiquement les screenshots pour tous les appareils requis.

⚠️ **Note** : Vérifier et ajuster les tests UI pour générer des screenshots pertinents.

### Soumettre pour Review

1. **Build sur TestFlight** :
   ```bash
   fastlane ios beta
   ```

2. **Aller sur App Store Connect** :
   - Sélectionner le build TestFlight
   - Renseigner les informations de version
   - Répondre aux questions de conformité
   - Cliquer sur **Submit for Review**

3. **Suivi** :
   - **Waiting for Review** : En attente
   - **In Review** : Apple examine l'app (~24-48h)
   - **Ready for Sale** : Approuvée et disponible
   - **Rejected** : Modifications nécessaires

### Déploiement Automatique

Pour automatiser complètement :

```bash
fastlane ios release
```

⚠️ **Note** : Cette lane doit être configurée dans le `Fastfile` si nécessaire.

## Fichiers de Configuration

### Fastfile

Contient les actions Fastlane disponibles :

- `setup_match` : Configuration initiale des certificats
- `regenerate_certificates` : Régénération complète
- `beta` : Upload sur TestFlight
- `build` : Build Release
- `screenshots` : Génération de screenshots

### Deliverfile

Configuration pour la livraison App Store :

```ruby
app_identifier("com.nicolasbarb.filea")
username("nicolas.barb.pro@gmail.com")
copyright("#{Time.now.year} Nicolas Barbosa")
```

### Metadata

Le dossier `fastlane/metadata/` peut contenir :
- `fr-FR/` : Métadonnées en français
  - `description.txt`
  - `keywords.txt`
  - `marketing_url.txt`
  - `privacy_url.txt`
  - `support_url.txt`

## Troubleshooting

### Erreur : "No matching provisioning profiles found"

**Solution** :
```bash
fastlane match appstore --force
```

### Erreur : "Certificate already exists"

**Solution** :
1. Vérifier sur [Apple Developer](https://developer.apple.com/account/resources/certificates/list)
2. Si corrompu, regénérer :
   ```bash
   fastlane ios regenerate_certificates
   ```

### Erreur : "Wrong team selected"

**Solution** :
- Vérifier le `team_id` dans `Matchfile` et `Appfile`
- S'assurer d'utiliser le bon compte Apple ID

### Build Number Conflict

Si le build number existe déjà sur TestFlight :

**Solution** :
```bash
# Incrémenter manuellement
agvtool next-version -all

# Ou laisser Fastlane le faire automatiquement
fastlane ios beta
```

### Mot de passe Match Oublié

⚠️ **Problème critique** : Si le mot de passe est perdu, tous les certificats doivent être régénérés.

**Solution** :
```bash
fastlane match nuke development
fastlane match nuke distribution
fastlane ios setup_match  # Avec nouveau mot de passe
```

## Bonnes Pratiques

### Versioning

- **Marketing Version** : `1.0`, `1.1`, `2.0` (semver simplifié)
- **Build Number** : Auto-incrémenté par Fastlane
- Format : `1.0 (5)` = Version 1.0, Build 5

### Changelog

Maintenir un changelog pour chaque release :
- Nouvelles fonctionnalités
- Corrections de bugs
- Améliorations

### Tests Avant Soumission

Checklist :
- [ ] Tests unitaires passent
- [ ] Build Release sans warnings
- [ ] Testé sur simulateur ET appareil réel
- [ ] Testé sur iOS 18.5 (version minimale)
- [ ] Screenshots à jour
- [ ] Métadonnées remplies
- [ ] Privacy policy à jour
- [ ] Support URL valide

## CI/CD (Futur)

Pour automatiser via GitHub Actions ou GitLab CI :

```yaml
# .github/workflows/deploy.yml
name: Deploy to TestFlight

on:
  push:
    tags:
      - 'v*'

jobs:
  deploy:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Fastlane
        run: gem install fastlane
      - name: Deploy
        env:
          MATCH_PASSWORD: ${{ secrets.MATCH_PASSWORD }}
          FASTLANE_USER: nicolas.barb.pro@gmail.com
          FASTLANE_PASSWORD: ${{ secrets.FASTLANE_PASSWORD }}
        run: fastlane ios beta
```

## Ressources

- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Match Guide](https://docs.fastlane.tools/actions/match/)
- [App Store Connect](https://appstoreconnect.apple.com)
- [Apple Developer](https://developer.apple.com)
- Documentation interne : `setup_match.md`, `fastlane/README.md`

---

**Note** : Ce guide couvre le processus de déploiement iOS. Pour des questions spécifiques, consulter `setup_match.md` ou la documentation Fastlane officielle.
