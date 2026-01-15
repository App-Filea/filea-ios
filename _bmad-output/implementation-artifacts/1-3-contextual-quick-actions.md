# Story 1.3: Contextual Quick Actions

Status: ready-for-dev

## Story

As a **user wanting to add documents quickly**,
I want **a contextual "Add" button that pre-selects the document type based on the active tab**,
so that **I can add documents without friction cognitive ("quel type dois-je choisir ?")**  and save time.

## Acceptance Criteria

### AC1: Quick Action Button Displayed Per Tab
**Given** the user is on any document-listing tab (Maintenance, Administration, Fuel)
**When** the tab content is displayed
**Then**
- A floating action button (FAB) or prominent "Add" button should be visible
- Button label should be contextual: "➕ Ajouter Entretien", "➕ Ajouter Document Admin", "➕ Ajouter Plein"
- Button should use Design System AccentButton style

### AC2: No Quick Action for Read-Only Tabs
**Given** the user is on Overview or Statistics tab
**When** the tab content is displayed
**Then**
- No Quick Action button should be visible (read-only tabs)
- User can still add documents via main navigation if needed

### AC3: Pre-Selected Document Type on Quick Action
**Given** the user is on Maintenance tab
**When** they tap "➕ Ajouter Entretien"
**Then**
- AddDocumentStore should open with document type pre-selected to `maintenance`
- User should not see document type picker (or it's disabled/hidden)
- Date should be pre-filled to today
- Kilométrage should be pre-filled to last known vehicle mileage

### AC4: Pre-Selected Type for Administration Tab
**Given** the user is on Administration tab
**When** they tap "➕ Ajouter Document Admin"
**Then**
- AddDocumentStore should open with document type pre-selected to `administrative`
- User proceeds directly to filling document details

### AC5: Pre-Selected Type for Fuel Tab
**Given** the user is on Carburant tab
**When** they tap "➕ Ajouter Plein"
**Then**
- AddDocumentStore should open with document type pre-selected to `fuel`
- User proceeds directly to filling fuel details

### AC6: Haptic Feedback on Quick Action Tap
**Given** the user taps any Quick Action button
**When** the tap is registered
**Then**
- Haptic feedback should be triggered (light impact)
- Reinforces action confirmation

### AC7: Navigation to AddDocumentView
**Given** the user taps a Quick Action button
**When** the action is processed
**Then**
- User should navigate to AddDocumentView
- Navigation should be smooth (< 100ms)
- Back button should return to the same tab they came from

## Tasks / Subtasks

- [ ] **Task 1**: Extend VehicleDetailTabStore with Quick Action Logic (AC: #1, #2)
  - [ ] Subtask 1.1: Add computed property `quickActionLabel` that returns contextual label or nil
  - [ ] Subtask 1.2: Add computed property `preSelectedDocumentType` for each tab
  - [ ] Subtask 1.3: Add action `quickActionTapped` to trigger document addition

- [ ] **Task 2**: Create QuickActionButton Component (AC: #1, #6)
  - [ ] Subtask 2.1: Create `QuickActionButton.swift` in `UI/Components/`
  - [ ] Subtask 2.2: Use AccentButton style from Design System
  - [ ] Subtask 2.3: Add haptic feedback with `.sensoryFeedback()`
  - [ ] Subtask 2.4: Make button prominent (floating or bottom-anchored)

- [ ] **Task 3**: Integrate Quick Action into VehicleDetailsView (AC: #1, #2, #7)
  - [ ] Subtask 3.1: Add QuickActionButton to each document-listing tab
  - [ ] Subtask 3.2: Hide button for Overview and Statistics tabs
  - [ ] Subtask 3.3: Position button strategically (bottom-right FAB or bottom toolbar)

- [ ] **Task 4**: Connect Quick Action to AddDocumentStore (AC: #3, #4, #5, #7)
  - [ ] Subtask 4.1: Add navigation action in VehicleDetailsStore for adding document
  - [ ] Subtask 4.2: Pass pre-selected document type to AddDocumentStore
  - [ ] Subtask 4.3: Update AddDocumentStore to accept pre-selected type
  - [ ] Subtask 4.4: Hide or disable document type picker when pre-selected

- [ ] **Task 5**: Pre-Fill Smart Defaults (AC: #3)
  - [ ] Subtask 5.1: Pre-fill date to today's date
  - [ ] Subtask 5.2: Pre-fill kilométrage to vehicle's last known mileage
  - [ ] Subtask 5.3: Make pre-filled fields editable (user can override)

- [ ] **Task 6**: Test Navigation Flow (AC: #7)
  - [ ] Subtask 6.1: Test navigation from each tab to AddDocumentView
  - [ ] Subtask 6.2: Test back navigation returns to correct tab
  - [ ] Subtask 6.3: Verify tab state preserved after adding document

- [ ] **Task 7**: Unit Tests for Quick Actions
  - [ ] Subtask 7.1: Test `quickActionLabel` returns correct label per tab
  - [ ] Subtask 7.2: Test `preSelectedDocumentType` returns correct type
  - [ ] Subtask 7.3: Test quick action triggers navigation with correct type
  - [ ] Subtask 7.4: Test no quick action for Overview/Statistics tabs

## Dev Notes

### Architecture Context

**Dependencies on Previous Stories:**
- **Story 1.1**: Custom Segmented Control with tab selection
- **Story 1.2**: Document filtering by tab (understanding of tab types)

**Current State:**
- User can navigate between tabs
- Documents are filtered by tab
- To add a document, user must go through main navigation and select type manually

**Target State:**
- Quick Action button visible on each document-listing tab
- Tap button → AddDocumentView opens with type pre-selected
- 30% reduction in time to add document (UX goal from PRD)
- No friction cognitive: "quel type dois-je choisir ?"

### TCA Store Extension

**Extend VehicleDetailTabStore:**
```swift
extension VehicleDetailTabStore {
    struct State: Equatable {
        var selectedTab: Tab = .overview
        var scrollPositions: [Tab: CGFloat] = [:]

        // Quick Action computed properties
        var quickActionLabel: String? {
            switch selectedTab {
            case .overview, .statistics:
                return nil  // Read-only tabs, no quick action
            case .maintenance:
                return "➕ Ajouter Entretien"
            case .administration:
                return "➕ Ajouter Document Admin"
            case .fuel:
                return "➕ Ajouter Plein"
            }
        }

        var preSelectedDocumentType: DocumentType? {
            switch selectedTab {
            case .overview, .statistics:
                return nil
            case .maintenance:
                return .maintenance  // Note: could be .maintenance or .repair
            case .administration:
                return .administrative
            case .fuel:
                return .fuel
            }
        }

        var showsQuickAction: Bool {
            quickActionLabel != nil
        }
    }

    enum Action: Equatable {
        case tabSelected(Tab)
        case scrollPositionChanged(Tab, CGFloat)
        case quickActionTapped
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

            case .quickActionTapped:
                // Parent store will handle navigation
                return .none
            }
        }
    }
}
```

**VehicleDetailsStore Integration:**
```swift
struct VehicleDetailsStore: Reducer {
    struct State: Equatable {
        var vehicle: Vehicle
        var documents: [Document]
        var tabStore: VehicleDetailTabStore.State = .init()

        // Navigation state
        @PresentationState var addDocumentStore: AddDocumentStore.State?

        var filteredDocuments: [Document] {
            tabStore.filteredDocuments(from: documents)
        }
    }

    enum Action: Equatable {
        case tabStore(VehicleDetailTabStore.Action)
        case documentsLoaded([Document])
        case addDocumentStore(PresentationAction<AddDocumentStore.Action>)
        case addDocumentButtonTapped
        // ... other actions
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.tabStore, action: /Action.tabStore) {
            VehicleDetailTabStore()
        }

        Reduce { state, action in
            switch action {
            case .tabStore(.quickActionTapped):
                // User tapped quick action - navigate to AddDocumentStore
                return .send(.addDocumentButtonTapped)

            case .addDocumentButtonTapped:
                // Open AddDocumentStore with pre-selected type
                let preSelectedType = state.tabStore.preSelectedDocumentType
                state.addDocumentStore = AddDocumentStore.State(
                    vehicleId: state.vehicle.id,
                    preSelectedType: preSelectedType,
                    preFilledDate: Date(),  // Today
                    preFilledMileage: state.vehicle.mileage  // Last known
                )
                return .none

            case .addDocumentStore(.presented(.documentSaved)):
                // Document saved, dismiss and reload
                state.addDocumentStore = nil
                return .run { [vehicleId = state.vehicle.id] send in
                    let documents = try await documentRepository.fetchDocuments(for: vehicleId)
                    await send(.documentsLoaded(documents))
                }

            case .addDocumentStore:
                return .none

            // ... other actions
            }
        }
        .ifLet(\.$addDocumentStore, action: /Action.addDocumentStore) {
            AddDocumentStore()
        }
    }
}
```

**AddDocumentStore Extension:**
```swift
extension AddDocumentStore {
    struct State: Equatable {
        var vehicleId: UUID
        var documentType: DocumentType?  // Optional, can be pre-selected
        var preSelectedType: DocumentType?  // Indicates if type was pre-selected
        var date: Date = Date()
        var mileage: String?
        var title: String = ""
        var amount: String = ""
        // ... other fields

        var isTypePickerDisabled: Bool {
            preSelectedType != nil
        }

        init(
            vehicleId: UUID,
            preSelectedType: DocumentType? = nil,
            preFilledDate: Date = Date(),
            preFilledMileage: String? = nil
        ) {
            self.vehicleId = vehicleId
            self.preSelectedType = preSelectedType
            self.documentType = preSelectedType  // Pre-select if provided
            self.date = preFilledDate
            self.mileage = preFilledMileage
        }
    }

    // ... existing actions and reducer
}
```

### SwiftUI Component Structure

**QuickActionButton Component:**
```swift
import SwiftUI
import ComposableArchitecture

struct QuickActionButton: View {
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            HStack(spacing: SpacingTokens.sm) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text(label)
                    .font(TypographyTokens.bodyBold)
            }
            .foregroundColor(.white)
            .padding(.horizontal, SpacingTokens.lg)
            .padding(.vertical, SpacingTokens.md)
            .background(ColorTokens.accent)
            .cornerRadius(RadiusTokens.lg)
            .shadow(
                color: Color.black.opacity(0.2),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .sensoryFeedback(.impact(weight: .light), trigger: label)
        .accessibilityLabel(label)
        .accessibilityHint("Ajouter un nouveau document avec le type pré-sélectionné")
    }
}
```

**VehicleDetailsView Integration:**
```swift
struct VehicleDetailsView: View {
    let store: StoreOf<VehicleDetailsStore>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing: 0) {
                    // Custom Segmented Control
                    CustomSegmentedControl(
                        store: store.scope(
                            state: \.tabStore,
                            action: VehicleDetailsStore.Action.tabStore
                        )
                    )
                    .padding(.vertical, SpacingTokens.md)

                    // Tab Content
                    TabContentView(
                        selectedTab: viewStore.tabStore.selectedTab,
                        filteredDocuments: viewStore.filteredDocuments,
                        vehicle: viewStore.vehicle
                    )
                }

                // Quick Action Button (floating bottom-right)
                if let quickActionLabel = viewStore.tabStore.quickActionLabel {
                    QuickActionButton(label: quickActionLabel) {
                        viewStore.send(.tabStore(.quickActionTapped))
                    }
                    .padding(.trailing, SpacingTokens.lg)
                    .padding(.bottom, SpacingTokens.xl)
                }
            }
            .navigationTitle(viewStore.vehicle.displayName)
            .sheet(
                store: store.scope(
                    state: \.$addDocumentStore,
                    action: { .addDocumentStore($0) }
                )
            ) { addDocumentStore in
                AddDocumentView(store: addDocumentStore)
            }
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}
```

**AddDocumentView Updates:**
```swift
struct AddDocumentView: View {
    let store: StoreOf<AddDocumentStore>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    // Document Type Picker
                    Section("Type de Document") {
                        if viewStore.isTypePickerDisabled {
                            // Show read-only type when pre-selected
                            HStack {
                                Text("Type")
                                Spacer()
                                Text(viewStore.documentType?.displayName ?? "")
                                    .foregroundColor(ColorTokens.secondary)
                            }
                        } else {
                            // Show picker if not pre-selected
                            Picker("Type", selection: viewStore.binding(\.$documentType)) {
                                ForEach(DocumentType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type as DocumentType?)
                                }
                            }
                        }
                    }

                    // Date (pre-filled to today)
                    Section("Date") {
                        DatePicker(
                            "Date",
                            selection: viewStore.binding(\.$date),
                            displayedComponents: .date
                        )
                    }

                    // Mileage (pre-filled to vehicle's last known)
                    Section("Kilométrage") {
                        TextField(
                            "Kilométrage",
                            text: viewStore.binding(\.$mileage).withDefault("")
                        )
                        .keyboardType(.numberPad)
                    }

                    // ... other fields
                }
                .navigationTitle("Ajouter Document")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Annuler") {
                            viewStore.send(.cancelButtonTapped)
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Sauvegarder") {
                            viewStore.send(.saveButtonTapped)
                        }
                        .disabled(!viewStore.isFormValid)
                    }
                }
            }
        }
    }
}

// Helper extension
extension Binding where Value == String? {
    func withDefault(_ defaultValue: String) -> Binding<String> {
        Binding<String>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0.isEmpty ? nil : $0 }
        )
    }
}
```

### UX Design Principles

From UX Design Specification:

**"Ajout sans friction cognitive" - Scan Intelligent et Contexte**
- Quick Actions eliminate the mental question: "Quel type dois-je choisir ?"
- Type is already selected based on context (current tab)
- User proceeds directly to filling details
- **Goal**: 30% reduction in time to add document

**Smart Pre-Filling:**
- Date pre-filled to today (most common case)
- Kilométrage pre-filled to vehicle's last known value
- User can override if needed (flexibility)

**Contextual Labels:**
- "➕ Ajouter Entretien" (not generic "Ajouter Document")
- Clear, specific action label
- Matches user's mental model

### Performance Requirements

**Interaction Performance:**
- Tap to sheet presentation: < 100ms
- Haptic feedback: immediate (< 50ms)
- Smooth animation for sheet appearance

**Memory:**
- No memory leaks from repeated Quick Action usage
- AddDocumentStore properly dismissed and deallocated

### Integration Points

**Files to Modify:**
1. **Modify**: `Stores/VehicleDetailTabStore/VehicleDetailTabStore.swift`
   - Add `quickActionLabel`, `preSelectedDocumentType`, `showsQuickAction` computed properties
   - Add `quickActionTapped` action

2. **Modify**: `Stores/VehicleDetailsStore/VehicleDetailsStore.swift`
   - Add `@PresentationState var addDocumentStore`
   - Add `addDocumentButtonTapped` action
   - Add navigation logic to AddDocumentStore
   - Add `.ifLet` for AddDocumentStore presentation

3. **Modify**: `Stores/VehicleDetailsStore/VehicleDetailsView.swift`
   - Add `QuickActionButton` in ZStack
   - Add `.sheet` for AddDocumentView presentation
   - Position button floating bottom-right

4. **Create**: `UI/Components/QuickActionButton.swift`
   - Reusable Quick Action button component
   - AccentButton style with shadow
   - Haptic feedback integration

5. **Modify**: `Stores/AddDocumentStore/AddDocumentStore.swift`
   - Add `preSelectedType` parameter to State init
   - Add `isTypePickerDisabled` computed property
   - Pre-fill date and mileage in init

6. **Modify**: `Stores/AddDocumentStore/AddDocumentView.swift`
   - Show read-only type when pre-selected
   - Or hide type picker completely

### Testing Strategy

**Unit Tests** (create `VehicleDetailTabStore_QuickActionsSpec.swift`):
```swift
import XCTest
import ComposableArchitecture
@testable import Invoicer

final class VehicleDetailTabStore_QuickActionsSpec: XCTestCase {

    func test_quickActionLabel_maintenanceTab_returnsCorrectLabel() {
        let state = VehicleDetailTabStore.State(selectedTab: .maintenance)

        XCTAssertEqual(
            state.quickActionLabel,
            "➕ Ajouter Entretien",
            "Maintenance tab should have contextual quick action"
        )
    }

    func test_quickActionLabel_administrationTab_returnsCorrectLabel() {
        let state = VehicleDetailTabStore.State(selectedTab: .administration)

        XCTAssertEqual(
            state.quickActionLabel,
            "➕ Ajouter Document Admin",
            "Administration tab should have contextual quick action"
        )
    }

    func test_quickActionLabel_fuelTab_returnsCorrectLabel() {
        let state = VehicleDetailTabStore.State(selectedTab: .fuel)

        XCTAssertEqual(
            state.quickActionLabel,
            "➕ Ajouter Plein",
            "Fuel tab should have contextual quick action"
        )
    }

    func test_quickActionLabel_overviewTab_returnsNil() {
        let state = VehicleDetailTabStore.State(selectedTab: .overview)

        XCTAssertNil(
            state.quickActionLabel,
            "Overview tab is read-only, should have no quick action"
        )
    }

    func test_quickActionLabel_statisticsTab_returnsNil() {
        let state = VehicleDetailTabStore.State(selectedTab: .statistics)

        XCTAssertNil(
            state.quickActionLabel,
            "Statistics tab is read-only, should have no quick action"
        )
    }

    func test_preSelectedDocumentType_maintenanceTab_returnsMaintenance() {
        let state = VehicleDetailTabStore.State(selectedTab: .maintenance)

        XCTAssertEqual(
            state.preSelectedDocumentType,
            .maintenance,
            "Maintenance tab should pre-select maintenance type"
        )
    }

    func test_preSelectedDocumentType_administrationTab_returnsAdministrative() {
        let state = VehicleDetailTabStore.State(selectedTab: .administration)

        XCTAssertEqual(
            state.preSelectedDocumentType,
            .administrative,
            "Administration tab should pre-select administrative type"
        )
    }

    func test_preSelectedDocumentType_fuelTab_returnsFuel() {
        let state = VehicleDetailTabStore.State(selectedTab: .fuel)

        XCTAssertEqual(
            state.preSelectedDocumentType,
            .fuel,
            "Fuel tab should pre-select fuel type"
        )
    }

    func test_showsQuickAction_maintenanceTab_returnsTrue() {
        let state = VehicleDetailTabStore.State(selectedTab: .maintenance)

        XCTAssertTrue(
            state.showsQuickAction,
            "Maintenance tab should show quick action"
        )
    }

    func test_showsQuickAction_overviewTab_returnsFalse() {
        let state = VehicleDetailTabStore.State(selectedTab: .overview)

        XCTAssertFalse(
            state.showsQuickAction,
            "Overview tab should not show quick action"
        )
    }
}
```

**Integration Tests** (in `VehicleDetailsStore_Spec.swift`):
```swift
func test_quickActionTapped_opensAddDocumentStoreWithPreSelectedType() async {
    let vehicle = Vehicle.make(id: UUID(0), mileage: "50000")
    let store = TestStore(
        initialState: VehicleDetailsStore.State(
            vehicle: vehicle,
            documents: [],
            tabStore: VehicleDetailTabStore.State(selectedTab: .maintenance)
        ),
        reducer: { VehicleDetailsStore() }
    )

    await store.send(.tabStore(.quickActionTapped))
    await store.send(.addDocumentButtonTapped) {
        $0.addDocumentStore = AddDocumentStore.State(
            vehicleId: UUID(0),
            preSelectedType: .maintenance,
            preFilledDate: Date(),
            preFilledMileage: "50000"
        )
    }

    // Verify state
    XCTAssertNotNil(store.state.addDocumentStore, "AddDocumentStore should be presented")
    XCTAssertEqual(
        store.state.addDocumentStore?.preSelectedType,
        .maintenance,
        "Document type should be pre-selected to maintenance"
    )
    XCTAssertEqual(
        store.state.addDocumentStore?.mileage,
        "50000",
        "Mileage should be pre-filled from vehicle"
    )
}
```

### Critical Constraints from CLAUDE.md

**MUST Follow:**
1. ✅ **Swift 6** syntax with strict concurrency
2. ✅ **TCA presentation pattern** with `@PresentationState` and `.ifLet`
3. ✅ **Design System AccentButton** for Quick Action
4. ✅ **Haptic feedback** with `.sensoryFeedback()`
5. ✅ **Accessibility** with labels and hints
6. ✅ **No `try!`** in app code
7. ✅ **Test pattern** with Given-When-Then

### Apple HIG Consultation

**Before implementing, consult HIG:**
```
use context7 /apple/human-interface-guidelines floating action buttons
use context7 /apple/human-interface-guidelines buttons best practices
use context7 /apple/human-interface-guidelines haptic feedback
```

**Key HIG Principles:**
- FAB placement: Bottom-right corner (avoid navigation areas)
- Touch target size: Minimum 44×44 points
- Haptic feedback: Light impact for non-destructive actions
- Shadow for elevation: Creates visual hierarchy

### Edge Cases to Handle

1. **Vehicle with no mileage**: Pre-fill mileage field as empty (optional field)
2. **Quick Action during document loading**: Disable button until documents loaded
3. **Multiple rapid taps**: Button should be non-repeatable (idempotent)
4. **Sheet dismissal**: Preserve tab state when user cancels
5. **Document save success**: Dismiss sheet and reload documents for current tab

### Previous Stories Intelligence

**Story 1.1 Context:**
- Custom Segmented Control with 5 tabs
- Tab selection mechanism

**Story 1.2 Context:**
- Document filtering by tab
- Understanding of document types per tab

**Building On:**
- Quick Actions leverage tab context (maintenance, admin, fuel)
- Pre-selected types align with filtered document types
- Completes the "Ajout sans friction" UX principle

### References

**PRD Context:**
- [Source: _bmad-output/planning-artifacts/prd.md#MVP - Quick Actions Contextuelles FR12-FR14]
- [Source: _bmad-output/planning-artifacts/prd.md#Functional Requirements - Contextual Actions]

**UX Design Context:**
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Effortless Interactions - Ajout de Document Sans Friction]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Design Opportunities - Quick Actions Contextuelles Intelligentes]

**Architecture Context:**
- [Source: CLAUDE.md#Pattern Principal : Composable Architecture (TCA)]
- [Source: CLAUDE.md#Design System - Buttons]

**Dependencies:**
- Story 1.1: Custom Segmented Control Component (prerequisite)
- Story 1.2: Document Filtering by Tab (prerequisite)

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

### Debug Log References

_To be filled during implementation_

### Completion Notes List

_To be filled during implementation_

### File List

_To be filled during implementation_
