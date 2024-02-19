//
//  Functions.swift
//  MyLocations
//
//  Created by Travis Burns on 2/10/24.
//

import Foundation


//wait delay
func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(
        deadline: .now() + seconds,
        execute: run)
    
}

//file path
let applicationDocumentsDirectory: URL = {
    let paths = FileManager.default.urls(
        for: .documentDirectory,
        in: .userDomainMask)
    return paths[0]
    
}()

let dataSaveFailedNotification = Notification.Name(
  rawValue: "DataSaveFailedNotification")

//fatal error
func fatalCoreDataError(_ error: Error) {
    print("*** Fatal error: \(error)")
    NotificationCenter.default.post(
        name: dataSaveFailedNotification,
        object: nil)
    
}

