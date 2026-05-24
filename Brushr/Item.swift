import Foundation
import SwiftData

@Model
final class BrushSession {
    var date: Date
    var brushDuration: TimeInterval
    var usedMouthwash: Bool
    var usedFloss: Bool

    init(date: Date, brushDuration: TimeInterval, usedMouthwash: Bool, usedFloss: Bool) {
        self.date = date
        self.brushDuration = brushDuration
        self.usedMouthwash = usedMouthwash
        self.usedFloss = usedFloss
    }
}
