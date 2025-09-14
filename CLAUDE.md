# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Règles Spécifiques au Projet

- **Toujours répondre en français** - Toutes les interactions doivent être en français
- **Le code est toujours en anglais** - Variables, fonctions, classes et commentaires de code en anglais
- **Utiliser les MCP Swift, SwiftUI, Composable Architecture, Sharing-GRDB, Supabase Swift** - Privilégier ces frameworks et architectures
- **Le code doit être en Swift 6** - Utiliser les dernières fonctionnalités et syntaxe de Swift 6

## Aperçu du Projet

Il s'agit d'une application iOS appelée "Invoicer" construite avec SwiftUI et Xcode 16.4. Le projet supporte plusieurs plateformes Apple incluant iOS (18.5+), macOS (15.4+), mais PAS visionOS (désactivé dans la configuration récente).

## Commandes de Build (À NE PAS EXÉCUTER)

```bash
# Build de l'app (NE PAS EXÉCUTER)
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -configuration Debug build

# Build pour release (NE PAS EXÉCUTER)
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -configuration Release build

# Clean build (NE PAS EXÉCUTER)
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer clean

# Tests unitaires (NE PAS EXÉCUTER)
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' test

# Tests UI (NE PAS EXÉCUTER)
xcodebuild -project Invoicer.xcodeproj -scheme Invoicer -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest' -only-testing:InvoicerUITests test
```

## Structure du Projet

- **Invoicer/**: Target principal de l'application contenant les vues SwiftUI et la logique de l'app
  - `InvoicerApp.swift`: Point d'entrée de l'app avec l'annotation @main
  - `ContentView.swift`: Vue SwiftUI racine
  - `Assets.xcassets/`: Icônes de l'app et ressources de couleurs
  - `Invoicer.entitlements`: Droits de sandbox et sécurité de l'app
- **InvoicerTests/**: Target de tests unitaires utilisant le framework XCTest
- **InvoicerUITests/**: Target de tests UI utilisant le framework XCUITest

## Configuration de Développement

- **Version Swift**: 6.0
- **Targets de Déploiement**: iOS 18.5+, macOS 15.4+
- **Bundle Identifier**: com.invoicer.nbarb.Invoicer
- **Équipe de Développement**: 5DDBZ7D32L
- **App Sandbox**: Activé avec accès en lecture seule aux fichiers sélectionnés par l'utilisateur
- **Catalyst**: Désactivé (SUPPORTS_MACCATALYST = NO)

## Notes d'Architecture

Il s'agit d'une app SwiftUI standard avec le pattern App protocol. L'app utilise :
- SwiftUI pour l'interface utilisateur
- XCTest pour les tests unitaires
- XCUITest pour l'automatisation des tests UI
- App sandbox avec accès restreint au système de fichiers
- Support multi-plateforme (iOS, macOS uniquement)

Le code actuel est minimal avec une implémentation basique "Hello, world!", indiquant qu'il s'agit probablement d'un nouveau projet prêt pour le développement de fonctionnalités.

## Frameworks Recommandés

- **Swift** et **SwiftUI** pour l'interface
- **Composable Architecture** pour l'architecture de l'app
- **Sharing-GRDB** pour la persistence des données
- **Supabase Swift** pour les services backend et authentification

## Documentation Supabase

- **Référence API Auth** : https://supabase.com/docs/reference/swift/auth-api
  - Configuration client : `SupabaseClient(supabaseURL:, supabaseKey:)`
  - Méthodes d'authentification : sign up, sign in, OTP, OAuth, sessions
  - Gestion des deep links avec `.onOpenURL` modifier
  - Support MFA et gestion utilisateurs avancée