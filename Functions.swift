//
//  Functions.swift
//  MyLocations
//
//  Created by Travis Burns on 2/10/24.
//

import Foundation


func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + seconds,
        execute: run)
    
}
