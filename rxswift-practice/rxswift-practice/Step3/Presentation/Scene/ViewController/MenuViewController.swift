//
//  MenuViewController.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxViewController

final class MenuViewController: UIViewController {
    
    // MARK - Property
    var viewModel: MenuViewModel?
    private let disposeBag = DisposeBag()
    
    // MARK - UI
    private var headerTitle = UILabel().then {
        $0.text = "Bear Fried Center"
        $0.font = UIFont.systemFont(ofSize: 32, weight: .heavy)
    }
    
    private var indicator = UIActivityIndicatorView().then {
        $0.style = UIActivityIndicatorView.Style.large
        $0.tintColor = .lightGray
        $0.startAnimating()
    }
    
    private var menuTableView = UITableView().then {
        $0.layer.backgroundColor = UIColor.white.cgColor
        $0.register(MenuItemTableViewCell.self, forCellReuseIdentifier: "MenuItemTableViewCell")
    }

    private var orderTitle = UILabel().then {
        $0.text = "Your Orders"
        $0.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    }
    
    private lazy var clearBtn = UIButton().then {
        $0.setTitle("Clear", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15)
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
    
    private lazy var orderBtn = UIButton().then {
        $0.setTitle("ORDER", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        $0.backgroundColor = .black
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
    
    // MARK - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCommonUI()
        configureSubViews()
        configureLayout()
        bindViewModel()
    }
    
    
    // MARK - Configure
    private func configureCommonUI() {
        self.view.backgroundColor = .white
        configureTableView()
    }
    
    private func configureTableView() {
        menuTableView.refreshControl = UIRefreshControl()
    }
    
    private func configureSubViews() {
        self.view.addSubview(ContainerView)
    }
    
    private func configureLayout() {
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
    
}

extension MenuViewController {
    // MARK - Binding
    func bindViewModel() {
        
        let input = MenuViewModel.Input(
            viewWillAppearEvent: rx.viewWillAppear.map { _ in () },
            refreshTableViewEvent: self.menuTableView.refreshControl?.rx.controlEvent(.valueChanged).map { _ in () } ?? Observable.just(()),
            clearBtnTapEvent: self.clearBtn.rx.tap.asObservable(),
            orderBtnTapEvent: orderBtn.rx.tap.asObservable()
        )
        
        guard let viewModel = self.viewModel else { print("No Viewmodel"); return }
        
        let output = viewModel.transform(from: input, disposeBag: self.disposeBag)

        output.menus
            .bind(to: menuTableView.rx.items(cellIdentifier: MenuItemTableViewCell.identifier, cellType: MenuItemTableViewCell.self)) { index, element, cell in
                
                cell.onData
                    .asObserver()
                    .onNext(element)
                
                cell.onChanged
                    .map { (element, $0) }
                    .bind(to: viewModel.increaseMenuCount)
                    .disposed(by: cell.disposeBag)
            }
            .disposed(by: disposeBag)
        
        output.orderedMenus
            .subscribe {
                viewModel.coordinator?.showOrderViewController(with: $0)
            }
            .disposed(by: disposeBag)
        
        output.activeIndicator
            .observe(on: MainScheduler.instance)
            .do(onNext: { [weak self] isActive in
                if isActive {
                    self?.menuTableView.refreshControl?.endRefreshing() }
                })
            .map { !$0 }
            .bind(to: indicator.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.totalCountText
            .debug()
            .bind(to: itemCount.rx.text)
            .disposed(by: disposeBag)
        
        output.totalPriceText
            .debug()
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)

    }
}
