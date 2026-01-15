# Story 1.1: Custom Segmented Control Component

Status: ready-for-dev

## Story

As a **user managing vehicle documents**,
I want **a custom segmented control with 5 themed tabs in the vehicle details view**,
so that **I can navigate between different document categories instantly without scrolling through a long mixed list**.

## Acceptance Criteria

### AC1: Five Themed Tabs Display
**Given** the user opens a vehicle details view
**When** the view loads
**Then** 5 tabs should be visible with correct labels and icons:
- 📋 **Vue d'Ensemble** (Overview) - default selected
- 📊 **Statistiques** (Statistics)
- 🔧 **Entretiens & Réparations** (Maintenance & Repairs)
- 🏛️ **Administration** (Administrative)
- ⛽ **Carburant** (Fuel)

### AC2: Tab Selection and Visual State
**Given** the segmented control is displayed
**When** the user taps on any tab
**Then**
- The tapped tab should show active state (Design System: AccentLabel or equivalent)
- The previously active tab should return to inactive state
- Tab change should complete in < 100ms

### AC3: Default Tab Selection
**Given** the user navigates to vehicle details for the first time
**When** the view appears
**Then** the "Vue d'Ensemble" (Overview) tab should be selected by default

### AC4: Scroll Independence per Tab
**Given** the user has scrolled within a tab's content
**When** the user switches to another tab and then returns
**Then** the scroll position should be preserved for each tab independently

### AC5: Accessible Navigation
**Given** VoiceOver is enabled
**When** the user navigates the segmented control
**Then**
- Each tab should announce its name clearly
- Selected tab state should be announced
- Tab changes should be announced

## Tasks / Subtasks

