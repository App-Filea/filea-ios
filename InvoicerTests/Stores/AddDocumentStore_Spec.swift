//
//  AddDocumentStore_Spec.swift
//  InvoicerTests
//
//  Created by Claude Code on 25/10/2025.
//

import ComposableArchitecture
import XCTest
@testable import Invoicer

@MainActor
final class AddDocumentStore_Spec: XCTestCase {

    func test_initialState_viewStateIsModeChoice() async {
        givenStore()
        XCTAssertEqual(store.state.viewState, .modeChoice)
    }

    func test_openCameraViewButtonTapped_opensCamera() async {
        givenStore()

        await store.send(.view(.openCameraViewButtonTapped))
        await store.receive(.openCameraScan) {
            $0.showDocumentScanView = true
        }
    }

    func test_openPhotoPickerButtonTapped_opensPhotoPicker() async {
        givenStore()

        await store.send(.view(.openPhotoPickerButtonTapped))
        await store.receive(.openPhotoPicker) {
            $0.showPhotoPickerView = true
        }
    }

    func test_openFileManagerButtonTapped_opensFileManager() async {
        givenStore()

        await store.send(.view(.openFileManagerButtonTapped))
        await store.receive(.openFileManager) {
            $0.showFileManagerView = true
        }
    }

//    func test_documentScanned_singlePage_createsPDFAndGoesToMetadataView() async {
//        givenStore()
//
//        await store.send(.view(.openCameraViewButtonTapped))
//        await store.receive(.openCameraScan) {
//            $0.showDocumentScanView = true
//        }
//
//        let fakeImage = UIImage()
//        await store.send(.view(.documentScanned([fakeImage])))
//        await store.receive(.transformToPdf([fakeImage]))
//        await store.receive(\.fileSelected) {
//            $0.viewState = .metadataForm
//            $0.showFileManagerView = false
//            XCTAssertNotNil($0.selectedFileURL)
//            XCTAssertTrue($0.selectedFileURL?.pathExtension == "pdf")
//        }
//    }

//    func test_documentScanned_multiplePages_createsPDFAndGoesToMetadataView() async {
//        givenStore()
//
//        await store.send(.view(.openCameraViewButtonTapped))
//        await store.receive(.openCameraScan) {
//            $0.showDocumentScanView = true
//        }
//
//        let fakeImages = [UIImage(), UIImage(), UIImage()]
//        await store.send(.view(.documentScanned(fakeImages)))
//        await store.receive(.transformToPdf(fakeImages))
//        await store.receive(\.fileSelected) {
//            $0.viewState = .metadataForm
//            $0.showFileManagerView = false
//            XCTAssertNotNil($0.selectedFileURL)
//            XCTAssertTrue($0.selectedFileURL?.pathExtension == "pdf")
//        }
//    }

//    func test_photoSelected_singlePhoto_createsPDFAndGoesToMetadataView() async {
//        givenStore()
//
//        await store.send(.view(.openPhotoPickerButtonTapped))
//        await store.receive(.openPhotoPicker) {
//            $0.showPhotoPickerView = true
//        }
//
//        // PhotoPicker selection is handled via BindingReducer onChange
//        // The test would need to simulate photoPickerItems binding change
//        // For now, we can test transformToPdf directly
//        let fakeImage = UIImage()
//        await store.send(.transformToPdf([fakeImage]))
//        await store.receive(\.fileSelected) {
//            $0.viewState = .metadataForm
//            $0.showFileManagerView = false
//            XCTAssertNotNil($0.selectedFileURL)
//            XCTAssertTrue($0.selectedFileURL?.pathExtension == "pdf")
//        }
//    }

//    func test_photoSelected_multiplePhotos_createsPDFAndGoesToMetadataView() async {
//        givenStore()
//
//        let fakeImages = [UIImage(), UIImage(), UIImage()]
//        await store.send(.transformToPdf(fakeImages))
//        await store.receive(\.fileSelected) {
//            $0.viewState = .metadataForm
//            $0.showFileManagerView = false
//            XCTAssertNotNil($0.selectedFileURL)
//            XCTAssertTrue($0.selectedFileURL?.pathExtension == "pdf")
//        }
//    }

    func test_fileSelected_goesToMetadataView() async {
        givenStore()

        await store.send(.view(.openFileManagerButtonTapped))
        await store.receive(.openFileManager) {
            $0.showFileManagerView = true
        }

        let fakeURL = URL(fileURLWithPath: "/test/document.pdf")
        await store.send(.fileSelected(fakeURL)) {
            $0.viewState = .metadataForm
            $0.showFileManagerView = false
            $0.selectedFileURL = fakeURL
            $0.selectedFileName = "document.pdf"
        }
    }

    func test_backFromMetadataForm_returnsToModeChoice() async {
        givenStore(viewState: .metadataForm)

        await store.send(.view(.backFromMetadataFormButtonTapped)) {
            $0.viewState = .modeChoice
        }
    }

    private func givenStore(
        viewState: AddDocumentStore.State.ViewState = .modeChoice
    ) {
        store = TestStore(
            initialState: AddDocumentStore.State(
                vehicleId: UUID(),
                viewState: viewState
            ),
            reducer: { AddDocumentStore() }
        )
    }

    private var store: TestStoreOf<AddDocumentStore>!
}
