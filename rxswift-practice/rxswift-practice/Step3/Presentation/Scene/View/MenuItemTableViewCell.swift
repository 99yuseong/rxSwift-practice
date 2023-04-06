//
//  MenuItemTableViewCell.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxRelay

class MenuItemTableViewCell: UITableViewCell {

    // MARK - Property
    static let identifier = "MenuItemTableViewCell"
    
    private var cellDisposeBag = DisposeBag() // Cell이 deinit() 될 때, dispose
    var disposeBag = DisposeBag() // Cell이 Reuse 될 때, dispose
    
    lazy var onCountChanged: (Int) -> Void = { self.onChanged.onNext($0) }
    
    let onData = BehaviorSubject<Menu>(value: Menu.mock)
    let onChanged = PublishSubject<Int>()
    
    // MARK - LifeCycle
    override init(style: MenuItemTableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureSubviews()
        configureLayout()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    // MARK - UI
    lazy var plusBtn = UIButton().then {
        $0.setTitle("+", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
    }
    
    lazy var minusBtn = UIButton().then {
        $0.setTitle("-", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
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
    
    
    // MARK - Configure
    private func configureSubviews() {
        contentView.addSubview(btnStack)
        contentView.addSubview(menuNameStack)
        contentView.addSubview(price)
    }
    
    private func configureLayout() {
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
    private func bindUI() {
        onData // 얘는 cell이 deinit 될 때까지 계속 켜져 있어야해
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] menu in
                self?.setMenuName(title: menu.name)
                self?.setMenuPrice(for: menu.price)
                self?.setCount(for: menu.count)
            })
            .disposed(by: cellDisposeBag) // 이녀석이 대단한 녀석이었군
        
        plusBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in self?.onChanged.onNext(1) })
            .disposed(by: cellDisposeBag)
        
        minusBtn.rx.tap
            .asObservable()
            .subscribe(onNext: { [weak self] in self?.onChanged.onNext(-1) })
            .disposed(by: cellDisposeBag)
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
