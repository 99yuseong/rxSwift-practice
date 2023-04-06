//
//  MenuDTO.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/29.
//

import Foundation

struct MenusDTO: Codable {
    let menus: [MenuDTO]
}

struct MenuDTO: Codable {
    var name: String
    var price: Int
    
    func toDomain() -> Menu {
        return Menu(name: self.name, price: self.price, count: 0)
    }
}
