//
//  CustomTableViewCell.swift
//  My Places
//
//  Created by Alexander Popov on 13.05.2022.
//

import UIKit
import Cosmos

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var imageOfPlace: UIImageView! {
        didSet{
            imageOfPlace.layer.cornerRadius = imageOfPlace.frame.size.height / 2
            imageOfPlace.clipsToBounds = true
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!{
        didSet{
            cosmosView.settings.fillMode = .full
            cosmosView.settings.updateOnTouch = false
        }
    }
    
}
