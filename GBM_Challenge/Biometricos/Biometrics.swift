//
//  Biometrics.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 10/05/21.
//

import Foundation
import LocalAuthentication

enum BiometricType {
    case none
    case touch
    case face
}

enum BiometricsErrorType {
    case cancel
    case authFail
    case other
}

class Biometrics {
    static func supportedType() -> BiometricType
    {
        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        var error: NSError?

        let myContext = LAContext()
        let _ = myContext.canEvaluatePolicy(policy, error: &error)
        switch(myContext.biometryType) {
            case .none:
                return .none
            case .touchID:
                return .touch
            case .faceID:
                return .face
        default:
            return .none
        }
    }
    
    static func authenticate(withTitle title:String, successHandler: @escaping () -> Void, errorHandler: @escaping (BiometricsErrorType) -> Void)
    {
        let myLocalizedReasonString = title

        let policy: LAPolicy = .deviceOwnerAuthenticationWithBiometrics
        var error: NSError?

        let myContext = LAContext()
        if myContext.canEvaluatePolicy(policy, error: &error)
        {
            myContext.evaluatePolicy(policy, localizedReason: myLocalizedReasonString, reply: { (success, error) in
                DispatchQueue.main.async {
                    if success
                    {
                        successHandler()
                    }
                    else if let error = error
                    {
                        switch((error as NSError).code)
                        {
                        case LAError.Code.userCancel.rawValue:
                            errorHandler(.cancel)
                            break;

                        case LAError.Code.authenticationFailed.rawValue,
                             LAError.Code.biometryLockout.rawValue:
                            errorHandler(.authFail)
                            break;

                        default:
                            errorHandler(.other)
                        }
                    }
                    else
                    {
                        errorHandler(.other)
                    }
                }
            })
        }
        else
        {
            DispatchQueue.main.async {
                errorHandler(.other)
            }
        }
    }
}
