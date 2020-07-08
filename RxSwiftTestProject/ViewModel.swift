//
//  ViewModel.swift
//  RxSwiftTestProject
//
//  Created by Артем Холодок on 08.07.2020.
//  Copyright © 2020 Артем Холодок. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

class ViewModel {
    private let bag = DisposeBag()
    let password: BehaviorRelay<String?> = BehaviorRelay<String?>(value: nil)
    let isValue: BehaviorRelay<Bool?> = BehaviorRelay<Bool?>(value: nil)
    let validPasswordSignal = ReplaySubject<Bool>.create(bufferSize: 1)
    let validSwitchSignal = ReplaySubject<Bool>.create(bufferSize: 1)
    private var validFormPasswordSignal = ReplaySubject<Bool>.create(bufferSize: 1)
    var validFormSignal: Observable<Bool>!
    weak var controller: ViewController!
    
    func configure() {
        validFormSignal = Observable.combineLatest(validSwitchSignal, validFormPasswordSignal) {
            $0 && $1
        }
        
        password.subscribe(
            onNext: { [unowned self] in
                self.validPasswordSignal.onNext(self.validate(password: $0 ?? ""))
            }
        )
            .disposed(by: bag)
        
        isValue.subscribe(
            onNext: { [unowned self] in
                self.validSwitchSignal.onNext($0 ?? false)
            }
        )
            .disposed(by: bag)
    }
    
    func validate(password: String) -> Bool {
        guard !password.isEmpty else {
            return true
        }
        return controller.isAlphanumeric(password)
    }
}
