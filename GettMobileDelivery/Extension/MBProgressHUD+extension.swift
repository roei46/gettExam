//
//  MBProgressHUD+extension.swift
//  GettMobileDelivery
//
//  Created by Roei Baruch on 08/06/2021.
//

import Foundation
import MBProgressHUD
import RxSwift
import RxCocoa

extension Reactive where Base: MBProgressHUD {
    public var animation: Binder<Bool> {
        return Binder(self.base) { hud, show in
            guard let view = UIApplication.shared.keyWindow else { return }
            if show {
                if hud.superview == nil {
                    view.addSubview(hud)
                }
                hud.show(animated: true)
            } else {
                hud.hide(animated: true)
            }
        }
    }
}
