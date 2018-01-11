

import Foundation
import RxSwift


struct SignupViewModel {
    var emailText = Variable<String>("")
    var passwordText = Variable<String>("")
    var passwordCheckText = Variable<String>("")
    
    var isValidEmail: Observable<Bool> {
        return Observable.combineLatest([emailText.asObservable()]) { email in
            (email.first?.validEmailAddress)!
        }
    }
    
    var isValidPassword: Observable<Bool> {
        return Observable.combineLatest([passwordText.asObservable()]) { (password) in
            (password.first?.isPasswordValid())!
        }
    }
    
    var isvalidPasswordCheck: Observable<Bool> {
        return Observable.combineLatest(passwordText.asObservable(),
                                        passwordCheckText.asObservable()) { pass, passcheck in
                pass == passcheck && !passcheck.isEmpty
        }
    }
    
    var signupValid: Observable<Bool> {
        return Observable.combineLatest(emailText.asObservable(),
                                        passwordText.asObservable(),
                                        passwordCheckText.asObservable()) {
                                            email, password, passwordcheck in
                                            email.validEmailAddress && password == passwordcheck
                                            && !password.isEmpty && !passwordcheck.isEmpty
        }
    }
    
}
