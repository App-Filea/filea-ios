# Story 1.2: Document Filtering by Tab

Status: ready-for-dev

## Story

As a **user with multiple documents across different categories**,
I want **documents to be automatically filtered and displayed based on the selected tab**,
so that **I see only relevant documents for each category without having to scroll through an unfiltered list**.

## Acceptance Criteria

### AC1: Overview Tab Shows All Recent Documents
**Given** the user has documents of various types
**When** the "Vue d'Ensemble" (Overview) tab is selected
**Then**
- All documents should be displayed regardless of type
- Documents should be sorted by date (most recent first)
- Maximum of 10-20 most recent documents shown (configurable)

### AC2: Statistics Tab Shows Statistics Content
**Given** the user selects the "Statistiques" (Statistics) tab
**When** the tab content loads
**Then**
- Existing statistics cards should be displayed (Total Cost, Monthly Expenses, etc.)
- No document list should be shown (read-only statistics view)
- Statistics should be calculated from all vehicle documents

### AC3: Maintenance Tab Filters Maintenance & Repair Documents
**Given** the user has documents of types `maintenance` and `repair`
**When** the "Entretiens & Réparations" (Maintenance) tab is selected
**Then**
- Only documents with type `maintenance` OR `repair` should be displayed
- Documents should be sorted chronologically (most recent first)
- Other document types (admin, fuel) should not appear

### AC4: Administration Tab Filters Administrative Documents
**Given** the user has documents of type `administrative`
**When** the "Administration" tab is selected
**Then**
- Only documents with type `administrative` should be displayed
- Documents should be sorted chronologically (most recent first)
- Other document types (maintenance, repair, fuel) should not appear

### AC5: Fuel Tab Filters Fuel Documents
**Given** the user has documents of type `fuel`
**When** the "Carburant" (Fuel) tab is selected
**Then**
- Only documents with type `fuel` should be displayed
- Documents should be sorted chronologically (most recent first)
- Other document types should not appear

### AC6: Empty State Handled Gracefully
**Given** the user has no documents for a specific category
**When** they select that category's tab
**Then**
- An empty state message should be displayed
- Message should be contextual to the tab (e.g., "Aucun Document d'Entretien")
- CTA for adding first document should be visible (implementation in Story 1.4)

### AC7: Document Count Per Tab
**Given** documents exist in various categories
**When** tabs are displayed
**Then**
- Each tab should optionally show a badge with document count for that category
- Overview tab shows total count
- Statistics tab shows no badge (read-only)

## Tasks / Subtasks

