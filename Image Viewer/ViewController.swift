//
//  ViewController.swift
//  Image Viewer
//
//  Created by Łukasz Nycz on 26/06/2021.
//

import UIKit

class ViewController: UITableViewController {

    class Model: NSObject, Codable {
        let picture: String
        var count = 0
        
        init(picture: String, count: Int) {
            self.picture = picture
            self.count = count
        }
    }
    var pictures = [Model]() {
        didSet {
            tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Image Viewer"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        performSelector(inBackground: #selector(fetchData), with: nil)
        
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        
        pictures = pictures.sorted(by: { $0.picture < $1.picture })
        
        tableView.reloadData()
    }
    override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
         if let savedCounter = defaults.object(forKey: "pictures") as? Data {
             let jsonDecoder = JSONDecoder()

             do {
                 pictures = try jsonDecoder.decode([Model].self, from: savedCounter)
             } catch {
                 print("Failed to load counter")
             }
         }
    }
    
    func save() {
        let jsonEncoder = JSONEncoder()
        if let savedData = try? jsonEncoder.encode(pictures) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "pictures")
        } else {
            print("Failed to save counter.")
        }
    }
    
    
    @objc func fetchData() {
        let fm = FileManager.default
        let path = Bundle.main.resourcePath!
        let items = try! fm.contentsOfDirectory(atPath: path)
        
        DispatchQueue.main.async { [weak self] in
            for item in items {
                if item.hasPrefix("nssl") {
                    self?.pictures.append(Model(picture: item, count: 0))
                }
            }
        }
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pictures.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Picture", for: indexPath)
        let model = self.pictures[indexPath.row]
        cell.textLabel?.text = model.picture
        cell.detailTextLabel?.text = "Performed to image times: \(model.count)"
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let vc = storyboard?.instantiateViewController(identifier: "Detail") as? DetailViewController {
            let model = pictures[indexPath.row]
            navigationController?.pushViewController(vc, animated: true)
            vc.detailVCTitle = "Picture \(indexPath.row + 1) of \(pictures.count)"
            vc.selectedImage = model.picture
            model.count += 1
            save()
            pictures[indexPath.row] = model

        }
    }
}

