//
//  MainViewController.swift
//  My Places
//
//  Created by Alexander Popov on 11.05.2022.
//

import UIKit

class MainViewController: UITableViewController {
    
    let restaurantNames = [
    "У Декса","Чайший Восход","Дикий гриль","Вита","Зиклесс",
    "Burger Heroes", "Kitchen", "Bonsai","X.O","Sherlock Holmes",
    "Speak Easy", "Morris Pub","Классик", "Love&Life", "Шок"
    ]
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return restaurantNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        cell.nameLabel.text = restaurantNames[indexPath.row]
        cell.imageOfPlace.image = UIImage(named: restaurantNames[indexPath.row])
        cell.imageOfPlace.layer.cornerRadius = cell.imageOfPlace.frame.size.height/2
        cell.imageOfPlace.clipsToBounds = true
        return cell
    }
    
    // MARK: - Table view Deligate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
