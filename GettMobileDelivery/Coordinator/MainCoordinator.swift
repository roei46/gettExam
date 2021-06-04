//
//  MainCoordinator.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 04/06/2021.
//

import Foundation
import UIKit

final class MainCoordinator: Coordinator {
    let navigationController: UINavigationController
//    private let viewModel = ToDoListViewModel()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = MainVIewModel()
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
        
    }
}
