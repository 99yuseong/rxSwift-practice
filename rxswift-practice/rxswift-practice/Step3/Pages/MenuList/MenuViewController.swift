//
//  MenuViewController.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then


class MenuViewController: UIViewController {

    // MARK - Header
    private var headerTitle = UILabel().then {
        $0.text = "Bear Fried Center"
        $0.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
    }
    
    private var indicator = UIActivityIndicatorView().then {
        $0.style = UIActivityIndicatorView.Style.large
        $0.tintColor = .lightGray
        $0.startAnimating()
    }
    
    // MARK - TableView
    private var menuTableView = UITableView().then {
        $0.layer.backgroundColor = UIColor.white.cgColor
        $0.register(MenuItemTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }
    
    // MARK - Order
    private var orderTitle = UILabel().then {
        $0.text = "Your Orders"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    private lazy var clearBtn = UIButton().then {
        $0.setTitle("Clear", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        
        $0.addTarget(self, action: #selector(onClear), for: .touchUpInside)
    }
    
    private var itemCount = UILabel().then {
        $0.text = "0"
        $0.textColor = .purple
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    private var items = UILabel().then {
        $0.text = "Items"
        $0.textColor = .purple
        $0.font = UIFont.systemFont(ofSize: 17, weight: .light)
    }
    
    private var totalPrice = UILabel().then {
        $0.text = "1,000,000"
        $0.font = UIFont.systemFont(ofSize: 50, weight: .bold)
    }
    
    private lazy var itemStack = UIStackView(arrangedSubviews: [itemCount, items]).then {
        $0.spacing = 8
    }
    
    // MARK - OrderBtn
    private lazy var orderBtn = UIButton().then {
        $0.setTitle("ORDER", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .black
        
        $0.addTarget(self, action: #selector(onOrder), for: .touchUpInside)
    }
    
    private lazy var headerContainer = UIView().then {
        $0.addSubview(headerTitle)
        $0.addSubview(indicator)
    }
    
    private lazy var orderCotainer = UIView().then {
        $0.addSubview(orderTitle)
        $0.addSubview(clearBtn)
        $0.addSubview(itemStack)
        $0.addSubview(totalPrice)
        $0.backgroundColor = .lightGray
    }
    
    private lazy var ContainerView = UIStackView(arrangedSubviews: [
        headerContainer,
        menuTableView,
        orderCotainer,
        orderBtn])
        .then {
        $0.axis = .vertical
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupDelegate()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
    }
    
    private func setupLayout() {
        self.view.addSubview(ContainerView)
        
        ContainerView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        headerContainer.snp.makeConstraints { make in
            make.height.equalTo(60)
        }
        
        headerTitle.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.trailing.lessThanOrEqualToSuperview().offset(-20)
        }
        
        indicator.snp.makeConstraints { make in
            make.leading.equalTo(headerTitle.snp.trailing).offset(16)
            make.centerY.equalToSuperview()
        }
        
        orderTitle.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.leading.equalToSuperview().offset(20)
        }
        
        clearBtn.snp.makeConstraints { make in
            make.width.greaterThanOrEqualTo(48)
            make.height.equalTo(36)
            make.leading.equalTo(orderTitle.snp.trailing).offset(16)
            make.centerY.equalTo(orderTitle)
        }
        
        itemStack.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualTo(clearBtn.snp.trailing).offset(20)
            make.centerY.equalTo(orderTitle)
            make.trailing.equalToSuperview().offset(-20)
        }
        
        totalPrice.snp.makeConstraints { make in
            make.top.equalTo(itemStack.snp.bottom).offset(16)
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview().offset(-16)
        }
        
        orderBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
    }
    
    private func setupDelegate() {
        self.menuTableView.delegate = self
        self.menuTableView.dataSource = self
    }
    
}

extension MenuViewController {
    @objc private func onClear() {
        print("clear")
    }
    
    @objc private func onOrder() {
        print("Order")
        let vc = OrderViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MenuItemTableViewCell
        
        cell.setMenuName(title: "MENU \(indexPath.row)")
        cell.setMenuPrice(for: indexPath.row * 100)
        cell.setCount(for: 0)
        
        return cell
    }
    
    
}

#if DEBUG

import SwiftUI

struct MenuViewController_ViewPresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        MenuViewController()
    }
    
    
}

struct MenuViewController_PreviewProvider : PreviewProvider {
    static var previews: some View {
        MenuViewController_ViewPresentable()
            .ignoresSafeArea()
    }
}

#endif
