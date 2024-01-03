import UIKit
import OSLog

let log = Logger()

class DetailsViewController: UIViewController {
    lazy var urlSessionWrapper = URLSessionWrapper()

    var loadCount = 0 {
        didSet {
            log.debug("----- load count \(self.loadCount)")
            loadingIndicator.isHidden = loadCount == 0
        }
    }

    deinit {
        log.debug("deinit VC")
    }

    @IBOutlet var loadingIndicator: UIActivityIndicatorView!

    @IBAction func loadViaWrapperTapped() {
        load(useWrapper: true)
    }

    @IBAction func loadViaURLSessionTapped() {
        load(useWrapper: false)
    }

    func load(useWrapper: Bool) {
        Task { [weak self] in
            self?.loadCount += 1
            do {
                log.debug("loading")
                if useWrapper {
                    let _ = try await self?.urlSessionWrapper.loadSomething()
                } else {
                    let _ = try await self?.urlSessionWrapper.urlSession.loadSomething()
                }
                log.debug("loaded")
            } catch {
                log.debug("error: \(error)")
            }

            self?.loadCount -= 1
        }
    }
}

class URLSessionWrapper {
    lazy var urlSession = URLSession(
        configuration: .default,
        delegate: nil,
        delegateQueue: nil
    )

    deinit {
        log.debug("deinit wrapper")
        urlSession.invalidateAndCancel()
    }
}

extension URLSessionWrapper {
    func loadSomething() async throws -> Data {
        try await self.urlSession.loadSomething()
    }
}

extension URLSession {
    func loadSomething() async throws -> Data {
        try await self.data(from: URL(string: "https://httpbin.io/delay/3")!).0
    }
}
