//
//  PreferenceManager.swift
//  ObjectWin
//
//  Created by DEVM-SUNDAR on 20/03/25.
//

import Foundation
import UIKit
//Preference class used for common methods
class PreferenceManager {
    
    static let  shared = PreferenceManager()
    
    private init() { }
    
    func convertUTCToLocalTime(utcTime: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Input format
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC") // Set UTC timezone

        if let date = dateFormatter.date(from: utcTime) {
            dateFormatter.timeZone = TimeZone.current // Convert to local timezone
            dateFormatter.dateFormat = "MM-dd-yyyy h:mm a" // Desired output format
            return dateFormatter.string(from: date)
        }
        return nil
    }
   
    //Error handling
    func errorHandling(errorMessage: String,currentController:UIViewController,completion:(() -> Void)? = nil) {
        DispatchQueue.main.async {
            let showAlert = UIAlertController(title: "Response Error", message: errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
                       completion?() // Call the completion handler when OK is tapped
                }
            showAlert.addAction(okAction)
            currentController.present(showAlert, animated: true)
        }
    }
    
}
