//
//  MapViewModel.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit
import CoreLocation

protocol MapViewModelProtocol: AnyObject {
    func takePhoto(touchCoordinate: CLLocationCoordinate2D)
    func choosePhoto(touchCoordinate: CLLocationCoordinate2D)
    func uploadImageData(from model: PhotoCardModel)
    func resetTouchCoordinate()
}

class MapViewModel: NSObject {
    weak var view: MapViewInput!
    var coordinator: MapCoordinatorDelegate!
    private var touchCoordinate: CLLocationCoordinate2D?
    
    private var queue = DispatchQueue(label: "MapViewModelQueue", qos: .background)
}

extension MapViewModel: MapViewModelProtocol {
    
    func takePhoto(touchCoordinate: CLLocationCoordinate2D) {
        self.touchCoordinate = touchCoordinate
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .camera
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            view.presentPicker(picker: picker)
        }
    }
    
    func choosePhoto(touchCoordinate: CLLocationCoordinate2D) {
        self.touchCoordinate = touchCoordinate
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.image"]
            picker.allowsEditing = true
            view.presentPicker(picker: picker)
        }
    }
    
    func uploadImageData(from model: PhotoCardModel) {
        queue.async {
            guard
                let imageData = model.image.jpegData(compressionQuality: 0.1),
                let token = SecureStorageService.shared.obtainToken()
            else { return }
            FirebaseService.shared.uploadImage(data: imageData) { result in
                switch result {
                case .success(let url):
                    let restModel = PhotoRestModel(cardModel: model, imageUrl: url)
                    do {
                        let data = try DictionaryEncoder().encode(restModel)
                        FirebaseService.shared.setDataAt(path: "\(token)/\(restModel.id)", data: data) { result in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    self.view.addPin(model: model)
                                }
                            case .failure(let error):
                                DispatchQueue.main.async {
                                    self.view.showError(error: error)
                                }
                            }
                        }
                    } catch let error {
                        DispatchQueue.main.async {
                            self.view.showError(error: error)
                        }
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.view.showError(error: error)
                    }
                }
            }
        }
    }
    
    func resetTouchCoordinate() {
        touchCoordinate = nil
    }
}

extension MapViewModel: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.editedImage] as? UIImage else { return }
        picker.dismiss(animated: false, completion: nil)
        
        guard let touchCoordinate = touchCoordinate else { return }
        let cardModel = PhotoCardModel(
            image: image,
            date: Date().timeIntervalSince1970,
            stringDate: "",
            category: .friends,
            text: "",
            lat: touchCoordinate.latitude,
            lon: touchCoordinate.longitude
        )
        view.showPopupView(with: cardModel)
    }
}
