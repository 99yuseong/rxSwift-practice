//
//  OrderViewController.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then
import RxSwift

class OrderViewController: UIViewController {
    
    // MARK - Property
    var viewModel: OrderViewModel?
    var orderedMenus: [Menu]?
    private let disposeBag = DisposeBag()
    
    // MARK - UI
    private var receiptTitle = UILabel().then {
        $0.text = "Ordered Items"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .medium)
    }
    
    private var ordersList = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 32, weight: .thin)
    }
    
    private var priceTitle = UILabel().then {
        $0.text = "Price to pay"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .medium)
    }
    
    private var itemsTitle = UILabel().then {
        $0.text = "Items"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .thin)
    }
    
    private var itemsPrice = UILabel().then {
        $0.text = "₩0"
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .right
    }
    
    private var vatTitle = UILabel().then {
        $0.text = "VAT"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .thin)
    }
    
    private var vatPrice = UILabel().then {
        $0.text = "₩0"
        $0.font = UIFont.systemFont(ofSize: 17)
        $0.textAlignment = .right
    }
    
    private var divider = UIView().then {
        $0.backgroundColor = .lightGray
    }
    
    private var totalPrice = UILabel().then {
        $0.text = "₩0"
        $0.font = UIFont.systemFont(ofSize: 50, weight: .bold)
        $0.textAlignment = .right
    }
    
    private lazy var itemStack = UIStackView(arrangedSubviews: [itemsTitle, itemsPrice]).then {
        $0.distribution = .fillEqually
    }
    private lazy var vatStack = UIStackView(arrangedSubviews: [vatTitle, vatPrice]).then {
        $0.distribution = .fillEqually
    }
    
    private lazy var containerStack = UIStackView(arrangedSubviews: [receiptTitle, ordersList, priceTitle, itemStack, vatStack, divider, totalPrice]).then {
        $0.axis = .vertical
        $0.layoutMargins = UIEdgeInsets(top: 30, left: 20, bottom: 40, right: 20)
        $0.isLayoutMarginsRelativeArrangement = true
    }
    
    private var scrollView = UIScrollView()
    private var contentView = UIView()
    
    // MARK - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureCommonUI()
        showOrderList()
        configureLayout()
        bindViewModel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    
    private func configureCommonUI() {
        self.view.backgroundColor = .white
        configureNavigationBar()
    }
    
    private func configureNavigationBar() {
        self.title = "Receipt"
        navigationController?.navigationBar.backgroundColor = .black
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func configureLayout() {
        self.view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(containerStack)
        
        scrollView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.top.leading.bottom.trailing.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        containerStack.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }
        
        containerStack.setCustomSpacing(8, after: receiptTitle)
        containerStack.setCustomSpacing(46, after: ordersList)
        containerStack.setCustomSpacing(8, after: priceTitle)
        containerStack.setCustomSpacing(8, after: itemStack)
        containerStack.setCustomSpacing(32, after: vatStack)
        containerStack.setCustomSpacing(32, after: divider)
        
        ordersList.snp.makeConstraints { make in
            make.height.equalTo(160)
        }
        
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)

        }
        
    }

}

extension OrderViewController {
    
    func bindViewModel() {
        let input = OrderViewModel.Input(menus: orderedMenus ?? [])
        
        guard let viewModel = self.viewModel else { print("No ViewModel"); return }
        
        let output = viewModel.transform(from: input, disposeBag: self.disposeBag)
        
        ordersList.rx.text.orEmpty
            .distinctUntilChanged()
            .map { [weak self] _ in self?.ordersList.calcHeight() ?? 0 }
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] height in
                self?.ordersList.snp.updateConstraints { make in
                    make.height.equalTo(height + 40)
                }
                self?.view.layoutIfNeeded()
            })
            .disposed(by: disposeBag)
                
        output.orderedList
            .asObservable()
            .bind(to: ordersList.rx.text)
            .disposed(by: disposeBag)

        output.itemPriceText
            .bind(to: itemsPrice.rx.text)
            .disposed(by: disposeBag)
        
        output.itemVatText
            .bind(to: vatPrice.rx.text)
            .disposed(by: disposeBag)
        
        output.totalPriceText
            .bind(to: totalPrice.rx.text)
            .disposed(by: disposeBag)
    }
    
    private func showOrderList() {
        self.ordersList.text = """
        SELECTED MENU 1
        SELECTED MENU 2
        SELECTED MENU 3
        SELECTED MENU 4
        SELECTED MENU 5
        SELECTED MENU 6
        SELECTED MENU 7
        SELECTED MENU 8
        SELECTED MENU 9
        """
        updateTextViewHeight()
    }
    
    private func updateTextViewHeight() {
        let text = ordersList.text ?? ""
        let width = ordersList.bounds.width
        let font = ordersList.font ?? UIFont.systemFont(ofSize: 20)

        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = text.boundingRect(with: constraintRect,
                                            options: [.usesLineFragmentOrigin, .usesFontLeading],
                                            attributes: [NSAttributedString.Key.font: font],
                                            context: nil)
        let height = boundingBox.height

        ordersList.snp.updateConstraints { make in
            make.height.equalTo(height + 40)
        }
        self.view.layoutIfNeeded()
    }
}

#if DEBUG

import SwiftUI

struct OrderViewController_ViewPresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        OrderViewController()
    }
    
    
}

struct OrderViewController_PreviewProvider : PreviewProvider {
    static var previews: some View {
        OrderViewController_ViewPresentable()
            .ignoresSafeArea()
    }
}

#endif
