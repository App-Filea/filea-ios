# Recherche Technique : StoreKit 2 vs RevenueCat

**Date** : 22 janvier 2026
**Projet** : Holfy (Filea)
**Auteur** : Mary (Business Analyst) avec Nicolas
**Statut** : Terminé
**Décision** : StoreKit 2 natif

---

## Résumé Exécutif

Cette recherche compare StoreKit 2 (solution native Apple) et RevenueCat (service tiers) pour l'implémentation des abonnements in-app dans Holfy.

**Décision finale** : **StoreKit 2 natif** est recommandé pour Holfy car :
- Application iOS uniquement
- Modèle d'abonnement simple (1 tier)
- Stack Swift 6 + SwiftUI + TCA compatible
- Zéro coût récurrent
- Contrôle total du code

---

## Contexte : Modèle d'Abonnement Holfy

| Tier | Prix | Fonctionnalités |
|------|------|-----------------|
| **Gratuit** | 0€ | Véhicules illimités, ajout docs manuel, rappels manuels |
| **Premium** | 2,99€/mois (24,99€/an) | OCR auto-remplissage, rappels intelligents, statistiques & graphiques, export PDF |

---

## Comparatif Détaillé

### Vue d'ensemble

| Critère | StoreKit 2 | RevenueCat |
|---------|------------|------------|
| **Coût** | Gratuit | Gratuit < 2 500€ MTR, puis 1% |
| **Temps de dev** | ~50-100h | ~15-25h |
| **Complexité** | Moyenne | Faible |
| **iOS minimum** | iOS 15+ | iOS 13+ |
| **Backend requis** | Non | Non |
| **Analytics** | App Store Connect | Dashboard complet |
| **Multi-plateforme** | iOS/macOS | iOS, Android, Web |

### Analyse des Coûts RevenueCat

| MTR (Monthly Tracked Revenue) | Coût RevenueCat | % des revenus nets |
|-------------------------------|-----------------|-------------------|
| < 2 500€ | **0€** | 0% |
| 2 500€ | 25€/mois | ~1,2% |
| 5 000€ | 50€/mois | ~1,2% |
| 10 000€ | 100€/mois | ~1,2% |

**Note importante** : Le 1% est calculé sur le revenu **brut** (avant commission Apple 15-30%).

### Temps de Développement Estimé

#### StoreKit 2 Natif

| Tâche | Temps estimé |
|-------|--------------|
| Documentation + compréhension API | 8-16h |
| Setup App Store Connect | 4-8h |
| Implémentation achat + vérification | 16-24h |
| Gestion états (restore, expiration) | 8-16h |
| UI paywall SwiftUI | 8-16h |
| Tests sandbox + edge cases | 8-16h |
| **Total** | **50-100h** |

#### RevenueCat

| Tâche | Temps estimé |
|-------|--------------|
| Setup compte + dashboard | 1-2h |
| Intégration SDK | 2-4h |
| Implémentation achat | 4-8h |
| UI paywall | 4-8h |
| Tests | 2-4h |
| **Total** | **15-25h** |

### Avantages StoreKit 2

- Zéro dépendance externe
- Zéro coût récurrent
- SwiftUI Views natives (`SubscriptionStoreView`)
- Validation locale sécurisée (plus besoin de serveur)
- Contrôle total du code
- Parfait pour apps iOS-only

### Avantages RevenueCat

- Implémentation 3x plus rapide
- Dashboard analytics complet (churn, LTV, MRR)
- A/B testing sur prix/paywalls
- Webhooks pour intégrations
- Support multi-plateforme
- Gratuit jusqu'à 2 500€ MTR

---

## Informations Techniques Clés

### StoreKit 2 - Points Importants

1. **iOS 15+ requis** - Certaines APIs ajoutées en iOS 16 (ex: `originalPurchaseDate`)
2. **Swift-only** - API moderne avec async/await
3. **Validation locale** - `Transaction.currentEntitlements` gère tout
4. **SwiftUI Views** - `StoreView`, `ProductView`, `SubscriptionStoreView`
5. **StoreKit 1 déprécié** - Annoncé à WWDC 2024

### RevenueCat - Points Importants

1. **SDK 5.0** (juillet 2024) - Utilise StoreKit 2 par défaut sur iOS 16+
2. **MTR** - Calculé sur le brut, pas le net
3. **Tier gratuit généreux** - Toutes fonctionnalités jusqu'à 2 500€
4. **1% après seuil** - Appliqué uniquement sur les mois dépassant 2 500€

---

## Sources et Ressources

### Documentation Officielle

