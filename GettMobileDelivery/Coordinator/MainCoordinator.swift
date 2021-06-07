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
    private let viewModel = MainVIewModel()
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        viewModel.showEndOfDeliviry
            .drive(onNext: { [weak self]  isEnd in
                guard let self = self else { return }
                if isEnd {
                    self.showAlert()
                }
            })
            .disposed(by: viewModel.disposeBag)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
        
    }
}

extension MainCoordinator {
    func showAlert() {
        let alertController = UIAlertController(title: "Delivery Completed!", message: "Now go and drink a beer or two!", preferredStyle: .alert)
        self.navigationController.present(alertController, animated: true, completion: nil)
    }
}
