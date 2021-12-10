//
//  AuthCoordinator.swift
//  PhotoMap
//
//  Created by Mikita Glavinski on 12/2/21.
//

import UIKit

protocol AuthCoordinatorDelegate {
    func routeToRegister()
    func routeToMainScreen()
}

class AuthCoordinator: Coordinator {
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
        guard let view = storyboard.instantiateViewController(withIdentifier: "Auth") as? AuthViewController else { return }
        let viewModel = AuthViewModel()
        view.viewModel = viewModel
        viewModel.view = view
        viewModel.coordinator = self
        
        rootNavigationController.setViewControllers([view], animated: true)
    }
    
    func add(childCoordinator: Coordinator) {
        childCoordinators.append(childCoordinator)
    }
    
    func remove(childCoordinator: Coordinator) {
        guard let index = childCoordinators.firstIndex(where: {$0 === childCoordinator}) else { return }
        childCoordinators.remove(at: index)
    }
}

extension AuthCoordinator: AuthCoordinatorDelegate {
    func routeToRegister() {
        guard let rootNavigationController = rootNavigationController else { return }
        let registerCoordinator = RegisterCoordinator(rootNavigationController: rootNavigationController)
        registerCoordinator.onEnd = { [unowned registerCoordinator] in
            self.remove(childCoordinator: registerCoordinator)
        }
        registerCoordinator.start()
        add(childCoordinator: registerCoordinator)
    }
    
    func routeToMainScreen() {
        guard let rootNavigationController = rootNavigationController else { return }
        let mapCoordinator = MapCoordinator(rootNavigationController: rootNavigationController)
        mapCoordinator.start()
        if let deepLinkPath = deepLinkPath {
            FirebaseService.shared.getUserPhotos { result in
                switch result {
                case .success(let photos):
                    guard let index = photos.firstIndex(where: {URL(string: $0.imageUrl)?.path == deepLinkPath}) else { return }
                    let photoCardModel = PhotoCardModel(restModel: photos[index])
                    mapCoordinator.showPhoto(with: photoCardModel)
                case .failure:
                    return
                }
            }
        }
    }
}
