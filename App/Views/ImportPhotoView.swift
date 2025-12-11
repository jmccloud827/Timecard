import PhotosUI
import SwiftUI
import VisionKit

struct ImportPhotoView: View {
    let onSelectImage: (UIImage) -> Void
    
    @State private var showSheet = false
    @State private var showDocumentScanner = false
    @State private var source: UIImagePickerController.SourceType = .photoLibrary
    
    var body: some View {
        Menu {
            Button("Camera", systemImage: "camera") {
                showDocumentScanner = true
            }
            
            Button("Photo Library", systemImage: "photo") {
                source = .photoLibrary
                showSheet = true
            }
        } label: {
            Label("Import", systemImage: "square.and.arrow.down")
        }
        .fullScreenCover(isPresented: $showSheet) {
            CameraView(sourceType: source) { image in
                if let image {
                    onSelectImage(image)
                }
            }
            .ignoresSafeArea()
        }
        .fullScreenCover(isPresented: $showDocumentScanner) {
            DocumentScannerView { result in
                switch result {
                case let .success(image):
                    onSelectImage(image)
                    
                case .failure:
                    print("Failed")
                }
            }
            .ignoresSafeArea()
        }
    }
    
    private struct CameraView: UIViewControllerRepresentable {
        @Environment(\.presentationMode) var isPresented
        
        var sourceType: UIImagePickerController.SourceType
        var onDidFinish: (UIImage?) -> Void = { _ in }
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let imagePicker = UIImagePickerController()
            imagePicker.sourceType = sourceType
            imagePicker.delegate = context.coordinator
            return imagePicker
        }
        
        func updateUIViewController(_: UIImagePickerController, context _: Context) {}

        func makeCoordinator() -> Coordinator {
            Coordinator(parent: self)
        }
    }

    private class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            guard let selectedImage = info[.originalImage] as? UIImage else {
                return
            }
            self.parent.onDidFinish(selectedImage)
            self.parent.isPresented.wrappedValue.dismiss()
        }
    }
}

private struct DocumentScannerView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    var onCompletion: (Result<UIImage, Error>) -> Void
    
    init(onCompletion: @escaping (Result<UIImage, Error>) -> Void) {
        self.onCompletion = onCompletion
    }
    
    func makeUIViewController(context: Context) -> VNDocumentCameraViewController {
        let documentCamera = VNDocumentCameraViewController()
        documentCamera.delegate = context.coordinator
        return documentCamera
    }
    
    func updateUIViewController(_: VNDocumentCameraViewController, context _: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    @MainActor class Coordinator: NSObject, VNDocumentCameraViewControllerDelegate {
        var parent: DocumentScannerView
        
        init(_ parent: DocumentScannerView) {
            self.parent = parent
        }
        
        func documentCameraViewController(_: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
            guard let image = (0 ..< scan.pageCount).map(scan.imageOfPage(at:)).first else {
                parent.onCompletion(.failure(URLError(.unknown)))
                return
            }
            
            
            parent.onCompletion(.success(image))
            parent.dismiss()
        }
        
        func documentCameraViewControllerDidCancel(_: VNDocumentCameraViewController) {
            parent.dismiss()
        }
        
        func documentCameraViewController(_: VNDocumentCameraViewController, didFailWithError error: Error) {
            parent.onCompletion(.failure(error))
            parent.dismiss()
        }
    }
}
