import SwiftUI

func formatBrushDuration(_ duration: TimeInterval) -> String {
    let mins = Int(duration) / 60
    let secs = Int(duration) % 60
    return String(format: "%d:%02d", mins, secs)
}
