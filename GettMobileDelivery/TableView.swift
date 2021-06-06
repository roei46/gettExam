//
//  TableView.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 06/06/2021.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class TableView: UIView {
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()

    var vm: ParcelsViewModel!
    
    init(frame: CGRect, viewModel: ParcelsViewModel) {
        super.init(frame: frame)
        vm = viewModel
        Bundle.main.loadNibNamed("TableView", owner: self, options: nil)
        tableView.frame = self.bounds
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(tableView)
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")

        vm.items.bind(to: tableView.rx.items(cellIdentifier: "TableViewCell", cellType: TableViewCell.self)) { (row,item,cell) in
            if item.display_identifier == "header" {
                cell.config(name: viewModel.title)
            } else {
                cell.config(name: item.display_identifier)

            }
        }.disposed(by: disposeBag)

    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
