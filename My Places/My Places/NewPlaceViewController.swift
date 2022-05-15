//
//  NewPlaceViewController.swift
//  My Places
//
//  Created by Alexander Popov on 15.05.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Убираем разлиновку tableview, в новых версиях iOS убирается автоматически
        tableView.tableFooterView = UIView()
        
    }

    // MARK: table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
        }
        else{
            view.endEditing(true)
        }
    }


}


// MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate{
    //  Скрываем клавиатуру по нажатию done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
}
