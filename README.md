# rxSwift-practice

``` swift
extension ViewController {
	private func downloadJson(_ url: String, _ completion: @escaping (String?) -> Void) {
		DispatchQueue.global().async {
        	let url = URL(string: url)!
     		let data = try! Data(contentsOf: url)
       		let json = String(data: data, encoding: .utf8)
       		DispatchQueue.main.async {
       			completion(json)
        	}
    	}
	}
    
	@objc private func onLoad() {
		self.editText.text = ""
		setVisibleWithAnimation(self.indicator, true)
        	
		self.downloadJson(MEMBER_LIST_URL) { json in
			self.editText.text = json
			self.setVisibleWithAnimation(self.indicator, false)
		}   
	}
}
```


``` swift
class 나중에생기는데이터<T> {
    private let task: (@escaping (T) -> Void) -> Void
    
    init(task: @escaping (@escaping (T) -> Void) -> Void) {
        self.task = task
    }
    
    func 나중에오면(_ f: @escaping (T) -> Void) {
        task(f)
    }
}

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
```

``` swift 
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

```
