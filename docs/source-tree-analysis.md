# Analyse de l'Arbre des Sources - Holfy

**Projet :** Holfy (Filea)
**Type :** Application iOS native
**Langage :** Swift 6
**Date de génération :** 2026-01-11

## Vue d'ensemble

Holfy est une application iOS de gestion de documents automobiles construite avec SwiftUI et Composable Architecture. La structure du projet suit une architecture en couches claire avec séparation des responsabilités.

## Arbre des Sources Annoté

```
Holfy/                                          # 📱 Répertoire racine du projet
│
├── Holfy/                                      # 🎯 Sources principales de l'application
│   ├── HolfyApp.swift                          # ⭐ Point d'entrée de l'application
│   ├── Holfy.entitlements                      # 🔐 Capabilities (App Sandbox, file access)
│   ├── GoogleService-Info.plist                # 📊 Configuration Firebase (non utilisé actuellement)
│   ├── Localizable.xcstrings                   # 🌍 Fichier de localisation
│   │
│   ├── Data/                                   # 💾 Couche de données
│   │   ├── Database/                           # 🗄️ Base de données GRDB
│   │   │   ├── Records/                        # Tables SQLite avec @Table macro
│   │   │   │   ├── VehicleRecord.swift
│   │   │   │   └── FileMetadataRecord.swift
│   │   │   ├── DTOs/                           # Transfer Objects pour JSON
│   │   │   │   ├── VehicleDTO.swift
│   │   │   │   ├── FileMetadataDTO.swift
│   │   │   │   └── VehicleMetadataFile.swift
│   │   │   ├── Mappers/                        # Conversions Record ↔ Domain ↔ DTO
│   │   │   ├── DatabaseManager.swift           # Gestionnaire principal GRDB
│   │   │   ├── DatabaseMigrator.swift          # Migrations SQL
│   │   │   ├── VehicleMetadataSyncManager.swift # Sync GRDB ↔ JSON
│   │   │   ├── VehicleMetadataSyncManagerClient.swift
│   │   │   └── LegacyDataMigratorClient.swift
│   │   │
│   │   ├── Models/                             # 🎯 Modèles métier (Domain)
│   │   │   ├── Vehicle.swift                   # Modèle principal véhicule
│   │   │   ├── Document.swift                  # Modèle document
│   │   │   ├── UserPreferences.swift
│   │   │   ├── ScannedVehicleData.swift        # Données scannées carte grise
│   │   │   ├── DocumentSource.swift
│   │   │   ├── ScanMode.swift
│   │   │   ├── ScanError.swift
│   │   │   └── CameraAvailability.swift
│   │   │
│   │   ├── Repositories/                       # 📦 Repositories (CRUD)
│   │   │   ├── VehicleGRDBClient.swift         # Client GRDB consolidé véhicules
│   │   │   ├── DocumentRepository.swift
│   │   │   ├── StatisticsRepository.swift
│   │   │   └── DocumentDatabase/
│   │   │       ├── DocumentDatabaseRepository.swift
│   │   │       └── DocumentDatabaseRepositoryClient.swift
│   │   │
│   │   ├── Services/                           # 🔧 Services métier
│   │   │   ├── DocumentParserService.swift
│   │   │   └── OCRService.swift
│   │   │
│   │   └── Storage/                            # 📁 Gestion du système de fichiers
│   │       ├── VehicleStorageManager/
│   │       │   └── VehicleStorageManagerClient.swift
│   │       └── StorageError.swift
│   │
│   ├── Stores/                                 # 🏪 Composable Architecture Stores (19 stores)
│   │   ├── AppStore/                           # Store principal de navigation
│   │   │   └── AppStore.swift
│   │   ├── MainStore/                          # Dashboard principal
│   │   │   ├── MainStore.swift
│   │   │   ├── TotalCostVehicleStore/
│   │   │   ├── WarningVehicleStore/
│   │   │   └── VehicleMonthlyExpensesStore/
│   │   ├── VehiclesListStore/                  # Liste des véhicules
│   │   ├── VehicleDetailsStore/                # Détails d'un véhicule
│   │   ├── AddVehicleStore/                    # Ajout de véhicule
│   │   ├── AddFirstVehicleStore/               # Ajout premier véhicule (onboarding)
│   │   ├── EditVehicleStore/                   # Édition de véhicule
│   │   ├── AddDocumentStore/                   # Ajout de document
│   │   ├── EditDocumentStore/                  # Édition de document
│   │   ├── DocumentDetailStore/                # Détail d'un document
│   │   ├── VehicleCardDocumentScanStore/       # Scan carte grise
│   │   ├── OnboardingStore/                    # Onboarding initial
│   │   ├── StorageOnboardingStore/             # Onboarding choix dossier
│   │   └── Settings/                           # Paramètres
│   │       ├── GlobalSettingsStore/
│   │       ├── StorageSettingsStore/
│   │       └── UnitAndMeasureSettingStore/
│   │
│   ├── UI/                                     # 🎨 Interface utilisateur
│   │   ├── DesignSystem/                       # Design System
│   │   │   ├── Tokens/                         # Design Tokens
│   │   │   │   ├── ColorTokens.swift
│   │   │   │   ├── SpacingTokens.swift
│   │   │   │   ├── TypographyTokens.swift (référencé)
│   │   │   │   └── RadiusTokens.swift
│   │   │   ├── Buttons/                        # Styles de boutons
│   │   │   │   └── ButtonStyle.swift
│   │   │   ├── Labels/                         # Styles de labels
│   │   │   │   └── LabelStyle.swift
│   │   │   └── Spacing.swift
│   │   ├── Components/                         # Composants UI custom
│   │   └── Assets.xcassets/                    # 🎨 Assets (images, couleurs)
│   │
│   ├── SharedViews/                            # 🔄 Vues partagées (10+ composants)
│   │   ├── Forms/
│   │   │   └── FormField.swift                 # Champs de formulaire
│   │   ├── Cards/
│   │   │   ├── StatCard.swift                  # Carte statistique
│   │   │   ├── DocumentCard.swift              # Carte document
│   │   │   └── DetailCard.swift
│   │   ├── Charts/
│   │   │   └── MonthlyExpenseChart.swift       # Graphique dépenses mensuelles
│   │   ├── Media/
│   │   │   └── ThumbnailView.swift             # Vue miniature
│   │   ├── Camera/
│   │   │   └── DocumentScannerView.swift       # Scanner de documents
│   │   ├── CameraView.swift
│   │   ├── FolderPickerView.swift
│   │   └── DocumentFilePickerView.swift
│   │
│   └── Shared/                                 # 🛠️ Utilitaires
│       ├── Extensions/                         # Extensions Swift
│       ├── Utilities/                          # Classes utilitaires
│       ├── Constants/                          # Constantes de l'app
│       └── Protocols/                          # Protocols partagés
│
├── HolfyTests/                                 # ✅ Tests unitaires
│   ├── Stores/                                 # Tests des stores TCA
│   ├── Data/
│   │   ├── Database/                           # Tests database
│   │   └── Repositories/                       # Tests repositories
│   └── Utils/
│       ├── Extensions/
│       │   └── Vehicle+Testing.swift           # Helpers de test
│       └── Fakes/                              # Mocks et fakes
│
├── Holfy.xcodeproj/                            # 📦 Projet Xcode
│   └── project.pbxproj                         # Configuration du projet
│
├── fastlane/                                   # 🚀 Configuration CI/CD
│   ├── Fastfile                                # Actions Fastlane
│   ├── Matchfile                               # Gestion certificats
│   ├── Appfile                                 # Configuration app
│   ├── Deliverfile                             # Livraison App Store
│   └── README.md                               # Documentation Fastlane
│
├── CLAUDE.md                                   # 📖 Guide de développement AI-assisté
├── setup_match.md                              # 📋 Guide configuration certificats
└── docs/                                       # 📚 Documentation générée
    ├── index.md
    └── ...
```

