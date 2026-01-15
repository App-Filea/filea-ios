# Story 1.5: OCR Smart Document Scan

Status: ready-for-dev

## Story

As a **user adding a document**,
I want **to scan my document (invoice, receipt, ticket) with my phone camera and have the information automatically extracted**,
so that **I save time (10 seconds vs 2 minutes) and avoid manual data entry errors**.

## Acceptance Criteria

### AC1: Camera Scan Access from AddDocumentView
**Given** the user is in AddDocumentView (adding a new document)
**When** they see the form
**Then**
- A "📸 Scanner le Document" button should be prominent at the top
- Button should use Design System (AccentButton or SecondaryButton)
- Tapping opens camera interface with document scanning mode

### AC2: Document Capture with VisionKit
**Given** the user taps "Scanner le Document"
**When** the camera interface opens
**Then**
- VisionKit's document camera scanner should be used (DataScannerViewController or DocumentCamera)
- User can take a photo of the document
- Photo should be captured in high resolution for OCR accuracy
- User can retake photo if needed

### AC3: OCR Text Extraction from Invoice/Receipt
**Given** the user has captured a document photo
**When** OCR processing runs
**Then** the system should extract:
- **Date**: Scan for date patterns (dd/mm/yyyy, dd-mm-yyyy, etc.)
- **Amount**: Scan for currency patterns (€, EUR followed by numbers)
- **Vendor/Garage**: Scan for business name (top of document usually)
- **Document type hints**: Keywords like "VIDANGE", "ASSURANCE", "ESSENCE", "GAZOLE"

### AC4: Smart Pre-Filling of Form Fields
**Given** OCR extraction completed successfully
**When** AddDocumentView reappears
**Then**
- **Date field**: Pre-filled with extracted date (if found)
- **Amount field**: Pre-filled with extracted amount (if found)
- **Title field**: Pre-filled with vendor name or document type (if found)
- **Document type**: Smart suggestion based on keywords (e.g., "VIDANGE" → maintenance)
- All fields remain editable (user can correct)

### AC5: Confidence-Based Pre-Filling
**Given** OCR extraction returns low-confidence results
**When** fields are pre-filled
**Then**
- High confidence (>80%): Pre-fill automatically
- Medium confidence (50-80%): Pre-fill with visual hint (yellow background or icon)
- Low confidence (<50%): Leave empty, don't risk wrong data
- User can always override any pre-filled value

### AC6: Store Scanned Image as Document Attachment
**Given** the user scanned a document
**When** they save the document
**Then**
- The scanned photo should be saved as the document's attachment
- Photo stored in vehicle's documents folder
- Photo accessible from DocumentDetailView
- Photo should be compressed appropriately (balance quality vs storage)

### AC7: Fallback for OCR Failure
**Given** OCR fails to extract any usable information
**When** AddDocumentView reappears
**Then**
- Show brief message: "Aucune information détectée. Veuillez saisir manuellement."
- Form fields remain empty
- Scanned image still attached
- User proceeds with manual entry

### AC8: Loading State During OCR Processing
**Given** OCR is running (can take 1-3 seconds)
**When** processing
**Then**
- Show loading indicator with message: "Extraction des informations..."
- Disable form interaction during processing
- Progress indicator should be indeterminate (spinner)

### AC9: Permission Handling for Camera
**Given** the app needs camera access for scanning
**When** user first tries to scan
**Then**
- Request camera permission if not granted
- Show rationale: "L'appareil photo est nécessaire pour scanner vos documents"
- If permission denied, disable scan button with explanation

## Tasks / Subtasks

