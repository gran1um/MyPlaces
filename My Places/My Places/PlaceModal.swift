//
//  PalceModal.swift
//  My Places
//
//  Created by Alexander Popov on 15.05.2022.
//

import RealmSwift

class Place: Object{
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData : Data?
        
    let restaurantNames = [
    "У Декса","Чайший Восход","Дикий гриль","Вита","Зиклесс",
    "Burger Heroes", "Kitchen", "Bonsai","X.O","Sherlock Holmes",
    "Speak Easy", "Morris Pub","Классик", "Love&Life", "Шок"
    ]
    
    func savePlaces(){
        
        for place in restaurantNames {
            
            let image = UIImage(named: place)
            
            guard let imageData = image?.pngData() else { return }
            
            let newPlace = Place()
            newPlace.name = place
            newPlace.location = "Ryazan"
            newPlace.type = "Restaurant"
            newPlace.imageData = imageData
            
            StorageManager.saveObject(newPlace)
        }
    }
}
