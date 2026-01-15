---
stepsCompleted: [1, 2, 3]
inputDocuments:
  - '_bmad-output/planning-artifacts/prd.md'
  - 'docs/project-overview.md'
  - 'docs/architecture.md'
workflowType: 'ux-design'
lastStep: 3
completed: true
completionDate: '2026-01-14'
completionNote: 'Workflow terminé après Core Experience - suffisant pour implémentation'
documentCounts:
  prdCount: 1
  briefCount: 0
  projectDocsCount: 2
  otherCount: 0
---

# UX Design Specification Holfy

**Auteur:** Nicolas
**Date:** 2026-01-12

---

## Executive Summary

### Project Vision

Holfy transforme la gestion de documents automobiles en éliminant la friction cognitive d'une liste unique scrollable. L'ajout du **Custom Segmented Control** avec 5 onglets thématiques (Vue d'Ensemble, Statistiques, Entretiens & Réparations, Administration, Carburant) permet aux utilisateurs de retrouver instantanément l'information recherchée sans scan visuel.

**Objectif UX** : Passer de "Où dois-je chercher ?" à "Je sais exactement où c'est."

**Valeur Croissante** : Plus l'utilisateur accumule de documents (1 an, 2 ans, 5 ans), plus le gain de temps devient significatif comparé à une longue liste scrollable.

### Target Users

**Personas Clés** :

1. **Marc - Propriétaire d'un véhicule unique**
   - Besoin : Retrouver rapidement un document spécifique (contrôle technique, assurance)
   - Gain : Temps de recherche réduit de 45s à 3s
   - Citation : "Je n'ai plus besoin de chercher dans toute la liste"

2. **Sophie - Gestionnaire de flotte familiale (4 véhicules)**
   - Besoin : Naviguer efficacement entre véhicules et sections thématiques
   - Gain : Navigation par contexte thématique plutôt que par véhicule complet
   - Pattern : "Je cherche une info admin ? J'ouvre l'onglet Admin de chaque véhicule"

3. **Thomas - Novice (première voiture)**
   - Besoin : Guidage naturel pour comprendre l'organisation
   - Gain : Empty states avec exemples concrets transforment chaque onglet en mini-tutoriel
   - Apprentissage : "Learn by Doing" sans tutoriel lourd

4. **Jean - Analyste passionné (3 véhicules)**
   - Besoin : Organisation claire pour analyses approfondies de coûts
   - Gain : Isolation parfaite de chaque catégorie sans bruit visuel
   - Usage : Analyses hebdomadaires facilitées par séparation thématique

**Niveau Technique** : Spectrum large (novices à experts), référence interfaces modernes (Spotify, Instagram)

**Contexte d'Usage** : Mobile iOS 18.5+, souvent en situation urgente (besoin immédiat d'un document)

### Key Design Challenges

1. **Navigation Cognitive Claire**
   - Créer une organisation mentale prévisible avec 5 onglets thématiques
   - État visuel distinct de l'onglet actif (Design System : AccentLabel ou équivalent)
   - Scroll indépendant par onglet avec préservation de la position

2. **Onboarding Invisible pour Novices**
   - Guider naturellement via empty states explicatifs (pas de tutoriel lourd)
   - Exemples concrets par onglet : "Vidange moteur, Changement pneus, Révision"
   - Pattern "Learn by Doing" : l'utilisateur apprend en utilisant

3. **Performance Perçue et Fluidité**
   - Changement d'onglet < 100ms pour renforcer la confiance
   - Scroll 60 FPS avec jusqu'à 100 documents par onglet
   - Pas de lag ou memory leaks (profiling Instruments)

4. **Accessibilité et Adaptativité**
   - Support VoiceOver avec annonces claires
   - Dynamic Type pour tailles de texte
   - Contraste WCAG AA (4.5:1 minimum)
   - Boutons 44×44 points minimum (Apple HIG)

### Design Opportunities