## Répertoires Critiques

### 🎯 Point d'entrée
- **HolfyApp.swift** : Point d'entrée SwiftUI avec initialisation DatabaseManager

### 💾 Couche de données (Data/)
- **Database/** : Gestion GRDB avec Records, DTOs, Mappers
- **Models/** : Modèles métier (Vehicle, Document, etc.)
- **Repositories/** : Couche d'accès aux données (CRUD)
- **Services/** : Services métier (OCR, parsing)
- **Storage/** : Gestion du système de fichiers

### 🏪 State Management (Stores/)
- **AppStore** : Store racine pour la navigation
- **MainStore** : Dashboard et sous-stores
- **Feature Stores** : Stores par fonctionnalité (CRUD véhicules/documents)
- **Settings** : Stores de paramètres

### 🎨 Interface utilisateur (UI/ & SharedViews/)
- **DesignSystem/** : Tokens et styles réutilisables
- **SharedViews/** : Composants partagés (Cards, Forms, Charts)

### 🛠️ Utilitaires (Shared/)
- **Extensions/** : Extensions Swift (Date, String, View, Color, Double)
- **Utilities/** : Classes utilitaires
- **Constants/** : Constantes de l'application

### ✅ Tests (HolfyTests/)
- Tests unitaires pour Stores, Repositories, Database
- Helpers et extensions pour tests
- Pattern BDD (Given-When-Then)

## Architecture des Fichiers

### Pattern d'organisation

L'application suit une architecture **en couches** :

1. **Presentation Layer** : Stores/ (TCA) + UI/ + SharedViews/
2. **Domain Layer** : Data/Models/
3. **Data Layer** : Data/Database/ + Data/Repositories/
4. **Infrastructure Layer** : Data/Services/ + Data/Storage/

### Conventions de nommage

- **Stores** : `{Feature}Store.swift` (ex: `AddVehicleStore.swift`)
- **Models** : `{Entity}.swift` (ex: `Vehicle.swift`)
- **Records** : `{Entity}Record.swift` (ex: `VehicleRecord.swift`)
- **DTOs** : `{Entity}DTO.swift` (ex: `VehicleDTO.swift`)
- **Clients** : `{Feature}Client.swift` (ex: `VehicleGRDBClient.swift`)
- **Views** : `{Component}View.swift` (ex: `DocumentCardView.swift`)

## Intégrations

### Dépendances externes (SPM)
- **Composable Architecture** : State management
- **SQLite Data** : Base de données locale (remplace sharing-grdb)
- **Supabase Swift** : Référencé mais non utilisé

### Frameworks Apple
- **SwiftUI** : UI framework
- **Combine** : Réactivité
- **PhotosUI** : Sélection photos
- **PDFKit** : Affichage PDF
- **Charts** : Graphiques

## Points d'attention

### Architecture hybride GRDB + JSON
- Base de données GRDB pour performance
- Export JSON automatique pour portabilité
- Sync bidirectionnel entre GRDB et JSON

### Local-First
- Toutes les données stockées localement
- Pas de dépendance cloud
- Backup automatique via dossier utilisateur

### Design System
- Tokens centralisés (couleurs, spacing, radius, typo)
- Composants réutilisables avec variantes
- Hiérarchie : Default, Positive, Negative

## Statistiques

- **105 fichiers Swift** dans le code source
- **19 TCA Stores** pour le state management
- **13 modèles de données** (Domain + Records + DTOs)
- **11 fichiers** de repositories/clients/services
- **15+ composants UI** réutilisables
- **Tests unitaires** avec pattern BDD

---

**Note** : Cette analyse a été générée avec un Quick Scan (basé sur les patterns de fichiers). Pour une analyse plus détaillée du contenu des fichiers, utilisez un Deep ou Exhaustive Scan.