- [ ] **Task 1**: Extend VehicleDetailTabStore with Filtering Logic (AC: #1-#5)
  - [ ] Subtask 1.1: Add computed property to filter documents based on selected tab
  - [ ] Subtask 1.2: Implement filtering for Overview (all documents)
  - [ ] Subtask 1.3: Implement filtering for Maintenance (maintenance + repair types)
  - [ ] Subtask 1.4: Implement filtering for Administration (administrative type)
  - [ ] Subtask 1.5: Implement filtering for Fuel (fuel type)

- [ ] **Task 2**: Update VehicleDetailsStore to Use Filtered Documents (AC: #1-#5)
  - [ ] Subtask 2.1: Connect `VehicleDetailTabStore` filtering to document display
  - [ ] Subtask 2.2: Pass filtered documents to list view
  - [ ] Subtask 2.3: Ensure document sorting by date (most recent first)

- [ ] **Task 3**: Create DocumentListView Component (AC: #1-#5, #6)
  - [ ] Subtask 3.1: Create reusable `DocumentListView.swift` in `SharedViews/`
  - [ ] Subtask 3.2: Accept filtered documents as parameter
  - [ ] Subtask 3.3: Display documents in chronological order
  - [ ] Subtask 3.4: Handle empty state with contextual message
  - [ ] Subtask 3.5: Integrate existing `DocumentCard` component

- [ ] **Task 4**: Integrate Statistics View in Statistics Tab (AC: #2)
  - [ ] Subtask 4.1: Move existing statistics cards to separate component if not already
  - [ ] Subtask 4.2: Display statistics when Statistics tab is selected
  - [ ] Subtask 4.3: Hide document list in Statistics tab

- [ ] **Task 5**: Add Document Count Badges (AC: #7) - Optional for MVP
  - [ ] Subtask 5.1: Calculate document count per category
  - [ ] Subtask 5.2: Add badge UI to `CustomSegmentedControl`
  - [ ] Subtask 5.3: Update badge when documents change

- [ ] **Task 6**: Performance Optimization for Large Document Lists (AC: #1-#5)
  - [ ] Subtask 6.1: Implement lazy loading if needed (List already lazy in SwiftUI)
  - [ ] Subtask 6.2: Profile scroll performance with 100+ documents
  - [ ] Subtask 6.3: Optimize filtering computation (memoization if needed)

- [ ] **Task 7**: Unit Tests for Document Filtering
  - [ ] Subtask 7.1: Test Overview tab returns all documents
  - [ ] Subtask 7.2: Test Maintenance tab filters maintenance + repair
  - [ ] Subtask 7.3: Test Administration tab filters administrative
  - [ ] Subtask 7.4: Test Fuel tab filters fuel
  - [ ] Subtask 7.5: Test empty state when no documents match filter

## Dev Notes

### Architecture Context

**Dependencies on Story 1.1:**
- Requires `VehicleDetailTabStore` with `selectedTab` state
- Requires `CustomSegmentedControl` component
- Builds on tab selection mechanism

**Current State:**
- `VehicleDetailsStore` currently has all documents in a single list
- No filtering based on document type
- Users must scroll through mixed document types

**Target State:**
- Documents automatically filtered based on selected tab
- Each tab shows only relevant document types
- Smooth transition between filtered lists
- Empty states handled gracefully

### Document Type Mapping

**Document Model Reference** (from CLAUDE.md):
```swift
enum DocumentType: String, Codable {
    case administrative
    case maintenance
    case repair
    case fuel
    case other
}
```

**Tab to DocumentType Mapping:**
- **Overview**: All types (no filter)
- **Statistics**: No documents (statistics only)
- **Maintenance**: `maintenance` + `repair` types
- **Administration**: `administrative` type
- **Fuel**: `fuel` type

### TCA Store Extension

**Extend VehicleDetailTabStore:**
```swift
extension VehicleDetailTabStore {
    struct State: Equatable {
        var selectedTab: Tab = .overview
        var scrollPositions: [Tab: CGFloat] = [:]

        // Computed property for filtering
        func filteredDocuments(from allDocuments: [Document]) -> [Document] {
            switch selectedTab {
            case .overview:
                // Return all documents, sorted by date
                return allDocuments.sorted { $0.date > $1.date }

            case .statistics:
                // No documents for statistics tab
                return []

            case .maintenance:
                // Filter maintenance + repair types
                return allDocuments
                    .filter { $0.type == .maintenance || $0.type == .repair }
                    .sorted { $0.date > $1.date }

            case .administration:
                // Filter administrative type
                return allDocuments
                    .filter { $0.type == .administrative }
                    .sorted { $0.date > $1.date }

            case .fuel:
                // Filter fuel type
                return allDocuments
                    .filter { $0.type == .fuel }
                    .sorted { $0.date > $1.date }
            }
        }

        // Computed property for document count per tab
        func documentCount(for tab: Tab, from allDocuments: [Document]) -> Int {
            switch tab {
            case .overview:
                return allDocuments.count
            case .statistics:
                return 0  // No badge for statistics
            case .maintenance:
                return allDocuments.filter { $0.type == .maintenance || $0.type == .repair }.count
            case .administration:
                return allDocuments.filter { $0.type == .administrative }.count
            case .fuel:
                return allDocuments.filter { $0.type == .fuel }.count
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
        var documents: [Document]  // All documents for this vehicle
        var tabStore: VehicleDetailTabStore.State = .init()

        // Computed property for filtered documents
        var filteredDocuments: [Document] {
            tabStore.filteredDocuments(from: documents)
        }
    }

    enum Action: Equatable {
        case tabStore(VehicleDetailTabStore.Action)
        case documentsLoaded([Document])
        // ... other actions
    }

    @Dependency(\.documentRepository) var documentRepository

    var body: some ReducerOf<Self> {
        Scope(state: \.tabStore, action: /Action.tabStore) {
            VehicleDetailTabStore()
        }

        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { [vehicleId = state.vehicle.id] send in
                    let documents = try await documentRepository.fetchDocuments(for: vehicleId)
                    await send(.documentsLoaded(documents))
                }

            case let .documentsLoaded(documents):
                state.documents = documents
                return .none

            case .tabStore:
                // Tab change handled by child reducer
                // Filtered documents automatically update via computed property
                return .none

            // ... other actions
            }
        }
    }
}
```

### SwiftUI View Structure

**VehicleDetailsView Updates:**
```swift
struct VehicleDetailsView: View {
    let store: StoreOf<VehicleDetailsStore>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                // Custom Segmented Control at top
                CustomSegmentedControl(
                    store: store.scope(
                        state: \.tabStore,
                        action: VehicleDetailsStore.Action.tabStore
                    )
                )
                .padding(.vertical, SpacingTokens.md)

                // Content based on selected tab
                TabContentView(
                    selectedTab: viewStore.tabStore.selectedTab,
                    filteredDocuments: viewStore.filteredDocuments,
                    vehicle: viewStore.vehicle
                )
            }
            .navigationTitle(viewStore.vehicle.displayName)
            .onAppear { viewStore.send(.onAppear) }
        }
    }
}

private struct TabContentView: View {
    let selectedTab: VehicleDetailTabStore.Tab
    let filteredDocuments: [Document]
    let vehicle: Vehicle

    var body: some View {
        switch selectedTab {
        case .overview:
            DocumentListView(
                documents: filteredDocuments,
                emptyStateMessage: "Aucun document"
            )

        case .statistics:
            VehicleStatisticsView(vehicle: vehicle)

        case .maintenance:
            DocumentListView(
                documents: filteredDocuments,
                emptyStateMessage: "Aucun Document d'Entretien"
            )

        case .administration:
            DocumentListView(
                documents: filteredDocuments,
                emptyStateMessage: "Aucun Document Administratif"
            )

        case .fuel:
            DocumentListView(
                documents: filteredDocuments,
                emptyStateMessage: "Aucun Plein d'Essence"
            )
        }
    }
}
```

**DocumentListView Component:**
```swift
import SwiftUI

struct DocumentListView: View {
    let documents: [Document]
    let emptyStateMessage: String

    var body: some View {
        Group {
            if documents.isEmpty {
                EmptyStateView(message: emptyStateMessage)
            } else {
                List(documents) { document in
                    DocumentCard(document: document)
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

// Simple empty state for now (Story 1.4 will enhance this)
private struct EmptyStateView: View {
    let message: String

    var body: some View {
        VStack(spacing: SpacingTokens.lg) {
            Text(message)
                .font(TypographyTokens.heading)
                .foregroundColor(ColorTokens.secondary)

            Text("Les documents de cette catégorie apparaîtront ici")
                .font(TypographyTokens.body)
                .foregroundColor(ColorTokens.tertiary)
        }
        .padding(SpacingTokens.xl)
    }
}
```

### Performance Considerations

**Filtering Performance:**
- Filtering is done via computed property (reactive)
- SwiftUI automatically re-renders when `selectedTab` or `documents` change
- For large document lists (100+), filtering is O(n) which is acceptable
- If performance issues arise, consider memoization with `@Memoized` (if available) or manual caching

**Memory Management:**
- Filtered documents are computed, not stored (no duplication)
- Original documents array maintained in state
- No memory leaks expected (value types)

**Scroll Performance:**
- SwiftUI `List` is lazy by default (good for large lists)
- Target: 60 FPS with 100 documents per tab
- Profile with Instruments if issues arise

### Data Flow

**Document Loading Flow:**
```
1. VehicleDetailsView.onAppear
2. VehicleDetailsStore.onAppear action
3. Effect: documentRepository.fetchDocuments(vehicleId)
4. documentsLoaded action with [Document]
5. State.documents updated
6. filteredDocuments computed property recalculates
7. SwiftUI re-renders with filtered list
```

**Tab Change Flow:**
```
1. User taps tab in CustomSegmentedControl
2. VehicleDetailTabStore.tabSelected(tab) action
3. State.selectedTab updated
4. filteredDocuments computed property recalculates
5. SwiftUI re-renders with new filtered list
6. < 100ms from tap to display (performance requirement)
```

### Integration Points

**Files to Modify:**
1. **Modify**: `Stores/VehicleDetailTabStore/VehicleDetailTabStore.swift`
   - Add `filteredDocuments()` and `documentCount()` computed methods

2. **Modify**: `Stores/VehicleDetailsStore/VehicleDetailsStore.swift`
   - Add `documents` property to State
   - Add `documentsLoaded` action
   - Add effect to load documents on appear
   - Add `filteredDocuments` computed property

3. **Modify**: `Stores/VehicleDetailsStore/VehicleDetailsView.swift`
   - Add `CustomSegmentedControl` at top
   - Replace single list with `TabContentView`
   - Pass filtered documents to list

4. **Create**: `SharedViews/DocumentListView.swift`
   - Reusable document list component
   - Handles empty state
   - Uses existing `DocumentCard`

5. **Optional**: Update `CustomSegmentedControl.swift` for badges (Task 5)

**Dependencies:**
- Requires `@Dependency(\.documentRepository)` to fetch documents
- Existing `DocumentCard` component from `SharedViews/Cards/`
- Existing `VehicleStatisticsView` (if already exists) or create simple version

### Testing Strategy

**Unit Tests** (create `VehicleDetailTabStore_FilteringSpec.swift`):
```swift
import XCTest
import ComposableArchitecture
@testable import Invoicer

final class VehicleDetailTabStore_FilteringSpec: XCTestCase {

    func test_filteredDocuments_overviewTab_returnsAllDocuments() {
        let state = VehicleDetailTabStore.State(selectedTab: .overview)
        let documents = [
            Document.make(type: .maintenance),
            Document.make(type: .administrative),
            Document.make(type: .fuel)
        ]

        let filtered = state.filteredDocuments(from: documents)

        XCTAssertEqual(filtered.count, 3, "Overview tab should show all documents")
    }

    func test_filteredDocuments_maintenanceTab_returnsMaintenanceAndRepair() {
        let state = VehicleDetailTabStore.State(selectedTab: .maintenance)
        let documents = [
            Document.make(type: .maintenance),
            Document.make(type: .repair),
            Document.make(type: .administrative),
            Document.make(type: .fuel)
        ]

        let filtered = state.filteredDocuments(from: documents)

        XCTAssertEqual(filtered.count, 2, "Maintenance tab should show maintenance + repair")
        XCTAssertTrue(filtered.allSatisfy { $0.type == .maintenance || $0.type == .repair })
    }

    func test_filteredDocuments_administrationTab_returnsAdministrative() {
        let state = VehicleDetailTabStore.State(selectedTab: .administration)
        let documents = [
            Document.make(type: .administrative),
            Document.make(type: .maintenance),
            Document.make(type: .fuel)
        ]

        let filtered = state.filteredDocuments(from: documents)

        XCTAssertEqual(filtered.count, 1, "Administration tab should show only administrative")
        XCTAssertTrue(filtered.allSatisfy { $0.type == .administrative })
    }

    func test_filteredDocuments_fuelTab_returnsFuel() {
        let state = VehicleDetailTabStore.State(selectedTab: .fuel)
        let documents = [
            Document.make(type: .fuel),
            Document.make(type: .maintenance),
            Document.make(type: .administrative)
        ]

        let filtered = state.filteredDocuments(from: documents)

        XCTAssertEqual(filtered.count, 1, "Fuel tab should show only fuel")
        XCTAssertTrue(filtered.allSatisfy { $0.type == .fuel })
    }

    func test_filteredDocuments_sortedByDateDescending() {
        let state = VehicleDetailTabStore.State(selectedTab: .overview)
        let oldDoc = Document.make(date: Date(timeIntervalSince1970: 1000))
        let newDoc = Document.make(date: Date(timeIntervalSince1970: 2000))
        let documents = [oldDoc, newDoc]

        let filtered = state.filteredDocuments(from: documents)

        XCTAssertEqual(filtered.first?.id, newDoc.id, "Most recent document should be first")
    }

    func test_documentCount_maintenanceTab_countsMaintenanceAndRepair() {
        let state = VehicleDetailTabStore.State()
        let documents = [
            Document.make(type: .maintenance),
            Document.make(type: .repair),
            Document.make(type: .administrative)
        ]

        let count = state.documentCount(for: .maintenance, from: documents)

        XCTAssertEqual(count, 2, "Should count maintenance + repair")
    }

    // ... more tests for other tabs

    private var testDatabase: DatabaseManager!
    private var fetchedDocuments: [Document] = []
}

// Extension for test data
extension Document {
    static func make(
        id: UUID = UUID(),
        type: DocumentType = .maintenance,
        date: Date = Date(),
        title: String = "Test Document"
    ) -> Document {
        Document(
            id: id,
            vehicleId: UUID(),
            type: type,
            subtype: nil,
            title: title,
            amount: nil,
            date: date,
            mileage: nil,
            note: nil,
            filePath: ""
        )
    }
}
```

### Critical Constraints from CLAUDE.md

**MUST Follow:**
1. ✅ **Swift 6** syntax and strict concurrency
2. ✅ **No `try!`** in app code
3. ✅ **TCA pattern** with computed properties for derived state
4. ✅ **Test pattern**: Given-When-Then with BDD naming
5. ✅ **Performance**: Scroll at 60 FPS with 100+ documents
6. ✅ **Design System**: Use existing `DocumentCard` component

### UX Principles to Respect

From UX Design Specification:

**1. "Je sais exactement où c'est" - Organisation Mentale Claire**
- Filtering must be accurate and predictable
- No documents should appear in wrong tabs
- User should trust the organization

**2. "Pas de Scan Visuel" - Éliminer le Bruit**
- Filtering eliminates noise (5-10 documents per tab vs 50+ mixed)
- Each tab shows only relevant documents
- Chronological sorting helps find recent items quickly

**3. "Instantané et Fluide" - Performance Perçue**
- Tab change with filtered list must be < 100ms
- Smooth transition between lists
- No lag or jank during filtering

### Edge Cases to Handle

1. **No documents for a tab**: Show empty state message
2. **All documents of one type**: Other tabs show empty state
3. **Documents without type**: Should not crash (defensive coding)
4. **Very large document list (100+)**: Performance should remain acceptable
5. **Tab change during document loading**: Handle gracefully with loading state

### Previous Story Intelligence

**Story 1.1 Context:**
- Custom Segmented Control created with 5 tabs
- Tab selection mechanism implemented
- `VehicleDetailTabStore` with `selectedTab` state
- Visual active/inactive tab states

**Building On:**
- This story adds filtering logic to the tab store
- Connects filtered documents to the view
- Completes the navigation → content flow

### References

**PRD Context:**
- [Source: _bmad-output/planning-artifacts/prd.md#MVP - Document Filtering & Display FR6-FR11]
- [Source: _bmad-output/planning-artifacts/prd.md#Functional Requirements - Document Filtering]

**Architecture Context:**
- [Source: docs/architecture.md#Data Layer - Document Model]
- [Source: CLAUDE.md#Structure du Projet - Models/Document.swift]

**UX Design Context:**
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Effortless Interactions - Consultation]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Critical Success Moments - Retrouver Facilement]

**Dependencies:**
- Story 1.1: Custom Segmented Control Component (prerequisite)

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

### Debug Log References

_To be filled during implementation_

### Completion Notes List

_To be filled during implementation_

### File List

_To be filled during implementation_