1. **Quick Actions Contextuelles Intelligentes**
   - Réduire la friction d'ajout en pré-sélectionnant le type de document selon l'onglet actif
   - "➕ Ajouter Entretien" dans l'onglet Entretiens → type déjà sélectionné
   - Gain : 30% de réduction du temps d'ajout de document

2. **Empty States Éducatifs et Accueillants**
   - Transformer chaque onglet vide en mini-tutoriel avec exemples concrets
   - CTA clairs : "➕ Ajouter Votre Premier [Type]"
   - Design moderne et épuré (texte prioritaire sur icônes complexes)

3. **Scalabilité Visuelle à Long Terme**
   - L'organisation thématique gagne en valeur avec le volume de documents
   - Après 1 an, 2 ans, 5 ans d'usage : gain de temps exponentiel vs liste unique
   - Architecture prête pour futures extensions (tooltips progressifs, recherche cross-onglets)

4. **Avantage Compétitif par l'UX**
   - Navigation mentale claire devient un différenciateur fort
   - Expérience qui "grandit en valeur" avec l'usage (rétention utilisateur)
   - Potentiel de recommandation élevé ("Tout est organisé exactement comme je le pense")

---

## Core User Experience

### Defining Experience

L'expérience centrale de Holfy repose sur **deux actions fondamentales** :

1. **Ajouter un document** facilement et sans friction cognitive
2. **Retrouver un document** instantanément grâce à l'organisation thématique

**Le moment critique de succès** : Quand l'utilisateur revient dans l'app et retrouve tous ses documents organisés exactement comme il les pense mentalement. "Je sais exactement où c'est" devient la phrase clé de l'expérience.