- [Apple Developer - StoreKit 2](https://developer.apple.com/storekit/)
- [Apple - Meet StoreKit 2 (WWDC21)](https://developer.apple.com/videos/play/wwdc2021/10114/)
- [Apple - StoreKit Documentation](https://developer.apple.com/documentation/storekit)

### Tutorials StoreKit 2

- [iOS In-App Subscription Tutorial with StoreKit 2 and Swift](https://www.revenuecat.com/blog/engineering/ios-in-app-subscription-tutorial-with-storekit-2-and-swift/) - Par RevenueCat, très complet (mis à jour juin 2024)
- [StoreKit 2 Tutorial with SwiftUI - Superwall](https://superwall.com/blog/make-a-swiftui-app-with-in-app-purchases-and-subscriptions-using-storekit-2/) - Février 2024
- [Implement In-App Subscriptions Using Swift and StoreKit2 (Serverless)](https://medium.com/@aisultanios/implement-inn-app-subscriptions-using-swift-and-storekit2-serverless-and-share-active-purchases-7d50f9ecdc09) - Septembre 2024
- [Mastering StoreKit 2 - Swift with Majid](https://swiftwithmajid.com/2023/08/01/mastering-storekit2/)
- [Mastering StoreKit 2 in SwiftUI: A Complete Guide (2025)](https://medium.com/@dhruvinbhalodiya752/mastering-storekit-2-in-swiftui-a-complete-guide-to-in-app-purchases-2025-ef9241fced46)
- [Implementing subscriptions In-App Purchases with StoreKit 2](https://www.createwithswift.com/implementing-subscriptions-in-app-purchases-with-storekit-2/)
- [Get started with StoreKit 2](https://tanaschita.com/20231002-storekit-2-overview/)

### Packages et Outils

- [StoreHelper - GitHub](https://github.com/russell-archer/StoreHelper) - Package Swift prêt à l'emploi, mis à jour 2024

### RevenueCat

- [RevenueCat Pricing](https://www.revenuecat.com/pricing/)
- [RevenueCat Pricing 2025 - MetaCTO](https://www.metacto.com/blogs/the-real-cost-of-revenuecat-what-app-publishers-need-to-know)
- [StoreKit With and Without RevenueCat](https://www.revenuecat.com/blog/engineering/implementing-storekit/)
- [StoreKit 2 Overview - RevenueCat](https://www.revenuecat.com/blog/engineering/storekit-2-overview/)
- [RevenueCat SDK 5.0 - The StoreKit 2 Update](https://www.revenuecat.com/blog/engineering/revenuecat-sdk-5-0-the-storekit-2-update/)
- [Navigating RevenueCat's new pricing](https://www.revenuecat.com/blog/company/navigating-revenuecats-new-pricing-for-existing-users/)

### Comparatifs et Analyses

- [StoreKit 1 deprecation - WWDC 2024](https://www.revenuecat.com/blog/engineering/storekit-1-deprecation-wwdc-2024-recap/)
- [StoreKit 1 vs 2: How to Migrate](https://www.revenuecat.com/blog/engineering/migrating-from-storekit-1-to-storekit-2/)
- [WWDC 2024: What Subscription Apps Need to Know](https://subclub.com/episode/wwdc-2024-what-subscription-apps-need-to-know-david-barnard-jacob-eiting-charlie-chapman-revenuecat)
- [WWDC 2025: What Subscription Apps Need to Know](https://subclub.com/episode/wwdc-2025-what-subscription-apps-need-to-know)
- [RevenueCat Alternatives - Adapty](https://adapty.io/blog/revenuecat-alternatives-why-i-switched-to-adapty/)

### Rapports et Statistiques

- [State of Subscription Apps 2024 - RevenueCat](https://www.revenuecat.com/state-of-subscription-apps-2024/)
- [State of Subscription Apps 2025 - RevenueCat](https://www.revenuecat.com/state-of-subscription-apps-2025/)

### Reviews et Retours Utilisateurs

- [RevenueCat Reviews 2026 - Capterra](https://www.capterra.com/p/212540/RevenueCat/reviews/)
- [RevenueCat Pricing 2025 - G2](https://www.g2.com/products/revenuecat/pricing)

---

## Prochaines Étapes

1. **Créer les produits dans App Store Connect** - Définir l'abonnement Premium mensuel et annuel
2. **Configurer StoreKit Configuration File** - Pour tests locaux sans sandbox
3. **Implémenter le Store avec TCA** - Créer `SubscriptionStore` avec pattern Dependencies
4. **Créer le Paywall UI** - Utiliser `SubscriptionStoreView` ou custom SwiftUI
5. **Implémenter la logique Premium** - Conditionner l'accès aux features (OCR, rappels intelligents, stats)
6. **Tests complets** - Sandbox testing, edge cases (restore, expiration, upgrade)

---

## Notes de Session

- La recherche a validé que StoreKit 2 est suffisamment mature et simplifié pour une app indie iOS-only
- RevenueCat reste une option viable si le besoin d'analytics avancés ou de multi-plateforme émerge
- Le modèle Gratuit/Premium à 2,99€ est aligné avec les pratiques du marché
- Les rappels intelligents sont identifiés comme la killer feature justifiant l'abonnement récurrent
