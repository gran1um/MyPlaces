//
//  MainViewController.swift
//  My Places
//
//  Created by Alexander Popov on 11.05.2022.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
    @IBOutlet weak var tableView: UITableView!
    var places: Results<Place>!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        places = realm.objects(Place.self)
    }

    // MARK: - Table view data source

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return places.isEmpty ? 0 : places.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell

        let place = places[indexPath.row]

        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height/2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
    // MARK: Table view delegate
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let place = places[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
            StorageManager.deleteObject(place)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return [deleteAction]
    }
    
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail"{
            guard let indexPath = tableView.indexPathForSelectedRow else{return}
            let place = places[indexPath.row]
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
            
        }
    }
    

    @IBAction func unwindSegue( _ segue: UIStoryboardSegue){
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }
        
        newPlaceVC.savePlace()
        tableView.reloadData()
    }

}
