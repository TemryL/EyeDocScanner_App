//
//  FileController.swift
//  EyeDocScanner
//
//  Created by Tom MERY on 18.03.23.
//

import Foundation
import UIKit

class FileController: ObservableObject {
    let manager = FileManager.default
    let userDirectory: URL?
    let JPEG_QUALITY = 0.8
    
    init() {
        guard let url = manager.urls(
            for: .documentDirectory,
            in: .userDomainMask
        ).first else {
            self.userDirectory = nil
            return
        }
        self.userDirectory = url
    }
        
    func generateNewFilename() -> String {
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH-mm-ssSSS"
        // force 24h format
        formatter.locale = Locale(identifier: "en_US_POSIX")
        let filename = formatter.string(from: currentDate)
        return filename
    }


    func generatePath(_ filename: String, _ fileExtension: String) -> URL {
        let dir = userDirectory!
        let path = dir.appendingPathComponent("\(filename).\(fileExtension)", isDirectory: false)
        return path
    }


    func saveImage(_ image: UIImage, _ path: URL) {
        // Save picture in local file system
        guard let jpg = image.jpegData(compressionQuality: JPEG_QUALITY) else {
            print("Error: Could not get jpg data of image")
            return
        }
        
        do {
            try jpg.write(to: path)
            print("Picture saved successfully")
        }
        catch {
            print("Error: could not save picture. \(error)")
        }
    }
    
    func writeCSV(data: [[String: String]]) -> Void {
        let headers = data.flatMap { $0.keys }.joined(separator: ",")
        let values = data.flatMap { $0.values }.joined(separator: ",")
        let csvString = headers + "\n" + values
        
        if let url = userDirectory {
            let filename = generateNewFilename()
            let csvPath = generatePath(filename, "csv")
            do {
                try csvString.write(to: csvPath, atomically: true, encoding: .utf8)
            }
            catch {
                print("Error creating csv file")
            }
        }
    }
}