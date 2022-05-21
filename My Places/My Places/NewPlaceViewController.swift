//
//  NewPlaceViewController.swift
//  My Places
//
//  Created by Alexander Popov on 15.05.2022.
//

import UIKit

class NewPlaceViewController: UITableViewController {
    
    var newPlace = Place()
    var imageIsChaned = false
    
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.newPlace.savePlaces()
        }
        
        
        //Убираем разлиновку tableview, в новых версиях iOS убирается автоматически
        tableView.tableFooterView = UIView()
        
        saveButton.isEnabled = false
        
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
    }

    // MARK: table view delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            
            let cameraIcon = UIImage(named: "camera")
            let photoIcon = UIImage(named: "photo")
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction.init(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photo = UIAlertAction.init(title: "Photo", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photo.setValue(photoIcon, forKey: "image")
            photo.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photo)
            actionSheet.addAction(cancel)
            
            present(actionSheet, animated: true)
        }
        else{
            view.endEditing(true)
        }
    }

    func saveNewPlace(){
        
        var image: UIImage?
        
        if imageIsChaned{
            image = placeImage.image
        }
        else{
            image = UIImage(named: "imagePlaceholder")
        }
        
//        newPlace = Place(name: placeName.text!, location: placeLocation.text, type: placeType.text, image: image, restaurantImage: nil)
    }

    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
}


// MARK: Text field delegate

extension NewPlaceViewController: UITextFieldDelegate{
    //  Скрываем клавиатуру по нажатию done
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    @objc private func textFieldChanged(){
        if placeName.text?.isEmpty == false {
            saveButton.isEnabled = true
        }
        else{
            saveButton.isEnabled = false
        }
    }
}

// MARK: Work with image

extension NewPlaceViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func chooseImagePicker(source: UIImagePickerController.SourceType){
        
        if UIImagePickerController.isSourceTypeAvailable(source){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        placeImage.image = info[.editedImage ] as! UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChaned = true
        
        dismiss(animated: true)
    }
}
