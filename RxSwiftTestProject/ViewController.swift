//
//  ViewController.swift
//  RxSwiftTestProject
//
//  Created by Артем Холодок on 02.07.2020.
//  Copyright © 2020 Артем Холодок. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var switcher: UISwitch!
    
    
    private let bag = DisposeBag()
    var viewModel: ViewModel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ViewModel()
        viewModel.controller = self
        configure()
        viewModel.configure()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        view.addGestureRecognizer(tap)
    }
    
    func configure() {
        textField.rx.text
            .bind(to: self.viewModel.password)
            .disposed(by: bag)
        
        switcher.rx.isOn
            .bind(to: self.viewModel.isValue)
            .disposed(by: bag)
        
        let isValidPassword = textField.rx
            .text.orEmpty
            .map { self.confirmOldPasswordFormat($0) }
        
        Observable.combineLatest(switcher.rx.isOn, isValidPassword)
            .map { $0 && $1 }
            .bind(to: actionButton.rx.isEnabled)
            .disposed(by: bag)
        
        viewModel.validPasswordSignal
            .skip(1)
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [unowned errorLabel] valid in
                if !valid {
                    UIView.animate(withDuration: 1) {
                        errorLabel?.text = "error"
                        errorLabel?.textColor = .red
                        errorLabel?.alpha = 0.7
                    }
                } else {
                    UIView.animate(withDuration: 1) {
                        errorLabel?.text = "good"
                        errorLabel?.textColor = .green
                        errorLabel?.alpha = 0.3
                    }
                }
            }).disposed(by: bag)
    }
}


extension ViewController {
    
    @objc func handleTap() {
        view.becomeFirstResponder()
    }
    
    func validate(password: String) -> Bool {
        guard !password.isEmpty else {
            return true
        }
        return isAlphanumeric(password)
    }
    
    func confirmOldPasswordFormat(_ password: String) -> Bool {
        let pattern = "^[a-zA-Z0-9~!@#$%^&*()_+`\\-={}\\[\\]:;<>./\\\\]{6,32}$"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: password)
    }
    
    func isAlphanumeric(_ string: String) -> Bool {
        let pattern = "^[A-Za-z0-9]+"
        let predicate = NSPredicate(format: "SELF MATCHES %@", pattern)
        return predicate.evaluate(with: string)
    }
}
