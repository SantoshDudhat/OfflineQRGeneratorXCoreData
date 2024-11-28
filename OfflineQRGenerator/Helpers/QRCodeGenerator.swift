//
//  QRCodeGenerator.swift
//  OfflineQRGenerator
//
//  Created by DREAMWORLD on 28/11/24.
//

import UIKit
import CoreImage

class QRCodeGenerator {
    func generateQRCode(from string: String) -> UIImage? {
        // Convert the string to data
        guard let data = string.data(using: .utf8) else { return nil }
        
        // Create a QR code filter
        guard let qrFilter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        qrFilter.setValue(data, forKey: "inputMessage")
        qrFilter.setValue("Q", forKey: "inputCorrectionLevel") // Error correction level: L, M, Q, H
        
        // Get the QR code image
        guard let ciImage = qrFilter.outputImage else { return nil }
        
        // Scale the image to a higher resolution
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = ciImage.transformed(by: transform)
        
        // Convert the CIImage to UIImage
        let uiImage = UIImage(ciImage: scaledImage)
        return uiImage
    }
}
