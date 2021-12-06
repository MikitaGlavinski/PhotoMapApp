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
    func showError(error: Error)
    func addPin(model: PhotoCardModel)
}

class MapViewController: UIViewController {
    
    private var locationManager: CLLocationManager!
    var viewModel: MapViewModelProtocol!
    @IBOutlet weak var mapView: MKMapView!
    
    private var photoModels = [PhotoCardModel]()
    
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
        mapView.delegate = self
        addGestures()
    }
    
    private func addGestures() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPress.minimumPressDuration = 1.5
        mapView.addGestureRecognizer(longPress)
    }
    
    private func showActionSheet(touchCoordinate: CLLocationCoordinate2D) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let takePhotoAction = UIAlertAction(title: "Take a Picture", style: .default) { _ in
            self.viewModel.takePhoto(touchCoordinate: touchCoordinate)
        }
        let choosePhotoAction = UIAlertAction(title: "Choose From Library", style: .default) { _ in
            self.viewModel.choosePhoto(touchCoordinate: touchCoordinate)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(takePhotoAction)
        alert.addAction(choosePhotoAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func getPhoto(_ sender: Any) {
        showActionSheet(touchCoordinate: mapView.userLocation.coordinate)
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
    
    @objc private func handleLongPress(_ touch: UITouch) {
        let coordinate = mapView.convert(touch.location(in: mapView), toCoordinateFrom: mapView)
        showActionSheet(touchCoordinate: coordinate)
    }
}

extension MapViewController: MapViewInput {
    
    func presentPicker(picker: UIImagePickerController) {
        present(picker, animated: true, completion: nil)
    }
    
    func showPopupView(with model: PhotoCardModel) {
        let popup = PopupView(frame: CGRect(x: 20.0, y: 150.0, width: UIScreen.main.bounds.width - 40.0, height: UIScreen.main.bounds.height - 300.0), model: model)
        popup.delegate = self
        view.addSubview(popup)
    }
    
    func showError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func addPin(model: PhotoCardModel) {
        photoModels.append(model)
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: model.lat, longitude: model.lon)
        pin.title = model.id
        mapView.addAnnotation(pin)
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
        viewModel.uploadImageData(from: model)
    }
    
    func cancel() {
        viewModel.resetTouchCoordinate()
    }
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let index = photoModels.firstIndex(where: {$0.id == annotation.title}) else {
            return nil
        }
        let imageView = UIImageView(image: UIImage(named: "annotation"))
        let view = MKAnnotationView()
        view.frame = CGRect(x: 0, y: 0, width: 40, height: 50)
        view.centerOffset = CGPoint(x: 0, y: -25)
        imageView.frame = view.bounds
        view.addSubview(imageView)
        switch photoModels[index].category {
        case .friends:
            imageView.tintColor = .systemOrange
        case .nature:
            imageView.tintColor = .systemGreen
        case .standart:
            imageView.tintColor = .systemBlue
        }
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("pin")
    }
}
