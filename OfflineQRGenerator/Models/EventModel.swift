//
//  EventModel.swift
//  OfflineQRGenerator
//
//  Created by DREAMWORLD on 28/11/24.
//

import Foundation

struct Events: Codable {
    let id: Int64
    let name: String
    let image: String
    let location: String
    let latitude: Double
    let longitude: Double
    let qrCodeUrl: String
}
