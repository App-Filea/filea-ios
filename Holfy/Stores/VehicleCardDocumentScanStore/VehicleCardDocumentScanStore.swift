////
////  VehicleCardDocumentScanStore.swift
////  Invoicer
////
////  Created by Claude Code on 20/10/2025.
////
//
//import ComposableArchitecture
//import Foundation
//import _PhotosUI_SwiftUI
//import AVFoundation
//import VisionKit
//import PDFKit
//
//enum ViewState: Equatable {
//    case modeChoice
//    case loading
//    case preview
//    case error
//}
//
//@Reducer
//struct VehicleCardDocumentScanStore {
//
//    @ObservableState
//    struct State: Equatable {
//        var viewState: ViewState = .modeChoice
//        var showDocumentScanView: Bool = false
//        var showPhotoPickerView: Bool = false
//        var showFileManagerView: Bool = false
//        
//        var photoPickerItem: PhotosPickerItem? = nil
//
//        var scanMode: ScanMode = .registrationCard
//        var scannedText: String = ""
//        var extractedData: ScannedVehicleData? = nil
//        var scanError: ScanError? = nil
//        
//        var scanSource: DocumentSource? = nil
//    }
//
//    enum Action: Equatable, BindableAction {
//        case binding(BindingAction<State>)
//        case view(ActionView)
//
//        case openCameraScan
//        case openPhotoPicker
//        case openFileManager
//
//        case loadPhotoPickerItem(PhotosPickerItem?)
//        case transformPhotoDataToUIImage(Data)
//
//        case fileSelected(URL)
//        case loadFileAsImage(URL)
//
//        case checkCameraAvailability
//        case documentScanned(VNDocumentCameraScan)
//        case captureImage(UIImage)
//        case textRecognized(String)
//        case parsingCompleted(ScannedVehicleData)
//        case scanFailed(ScanError)
//        case confirmData
//        case cancelScan
//        case closeScannerSheet
//
//        enum ActionView: Equatable {
//            case scanDocumentButtonTapped
//            case pickPhotoButtonTapped
//            case importFileButtonTapped
//        }
//    }
//
//    @Dependency(\.ocrService) var ocrService
//    @Dependency(\.documentParser) var documentParser
//    @Dependency(\.dismiss) var dismiss
//
//    var body: some ReducerOf<Self> {
//        BindingReducer()
//            .onChange(of: \.photoPickerItem) { _, newValue in
//                Reduce { _, _ in
//                    return .send(.loadPhotoPickerItem(newValue))
//                }
//            }
//        Reduce { state, action in
//            switch action {
//            case .view(let actionView):
//                switch actionView {
//                case .scanDocumentButtonTapped: return .send(.checkCameraAvailability)
//                case .pickPhotoButtonTapped: return .send(.openPhotoPicker)
//                case .importFileButtonTapped: return .send(.openFileManager)
//                }
//                
//            case .openCameraScan:
//                state.showDocumentScanView = true
//                return .none
//                
//            case .openPhotoPicker:
//                state.showPhotoPickerView = true
//                return .none
//                
//            case .openFileManager:
//                state.showFileManagerView = true
//                return .none
//
//            case .fileSelected(let fileURL):
//                state.showFileManagerView = false
//                return .send(.loadFileAsImage(fileURL))
//
//            case .loadFileAsImage(let fileURL):
//                state.viewState = .loading
//                return .run { send in
//                    do {
//                        let fileExtension = fileURL.pathExtension.lowercased()
//                        var image: UIImage?
//
//                        if ["jpg", "jpeg", "png", "heic"].contains(fileExtension) {
//                            let data = try Data(contentsOf: fileURL)
//                            image = UIImage(data: data)
//
//                        } else if fileExtension == "pdf" {
//                            guard let pdfDocument = PDFDocument(url: fileURL) else {
//                                await send(.scanFailed(.unknown("Impossible de lire le PDF")))
//                                return
//                            }
//
//                            image = pdfDocument.imageOfFirstPage()
//
//                        } else {
//                            await send(.scanFailed(.unknown("Type de fichier non supporté")))
//                            return
//                        }
//
//                        guard let finalImage = image else {
//                            await send(.scanFailed(.unknown("Impossible de créer l'image")))
//                            return
//                        }
//                        await send(.captureImage(finalImage))
//
//                    } catch {
//                        await send(.scanFailed(.unknown(error.localizedDescription)))
//                    }
//                }
//
//            case .loadPhotoPickerItem(let photoPickerItem):
//                guard let item = photoPickerItem else { return .none }
//                state.viewState = .loading
//                return .run { send in
//                    do {
//                        guard let data = try await item.loadTransferable(type: Data.self) else { return }
//                        await send(.transformPhotoDataToUIImage(data))
//    
//                    } catch(let error) {
//                        print("❌ [PhotoPickerStore] Error: \(error)")
//                    }
//                }
//                
//            case .transformPhotoDataToUIImage(let data):
//                return .run { send in
//                    guard let image = UIImage(data: data) else {
//                        print("❌ [PhotoPickerStore] Impossible de créer UIImage")
//                        return
//                    }
//                    await send(.captureImage(image))
//                }
//
//            case .checkCameraAvailability:
//                return .run { send in
//                    let isSupported = await MainActor.run { DataScannerViewController.isSupported }
//                    guard isSupported else {
//                        return
////                        return .notSupported(reason: "Votre appareil ne supporte pas la reconnaissance de texte en temps réel. iOS 16+ requis.")
//                    }
//
//                    let isAvailable = await MainActor.run { DataScannerViewController.isAvailable }
//                    guard isAvailable else {
//                        return
//                    }
//
//                    let status = AVCaptureDevice.authorizationStatus(for: .video)
//                    switch status {
//                    case .authorized: await send(.openCameraScan)
//                    case .denied, .restricted: return
//                    case .notDetermined:
//                        let granted = await AVCaptureDevice.requestAccess(for: .video)
//                        if granted { await send(.openCameraScan) } else {
//                            await send(.checkCameraAvailability)
//                            return
//                        }
//                        return
//                    @unknown default: return
//                    }
//                }
//
//            case .documentScanned(let scan):
//                state.showDocumentScanView = false
//
//                guard scan.pageCount > 0 else {
//                    return .send(.scanFailed(.noTextDetected))
//                }
//
//                let firstPage = scan.imageOfPage(at: 0)
//                return .send(.captureImage(firstPage))
//
//            case .closeScannerSheet:
//                state.showDocumentScanView = false
//                return .none
//
//            case .captureImage(let image):
//                state.viewState = .loading
//                return .run { [mode = state.scanMode] send in
//                    do {
//                        let recognizedText = try await ocrService.recognizeTextStatic(image)
//                        await send(.textRecognized(recognizedText))
//
//                        let parsedData = documentParser.parse(recognizedText, mode)
//                        await send(.parsingCompleted(parsedData))
//
//                    } catch let error as ScanError {
//                        await send(.scanFailed(error))
//                    } catch {
//                        await send(.scanFailed(.unknown(error.localizedDescription)))
//                    }
//                }
//
//            case .textRecognized(let text):
//                state.scannedText = text
//                return .none
//
//            case .parsingCompleted(let data):
//                state.extractedData = data
//                state.viewState = .preview
//
//                if !data.hasData {
//                    state.scanError = .noTextDetected
//                }
//
//                return .none
//
//            case .scanFailed(let error):
//                state.viewState = .error
//                return .none
//
//            case .confirmData:
//                return .run { _ in
//                    await dismiss()
//                }
//
//            case .cancelScan:
//                return .run { _ in
//                    await dismiss()
//                }
//                
//            default: return .none
//            }
//        }
//    }
//}
