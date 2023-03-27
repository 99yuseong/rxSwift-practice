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
import RxSwift

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
    
    // Observable의 생명주기
    // 1. Create
    // 2. Subscribe >> 실제 실행
    // 3. onNext
    // ----- 끝 -----
    // 4. onCompleted / onError
    // 5. Disposed
    
    private func downloadJson(_ url: String) -> Observable<String?> {
        // 1. 비동기로 생기는 데이터를 Observable로 감싸서 리턴하는 방법
        return Observable.create { emitter in
            let url = URL(string: url)!
            let task = URLSession.shared.dataTask(with: url) { data, _, err in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                
                if let data = data, let json = String(data: data, encoding: .utf8) {
                    emitter.onNext(json)
                }
                
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create() {
                // 중간 종료 시 cancel 작업
                task.cancel()
            }
            
        }
        
//        return Observable.create() { f in
//            DispatchQueue.global().async {
//                let url = URL(string: url)!
//                let data = try! Data(contentsOf: url)
//                let json = String(data: data, encoding: .utf8)
//                DispatchQueue.main.async {
//                    f.onNext(json)
//                    f.onCompleted() // self 순환참조 해결 - completed와 error에서 subscribe안의 클로저가 모두 메모리에서 제거됨 -> self reference count 복구
//                }
//            }
//
//            return Disposables.create()
//        }
    }
    
    @objc private func onLoad() {
        self.editText.text = ""
        setVisibleWithAnimation(self.indicator, true)
        
        // 2. Observable로 오는 데이터를 받아서 처리하는 방법
        let disposable = downloadJson(MEMBER_LIST_URL)
            .debug()
            .subscribe { event in
            switch event {
            case .next(let json):
                DispatchQueue.main.async {
                    self.editText.text = json
                    self.setVisibleWithAnimation(self.indicator, false)
                }
            case .completed:
                break
            case .error(let err):
                break
            }
        }
        
//        disposable.dispose() // 필요에 의해 호출 가능, 중간에 호출 시 바로 observable이 dispose되어 동작이 이뤄지지 않음
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

