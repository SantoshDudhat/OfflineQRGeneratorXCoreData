//
//  EventListVC.swift
//  OfflineQRGenerator
//
//  Created by DREAMWORLD on 28/11/24.
//

import UIKit

class EventListVC: UIViewController {
    
    @IBOutlet weak var tblEventList: UITableView!

    var arrEventList = [EventDetails]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tblEventList.delegate = self
        tblEventList.dataSource = self
        tblEventList.register(UINib(nibName: "CellEventList", bundle: nil), forCellReuseIdentifier: "CellEventList")
        CoreDataManager.shared.deleteAllData(entityName: "EventDetails")
        ImageCacheManager.shared.clearCache()
        if let url = Bundle.main.url(forResource: "events", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let events = try JSONDecoder().decode([Events].self, from: data)
                
                // Save each event to Core Data
                for event in events {
                    guard let imageURL = URL(string: event.image) else {
                        print("Invalid image URL for event: \(event.name)")
                        continue
                    }
                    
                    // Create a unique file name using event ID or any unique identifier
                    let uniqueFileName = "\(event.id)_\(ImageCacheManager.shared.getFileName(from: imageURL))"
                    
                    // Download and cache the image
                    URLSession.shared.dataTask(with: imageURL) { data, _, error in
                        if let data = data, error == nil {
                            // Save the image to cache with a unique name
                            ImageCacheManager.shared.saveImageToCache(imageData: data, withName: uniqueFileName)
                            
                            // Save the file path (or a reference to the cached image) to Core Data
                            let imageFilePath = ImageCacheManager.shared.cacheDirectory.appendingPathComponent(uniqueFileName).path
                            
                            // Save event data, including the unique image path
                            CoreDataManager.shared.saveEvent(
                                id: event.id,
                                name: event.name,
                                image: imageFilePath, // Store the unique file path
                                location: event.location,
                                latitude: event.latitude,
                                longitude: event.longitude,
                                qrCodeUrl: event.qrCodeUrl
                            )
                            
                            print("Image cached and saved for event: \(event.name)")
                        } else {
                            print("Failed to download image for event: \(event.name), error: \(error?.localizedDescription ?? "Unknown error")")
                        }
                    }.resume()
                }
                
                print("All events saved successfully!")
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.arrEventList = CoreDataManager.shared.fetchAllEvents()
                    self.tblEventList.reloadData()
                }
            } catch {
                print("Failed to load or decode JSON: \(error)")
            }
        }
    }
}

extension EventListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrEventList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellEventList", for: indexPath) as! CellEventList
        let event = arrEventList[indexPath.row]
        cell.lblName.text = event.name
        
        if let imageName = event.image, // Get the cached file name
           let cachedImage = ImageCacheManager.shared.loadImageFromCache(withName: imageName) {
            cell.imgEvent.image = cachedImage // Load image from cache
        } else if let imageURL = URL(string: event.image ?? "") {
            cell.imgEvent.loadImage(from: imageURL) // Download and cache if not already cached
        } else {
            cell.imgEvent.image = UIImage(named: "placeholder") // Placeholder image
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "QRCodeVC") as! QRCodeVC
        vc.event = self.arrEventList[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}