Cette dualité ajout/consultation définit l'architecture du Custom Segmented Control :
- **5 onglets thématiques** pour une organisation mentale claire (Vue d'Ensemble, Statistiques, Entretiens & Réparations, Administration, Carburant)
- **Quick Actions contextuelles** pour ajouter sans penser au type
- **Scan OCR intelligent** pour pré-remplir automatiquement les informations

### Platform Strategy

**Plateforme Native iOS** :
- iOS 18.5+ avec SwiftUI et Composable Architecture
- Interface tactile optimisée pour iPhone (gestures naturelles)
- Support iPad potentiel mais mobile-first

**Capacités Device Exploitées** :
- **Caméra** : Scan documents avec OCR (VisionKit) pour extraction automatique de données
  - Factures d'entretien → montant, date, garage, type de service
  - Tickets carburant → prix, litres, date, station
  - Documents admin → dates, montants, organismes
- **Photos** : Import depuis bibliothèque
- **Haptic Feedback** : Confirmation tactile des actions critiques (ajout document, changement onglet)
- **Dark Mode** : Support complet via ColorTokens du Design System

**Architecture Local-First** :
- Fonctionnalité 100% offline (GRDB + JSON)
- Aucune dépendance réseau pour usage quotidien
- Données privées, aucun cloud par défaut

### Effortless Interactions

**1. Ajout de Document Sans Friction**

L'ajout doit être **rapide, intelligent et guidé** :

- **Scan OCR Intelligent** : L'utilisateur scanne un document (facture, ticket), l'OCR extrait automatiquement :
  - Date, montant, fournisseur, type de service
  - Pré-remplissage de 80% des champs → validation en 2 taps

- **Quick Actions Contextuelles** : Tap sur "➕ Ajouter Entretien" dans l'onglet Entretiens :
  - Type de document déjà sélectionné (plus de dropdown mental)
  - Date pré-remplie (aujourd'hui)
  - Kilométrage pré-rempli (dernier connu du véhicule)

- **Validation en Temps Réel** : Feedback immédiat sur les erreurs pour éviter de soumettre un formulaire incomplet

**2. Consultation/Retrouver Sans Effort**

La consultation doit être **instantanée et prévisible** :

- **Navigation Mentale Claire** : L'utilisateur pense "Administration" → Tape sur onglet Administration → Voit ses 3 documents admin
- **Pas de Scan Visuel** : Filtrage automatique élimine le bruit (5-10 documents par onglet vs 50+ dans une liste unique)
- **Scroll Indépendant** : Position préservée par onglet → L'utilisateur ne perd jamais sa place
- **Aperçu Visuel** : Thumbnails des documents pour reconnaissance rapide

**3. Guidage Naturel pour Novices**

Les novices (Thomas) doivent **apprendre en faisant** :

- **Empty States Explicatifs** : "Aucun Document d'Entretien" + exemples concrets ("Vidange moteur, Changement pneus, Révision")
- **CTA Clairs** : "➕ Ajouter Votre Premier Entretien" guide l'action sans confusion
- **Pattern Learn by Doing** : Pas de tutoriel lourd, chaque onglet enseigne son rôle par l'usage

### Critical Success Moments

**1. Le Moment "Aha !" - Retrouver Facilement**

Le moment décisif où l'utilisateur réalise la valeur du Custom Segmented Control :

> **Marc, 2 semaines après adoption** : "Je dois retrouver mon contrôle technique pour l'assurance. Je tape sur mon véhicule, je vais dans Administration, et là : 3 documents seulement. Je trouve en 3 secondes. Ah ! Je n'ai plus besoin de chercher dans toute la liste."

Ce moment se produit **lors de la première consultation d'urgence**, pas lors de l'ajout. C'est quand l'utilisateur revient et trouve instantanément ce qu'il cherche qu'il comprend la vraie valeur.

**2. Premier Ajout Réussi - Scan OCR**

Le premier ajout avec scan OCR qui pré-remplit les champs :

> **Thomas, premier ajout** : "Je scanne ma facture de vidange, l'app extrait le montant, la date, le garage. Je vérifie, je tape 'Sauvegarder'. Fait en 10 secondes au lieu de 2 minutes."

**3. Guidage par Empty State - Compréhension Naturelle**

Novice qui découvre l'organisation via empty states :

> **Thomas, découverte** : "Je tape sur 'Entretiens', je vois 'Aucun Document d'Entretien' avec des exemples : 'Vidange moteur, Changement pneus'. Ah ! C'est ici que va ma prochaine vidange."

**4. Navigation Fluide - Confiance Renforcée**

Changement d'onglet instantané qui renforce la confiance :

> **Sophie, gestion multi-véhicules** : "Je passe d'un onglet à l'autre, c'est fluide, instantané. Pas de lag, pas d'attente. Je peux gérer mes 4 véhicules rapidement."

### Experience Principles

Ces principes guident toutes nos décisions UX pour le Custom Segmented Control :

**1. "Je sais exactement où c'est" - Organisation Mentale Claire**

L'organisation thématique en 5 onglets doit être **immédiatement compréhensible et prévisible**. L'utilisateur ne doit jamais se demander "dans quel onglet j'ai mis ça ?". L'état visuel de l'onglet actif doit être ultra-clair (Design System : AccentLabel ou équivalent).

**2. "Ajout sans friction cognitive" - Scan Intelligent et Contexte**

L'ajout de document doit éliminer la friction mentale grâce au **scan OCR intelligent** (pré-remplissage automatique) et aux **Quick Actions contextuelles** (type pré-sélectionné selon l'onglet actif). Réduction de 80% des champs à remplir manuellement.

**3. "Instantané et Fluide" - Performance Perçue**

Changement d'onglet **< 100ms** pour renforcer la confiance. Scroll **60 FPS** même avec 100+ documents. Aucun lag qui casserait la fluidité mentale. La performance perçue est aussi importante que la performance réelle.

**4. "Guidage Naturel, Pas de Tutoriel" - Learn by Doing**

Empty states explicatifs avec **exemples concrets par onglet** transforment chaque onglet vide en mini-tutoriel. L'utilisateur apprend en utilisant, pas en lisant. Pattern "Learn by Doing" privilégié sur onboarding lourd.

**5. "Valeur qui Croît avec l'Usage" - Scalabilité Visuelle**

L'organisation thématique **gagne en valeur** avec le volume de documents. Après 1 an, 2 ans, 5 ans : gain de temps exponentiel vs liste unique. L'expérience devient meilleure avec le temps, créant un effet de rétention naturel.

---
