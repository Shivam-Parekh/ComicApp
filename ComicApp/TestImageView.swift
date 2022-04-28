//
//  LoadImage.swift
//  ImageViewer
//
//  Created by Shivam Parekh on 4/11/22.
//

import SwiftUI

actor ImageLoaderP {
    private var images: [URLRequest: LoaderStatus] = [:]

    public func fetch(_ url: URL, loadExist: LoadWait) async throws -> UIImage {
        let request = URLRequest(url: url)
        return try await fetch(request, loadExist: loadExist)
    }

    public func fetch(_ urlRequest: URLRequest, loadExist: LoadWait) async throws -> UIImage {
        if let status = images[urlRequest] {
            await MainActor.run {
                loadExist.exist = true
            }
            print("IM HEREEE")
            switch status {
            case .fetched(let image):
                return image
            case .inProgress(let task):
                return try await task.value
            }
        }
        await MainActor.run {
            loadExist.exist = false
        }
//
//        if let image = try self.imageFromFileSystem(for: urlRequest) {
//            images[urlRequest] = .fetched(image)
//            return image
//        }
//
        
        let task: Task<UIImage, Error> = Task {
                let (imageData, _) = try await URLSession.shared.data(for: urlRequest)
                let image = UIImage(data: imageData)!
                //try self.persistImage(image, for: urlRequest)
                return image
            }

            images[urlRequest] = .inProgress(task)

            let image = try await task.value

            images[urlRequest] = .fetched(image)
            await MainActor.run {
                loadExist.exist = true
            }
            return image
    }
    
//    private func persistImage(_ image: UIImage, for urlRequest: URLRequest) throws {
//        guard let url = fileName(for: urlRequest),
//              let data = image.jpegData(compressionQuality: 0.8) else {
//            assertionFailure("Unable to generate a local path for \(urlRequest)")
//            return
//        }
//
//        try data.write(to: url)
//    }
    
    private func imageFromFileSystem(for urlRequest: URLRequest) throws -> UIImage? {
        guard let url = fileName(for: urlRequest) else {
            assertionFailure("Unable to generate a local path for \(urlRequest)")
            return nil
        }
        let data = try Data(contentsOf: url)
        return UIImage(data: data)
    }

    private func fileName(for urlRequest: URLRequest) -> URL? {
        guard let fileName = urlRequest.url?.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let applicationSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                  return nil
              }

        return applicationSupport.appendingPathComponent(fileName)
    }

    private enum LoaderStatus {
        case inProgress(Task<UIImage, Error>)
        case fetched(UIImage)
    }
}

struct ImageLoaderKey: EnvironmentKey {
    static let defaultValue = ImageLoaderP()
}

extension EnvironmentValues {
    var imageLoader: ImageLoaderP {
        get { self[ImageLoaderKey.self] }
        set { self[ImageLoaderKey.self ] = newValue}
    }
}

struct ZoomableScrollView<Content: View>: UIViewRepresentable {
  private var content: Content

  init(@ViewBuilder content: () -> Content) {
    self.content = content()
  }

  func makeUIView(context: Context) -> UIScrollView {
    // set up the UIScrollView
    let scrollView = UIScrollView()
    scrollView.delegate = context.coordinator  // for viewForZooming(in:)
    scrollView.maximumZoomScale = 20
    scrollView.minimumZoomScale = 1
    scrollView.bouncesZoom = true

    // create a UIHostingController to hold our SwiftUI content
    let hostedView = context.coordinator.hostingController.view!
    hostedView.translatesAutoresizingMaskIntoConstraints = true
    hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    hostedView.frame = scrollView.bounds
    scrollView.addSubview(hostedView)

    return scrollView
  }

  func makeCoordinator() -> Coordinator {
    return Coordinator(hostingController: UIHostingController(rootView: self.content))
  }

  func updateUIView(_ uiView: UIScrollView, context: Context) {
    // update the hosting controller's SwiftUI content
    context.coordinator.hostingController.rootView = self.content
    assert(context.coordinator.hostingController.view.superview == uiView)
  }

  // MARK: - Coordinator

  class Coordinator: NSObject, UIScrollViewDelegate {
    var hostingController: UIHostingController<Content>

    init(hostingController: UIHostingController<Content>) {
      self.hostingController = hostingController
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
      return hostingController.view
    }
  }
}

struct DraggableView: ViewModifier {
    @State var offset = CGPoint(x: 0, y: 0)
    
    func body(content: Content) -> some View {
        content
            .gesture(DragGesture(minimumDistance: 0)
                .onChanged { value in
                    self.offset.x += value.location.x - value.startLocation.x
                    self.offset.y += value.location.y - value.startLocation.y
            })
            .offset(x: offset.x, y: offset.y)
    }
}

extension View {
    func draggable() -> some View {
        return modifier(DraggableView())
    }
}

class LoadWait: ObservableObject {
    @Published var exist = false
}

struct RemoteImage: View {
    private let source: URLRequest
    @State private var image: UIImage?
    @StateObject var loadExist = LoadWait()

    @Environment(\.imageLoader) private var imageLoader

    init(source: URL) {
        self.init(source: URLRequest(url: source))
    }

    init(source: URLRequest) {
        self.source = source
    }

    var body: some View {
        ZStack {
            if loadExist.exist, let image = image {
                    ZoomableScrollView{
                        Image(uiImage: image).resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
            } else {
                AsyncImage(url: URL(string:"https://picsum.photos/200")!)
            }
        }
        .task {
            await loadImage(at: source)
        }
    }

    func loadImage(at source: URLRequest) async {
        print("DOINGTHISSS")
        do {
            image = try await imageLoader.fetch(source, loadExist: loadExist)
        } catch {
            print(error)
        }
    }
}

