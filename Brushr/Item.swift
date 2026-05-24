//
//  Item.swift
//  Brushr
//
//  Created by Jens Heyn on 24.05.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
