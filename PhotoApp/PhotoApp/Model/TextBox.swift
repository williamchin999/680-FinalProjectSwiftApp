//
//  TextBox.swift
//  ImageMapApp
//
//  Created by William Chin on 12/5/22.
//

import Foundation
import SwiftUI
import PencilKit

struct TextBox: Identifiable {
    var id = UUID().uuidString
    var text: String = ""
    var isBold: Bool = false
    //For draggoin view over screen
    var offset: CGSize = .zero
    var lastOffset: CGSize = .zero
    var textColor: Color = .black
    var isAdded: Bool = false
}
