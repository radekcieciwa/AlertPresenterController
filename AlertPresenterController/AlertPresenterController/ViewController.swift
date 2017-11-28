//
//  ViewController.swift
//  AlertPresenter
//
//  Created by Ruslan Ahapkin on 27/11/2017.
//  Copyright © 2017 Ruslan Ahapkin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let margin: CGFloat = 10.0
        let width: CGFloat = (self.view.bounds.width - (2 * margin))
        let textInput = UITextField(frame: CGRect(x: margin, y: 50, width: width, height: 40))
        textInput.autoresizingMask = .flexibleWidth
        textInput.layer.cornerRadius = 10
        textInput.layer.borderWidth = 1
        self.view.addSubview(textInput)

        let button = UIButton(type: .infoLight)
        button.frame = CGRect(x: margin, y: textInput.frame.maxY + margin, width: width, height: 30)
        button.autoresizingMask = .flexibleWidth
        button.addTarget(self, action: #selector(self.showAlert), for: .touchUpInside)
        self.view.addSubview(button)

        let button2 = UIButton(type: .contactAdd)
        button2.frame = CGRect(x: margin, y: button.frame.maxY + margin, width: width, height: 30)
        button2.autoresizingMask = .flexibleWidth
        button2.addTarget(self, action: #selector(self.showActionSheet), for: .touchUpInside)
        self.view.addSubview(button2)
    }

    @objc func showAlert() {
        // I like that it's detached from UIViewController flow, so you don't have to worry about it, but instance
        // drive approach would be usefull
        let alertPresenter = AlertControllerPresenter.alertPresenter(title: "Title", message: "Message")
        alertPresenter.addDefaultAction(title: "Ok")
        alertPresenter.addDestructiveAction(title: "Delete")
        alertPresenter.addCancelAction(title: "Cancel")
        alertPresenter.present()
    }

    @objc func showActionSheet() {
        let alertPresenter = AlertControllerPresenter.actionSheetPresenter(title: "Title")
        alertPresenter.addDefaultAction(title: "Ok")
        alertPresenter.addDestructiveAction(title: "Delete")
        alertPresenter.addCancelAction(title: "Cancel")
        alertPresenter.present()
    }
}

