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
        viewModel.showParcels
            .drive(onNext: { [weak self]  item in
            guard let self = self else { return }
     
        })
        .disposed(by: viewModel.disposeBag)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainViewController") as! MainViewController
        vc.viewModel = viewModel
        navigationController.pushViewController(vc, animated: true)
        
    }
}
