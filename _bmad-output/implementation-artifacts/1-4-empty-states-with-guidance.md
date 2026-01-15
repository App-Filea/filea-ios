# Story 1.4: Empty States with Guidance

Status: ready-for-dev

## Story

As a **new user or user with few documents**,
I want **clear, welcoming empty states with concrete examples when a tab has no documents**,
so that **I understand what belongs in each category and feel guided to add my first document naturally (Learn by Doing pattern)**.

## Acceptance Criteria

### AC1: Empty State Displayed When No Documents
**Given** the user selects a tab with no documents for that category
**When** the tab content loads
**Then**
- An empty state view should be displayed instead of an empty list
- Empty state should not feel like an error (welcoming tone)
- Content should be centered vertically and horizontally

### AC2: Contextual Empty State Message
**Given** each tab has its own empty state
**When** displayed
**Then** the message should be specific to the tab:
- **Maintenance**: "Aucun Document d'Entretien"
- **Administration**: "Aucun Document Administratif"
- **Fuel**: "Aucun Plein d'Essence"

### AC3: Concrete Examples Provided
**Given** an empty state is displayed
**When** the user reads the content
**Then** concrete examples should be shown:
- **Maintenance**: "Vidange moteur, Changement pneus, Révision, Remplacement freins"
- **Administration**: "Carte grise, Assurance auto, Contrôle technique"
- **Fuel**: "Pleins d'essence, Recharges électriques, Recharges hybrides"

### AC4: Clear Call-to-Action (CTA)
**Given** an empty state is displayed
**When** the user sees the CTA
**Then**
- A prominent button should say: "➕ Ajouter Votre Premier [Type]"
- Examples: "➕ Ajouter Votre Premier Entretien", "➕ Ajouter Votre Premier Document Admin"
- CTA should use AccentButton style (same as Quick Action)
- Tapping CTA should open AddDocumentView with type pre-selected (like Quick Actions)

### AC5: Illustration or Icon for Visual Interest
**Given** an empty state is displayed
**When** rendered
**Then**
- An SF Symbol icon or illustration should be shown
- Icon should be relevant to the tab context (wrench for maintenance, document for admin, fuel pump for fuel)
- Icon should be large (48-64pt) and use secondary color

### AC6: Explanation Text for Context
**Given** an empty state is displayed
**When** the user reads the content
**Then** a brief explanation should clarify:
- What documents go in this category
- Why it's useful to track them
- Example: "Les documents d'entretien vous aident à suivre l'historique de maintenance de votre véhicule"

### AC7: Empty State for Overview Tab (Optional)
**Given** the user has NO documents at all in any category
**When** the Overview tab is selected
**Then**
- A general welcome empty state should be displayed
- Message: "Bienvenue ! Ajoutez votre premier document pour commencer"
- Suggest exploring the tabs to see where different documents go

## Tasks / Subtasks

