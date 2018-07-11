//
//  AuthPhoneViewController.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

protocol AuthPhoneViewPresentation: class {
    func getData() -> String?
    func showAlert(_ message: String?)
}

class AuthPhoneViewController: UIViewController, AuthPhoneViewPresentation {

    var presenter: AuthPhonePresentation?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var phoneField: UITextField! {
        didSet {
            phoneField.keyboardType = .phonePad
            phoneField.textAlignment = .center
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.setTitle("auth_button_done".lcd, for: .normal)
            doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        }
    }

    deinit {
      
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addKeyboardNotification()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeKeyboardNotification()
    }

    // MARK: - Configure
    func configureViews () {
        title = "auth_title".lcd
        view.backgroundColor = cBackground

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tap)
    }

    // MARK: - AuthPhoneViewPresentation
    func getData() -> String? {
        return phoneField.text
    }

    func showAlert(_ message: String?) {
        showAlertController(message)
    }

    // MARK: - Actions
    @objc func doneTapped() {
        endEditing()
        presenter?.doneTapped()
    }

    @objc func viewTapped() {
        endEditing()
    }

    func endEditing() {
        view.endEditing(true)
    }
}

extension AuthPhoneViewController: KeyboardNotification {

    @objc func keyboardWillChangeFrame(notification: NSNotification) {

        if let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = stackView.frame.size.height - keyboardFrame.origin.y + stackView.frame.origin.y

            bottomConstraint.constant += keyboardHeight

            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }
}
