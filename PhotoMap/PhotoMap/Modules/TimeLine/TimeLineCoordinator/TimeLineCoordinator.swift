//
//  TimeLineCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/8/21.
//

import UIKit

protocol TimeLineCoordinatorDelegate: AnyObject {
    func showImage(model: PhotoCardModel)
    func showCategories()
}

class TimeLineCoordinator: Coordinator {
    
    private weak var rootNavigationController: UINavigationController?
    private var childCoordinators = [Coordinator]()
    
    init(rootNavigationController: UINavigationController) {
        self.rootNavigationController = rootNavigationController
    }
    
    func start() {
        
    }
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: {$0 === childCoordinator}) else { return }
        childCoordinators.remove(at: index)
    }
    
    
}

extension TimeLineCoordinator: TimeLineCoordinatorDelegate {
    
    func showImage(model: PhotoCardModel) {
        guard let rootNavigationController = rootNavigationController else { return }
        let photoCoordinator = PhotoScreenCoordinator(rootNavigationController: rootNavigationController, photoModel: model)
        photoCoordinator.onEnd = { [unowned photoCoordinator] in
            self.remove(childCoordinator: photoCoordinator)
        }
        photoCoordinator.start()
        add(childCoordinator: photoCoordinator)
    }
    
    func showCategories() {
        guard let rootNavigationController = rootNavigationController else { return }
        let categoryCoordinator = CategoryCoordinator(rootNavigationController: rootNavigationController)
        categoryCoordinator.onEnd = { [unowned categoryCoordinator] in
            self.remove(childCoordinator: categoryCoordinator)
        }
        categoryCoordinator.start()
        add(childCoordinator: categoryCoordinator)
    }
}
