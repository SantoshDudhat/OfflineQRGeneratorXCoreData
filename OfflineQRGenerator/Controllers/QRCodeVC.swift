//
//  QRCodeVC.swift
//  OfflineQRGenerator
//
//  Created by DREAMWORLD on 28/11/24.
//

import UIKit

class QRCodeVC: UIViewController {

    var event: EventDetails?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let qrCodeGenerator = QRCodeGenerator()
        let qrImage = qrCodeGenerator.generateQRCode(from: event?.qrCodeUrl ?? "")

        // Display the QR code
        let imageView = UIImageView(image: qrImage)
        imageView.frame = CGRect(x: 50, y: 100, width: 300, height: 300)
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
    }
}
