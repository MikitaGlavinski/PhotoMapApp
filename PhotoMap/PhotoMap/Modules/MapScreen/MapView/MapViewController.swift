//
//  MapViewController.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit
import CoreLocation
import MapKit

protocol MapViewInput: AnyObject {
    func presentPicker(picker: UIImagePickerController)
    func showPopupView(with model: PhotoCardModel)
}

class MapViewController: UIViewController {
    
    private var locationManager: CLLocationManager!
    var viewModel: MapViewModelProtocol!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
    }
    
    @IBAction func getPhoto(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a Picture", style: .default) { _ in
            self.viewModel.takePhoto()
        }
        let choosePhotoAction = UIAlertAction(title: "Choose From Library", style: .default) { _ in
            self.viewModel.choosePhoto()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(takePhotoAction)
        alert.addAction(choosePhotoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func changeLocationStyle(_ sender: Any) {
        
    }
    
    @objc private func keyboardWillAppear(_ notification: Notification) {
        view.frame.origin.y = 0
        guard let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let tabBarHeight = tabBarController?.tabBar.frame.height else { return }
        view.frame.origin.y -= size.height - tabBarHeight
    }
    
    @objc private func keyboardWillHide() {
        view.frame.origin.y = 0
    }
}

extension MapViewController: MapViewInput {
    
    func presentPicker(picker: UIImagePickerController) {
        present(picker, animated: true, completion: nil)
    }
    
    func showPopupView(with model: PhotoCardModel) {
        let popup = PopupView(frame: CGRect(x: 20.0, y: 150, width: UIScreen.main.bounds.width - 40.0, height: UIScreen.main.bounds.height - 300.0), model: model)
        popup.delegate = self
        view.addSubview(popup)
    }
}

extension MapViewController: PopupViewDelegate {
    
    func changeCategory(completion: @escaping (Category?) -> ()) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let friendsAction = UIAlertAction(title: "FRIENDS", style: .default) { _ in
            completion(.friends)
        }
        let natureAction = UIAlertAction(title: "NATURE", style: .default) { _ in
            completion(.nature)
        }
        let defaultAction = UIAlertAction(title: "DEFAULT", style: .default) { _ in
            completion(.standart)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(friendsAction)
        alert.addAction(natureAction)
        alert.addAction(defaultAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func savePhoto(model: PhotoCardModel) {
        
    }
}
