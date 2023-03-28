//
//  MemberListCellTableViewCell.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

struct Member: Decodable {
    let id: Int
    let name: String
    let avatar: String
    let job: String
    let age: Int
}

class MemberListCellTableViewCell: UITableViewCell {
    
    private var disposeBag = DisposeBag()
    
    private lazy var avatar = UIImageView()
    private lazy var name = UILabel().then {
        $0.text = "NAME"
        $0.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
    }
    
    private lazy var job = UILabel().then {
        $0.text = "JOB"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .thin)
    }
    
    private lazy var age = UILabel().then {
        $0.text = "(AGE)"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .thin)
    }
    
    private lazy var detailStackView = UIStackView(arrangedSubviews: [job, age]).then {
        $0.axis = .horizontal
        $0.spacing = 8
    }
    
    private lazy var contentStackView = UIStackView(arrangedSubviews: [name, detailStackView]).then {
        $0.axis = .vertical
        $0.distribution = .fillProportionally
        $0.alignment = .leading
    }
    
    private lazy var containerStackView = UIStackView(arrangedSubviews: [avatar, contentStackView]).then {
        $0.axis = .horizontal
        $0.alignment = .leading
        $0.spacing = 24
    }
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        
    }
    
    private func setupLayout() {
        contentView.addSubview(containerStackView)
        
        containerStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(4)
            make.leading.equalTo(contentView).offset(20)
            make.bottom.equalTo(contentView).offset(-4)
            make.trailing.equalTo(contentView).offset(-20)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }

}

extension MemberListCellTableViewCell {
    func setData(data: Member) {
        loadImage(from: data.avatar)
            .subscribe(on: MainScheduler.instance)
            .bind(to: avatar.rx.image)
            .disposed(by: self.disposeBag)
        setName(name: data.name)
        setJob(job: data.job)
        setAge(age: data.age)
    }
    
    private func setAvatar(img: UIImage) {
        self.avatar.image = img
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
}

extension MemberListCellTableViewCell {
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
