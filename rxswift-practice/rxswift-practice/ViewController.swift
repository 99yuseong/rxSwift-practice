//
//  ViewController.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/27.
//

import UIKit
import SnapKit
import Then
import SwiftyJSON

let MEMBER_LIST_URL = "https://my.api.mockaroo.com/members_with_avatar.json?key=44ce18f0"

class ViewController: UIViewController {
    
    private var indicatorAnimator: UIViewPropertyAnimator?

    private lazy var timerLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.text = "0.0"
    }
    
    private lazy var loadBtn = UIButton().then {
        $0.setTitle("LOAD", for: .normal)
        $0.titleLabel?.textColor = .white
        $0.backgroundColor = .black
        $0.addTarget(self, action: #selector(onLoad), for: .touchUpInside)
    }
    
    private lazy var indicator = UIActivityIndicatorView().then {
        $0.style = UIActivityIndicatorView.Style.medium
        $0.startAnimating()
        $0.isHidden = true
    }
    
    private lazy var loadContainer = UIStackView(arrangedSubviews: [loadBtn, indicator]).then {
        $0.spacing = 16
    }
    
    private lazy var editText = UITextView().then {
        $0.backgroundColor = .gray
    }
    
    private lazy var viewContainer = UIStackView(arrangedSubviews: [timerLabel, loadContainer, editText]).then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        setupTimer()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
    }
    
    private func setupLayout() {
        self.view.addSubview(viewContainer)
        
        viewContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        loadBtn.snp.makeConstraints { make in
            make.height.equalTo(48)
        }
        
    }
    
    private func setupTimer() {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.timerLabel.text = "\(Date().timeIntervalSince1970)"
        }
    }
}

// MARK - Animation
extension ViewController {
    private func setVisibleWithAnimation(_ v: UIView?, _ s: Bool) {
        guard let v = v else { return }
        
        self.indicatorAnimator = UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) { [weak v] in
            v?.isHidden = !s
        }
        
        self.indicatorAnimator?.addCompletion { [weak self] _ in
            self?.view.layoutIfNeeded()
        }
        
        self.indicatorAnimator?.startAnimation()
    }
}

class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) {
        task(f)
    }
}

// MARK - Data
extension ViewController {
    
    private func downloadJson(_ url: String) -> 나중에생기는데이터<String?> {
        return 나중에생기는데이터 { f in
            DispatchQueue.global().async {
                let url = URL(string: url)!
                let data = try! Data(contentsOf: url)
                let json = String(data: data, encoding: .utf8)
                DispatchQueue.main.async {
                    f(json)
                }
            }
        }
    }
    
    @objc private func onLoad() {
        self.editText.text = ""
        setVisibleWithAnimation(self.indicator, true)
        
        downloadJson(MEMBER_LIST_URL)
            .나중에오면 { json in
                self.editText.text = json
                self.setVisibleWithAnimation(self.indicator, false)
            }
    }
}


#if DEBUG

import SwiftUI

struct ViewController_ViewPresentable: UIViewControllerRepresentable {
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        ViewController()
    }
    
    
}

struct ViewController_PreviewProvider : PreviewProvider {
    static var previews: some View {
        ViewController_ViewPresentable()
            .ignoresSafeArea()
    }
}

#endif

