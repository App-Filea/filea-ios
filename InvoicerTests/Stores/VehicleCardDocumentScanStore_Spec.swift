////
////  VehicleCardDocumentScanStore_Spec.swift
////  InvoicerTests
////
////  Created by Claude Code on 15/11/2025.
////
//
//import ComposableArchitecture
//import XCTest
//import UIKit
//import _PhotosUI_SwiftUI
//@testable import Invoicer
//
//@MainActor
//final class VehicleCardDocumentScanStore_Spec: XCTestCase {
//
//    //TODO: refactor this test by adding camera authorization state
////    func test_Opens_camera_scan_view_when_tapping_scan_document_button() async {
////        givenStore()
////        
////        await store.send(.view(.scanDocumentButtonTapped))
////        await store.receive(.checkCameraAvailability) {
//////            $0.showDocumentScanView = true
////        }
////    }
//    
//    func test_Opens_photo_picker_view_when_tapping_pick_photo_button() async {
//        givenStore()
//        
//        await store.send(.view(.pickPhotoButtonTapped))
//        await store.receive(.openPhotoPicker) {
//            $0.showPhotoPickerView = true
//        }
//    }
//    
//    //TODO find a way to fake PhotosPickerItem, Data and UIImage
////    func test_Shows_loading_view_and_start_scanning_photo_when_photo_picker_sends_success_result() async {
////        givenStore()
////        
////        let imageToScan: UIImage = .init()
////        
////        await store.send(.view(.pickPhotoButtonTapped))
////        await store.receive(.openPhotoPicker) {
////            $0.showPhotoPickerView = true
////        }
////        await store.send(.loadPhotoPickerItem(PhotosPickerItem(itemIdentifier: ""))) {
////            $0.isProcessing = true
////        }
////        await store.receive(.transformPhotoDataToUIImage(Data()))
////        await store.receive(.captureImage(imageToScan)) {
////            $0.isProcessing = true
////            $0.showCamera = false
////        }
////    }
//    
//    func test_Opens_file_picker_view_when_tapping_import_file_button() async {
//        givenStore()
//        
//        await store.send(.view(.importFileButtonTapped))
//        await store.receive(.openFileManager) {
//            $0.showFileManagerView = true
//        }
//    }
//
//    private func givenStore() {
//        store = TestStore(
//            initialState: VehicleCardDocumentScanStore.State(),
//            reducer: { VehicleCardDocumentScanStore() }
//        )
//    }
//
//    private var store: TestStoreOf<VehicleCardDocumentScanStore>!
//}