- [ ] **Task 1**: Integrate VisionKit for Document Camera (AC: #2, #9)
  - [ ] Subtask 1.1: Add VisionKit framework to project
  - [ ] Subtask 1.2: Request camera permission in Info.plist (NSCameraUsageDescription)
  - [ ] Subtask 1.3: Create `DocumentScannerView.swift` wrapper for VisionKit DocumentCamera
  - [ ] Subtask 1.4: Handle photo capture callback

- [ ] **Task 2**: Implement OCR Text Extraction (AC: #3)
  - [ ] Subtask 2.1: Use Vision framework's `VNRecognizeTextRequest` for OCR
  - [ ] Subtask 2.2: Extract text from captured image
  - [ ] Subtask 2.3: Parse extracted text for date patterns
  - [ ] Subtask 2.4: Parse extracted text for amount patterns (€, EUR)
  - [ ] Subtask 2.5: Parse extracted text for vendor/business name
  - [ ] Subtask 2.6: Parse extracted text for document type keywords

- [ ] **Task 3**: Create OCR Service with Smart Parsing (AC: #3, #4, #5)
  - [ ] Subtask 3.1: Create `DocumentOCRService.swift` in `Data/Services/`
  - [ ] Subtask 3.2: Implement date extraction with regex patterns
  - [ ] Subtask 3.3: Implement amount extraction with currency patterns
  - [ ] Subtask 3.4: Implement vendor name extraction (top lines heuristic)
  - [ ] Subtask 3.5: Implement keyword-based document type detection
  - [ ] Subtask 3.6: Return confidence scores for each extracted field

- [ ] **Task 4**: Extend AddDocumentStore for OCR Integration (AC: #1, #4, #6, #7, #8)
  - [ ] Subtask 4.1: Add `scanDocumentButtonTapped` action
  - [ ] Subtask 4.2: Add `documentScanned(UIImage)` action
  - [ ] Subtask 4.3: Add `ocrCompleted(OCRResult)` action
  - [ ] Subtask 4.4: Add `isOCRProcessing` state for loading
  - [ ] Subtask 4.5: Add effect to run OCR service
  - [ ] Subtask 4.6: Pre-fill form fields with OCR results

- [ ] **Task 5**: Update AddDocumentView UI (AC: #1, #8)
  - [ ] Subtask 5.1: Add "📸 Scanner le Document" button at top of form
  - [ ] Subtask 5.2: Show loading indicator during OCR processing
  - [ ] Subtask 5.3: Disable form during processing
  - [ ] Subtask 5.4: Show DocumentScannerView in sheet presentation

- [ ] **Task 6**: Image Storage and Compression (AC: #6)
  - [ ] Subtask 6.1: Save scanned image to vehicle's documents folder
  - [ ] Subtask 6.2: Compress image appropriately (JPEG with 0.7-0.8 quality)
  - [ ] Subtask 6.3: Generate unique filename (UUID)
  - [ ] Subtask 6.4: Update Document model with filePath

- [ ] **Task 7**: Confidence-Based Visual Hints (AC: #5) - Optional for MVP
  - [ ] Subtask 7.1: Add confidence indicator to pre-filled fields
  - [ ] Subtask 7.2: Use yellow background or icon for medium confidence
  - [ ] Subtask 7.3: Add tooltip explaining confidence levels

- [ ] **Task 8**: Unit Tests for OCR Service
  - [ ] Subtask 8.1: Test date extraction with various formats
  - [ ] Subtask 8.2: Test amount extraction with €, EUR patterns
  - [ ] Subtask 8.3: Test vendor name extraction
  - [ ] Subtask 8.4: Test document type keyword detection
  - [ ] Subtask 8.5: Test confidence scoring logic

- [ ] **Task 9**: Integration Tests for OCR Flow
  - [ ] Subtask 9.1: Test full OCR flow from scan to pre-fill
  - [ ] Subtask 9.2: Test fallback when OCR fails
  - [ ] Subtask 9.3: Test image storage and retrieval

## Dev Notes

### Architecture Context

**Dependencies on Previous Stories:**
- **Story 1.3**: Quick Actions open AddDocumentView (entry point for scan)
- **Story 1.4**: Empty States CTA also opens AddDocumentView

**Current State:**
- User must manually type all document information
- Time-consuming (2 minutes average)
- Error-prone (typos in dates, amounts)

**Target State:**
- User scans document with camera
- OCR extracts key information (date, amount, vendor)
- 80% of fields pre-filled automatically
- User verifies and saves (10 seconds vs 2 minutes)
- **30% reduction in time to add document** (UX goal)

### Frameworks Required

**Apple Frameworks:**
1. **VisionKit** (iOS 13+)
   - `VNDocumentCameraViewController` for document capture
   - Handles document detection, perspective correction, lighting adjustment
   - Returns high-quality scanned images

2. **Vision** (iOS 11+)
   - `VNRecognizeTextRequest` for OCR text extraction
   - Fast, on-device text recognition
   - Supports multiple languages (French, English)
   - Returns confidence scores per recognized word

3. **AVFoundation** (for permissions)
   - Camera permission handling

### OCR Service Architecture

**DocumentOCRService.swift:**
```swift
import UIKit
import Vision

struct OCRResult: Equatable {
    struct ExtractedField: Equatable {
        let value: String
        let confidence: Float  // 0.0 to 1.0
    }

    var date: ExtractedField?
    var amount: ExtractedField?
    var vendor: ExtractedField?
    var documentType: DocumentType?
    var rawText: String
}

final class DocumentOCRService: @unchecked Sendable {

    func extractInformation(from image: UIImage) async throws -> OCRResult {
        // Step 1: Run Vision OCR
        let recognizedText = try await recognizeText(in: image)

        // Step 2: Parse text for specific fields
        let date = extractDate(from: recognizedText)
        let amount = extractAmount(from: recognizedText)
        let vendor = extractVendor(from: recognizedText)
        let docType = detectDocumentType(from: recognizedText)

        return OCRResult(
            date: date,
            amount: amount,
            vendor: vendor,
            documentType: docType,
            rawText: recognizedText
        )
    }

    private func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.invalidImage
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: "")
                    return
                }

                // Concatenate all recognized text
                let fullText = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }.joined(separator: "\n")

                continuation.resume(returning: fullText)
            }

            // Configure for best accuracy
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["fr-FR", "en-US"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

    private func extractDate(from text: String) -> OCRResult.ExtractedField? {
        // Date patterns: dd/mm/yyyy, dd-mm-yyyy, dd.mm.yyyy
        let patterns = [
            #"(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{4})"#,
            #"(\d{1,2})[\/\-\.](\d{1,2})[\/\-\.](\d{2})"#  // Short year
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {
                let dateString = (text as NSString).substring(with: match.range)

                // Calculate confidence (higher if found in first 30% of text)
                let matchLocation = Float(match.range.location) / Float(text.count)
                let confidence = matchLocation < 0.3 ? 0.9 : 0.7

                return OCRResult.ExtractedField(value: dateString, confidence: confidence)
            }
        }

        return nil
    }

    private func extractAmount(from text: String) -> OCRResult.ExtractedField? {
        // Amount patterns: €XX.XX, XX.XX EUR, XX,XX €
        let patterns = [
            #"(\d+[,\.]\d{2})\s*[€EUR]"#,
            #"[€EUR]\s*(\d+[,\.]\d{2})"#,
            #"Total\s*:?\s*(\d+[,\.]\d{2})"#
        ]

        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)) {

                // Extract numeric value
                let fullMatch = (text as NSString).substring(with: match.range)
                let numericValue = fullMatch.replacingOccurrences(of: "[^0-9,.]", with: "", options: .regularExpression)

                // Higher confidence if "Total" keyword found
                let confidence: Float = fullMatch.lowercased().contains("total") ? 0.9 : 0.7

                return OCRResult.ExtractedField(value: numericValue, confidence: confidence)
            }
        }

        return nil
    }

    private func extractVendor(from text: String) -> OCRResult.ExtractedField? {
        // Heuristic: Vendor name is usually in first 3-5 lines
        let lines = text.split(separator: "\n").prefix(5)

        // Find longest line (usually business name)
        guard let longestLine = lines.max(by: { $0.count < $1.count }),
              longestLine.count > 3 else {
            return nil
        }

        let vendorName = String(longestLine).trimmingCharacters(in: .whitespacesAndNewlines)

        // Confidence based on line length and position
        let confidence: Float = longestLine.count > 10 ? 0.7 : 0.5

        return OCRResult.ExtractedField(value: vendorName, confidence: confidence)
    }

    private func detectDocumentType(from text: String) -> DocumentType? {
        let lowercasedText = text.lowercased()

        // Keywords for document types
        let maintenanceKeywords = ["vidange", "révision", "entretien", "réparation", "pneu", "frein"]
        let administrativeKeywords = ["assurance", "carte grise", "contrôle technique", "certificat"]
        let fuelKeywords = ["essence", "gazole", "diesel", "carburant", "station-service", "total", "shell", "bp"]

        if maintenanceKeywords.contains(where: { lowercasedText.contains($0) }) {
            return .maintenance
        }

        if administrativeKeywords.contains(where: { lowercasedText.contains($0) }) {
            return .administrative
        }

        if fuelKeywords.contains(where: { lowercasedText.contains($0) }) {
            return .fuel
        }

        return nil
    }
}

enum OCRError: Error {
    case invalidImage
    case noTextFound
    case processingFailed
}
```

**Dependencies Client Pattern:**
```swift
// MARK: - OCR Service Client
struct DocumentOCRClient: Sendable {
    var extractInformation: @Sendable (UIImage) async throws -> OCRResult
}

// MARK: - Dependency Key
extension DocumentOCRClient: DependencyKey {
    static var liveValue: DocumentOCRClient {
        let service = DocumentOCRService()

        return DocumentOCRClient(
            extractInformation: { try await service.extractInformation(from: $0) }
        )
    }

    static var testValue: DocumentOCRClient {
        DocumentOCRClient(
            extractInformation: { _ in
                OCRResult(
                    date: OCRResult.ExtractedField(value: "15/01/2026", confidence: 0.9),
                    amount: OCRResult.ExtractedField(value: "45.50", confidence: 0.85),
                    vendor: OCRResult.ExtractedField(value: "Garage Dupont", confidence: 0.7),
                    documentType: .maintenance,
                    rawText: "Sample OCR text"
                )
            }
        )
    }
}

// MARK: - Dependency Values
extension DependencyValues {
    var documentOCRClient: DocumentOCRClient {
        get { self[DocumentOCRClient.self] }
        set { self[DocumentOCRClient.self] = newValue }
    }
}
```

### AddDocumentStore Extension

**Extended State and Actions:**
```swift
extension AddDocumentStore {
    struct State: Equatable {
        var vehicleId: UUID
        var documentType: DocumentType?
        var preSelectedType: DocumentType?
        var date: Date = Date()
        var mileage: String?
        var title: String = ""
        var amount: String = ""
        var note: String = ""

        // OCR-specific state
        var isOCRProcessing: Bool = false
        var scannedImage: UIImage?
        var ocrResult: OCRResult?
        @PresentationState var documentScanner: DocumentScannerStore.State?

        var isTypePickerDisabled: Bool {
            preSelectedType != nil
        }

        var isFormValid: Bool {
            documentType != nil && !title.isEmpty
        }
    }

    enum Action: Equatable {
        case tabSelected(Tab)
        case scanDocumentButtonTapped
        case documentScanner(PresentationAction<DocumentScannerStore.Action>)
        case documentScanned(UIImage)
        case ocrCompleted(Result<OCRResult, Error>)
        case saveButtonTapped
        case cancelButtonTapped
        // ... other actions
    }

    @Dependency(\.documentOCRClient) var ocrClient

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .scanDocumentButtonTapped:
                // Open document scanner
                state.documentScanner = DocumentScannerStore.State()
                return .none

            case .documentScanner(.presented(.documentCaptured(let image))):
                // Image captured, start OCR
                state.documentScanner = nil
                state.scannedImage = image
                state.isOCRProcessing = true

                return .run { send in
                    do {
                        let result = try await ocrClient.extractInformation(image)
                        await send(.ocrCompleted(.success(result)))
                    } catch {
                        await send(.ocrCompleted(.failure(error)))
                    }
                }

            case .ocrCompleted(.success(let result)):
                state.isOCRProcessing = false
                state.ocrResult = result

                // Pre-fill fields with high confidence values
                if let date = result.date, date.confidence > 0.8 {
                    // Parse date string and update state.date
                    state.date = parseDate(from: date.value) ?? state.date
                }

                if let amount = result.amount, amount.confidence > 0.8 {
                    state.amount = amount.value
                }

                if let vendor = result.vendor, vendor.confidence > 0.7 {
                    state.title = vendor.value
                }

                if let docType = result.documentType {
                    // Only auto-select if no pre-selected type
                    if state.preSelectedType == nil {
                        state.documentType = docType
                    }
                }

                return .none

            case .ocrCompleted(.failure):
                state.isOCRProcessing = false
                // Show brief error message (optional)
                return .none

            // ... other actions
            }
        }
        .ifLet(\.$documentScanner, action: /Action.documentScanner) {
            DocumentScannerStore()
        }
    }
}
```

### SwiftUI Views

**DocumentScannerView (VisionKit Wrapper):**
```swift
import SwiftUI
import VisionKit

struct DocumentScannerView: UIViewControllerRepresentable {
    let onDocumentCaptured: (UIImage) -> Void
    let onCancel: () -> Void

    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let scanner = VNDocumentCameraViewController()
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentCaptured: onDocumentCaptured, onCancel: onCancel)
    }

    class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        let onDocumentCaptured: (UIImage) -> Void
        let onCancel: () -> Void

        init(onDocumentCaptured: @escaping (UIImage) -> Void, onCancel: @escaping () -> Void) {
            self.onDocumentCaptured = onDocumentCaptured
            self.onCancel = onCancel
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            // Get first scanned page
            guard scan.pageCount > 0 else {
                controller.dismiss(animated: true)
                onCancel()
                return
            }

            let image = scan.imageOfPage(at: 0)
            controller.dismiss(animated: true) {
                self.onDocumentCaptured(image)
            }
        }

        func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
            controller.dismiss(animated: true)
            onCancel()
        }

        func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
            print("❌ [DocumentScanner] Failed with error: \(error)")
            controller.dismiss(animated: true)
            onCancel()
        }
    }
}
```

**Updated AddDocumentView:**
```swift
struct AddDocumentView: View {
    let store: StoreOf<AddDocumentStore>

    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            NavigationStack {
                Form {
                    // Scan Document Button at top
                    Section {
                        Button(action: { viewStore.send(.scanDocumentButtonTapped) }) {
                            HStack {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.title3)
                                Text("📸 Scanner le Document")
                                    .font(TypographyTokens.bodyBold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpacingTokens.sm)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(viewStore.isOCRProcessing)
                    }

                    // OCR Processing Indicator
                    if viewStore.isOCRProcessing {
                        Section {
                            HStack {
                                ProgressView()
                                    .padding(.trailing, SpacingTokens.sm)
                                Text("Extraction des informations...")
                                    .font(TypographyTokens.body)
                                    .foregroundColor(ColorTokens.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpacingTokens.md)
                        }
                    }

                    // Document Type Picker
                    Section("Type de Document") {
                        if viewStore.isTypePickerDisabled {
                            HStack {
                                Text("Type")
                                Spacer()
                                Text(viewStore.documentType?.displayName ?? "")
                                    .foregroundColor(ColorTokens.secondary)
                            }
                        } else {
                            Picker("Type", selection: viewStore.binding(\.$documentType)) {
                                ForEach(DocumentType.allCases, id: \.self) { type in
                                    Text(type.displayName).tag(type as DocumentType?)
                                }
                            }
                        }
                    }

                    // Date (may be pre-filled by OCR)
                    Section("Date") {
                        DatePicker(
                            "Date",
                            selection: viewStore.binding(\.$date),
                            displayedComponents: .date
                        )
                    }

                    // Amount (may be pre-filled by OCR)
                    Section("Montant") {
                        TextField(
                            "Montant",
                            text: viewStore.binding(\.$amount)
                        )
                        .keyboardType(.decimalPad)
                    }

                    // Title/Vendor (may be pre-filled by OCR)
                    Section("Titre") {
                        TextField(
                            "Titre",
                            text: viewStore.binding(\.$title)
                        )
                    }

                    // Mileage
                    Section("Kilométrage") {
                        TextField(
                            "Kilométrage",
                            text: viewStore.binding(\.$mileage).withDefault("")
                        )
                        .keyboardType(.numberPad)
                    }

                    // Note
                    Section("Note") {
                        TextEditor(text: viewStore.binding(\.$note))
                            .frame(minHeight: 100)
                    }
                }
                .disabled(viewStore.isOCRProcessing)
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
                        .disabled(!viewStore.isFormValid || viewStore.isOCRProcessing)
                    }
                }
                .sheet(
                    store: store.scope(
                        state: \.$documentScanner,
                        action: { .documentScanner($0) }
                    )
                ) { scannerStore in
                    // Present DocumentScannerView
                    DocumentScannerView(
                        onDocumentCaptured: { image in
                            ViewStore(scannerStore, observe: { $0 }).send(.documentCaptured(image))
                        },
                        onCancel: {
                            ViewStore(scannerStore, observe: { $0 }).send(.cancelTapped)
                        }
                    )
                    .ignoresSafeArea()
                }
            }
        }
    }
}
```

### Info.plist Requirements

**Add Camera Permission:**
```xml
<key>NSCameraUsageDescription</key>
<string>L'appareil photo est nécessaire pour scanner vos documents et extraire automatiquement les informations (date, montant, vendeur).</string>
```

### Performance Considerations

**OCR Processing Time:**
- Vision OCR: 1-3 seconds on modern iPhones
- Async processing with loading indicator
- Non-blocking UI (user can cancel)

**Image Storage:**
- Compress scanned images (JPEG quality 0.7-0.8)
- Typical size: 200-500 KB per document
- Store in vehicle's documents folder

**Memory:**
- UIImage released after OCR processing
- No memory leaks from Vision framework

### Testing Strategy

**Unit Tests** (create `DocumentOCRService_Spec.swift`):
```swift
import XCTest
import Vision
@testable import Invoicer

final class DocumentOCRService_Spec: XCTestCase {

    func test_extractDate_findsDatePattern_ddmmyyyy() {
        let service = DocumentOCRService()
        let text = "Facture du 15/01/2026\nMontant: 45.50€"

        let date = service.extractDate(from: text)

        XCTAssertEqual(date?.value, "15/01/2026")
        XCTAssertGreaterThan(date?.confidence ?? 0, 0.7)
    }

    func test_extractAmount_findsCurrencyPattern() {
        let service = DocumentOCRService()
        let text = "Total: 45.50 EUR\nMerci de votre visite"

        let amount = service.extractAmount(from: text)

        XCTAssertEqual(amount?.value, "45.50")
        XCTAssertGreaterThan(amount?.confidence ?? 0, 0.7)
    }

    func test_detectDocumentType_maintenance_fromKeywords() {
        let service = DocumentOCRService()
        let text = "GARAGE DUPONT\nVIDANGE MOTEUR\nDate: 15/01/2026\nMontant: 75.00€"

        let docType = service.detectDocumentType(from: text)

        XCTAssertEqual(docType, .maintenance)
    }

    func test_detectDocumentType_fuel_fromKeywords() {
        let service = DocumentOCRService()
        let text = "TOTAL Station-Service\nESSENCE SP95\n45.50 EUR"

        let docType = service.detectDocumentType(from: text)

        XCTAssertEqual(docType, .fuel)
    }

    // ... more tests for other patterns
}
```

### Critical Constraints from CLAUDE.md

**MUST Follow:**
1. ✅ **Swift 6** with strict concurrency (`@Sendable` for async operations)
2. ✅ **No `try!`** in app code (proper error handling)
3. ✅ **TCA pattern** for state management
4. ✅ **Dependencies Client** for OCR service
5. ✅ **Test pattern** with Given-When-Then
6. ✅ **Error logging** with emoji conventions

### Apple HIG & Documentation

**Consult before implementing:**
```
use context7 /apple/visionkit document camera
use context7 /apple/vision text recognition
use context7 /apple/human-interface-guidelines camera and photos
```

### Edge Cases to Handle

1. **Camera permission denied**: Disable scan button, show explanation
2. **OCR finds no text**: Show fallback message, allow manual entry
3. **Low-quality image**: Vision may return low-confidence results, leave fields empty
4. **Multiple dates/amounts**: Take first match (usually correct)
5. **Non-French documents**: Vision supports English, will still extract some info
6. **Very long processing**: Show cancel button during OCR

### Previous Stories Intelligence

**Story 1.3 Context:**
- Quick Actions open AddDocumentView with type pre-selected
- OCR respects pre-selected type (doesn't override)

**Story 1.4 Context:**
- Empty States CTA also opens AddDocumentView
- Same OCR flow applies

**Building On:**
- OCR completes the "Ajout sans friction" vision
- 80% of fields pre-filled automatically
- User verifies and saves in 10 seconds
- Achieves 30% time reduction goal from UX spec

### References

**PRD Context:**
- [Source: _bmad-output/planning-artifacts/prd.md#Growth Features - OCR not in MVP but user requested]
- [Source: _bmad-output/planning-artifacts/prd.md#Non-Functional Requirements - Performance]

**UX Design Context:**
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Effortless Interactions - Scan OCR Intelligent]
- [Source: _bmad-output/planning-artifacts/ux-design-specification.md#Critical Success Moments - Premier Ajout Réussi]

**Architecture Context:**
- [Source: docs/architecture.md#Services - FileStorageService pattern]
- [Source: CLAUDE.md#Structure du Projet - Data/Services/]

**Existing Scan Implementation:**
- [Source: CLAUDE.md#Stores - VehicleCardDocumentScanStore exists for carte grise]
- Can reuse patterns from existing scan implementation

**Dependencies:**
- Story 1.3: Contextual Quick Actions (entry point to AddDocumentView)
- Story 1.4: Empty States (another entry point)

## Dev Agent Record

### Agent Model Used

Claude Sonnet 4.5 (claude-sonnet-4-5-20250929)

### Debug Log References

_To be filled during implementation_

### Completion Notes List

_To be filled during implementation_

### File List

_To be filled during implementation_
