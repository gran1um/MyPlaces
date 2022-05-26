//
//  NewPlaceViewController.swift
//  My Places
//
//  Created by Alexander Popov on 15.05.2022.
//

import UIKit
import Cosmos

class NewPlaceViewController: UITableViewController {
    
    var currentPlace: Place!
    var imageIsChaned = false
    var currentRating = 0.0
    
    @IBOutlet weak var placeType: UITextField!
    @IBOutlet weak var placeLocation: UITextField!
    @IBOutlet weak var placeName: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var cosmosView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 1200, width: tableView.frame.size.width, height: 1))
        //Убираем разлиновку tableview, в новых версиях iOS убирается автоматически
        saveButton.isEnabled = false
        placeName.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        setupEditScreen()
        
        cosmosView.settings.fillMode = .half
        cosmosView.didTouchCosmos = { rating in
            self.currentRating = rating
        }
        
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
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier != "showMap" {return}
        
        let mapVC = segue.destination as! MapViewController
        mapVC.place.name = placeName.text!
        mapVC.place.location = placeLocation.text
        mapVC.place.type = placeType.text
        mapVC.place.imageData = placeImage.image?.pngData()
        
    }

    func savePlace(){
        
        let image = imageIsChaned ? placeImage.image : UIImage(named: "imagePlaceholder")

        let newPlace = Place(name: placeName.text!,
                             location: placeLocation.text,
                             type: placeType.text,
                             imageData: image?.pngData(),
                             rating: Double(ratingControl.rating))
        
        if currentPlace != nil{
            try! realm.write{
                currentPlace?.name = newPlace.name
                currentPlace?.location = newPlace.location
                currentPlace?.type = newPlace.type
                currentPlace?.imageData = newPlace.imageData
                currentPlace?.rating = newPlace.rating
            }
        }
        else{
            StorageManager.saveObject(newPlace)
        }
    }
    
    private func setupEditScreen(){
        if currentPlace !=  nil {
            setupNavigationBar()
            imageIsChaned = true
            
            guard let data = currentPlace?.imageData, let image = UIImage(data: data) else {return}
            placeImage.image = image
            placeImage.contentMode = .scaleAspectFill
            placeName.text = currentPlace?.name
            placeType.text = currentPlace?.type
            placeLocation.text = currentPlace?.location
            ratingControl.rating = Int(currentPlace.rating)
            
        }
    }
    
    private func setupNavigationBar(){
        if let topItem = navigationController?.navigationBar.topItem{
            topItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItems = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
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
        placeImage.image = info[.editedImage ] as? UIImage
        placeImage.contentMode = .scaleAspectFill
        placeImage.clipsToBounds = true
        
        imageIsChaned = true
        
        dismiss(animated: true)
    }
}
