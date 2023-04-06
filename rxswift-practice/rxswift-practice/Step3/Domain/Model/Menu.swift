//
//  Menu.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/04/03.
//

import Foundation

struct Menu {
    static let mock = Menu(name: "Mock", price: 100, count: 0)
    
    var name: String
    var price: Int
    var count: Int
    
    init(name: String, price: Int, count: Int) {
        self.name = name
        self.price = price
        self.count = count
    }
    
    func countUpdated(_ count: Int) -> Menu {
        return Menu(name: name, price: price, count: count)
    }
}
