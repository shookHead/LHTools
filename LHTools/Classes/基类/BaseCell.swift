//
//  BaseCell.swift
//  wenzhuanMerchants
//
//  Created by zbkj on 2020/7/15.
//  Copyright © 2020 baymax. All rights reserved.
//

import UIKit

open class BaseCell: UITableViewCell {

    open override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
}


public protocol CustomCellProtocol {
    static func cellFromNib(with table:UITableView) -> Self
    static func cell(with table:UITableView) -> Self
}

public extension CustomCellProtocol{
    static func cellFromNib(with table:UITableView) -> Self{
        let c = self as! UITableViewCell.Type
        let Identity = String(describing: c.classForCoder())
        var cell = table.dequeueReusableCell(withIdentifier: Identity) as? Self
        if cell == nil {
            let nib  = UINib(nibName: Identity, bundle: nil)
            print(nib)
            table.register(nib, forCellReuseIdentifier: Identity)
            cell = (table.dequeueReusableCell(withIdentifier: Identity)) as? Self
        }
        return cell!
    }
    static func cell(with table:UITableView) -> Self{
        let c = self as! UITableViewCell.Type
        let Identity = String(describing: c.classForCoder())
        var cell = table.dequeueReusableCell(withIdentifier: Identity) as? Self
        if cell == nil {
            table.register(c, forCellReuseIdentifier: Identity)
            cell = table.dequeueReusableCell(withIdentifier: Identity) as? Self
        }
        return cell!
    }
}

extension UITableViewCell:CustomCellProtocol{
    public static var nib:UINib{
        let name = String(describing: self.classForCoder())
        return UINib.init(nibName: name, bundle: Bundle.main)
    }
}


