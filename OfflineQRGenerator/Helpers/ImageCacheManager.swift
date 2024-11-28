//
//  ImageCacheManager.swift
//  OfflineQRGenerator
//
//  Created by DREAMWORLD on 28/11/24.
//

import UIKit

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let fileManager = FileManager.default
    let cacheDirectory: URL
    
    private init() {
        // Create a directory for cached images
        let urls = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
        cacheDirectory = urls[0].appendingPathComponent("ImageCache")
        
        // Create folder if it doesn't exist
        if !fileManager.fileExists(atPath: cacheDirectory.path) {
            try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        }
    }
    
    // Save image to cache
    func saveImageToCache(imageData: Data, withName name: String) {
        let filePath = cacheDirectory.appendingPathComponent(name)
        try? imageData.write(to: filePath)
    }
    
    // Retrieve image from cache
    func loadImageFromCache(withName name: String) -> UIImage? {
        let filePath = cacheDirectory.appendingPathComponent(name)
        if fileManager.fileExists(atPath: filePath.path) {
            return UIImage(contentsOfFile: filePath.path)
        }
        return nil
    }
    
    // Get file name from URL
    func getFileName(from url: URL) -> String {
        return url.lastPathComponent
    }
    
    func clearCache() {
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: cacheDirectory, includingPropertiesForKeys: nil)
            for fileURL in fileURLs {
                try fileManager.removeItem(at: fileURL)
            }
            print("Image cache cleared successfully.")
        } catch {
            print("Failed to clear image cache: \(error)")
        }
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        // Get the file name for caching
        let fileName = ImageCacheManager.shared.getFileName(from: url)
        
        // Check if the image is already cached
        if let cachedImage = ImageCacheManager.shared.loadImageFromCache(withName: fileName) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            print("Loaded image from cache.")
            return
        }
        
        // Download and cache the image
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error downloading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            // Save the image to cache
            ImageCacheManager.shared.saveImageToCache(imageData: data, withName: fileName)
            
            // Set the image
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
            print("Downloaded and cached image.")
        }.resume()
    }
}
