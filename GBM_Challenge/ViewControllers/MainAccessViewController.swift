//
//  MainAccessViewController.swift
//  GBM_Challenge
//
//  Created by Manuel Gonzalez on 08/05/21.
//

import UIKit

class MainAccessViewController: UIViewController {
    let segueIdToHome = "toHome"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func succesLogin() {
        performSegue(withIdentifier: segueIdToHome, sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        var biometric = "biométrico"
        switch Biometrics.supportedType() {
        case .touch:
            biometric = "Touch ID"
        case .face:
            biometric = "Face ID"
        default:
            return
        }
        
        Biometrics.authenticate(
            withTitle: "Inicia sesión con tu " + biometric,
            successHandler: {
                self.succesLogin()
            },
            errorHandler: { errorType in
                switch errorType{
                case .authFail:
                    break
                case .cancel:
                    break
                case .other:
                    break
                }
            })
    }
    
}