- [ ] **Task 1**: Create Custom Segmented Control SwiftUI Component (AC: #1, #2, #3)
  - [ ] Subtask 1.1: Create `CustomSegmentedControl.swift` in `UI/Components/`
  - [ ] Subtask 1.2: Define tab enum with 5 cases (Overview, Statistics, Maintenance, Admin, Fuel)
  - [ ] Subtask 1.3: Implement tab button UI with icon + label
  - [ ] Subtask 1.4: Apply Design System tokens (AccentLabel for active, SecondaryLabel for inactive)
  - [ ] Subtask 1.5: Implement tap gesture handling with haptic feedback

- [ ] **Task 2**: Create VehicleDetailTabStore TCA Store (AC: #1, #2, #3, #4)
  - [ ] Subtask 2.1: Create `VehicleDetailTabStore.swift` in `Stores/VehicleDetailTabStore/`
  - [ ] Subtask 2.2: Define State with `selectedTab` property
  - [ ] Subtask 2.3: Define Actions for tab selection (`tabSelected(Tab)`)
  - [ ] Subtask 2.4: Implement Reducer to handle tab changes
  - [ ] Subtask 2.5: Add scroll position tracking per tab (optional for MVP)

- [ ] **Task 3**: Integrate into VehicleDetailsStore (AC: #1, #2, #3)
  - [ ] Subtask 3.1: Add `VehicleDetailTabStore` as child reducer
  - [ ] Subtask 3.2: Update `VehicleDetailsView` to use `CustomSegmentedControl`
  - [ ] Subtask 3.3: Connect tab selection to content display (next stories will implement filtering)

- [ ] **Task 4**: Accessibility Implementation (AC: #5)
  - [ ] Subtask 4.1: Add `.accessibilityLabel()` to each tab button
  - [ ] Subtask 4.2: Add `.accessibilityHint()` for tab actions
  - [ ] Subtask 4.3: Add `.accessibilityAddTraits(.isSelected)` for active tab
  - [ ] Subtask 4.4: Test with VoiceOver

- [ ] **Task 5**: Performance Validation (AC: #2)
  - [ ] Subtask 5.1: Measure tab change latency with Instruments
  - [ ] Subtask 5.2: Optimize if needed to ensure < 100ms
  - [ ] Subtask 5.3: Profile memory usage during tab switching

- [ ] **Task 6**: Unit Tests for VehicleDetailTabStore
  - [ ] Subtask 6.1: Test initial state (Overview tab selected)
  - [ ] Subtask 6.2: Test tab selection changes state
  - [ ] Subtask 6.3: Test scroll position preservation per tab

## Dev Notes

### Architecture Context

**Current State:**
- `VehicleDetailsStore` currently displays a single scrollable list of all documents mixed together
- User has to scroll through potentially 50+ documents to find what they need
- No thematic organization or filtering

**Target State:**
- Custom Segmented Control at top of VehicleDetailsView
- 5 tabs with themed navigation
- Content below segmented control changes based on selected tab
- Foundation for future stories (filtering, quick actions, empty states)

### Design System Integration

**Tokens to Use:**
- **ColorTokens**:
  - Active tab: Use `AccentLabel` or equivalent accent color
  - Inactive tab: Use `SecondaryLabel`
- **SpacingTokens**:
  - Tab button padding: Use `SpacingTokens.md` (medium)
  - Between tabs: Use `SpacingTokens.sm` (small)
- **TypographyTokens**:
  - Tab labels: Use body font style
  - Active tab: Bold weight
- **RadiusTokens**:
  - Tab button corners: Use `RadiusTokens.md` if rounded design chosen

**Consult Apple HIG:**
```
use context7 /apple/human-interface-guidelines segmented controls
use context7 /apple/human-interface-guidelines tab bars
```

### TCA Architecture Pattern

**Store Composition:**
```swift
struct VehicleDetailTabStore: Reducer {
    enum Tab: String, CaseIterable, Sendable {
        case overview = "Vue d'Ensemble"
        case statistics = "Statistiques"
        case maintenance = "Entretiens & Réparations"
        case administration = "Administration"
        case fuel = "Carburant"

        var icon: String {
            switch self {
            case .overview: return "📋"
            case .statistics: return "📊"
            case .maintenance: return "🔧"
            case .administration: return "🏛️"
            case .fuel: return "⛽"
            }
        }
    }

    struct State: Equatable {
        var selectedTab: Tab = .overview
        var scrollPositions: [Tab: CGFloat] = [:]  // Optional for MVP
    }

    enum Action: Equatable {
        case tabSelected(Tab)
        case scrollPositionChanged(Tab, CGFloat)  // Optional for MVP
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .tabSelected(tab):
                state.selectedTab = tab
                return .none

            case let .scrollPositionChanged(tab, position):
                state.scrollPositions[tab] = position
                return .none
            }
        }
    }
}
```

**Integration into VehicleDetailsStore:**
```swift
struct VehicleDetailsStore: Reducer {
    struct State: Equatable {
        // ... existing properties
        var tabStore: VehicleDetailTabStore.State = .init()
    }

    enum Action: Equatable {
        // ... existing actions
        case tabStore(VehicleDetailTabStore.Action)
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.tabStore, action: /Action.tabStore) {
            VehicleDetailTabStore()
        }

        Reduce { state, action in
            // ... existing logic
        }
    }
}
```

### SwiftUI Component Structure

**CustomSegmentedControl.swift:**
```swift
import SwiftUI
import ComposableArchitecture

struct CustomSegmentedControl: View {
    let store: StoreOf<VehicleDetailTabStore>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack(spacing: SpacingTokens.sm) {
                ForEach(VehicleDetailTabStore.Tab.allCases, id: \.self) { tab in
                    TabButton(
                        tab: tab,
                        isSelected: viewStore.selectedTab == tab,
                        action: { viewStore.send(.tabSelected(tab)) }
                    )
                }
            }
            .padding(.horizontal, SpacingTokens.md)
        }
    }
}

private struct TabButton: View {
    let tab: VehicleDetailTabStore.Tab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SpacingTokens.xs) {
                Text(tab.icon)
                Text(tab.rawValue)
                    .font(isSelected ? .body.bold() : .body)
            }
            .foregroundColor(isSelected ? ColorTokens.accent : ColorTokens.secondary)
            .padding(.vertical, SpacingTokens.sm)
            .padding(.horizontal, SpacingTokens.md)
            .background(
                isSelected ? ColorTokens.accentBackground : Color.clear
            )
            .cornerRadius(RadiusTokens.md)
        }
        .accessibilityLabel(tab.rawValue)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .sensoryFeedback(.selection, trigger: isSelected)  // Haptic feedback
    }
}
```

### Performance Requirements

**Critical Performance Targets:**
- Tab change latency: **< 100ms** (PRD requirement)
- Scroll performance: **60 FPS** with up to 100 documents per tab
- Memory: No leaks during tab switching

**Validation:**
- Use Instruments to profile Time Profiler
- Measure from tap to UI update completion
- Test with large document datasets (50-100 documents)

### Integration Points

**Files to Modify:**
1. **Create**: `UI/Components/CustomSegmentedControl.swift`
2. **Create**: `Stores/VehicleDetailTabStore/VehicleDetailTabStore.swift`
3. **Modify**: `Stores/VehicleDetailsStore/VehicleDetailsStore.swift`
4. **Modify**: `Stores/VehicleDetailsStore/VehicleDetailsView.swift`

**Dependencies:**
- No new dependencies required
- Uses existing Design System tokens
- Integrates with TCA 1.22.2+

### Testing Strategy

**Unit Tests** (create `VehicleDetailTabStore_Spec.swift`):
```swift
func test_tabSelected_changesSelectedTab() async {
    let store = TestStore(
        initialState: VehicleDetailTabStore.State(),
        reducer: { VehicleDetailTabStore() }
    )

    await store.send(.tabSelected(.statistics)) {
        $0.selectedTab = .statistics
    }
}

func test_initialState_overviewTabSelected() {
    let state = VehicleDetailTabStore.State()
    XCTAssertEqual(state.selectedTab, .overview)
}
```

### Critical Constraints from CLAUDE.md

**MUST Follow:**
1. ✅ **Swift 6** syntax and strict concurrency
2. ✅ **No `try!`** in app code (only in tests)
3. ✅ **Use Context7** to consult Apple HIG before implementing UI
4. ✅ **Design System tokens** for all styling (no hard-coded colors/spacing)
5. ✅ **TCA pattern** with State/Action/Reducer
6. ✅ **Test pattern**: Given-When-Then with helpers `given`, `when`, `then`
7. ✅ **Logging**: Use emoji conventions (🚀 Init, ✅ Success, ❌ Error)

### UX Principles to Respect

From UX Design Specification:

**1. "Je sais exactement où c'est" - Organization Mentale Claire**
- Tab labels must be immediately understandable
- Active tab state must be ultra-clear visually
- No cognitive load to find the right tab

**2. "Instantané et Fluide" - Performance Perçue**
- Tab change **< 100ms** to reinforce confidence
- No lag that breaks mental fluidity
- Smooth animations (if any)

**3. "Guidage Naturel, Pas de Tutoriel" - Learn by Doing**
- Tab names and icons must be self-explanatory
- No tutorial needed to understand navigation
- Visual hierarchy guides the eye naturally

### Project Structure Notes

**Alignment with Project Structure:**
- Stores follow pattern: `Stores/[StoreName]/[StoreName].swift`
- Components in `UI/Components/` or `SharedViews/` depending on reusability
- Design System tokens located in `UI/DesignSystem/Tokens/`
- Tests in `InvoicerTests/Stores/` with `_Spec` suffix

**Recent Context from Git:**
Recent commits show project renaming from "Invoicer" to "Holfy":
- `96ff8fd`: Fix migration timing
- `a8bfde6`: Rename Vehicles→Holfy + migrate vehicles.json
- `c3c18af`: Complete legacy migration with folder copy
- `88235ca`: Rename user storage folder "Vehicles" to "Holfy"
- `d89f91d`: Rename app folder Invoicer to Holfy

**Note**: Code still uses "Invoicer" naming internally (bundle ID, folders). New components should follow established patterns.

### References

**PRD Context:**
- [Source: _bmad-output/planning-artifacts/prd.md#MVP - Minimum Viable Product]
- [Source: _bmad-output/planning-artifacts/prd.md#Functional Requirements - FR1 to FR5]

**Architecture Context:**
- [Source: docs/architecture.md#State Management]
- [Source: docs/architecture.md#Design System]

**UX Design Context:**
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Core User Experience]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Experience Principles]

**Project Conventions:**
- [Source: CLAUDE.md#Pattern Principal : Composable Architecture (TCA)]
- [Source: CLAUDE.md#Design System]
- [Source: CLAUDE.md#Conventions de Tests Unitaires]

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

### Debug Log References

_To be filled during implementation_

### Completion Notes List

_To be filled during implementation_

### File List

_To be filled during implementation_
