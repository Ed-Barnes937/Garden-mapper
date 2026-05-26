import SwiftUI

@MainActor
final class SetupViewModel: ObservableObject {
    @Published var stickHeightCm: Int {
        didSet { storage.stickHeight = stickHeightCm }
    }
    @Published private(set) var isLiDARAvailable: Bool

    private var storage: StickHeightStoring

    init(storage: StickHeightStoring = StickHeightStorage(),
         lidarAvailable: Bool = false) {
        self.storage = storage
        self.stickHeightCm = storage.stickHeight
        self.isLiDARAvailable = lidarAvailable
    }

    var canStartScan: Bool {
        isLiDARAvailable
    }

    func incrementHeight() {
        stickHeightCm = min(StickHeightStorage.maxHeight, stickHeightCm + 5)
    }

    func decrementHeight() {
        stickHeightCm = max(StickHeightStorage.minHeight, stickHeightCm - 5)
    }

    func setHeight(_ cm: Int) {
        stickHeightCm = StickHeightStorage.clamp(cm)
    }
}
