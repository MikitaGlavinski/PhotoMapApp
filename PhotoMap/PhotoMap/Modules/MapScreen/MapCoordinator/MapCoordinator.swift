//
//  MapCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol MapCoordinatorDelegate: AnyObject {
    
}

class MapCoordinator: Coordinator {
    
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    
    init(rootNavigationController: UINavigationController) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        guard let rootNavigationController = rootNavigationController else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let view = storyboard.instantiateViewController(withIdentifier: "Map") as? MapViewController else { return }
        let tabBarController = UITabBarController()
        let viewModel = MapViewModel()
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.coordinator = self
        
        tabBarController.setViewControllers([view], animated: false)
        rootNavigationController.setViewControllers([tabBarController], animated: true)
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
    
}
