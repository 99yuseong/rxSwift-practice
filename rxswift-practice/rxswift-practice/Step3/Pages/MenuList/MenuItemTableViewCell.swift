//
//  MenuItemTableViewCell.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then

class MenuItemTableViewCell: UITableViewCell {
    
    private lazy var plusBtn = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        
        $0.addTarget(self, action: #selector(addItems), for: .touchUpInside)
    }
    
    private lazy var minusBtn = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        
        $0.addTarget(self, action: #selector(removeItems), for: .touchUpInside)
    }
    
    private var menuName = UILabel().then {
        $0.text = "곰튀김"
        $0.font = UIFont.systemFont(ofSize: 20, weight: .medium)
    }
    
    private var countLeft = UILabel().then {
        $0.text = "("
        $0.font = UIFont.systemFont(ofSize: 17, weight: .thin)
        $0.textColor = .purple
    }
    
    private var menuCount = UILabel().then {
        $0.text = "0"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .thin)
        $0.textColor = .purple
    }
    
    private var countRight = UILabel().then {
        $0.text = ")"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .thin)
        $0.textColor = .purple
    }
    
    private lazy var btnStack = UIStackView(arrangedSubviews: [plusBtn, minusBtn])
    private lazy var countStack = UIStackView(arrangedSubviews: [countLeft, menuCount, countRight])
    private lazy var menuNameStack = UIStackView(arrangedSubviews: [menuName, countStack]).then { $0.spacing = 8 }
    private var price = UILabel().then {
        $0.text = "1,000"
        $0.textColor = .darkGray
        $0.font = UIFont.systemFont(ofSize: 17)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        contentView.addSubview(btnStack)
        contentView.addSubview(menuNameStack)
        contentView.addSubview(price)
        
        plusBtn.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(28)
        }
        
        minusBtn.snp.makeConstraints { make in
            make.width.equalTo(32)
            make.height.equalTo(28)
        }
        
        btnStack.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview().offset(8)
            make.leading.equalToSuperview().offset(20)
            make.bottom.lessThanOrEqualToSuperview().offset(-8)
        }
        
        menuNameStack.snp.makeConstraints { make in
            make.leading.equalTo(btnStack.snp.trailing).offset(16)
            make.centerY.equalTo(btnStack)
        }
        
        price.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalTo(btnStack)
            make.leading.greaterThanOrEqualTo(menuNameStack.snp.trailing).offset(16)
        }
    }
    
}

extension MenuItemTableViewCell {
    @objc private func addItems() {
        print("+ is pressed")
    }
    
    @objc private func removeItems() {
        print("- is pressed")
    }
    
    func setMenuName(title: String) {
        self.menuName.text = title
    }
    
    func setMenuPrice(for price: Int) {
        self.price.text = "\(price)"
    }
    
    func setCount(for count: Int) {
        self.menuCount.text = "\(count)"
    }
}
