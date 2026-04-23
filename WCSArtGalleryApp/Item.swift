//
//  Item.swift
//  WCSArtGalleryApp
//
//  Created by Christopher Appiah-Thompson  on 24/4/2026.
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
