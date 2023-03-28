//
//  DetailViewController.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class DetailViewController: UIViewController {

    private lazy var avatar = UIImageView()
    private var disposeBag = DisposeBag()
    
    private lazy var id = UILabel().then {
        $0.text = "#ID"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .thin)
    }
    private lazy var name = UILabel().then {
        $0.text = "Name"
        $0.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        $0.textAlignment = .center
    }
    private lazy var job = UILabel().then {
        $0.text = "Job"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        $0.textAlignment = .center
    }
    private lazy var age = UILabel().then {
        $0.text = "AGE"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .light)
        $0.textColor = .lightGray
        $0.textAlignment = .center
    }
    
    private lazy var containerView = UIStackView(arrangedSubviews: [avatar, name, job, age]).then {
        $0.axis = .vertical
        $0.spacing = 16
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        setupNavigationBar()
    }
    
    private func setupLayout() {
        self.view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.top.leading.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
        }
        
        avatar.snp.makeConstraints { make in
            make.height.equalTo(avatar.snp.width)
        }
    }
    
    private func setupNavigationBar() {
        self.title = "Detail"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}

extension DetailViewController {

    func updateData(member: Member) {
        loadImage(from: member.avatar)
            .subscribe(on: MainScheduler.instance)
            .bind(to: avatar.rx.image)
            .disposed(by: disposeBag)
        setName(name: member.name)
        setJob(job: member.job)
        setAge(age: member.age)
    }
    
    private func setId(id: Int) {
        self.id.text = "#\(id)"
    }
    
    private func setName(name: String) {
        self.name.text = name
    }
    
    private func setJob(job: String) {
        self.job.text = job
    }
    
    private func setAge(age: Int) {
        self.age.text = "(\(age))"
    }
    
    private func loadImage(from url: String) -> Observable<UIImage?> {
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: URL(string: url)!) { data, _, err in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                
                if let data = data, let image = UIImage(data: data) {
                    emitter.onNext(image)
                } else {
                    emitter.onNext(nil)
                }
                emitter.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
}
