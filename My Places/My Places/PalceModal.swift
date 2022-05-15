//
//  PalceModal.swift
//  My Places
//
//  Created by Alexander Popov on 15.05.2022.
//

import Foundation


struct Place{
    
    var name: String
    var location: String
    var type: String
    var image: String
    
    
    static let restaurantNames = [
    "У Декса","Чайший Восход","Дикий гриль","Вита","Зиклесс",
    "Burger Heroes", "Kitchen", "Bonsai","X.O","Sherlock Holmes",
    "Speak Easy", "Morris Pub","Классик", "Love&Life", "Шок"
    ]
    
    static func getPlaces() -> [Place]{
        var places = [Place]()
        
        for place in restaurantNames {
            places.append(Place(name: place, location: "Рязань", type: "Ресторан", image: place))
        }
        
        return places
    }
}
