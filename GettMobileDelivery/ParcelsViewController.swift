//
//  ParcelsViewController.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 05/06/2021.
//

import UIKit
import RxSwift
import RxCocoa

class ParcelsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    let disposeBag = DisposeBag()
    var viewModel:  ParcelsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindRx()
        
    }
    
    
    func bindRx() {
        //tableView.register(UINib(nibName: "ParcelTableViewCell", bundle: nil), forCellReuseIdentifier: "parcelCell")

        viewModel.items.bind(to: tableView.rx.items(cellIdentifier: "parcelCell", cellType: ParcelTableViewCell.self)) { (row,item,cell) in
            cell.config(parcel: item)
        }.disposed(by: disposeBag)
        
        
    }
}
