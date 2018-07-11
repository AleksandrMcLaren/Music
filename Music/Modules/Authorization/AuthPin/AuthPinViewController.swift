//
//  AuthPinViewController.swift
//  ARGame
//
//  Created by Aleksandr on 21/11/2017.
//  Copyright © 2017 Aleksandr. All rights reserved.
//

import UIKit

class AuthPinViewController: UIViewController {

    var verificationID: String?
    var completion: ((_ user: AnyObject) -> Void)?

    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pinField: UITextField! {
        didSet {
            pinField.keyboardType = .phonePad
            pinField.textAlignment = .center
        }
    }
    @IBOutlet weak var doneButton: UIButton! {
        didSet {
            doneButton.setTitle("pin_button_done".lcd, for: .normal)
            doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        }
    }

    fileprivate lazy var pinViewModel: AuthPinViewModelPresentation = {
        var pinViewModel: AuthPinViewModelPresentation = AuthPinViewModel()

        pinViewModel.refreshing = { [unowned self] (value) -> Void in

        }

        pinViewModel.completion = { [unowned self] (user) -> Void in
            self.completion?(user)
        }

        pinViewModel.signInError = { [unowned self] (message) -> Void in
            self.showAlertController(message)
        }

        return pinViewModel
    }()

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
        title = "pin_title".lcd
        view.backgroundColor = .yellow
        navigationItem.hidesBackButton = true

        let tap = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tap)
    }

    // MARK: - Actions
    @objc func doneTapped () {
        endEditing()
        pinViewModel.signIn(verificationID, pinField.text)
    }

    @objc func viewTapped() {
        endEditing()
    }

    func endEditing() {
        view.endEditing(true)
    }
}

extension AuthPinViewController: KeyboardNotification {

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
