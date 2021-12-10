//
//  MapCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol MapCoordinatorDelegate: AnyObject {
    func showPhoto(with model: PhotoCardModel)
    func showCategories(categories: [CategoryModel], delegate: CategorySelectionDelegate)
}

class MapCoordinator: Coordinator {
    
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    
    private var deepLinkPath: String?
    
    init(rootNavigationController: UINavigationController, deepLinkPath: String? = nil) {
        self.rootNavigationController = rootNavigationController
        self.deepLinkPath = deepLinkPath
    }
    
    func start() {
        guard let rootNavigationController = rootNavigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let mapView = storyboard.instantiateViewController(withIdentifier: "Map") as? MapViewController else { return }
        let tabBarController = UITabBarController()
        let mapViewModel = MapViewModel()
        mapView.viewModel = mapViewModel
        mapViewModel.view = mapView
        mapViewModel.coordinator = self
        
        let timeLineCoordinator = TimeLineCoordinator(rootNavigationController: rootNavigationController)
        guard let timeLineView = storyboard.instantiateViewController(withIdentifier: "TimeLine") as? TimeLineViewController else { return }
        let timeLineViewModel = TimeLineViewModel()
        timeLineView.viewModel = timeLineViewModel
        timeLineViewModel.view = timeLineView
        timeLineViewModel.coordinator = timeLineCoordinator
        
        tabBarController.setViewControllers([mapView, timeLineView], animated: false)
        rootNavigationController.navigationBar.isHidden = true
        rootNavigationController.setViewControllers([tabBarController], animated: true)
        
        if let deepLinkPath = deepLinkPath {
            FirebaseService.shared.getUserPhotos { result in
                switch result {
                case .success(let photos):
                    guard let index = photos.firstIndex(where: {URL(string: $0.imageUrl)?.path == deepLinkPath}) else { return }
                    let photoCardModel = PhotoCardModel(restModel: photos[index])
                    self.showPhoto(with: photoCardModel)
                case .failure:
                    return
                }
            }
        }
    }
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: {$0 === childCoordinator}) else { return }
        childCoordinators.remove(at: index)
    }
    
    
}

extension MapCoordinator: MapCoordinatorDelegate {
    
    func showPhoto(with model: PhotoCardModel) {
        guard let rootNavigationController = rootNavigationController else { return }
        let photoCoordinator = PhotoScreenCoordinator(rootNavigationController: rootNavigationController, photoModel: model)
        photoCoordinator.onEnd = { [unowned photoCoordinator] in
            self.remove(childCoordinator: photoCoordinator)
        }
        photoCoordinator.start()
        add(childCoordinator: photoCoordinator)
    }
    
    func showCategories(categories: [CategoryModel], delegate: CategorySelectionDelegate) {
        guard let rootNavigationController = rootNavigationController else { return }
        let categoryCoordinator = CategoryCoordinator(rootNavigationController: rootNavigationController, categories: categories, delegate: delegate)
        categoryCoordinator.onEnd = { [unowned categoryCoordinator] in
            self.remove(childCoordinator: categoryCoordinator)
        }
        categoryCoordinator.start()
        add(childCoordinator: categoryCoordinator)
    }
}