- [ ] **Task 1**: Create EmptyStateView Component (AC: #1, #2, #5, #6)
  - [ ] Subtask 1.1: Create `EmptyStateView.swift` in `SharedViews/`
  - [ ] Subtask 1.2: Accept parameters: title, description, examples, icon, ctaLabel, ctaAction
  - [ ] Subtask 1.3: Layout: Icon → Title → Description → Examples → CTA
  - [ ] Subtask 1.4: Use Design System tokens for spacing, typography, colors

- [ ] **Task 2**: Define Empty State Content Per Tab (AC: #2, #3, #6)
  - [ ] Subtask 2.1: Create `EmptyStateContent` struct or enum with tab-specific data
  - [ ] Subtask 2.2: Define titles, descriptions, examples, icons for each tab
  - [ ] Subtask 2.3: Localize strings (French for now)

- [ ] **Task 3**: Integrate Empty States into DocumentListView (AC: #1, #4)
  - [ ] Subtask 3.1: Update `DocumentListView` to show `EmptyStateView` when `documents.isEmpty`
  - [ ] Subtask 3.2: Pass tab-specific content to EmptyStateView
  - [ ] Subtask 3.3: Connect CTA to Quick Action logic (pre-select type and open AddDocumentView)

- [ ] **Task 4**: Create Overview Tab Welcome State (AC: #7)
  - [ ] Subtask 4.1: Create special empty state for Overview when no documents exist
  - [ ] Subtask 4.2: Add onboarding-style message
  - [ ] Subtask 4.3: Optionally add tips for exploring tabs

- [ ] **Task 5**: Visual Design and Refinement (AC: #5)
  - [ ] Subtask 5.1: Choose appropriate SF Symbols for each tab
  - [ ] Subtask 5.2: Apply proper sizing and colors
  - [ ] Subtask 5.3: Ensure layout works on different screen sizes

- [ ] **Task 6**: Accessibility Implementation
  - [ ] Subtask 6.1: Add `.accessibilityLabel()` to empty state content
  - [ ] Subtask 6.2: Ensure CTA button is accessible
  - [ ] Subtask 6.3: Test with VoiceOver

- [ ] **Task 7**: Test Empty State Display Logic
  - [ ] Subtask 7.1: Test empty state shows when no documents
  - [ ] Subtask 7.2: Test empty state hides when documents exist
  - [ ] Subtask 7.3: Test CTA opens AddDocumentView with correct type

## Dev Notes

### Architecture Context

**Dependencies on Previous Stories:**
- **Story 1.2**: Document filtering (determines when empty state should show)
- **Story 1.3**: Quick Actions (CTA reuses same navigation logic)

**Current State:**
- Simple "Aucun document" text when lists are empty (from Story 1.2)
- No guidance or examples for users
- No visual interest or welcoming tone

**Target State:**
- Rich, contextual empty states per tab
- Concrete examples guide users naturally
- CTA makes adding first document effortless
- "Learn by Doing" pattern: users learn by seeing examples and taking action

### UX Design Principles

From UX Design Specification:

**"Guidage Naturel, Pas de Tutoriel" - Learn by Doing**
- Empty states with examples transform each tab into a mini-tutorial
- User learns what goes where by seeing concrete examples
- No heavy onboarding needed
- "Ah ! C'est ici que va ma prochaine vidange"

**Welcoming Tone:**
- Not an error state (no red colors or alert icons)
- Positive framing: "Ajoutez votre premier..." (not "Vous n'avez aucun...")
- Encourages action rather than highlighting absence

### Empty State Content Data

**Create EmptyStateContent.swift:**
```swift
import SwiftUI

struct EmptyStateContent {
    let icon: String  // SF Symbol name
    let title: String
    let description: String
    let examples: [String]
    let ctaLabel: String

    static func content(for tab: VehicleDetailTabStore.Tab) -> EmptyStateContent? {
        switch tab {
        case .overview:
            return EmptyStateContent(
                icon: "doc.text",
                title: "Aucun Document",
                description: "Commencez par ajouter vos documents automobiles pour suivre l'historique de votre véhicule.",
                examples: [
                    "Explorez les onglets pour découvrir où ranger vos documents",
                    "Entretiens pour les vidanges et révisions",
                    "Administration pour carte grise et assurance",
                    "Carburant pour vos pleins d'essence"
                ],
                ctaLabel: "Ajouter un Document"
            )

        case .statistics:
            // Statistics tab doesn't have empty state (always shows some content)
            return nil

        case .maintenance:
            return EmptyStateContent(
                icon: "wrench.and.screwdriver",
                title: "Aucun Document d'Entretien",
                description: "Les documents d'entretien vous aident à suivre l'historique de maintenance de votre véhicule.",
                examples: [
                    "Vidange moteur",
                    "Changement pneus",
                    "Révision annuelle",
                    "Remplacement freins",
                    "Entretien climatisation"
                ],
                ctaLabel: "➕ Ajouter Votre Premier Entretien"
            )

        case .administration:
            return EmptyStateContent(
                icon: "doc.text.fill",
                title: "Aucun Document Administratif",
                description: "Gardez vos documents officiels accessibles et à jour pour éviter les mauvaises surprises.",
                examples: [
                    "Carte grise",
                    "Assurance auto",
                    "Contrôle technique",
                    "Certificat de cession"
                ],
                ctaLabel: "➕ Ajouter Votre Premier Document Admin"
            )

        case .fuel:
            return EmptyStateContent(
                icon: "fuelpump.fill",
                title: "Aucun Plein d'Essence",
                description: "Suivez vos dépenses de carburant pour mieux gérer votre budget automobile.",
                examples: [
                    "Pleins d'essence",
                    "Recharges électriques",
                    "Recharges hybrides",
                    "Suivi de consommation"
                ],
                ctaLabel: "➕ Ajouter Votre Premier Plein"
            )
        }
    }
}
```

### SwiftUI Component Structure

**EmptyStateView Component:**
```swift
import SwiftUI

struct EmptyStateView: View {
    let content: EmptyStateContent
    let onCTATapped: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: SpacingTokens.xl) {
                Spacer()

                // Icon
                Image(systemName: content.icon)
                    .font(.system(size: 56))
                    .foregroundColor(ColorTokens.secondary)
                    .accessibilityHidden(true)

                // Title
                Text(content.title)
                    .font(TypographyTokens.heading)
                    .foregroundColor(ColorTokens.primary)
                    .multilineTextAlignment(.center)

                // Description
                Text(content.description)
                    .font(TypographyTokens.body)
                    .foregroundColor(ColorTokens.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpacingTokens.xl)

                // Examples
                VStack(alignment: .leading, spacing: SpacingTokens.sm) {
                    ForEach(content.examples, id: \.self) { example in
                        HStack(alignment: .top, spacing: SpacingTokens.sm) {
                            Text("•")
                                .font(TypographyTokens.body)
                                .foregroundColor(ColorTokens.tertiary)
                            Text(example)
                                .font(TypographyTokens.bodySmall)
                                .foregroundColor(ColorTokens.tertiary)
                        }
                    }
                }
                .padding(.horizontal, SpacingTokens.xl)
                .padding(.vertical, SpacingTokens.md)
                .background(
                    RoundedRectangle(cornerRadius: RadiusTokens.md)
                        .fill(ColorTokens.backgroundSecondary)
                )
                .padding(.horizontal, SpacingTokens.xl)

                // CTA Button
                Button(action: onCTATapped) {
                    HStack(spacing: SpacingTokens.sm) {
                        Image(systemName: "plus.circle.fill")
                        Text(content.ctaLabel)
                            .font(TypographyTokens.bodyBold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, SpacingTokens.lg)
                    .padding(.vertical, SpacingTokens.md)
                    .background(ColorTokens.accent)
                    .cornerRadius(RadiusTokens.lg)
                }
                .accessibilityLabel(content.ctaLabel)
                .accessibilityHint("Ouvrir le formulaire d'ajout de document avec le type pré-sélectionné")
                .sensoryFeedback(.impact(weight: .light), trigger: content.ctaLabel)

                Spacer()
            }
            .padding(.vertical, SpacingTokens.xxl)
        }
    }
}
```

**Updated DocumentListView:**
```swift
import SwiftUI

struct DocumentListView: View {
    let documents: [Document]
    let tab: VehicleDetailTabStore.Tab
    let onAddDocument: () -> Void

    var body: some View {
        Group {
            if documents.isEmpty {
                if let emptyContent = EmptyStateContent.content(for: tab) {
                    EmptyStateView(
                        content: emptyContent,
                        onCTATapped: onAddDocument
                    )
                } else {
                    // Fallback for tabs without empty state (e.g., Statistics)
                    EmptyView()
                }
            } else {
                List(documents) { document in
                    NavigationLink {
                        DocumentDetailView(document: document)
                    } label: {
                        DocumentCard(document: document)
                    }
                    .listRowInsets(EdgeInsets(
                        top: SpacingTokens.sm,
                        leading: SpacingTokens.md,
                        bottom: SpacingTokens.sm,
                        trailing: SpacingTokens.md
                    ))
                }
                .listStyle(.plain)
            }
        }
    }
}
```

**VehicleDetailsView Integration:**
```swift
private struct TabContentView: View {
    let selectedTab: VehicleDetailTabStore.Tab
    let filteredDocuments: [Document]
    let vehicle: Vehicle
    let onAddDocument: () -> Void

    var body: some View {
        switch selectedTab {
        case .overview:
            DocumentListView(
                documents: filteredDocuments,
                tab: .overview,
                onAddDocument: onAddDocument
            )

        case .statistics:
            VehicleStatisticsView(vehicle: vehicle)

        case .maintenance:
            DocumentListView(
                documents: filteredDocuments,
                tab: .maintenance,
                onAddDocument: onAddDocument
            )

        case .administration:
            DocumentListView(
                documents: filteredDocuments,
                tab: .administration,
                onAddDocument: onAddDocument
            )

        case .fuel:
            DocumentListView(
                documents: filteredDocuments,
                tab: .fuel,
                onAddDocument: onAddDocument
            )
        }
    }
}
```

### Design System Tokens Usage

**Colors:**
- Icon: `ColorTokens.secondary` (not too bright, not too dull)
- Title: `ColorTokens.primary` (readable)
- Description: `ColorTokens.secondary`
- Examples: `ColorTokens.tertiary` (subtle)
- CTA: `ColorTokens.accent` with white text

**Spacing:**
- Between sections: `SpacingTokens.xl` (24pt)
- Icon to title: `SpacingTokens.xl`
- Examples list padding: `SpacingTokens.md`
- Horizontal padding: `SpacingTokens.xl`

**Typography:**
- Title: `TypographyTokens.heading` (bold, large)
- Description: `TypographyTokens.body` (regular)
- Examples: `TypographyTokens.bodySmall` (slightly smaller)
- CTA: `TypographyTokens.bodyBold`

**Radius:**
- Examples background: `RadiusTokens.md` (8pt)
- CTA button: `RadiusTokens.lg` (12pt)

### SF Symbols Selection

**Icons per Tab:**
- **Overview**: `doc.text` - Generic document
- **Maintenance**: `wrench.and.screwdriver` - Tools for maintenance
- **Administration**: `doc.text.fill` - Official documents
- **Fuel**: `fuelpump.fill` - Fuel pump

**Icon Styling:**
- Size: 56pt (large, prominent)
- Color: Secondary (not too bright)
- Rendering mode: Monochrome

### Integration Points

**Files to Create:**
1. **Create**: `SharedViews/EmptyStateView.swift`
   - Reusable empty state component
   - Accepts EmptyStateContent and CTA callback

2. **Create**: `Data/Models/EmptyStateContent.swift` or inline in EmptyStateView
   - Data structure for empty state content
   - Static method to get content for each tab

**Files to Modify:**
1. **Modify**: `SharedViews/DocumentListView.swift`
   - Add empty state logic
   - Pass tab type to get correct empty content
   - Connect CTA to parent action

2. **Modify**: `Stores/VehicleDetailsStore/VehicleDetailsView.swift`
   - Pass `onAddDocument` callback to DocumentListView
   - Ensure CTA reuses same navigation as Quick Actions

### Testing Strategy

**Unit Tests** (create `EmptyStateView_Spec.swift`):
```swift
import XCTest
import SwiftUI
import ViewInspector
@testable import Invoicer

final class EmptyStateView_Spec: XCTestCase {

    func test_emptyStateContent_maintenanceTab_returnsCorrectContent() {
        let content = EmptyStateContent.content(for: .maintenance)

        XCTAssertNotNil(content, "Maintenance tab should have empty state content")
        XCTAssertEqual(content?.title, "Aucun Document d'Entretien")
        XCTAssertTrue(content?.examples.contains("Vidange moteur") ?? false)
        XCTAssertEqual(content?.icon, "wrench.and.screwdriver")
    }

    func test_emptyStateContent_administrationTab_returnsCorrectContent() {
        let content = EmptyStateContent.content(for: .administration)

        XCTAssertNotNil(content, "Administration tab should have empty state content")
        XCTAssertEqual(content?.title, "Aucun Document Administratif")
        XCTAssertTrue(content?.examples.contains("Carte grise") ?? false)
    }

    func test_emptyStateContent_fuelTab_returnsCorrectContent() {
        let content = EmptyStateContent.content(for: .fuel)

        XCTAssertNotNil(content, "Fuel tab should have empty state content")
        XCTAssertEqual(content?.title, "Aucun Plein d'Essence")
        XCTAssertTrue(content?.examples.contains("Pleins d'essence") ?? false)
    }

    func test_emptyStateContent_statisticsTab_returnsNil() {
        let content = EmptyStateContent.content(for: .statistics)

        XCTAssertNil(content, "Statistics tab should not have empty state (read-only)")
    }

    func test_emptyStateView_ctaTapped_triggersCallback() throws {
        var ctaTapped = false
        let content = EmptyStateContent(
            icon: "doc",
            title: "Test",
            description: "Test description",
            examples: ["Example 1"],
            ctaLabel: "Add"
        )

        let view = EmptyStateView(
            content: content,
            onCTATapped: { ctaTapped = true }
        )

        // Note: This requires ViewInspector or UI testing
        // For unit tests, we primarily test the content logic
        XCTAssertNotNil(view, "EmptyStateView should be created")
    }
}
```

**UI Tests** (optional, in `InvoicerUITests`):
```swift
func test_emptyState_maintenanceTab_displayedWhenNoDocuments() {
    // Launch app with empty vehicle (no documents)
    app.launch()

    // Navigate to vehicle details
    app.buttons["Vehicle Name"].tap()

    // Switch to Maintenance tab
    app.buttons["Entretiens & Réparations"].tap()

    // Verify empty state is displayed
    XCTAssertTrue(app.staticTexts["Aucun Document d'Entretien"].exists)
    XCTAssertTrue(app.staticTexts["Vidange moteur"].exists)
    XCTAssertTrue(app.buttons["➕ Ajouter Votre Premier Entretien"].exists)
}
```

### Critical Constraints from CLAUDE.md

**MUST Follow:**
1. ✅ **Swift 6** syntax
2. ✅ **Design System tokens** for all styling
3. ✅ **Accessibility** with labels and hints
4. ✅ **French language** for all user-facing text
5. ✅ **Reusable components** in SharedViews/
6. ✅ **No hard-coded colors** or spacing

### Apple HIG Consultation

**Before implementing, consult HIG:**
```
use context7 /apple/human-interface-guidelines empty states
use context7 /apple/human-interface-guidelines onboarding
use context7 /apple/human-interface-guidelines sf symbols
```

**Key HIG Principles:**
- Empty states should be informative, not alarming
- Use clear, encouraging language
- Provide actionable next steps
- SF Symbols should match the context

### Edge Cases to Handle

1. **Very long examples list**: Use ScrollView if needed (already in EmptyStateView)
2. **Small screen sizes**: Ensure content doesn't overflow (test on iPhone SE)
3. **Dark Mode**: Ensure colors work in both light and dark
4. **VoiceOver**: Ensure all content is accessible
5. **Localization**: Prepare for future translations (use string keys)

### Previous Stories Intelligence

**Story 1.2 Context:**
- Document filtering determines when to show empty states
- Empty list detection logic already in place

**Story 1.3 Context:**
- Quick Actions navigation logic
- CTA in empty states reuses same mechanism

**Building On:**
- Empty states complete the "Learn by Doing" pattern
- Users guided naturally through examples
- CTA makes adding first document effortless

### References

**PRD Context:**
- [Source: _bmad-output/planning-artifacts/prd.md#MVP - Empty States Explicatifs FR16-FR21]
- [Source: _bmad-output/planning-artifacts/prd.md#User Journeys - Thomas persona discovering organization]

**UX Design Context:**
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Experience Principles - Guidage Naturel]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Critical Success Moments - Guidage par Empty State]

**Architecture Context:**
- [Source: CLAUDE.md#Design System]
- [Source: CLAUDE.md#Structure du Projet - SharedViews/]

**Dependencies:**
- Story 1.2: Document Filtering by Tab (determines empty state display)
- Story 1.3: Contextual Quick Actions (CTA navigation logic)

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

### Debug Log References

_To be filled during implementation_

### Completion Notes List

_To be filled during implementation_

### File List

_To be filled during implementation_
