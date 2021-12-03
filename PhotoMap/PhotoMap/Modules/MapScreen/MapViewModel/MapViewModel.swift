//
//  MapViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol MapViewModelProtocol: AnyObject {
    func takePhoto()
    func choosePhoto()
}

class MapViewModel: NSObject {
    weak var view: MapViewInput!
    var coordinator: MapCoordinatorDelegate!
}

extension MapViewModel: MapViewModelProtocol {
    
    func takePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            view.presentPicker(picker: picker)
        }
    }
    
    func choosePhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            view.presentPicker(picker: picker)
        }
    }
}

extension MapViewModel: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        picker.dismiss(animated: false, completion: nil)
        
        let cardModel = PhotoCardModel(image: image, date: Date().timeIntervalSince1970, stringDate: "", category: .friends, text: "")
        view.showPopupView(with: cardModel)
    }
}
