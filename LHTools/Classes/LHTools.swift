//
//  LHTools.swift
//  LHTools_Example
//
//  Created by 蔡林海 on 2021/5/28.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import UIKit

public class LHTools: NSObject {
    public static func get (){
        let path = Bundle.main.path(forResource: "city_db", ofType: "sqlite")
        print(path)
    }
}
