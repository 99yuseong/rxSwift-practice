//
//  Step2ViewController.swift
//  rxswift-practice
//
//  Created by 남유성 on 2023/03/28.
//

import UIKit
import SnapKit
import Then
import RxSwift

class Step2ViewController: UIViewController {
    
    var data: [Member] = []
    private var disposeBag = DisposeBag()
    
    private var customTableView = UITableView().then {
        $0.layer.backgroundColor = UIColor.white.cgColor
        $0.register(MemberListCellTableViewCell.classForCoder(), forCellReuseIdentifier: "Cell")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupLayout()
        loadTableView()
    }
    
    private func setupView() {
        self.view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
    }
    
    private func setupLayout() {
        self.view.addSubview(customTableView)
        
        customTableView.snp.makeConstraints { make in
            make.top.leading.bottom.right.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    private func setupTableView() {
        customTableView.delegate = self
        customTableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        self.title = "Member"
        navigationController?.navigationBar.prefersLargeTitles = true
    }

}


// MARK - TableView DataSource
extension Step2ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! MemberListCellTableViewCell
        let data = data[indexPath.row]
        
        cell.setData(data: data)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let member = data[indexPath.row]
        showDetail(member: member)
    }

}

extension Step2ViewController: SendMemberDataDelegate {
    
    func sendData(response: Member) -> Member {
        return response
    }
    
    private func showDetail(member: Member) {
        let vc = DetailViewController()
        vc.updateData(member: member)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension Step2ViewController {
    private func loadTableView() {
        _ = loadMembers()
            .observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] members in
                self?.data = members
                self?.customTableView.reloadData() })
            .disposed(by: disposeBag)
    }
    
    private func loadMembers() -> Observable<[Member]> {
        return Observable.create { emitter in
            let task = URLSession.shared.dataTask(with: URL(string: MEMBER_LIST_URL)!) { data, _, err in
                guard err == nil else {
                    emitter.onError(err!)
                    return
                }
                
                guard let data = data, let members = try? JSONDecoder().decode([Member].self, from: data) else {
                    emitter.onCompleted()
                    return
                }
                
                emitter.onNext(members)
                emitter.onCompleted()
            }
            
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

protocol SendMemberDataDelegate {
    func sendData(response: Member) -> Member
}
