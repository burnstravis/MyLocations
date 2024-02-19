//
//  String+AddText.swift
//  MyLocations
//
//  Created by Travis Burns on 2/18/24.
//

import Foundation

extension String {
    mutating func add(text: String?, separatedBy separator: String = "") {
        if let text = text {
            if !isEmpty {
                self += separator
            }
            self += text
        }
    }
}
