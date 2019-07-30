//
//  ViewController.swift
//  CalculateCredit
//
//  Created by Maxim Spiridonov on 30/07/2019.
//  Copyright © 2019 Maxim Spiridonov. All rights reserved.
//

import UIKit

enum TimeType {
    case month, year
}

class ViewController: UIViewController {
    
    var timeType: TimeType = .month {
        didSet {
            if timeType == .month {
                timeTypeButton.setTitle(NSLocalizedString("months", comment: ""), for: .normal)
            } else {
                timeTypeButton.setTitle(NSLocalizedString("years", comment: ""), for: .normal)
            }
        }
    }
    
    var deviceNow: IPhones!
    let shadowViewScreen = UIView()
    
    var differViewPopup: DifferResultPopupView!
    var annuitViewPopup: AnnuitResultPopupView!
    
    @IBOutlet var infoMainPopupView: UIView!
    
    @IBOutlet weak var paymentLabelTitle: UILabel!
    @IBOutlet weak var paymenLabelTappedInfoButton: UIButton!
    
    @IBOutlet weak var timeTypeButton: UIButton!
    
    
    @IBOutlet weak var mainSimpleLine: UIView!
    @IBOutlet weak var mainSimpleTitleHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTitleBottom: NSLayoutConstraint!
    @IBOutlet weak var buttonsHeight: NSLayoutConstraint!
    @IBOutlet weak var mainTitle: UILabel!
    @IBOutlet weak var leftSpace: NSLayoutConstraint!
    @IBOutlet weak var rightSpace: NSLayoutConstraint!
    
    @IBOutlet weak var sumMainField: UITextField!
    @IBOutlet weak var percentMainField: UITextField!
    @IBOutlet weak var monthsMainField: UITextField!
    
    @IBOutlet weak var paymentType: UISegmentedControl!
    
    @objc func openShadow() {
        shadowViewScreen.backgroundColor = UIColor.black
        shadowViewScreen.alpha = 0
        shadowViewScreen.frame.size = self.view.frame.size
        shadowViewScreen.center.x = self.view.frame.width/2
        shadowViewScreen.center.y = self.view.frame.height/2
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapShadowHandler))
        shadowViewScreen.addGestureRecognizer(gesture)
        
        
        self.view.addSubview(shadowViewScreen)
        UIView.animate(withDuration: 0.25, animations: {
            self.shadowViewScreen.alpha = 0.7
        })
    }
    
    @objc func closeShadow() {
//        clicks = clicks + 1
        UIView.animate(withDuration: 0.25, animations: {
            self.shadowViewScreen.alpha = 0
        }, completion: { _ in
            self.shadowViewScreen.removeFromSuperview()
        })
    }
    
    
    func showDifferPopup() {
        print("show")
        var months = Int(monthsMainField.text ?? "0") ?? 0
        if timeType == .year {
            months = months*12
        }
        let percent = NumberFormatter().number(from: percentMainField.text ?? "0") ?? 0
        let sum = Int(sumMainField.text?.stringByRemovingWhitespaces ?? "0") ?? 0
        
        DispatchQueue.main.async {
            self.differViewPopup = DifferResultPopupView.createPopup(months: months, percent: CGFloat(truncating: percent), sum: sum, rootVC: self)
            self.view.addSubview(self.differViewPopup)
        }
    }
    
    
    func showAnnuitPopup() {
        var months = Int(monthsMainField.text ?? "0") ?? 0
        
        if timeType == .year {
            months = months*12
        }
        
        let percent = NumberFormatter().number(from: percentMainField.text?.replacingOccurrences(of: ".", with: ",") ?? "0") ?? 0
        print("percent", percent)
        let sum = Int(sumMainField.text?.stringByRemovingWhitespaces ?? "0") ?? 0
        
        DispatchQueue.main.async {
            self.annuitViewPopup = AnnuitResultPopupView.createPopup(months: months, percent: CGFloat(truncating: percent), sum: sum, rootVC: self)
            self.view.addSubview(self.annuitViewPopup)
        }
    }
    
    
    func closeAnnuitPopup() {
        annuitViewPopup.closePopup()
    }
    
    func checkFields() -> Bool {
        var isOk = true
        if sumMainField.text == "" || sumMainField.text == "0" {
            isOk = false
            sumMainField.shake()
        }
        
        if percentMainField.text == "" || percentMainField.text == "0" {
            isOk = false
            percentMainField.shake()
        }
        
        if monthsMainField.text == "" || monthsMainField.text == "0" {
            isOk = false
            monthsMainField.shake()
        }
        return isOk
    }
    
    
    @objc func tapShadowHandler() {
        differViewPopup?.closePopup()
        annuitViewPopup?.closePopup()
    }
    
    @IBAction func timeTypeAction(_ sender: Any) {
        if timeType == .month {
            timeType = .year
        } else {
            timeType = .month
        }
    }
    
    
    @IBAction func completeAction(_ sender: Any) {
        
        if checkFields() {
            if paymentType.selectedSegmentIndex == 0 {
                showAnnuitPopup()
            } else {
                showDifferPopup()
            }
        } else {
            let alert = UIAlertController(title: NSLocalizedString("error_data", comment: ""), message: NSLocalizedString("error_descr", comment: ""), preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: NSLocalizedString("error_more", comment: ""), style: .default, handler: { _ in
                self.infoMainPopupView.frame.size = self.view.frame.size
                self.infoMainPopupView.center = self.view.center
                self.infoMainPopupView.alpha = 0
                self.openShadow()
                self.view.addSubview(self.infoMainPopupView)
                UIView.animate(withDuration: 0.2, animations: {
                    self.infoMainPopupView.alpha = 0.9
                })
            }))
            alert.addAction(UIAlertAction(title: NSLocalizedString("error_close", comment: ""),
                                          style: .destructive,
                                          handler: {(_: UIAlertAction!) in
                                            //Sign out action
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    @IBAction func closeInfoPopupAction(_ sender: Any) {
        closeShadow()
        UIView.animate(withDuration: 0.2, animations: {
            self.infoMainPopupView.alpha = 0
        }, completion: { _ in
            self.infoMainPopupView.removeFromSuperview()
        })
    }
    
    
    @IBAction func infoAction(_ sender: Any) {
        infoMainPopupView.frame.size = self.view.frame.size
        infoMainPopupView.center = self.view.center
        infoMainPopupView.alpha = 0
        openShadow()
        self.view.addSubview(infoMainPopupView)
        UIView.animate(withDuration: 0.2, animations: {
            self.infoMainPopupView.alpha = 0.9
        })
    }
    
    
    @IBAction func cleanAllAction(_ sender: Any) {
        print("clean")
        if sumMainField.text != "" {
            UIView.transition(with: sumMainField, duration: 0.4, options: .transitionFlipFromLeft, animations: {
                self.sumMainField.text = ""
            }, completion: nil)
        }
        if percentMainField.text != "" {
            UIView.transition(with: percentMainField, duration: 0.4, options: .transitionFlipFromLeft, animations: {
                self.percentMainField.text = ""
            }, completion: nil)
        }
        if monthsMainField.text != "" {
            UIView.transition(with: monthsMainField, duration: 0.4, options: .transitionFlipFromLeft, animations: {
                self.monthsMainField.text = ""
            }, completion: nil)
        }
        
    }
    
    func setForCurrentDevice() {
        deviceNow = DeviceChecker.checkDevice()
        switch deviceNow {
        case .se?:
            leftSpace.constant = 18
            rightSpace.constant = 18
            buttonsHeight.constant = 48
            mainTitleBottom.constant = 12
            mainSimpleTitleHeight.constant = 63
            mainTitle.font = UIFont.systemFont(ofSize: 26, weight: .heavy)
            paymentType.setTitle("Дифференцир...", forSegmentAt: 1)
        case .plus?:
            mainTitle.font = UIFont.systemFont(ofSize: 30, weight: .heavy)
            mainSimpleTitleHeight.constant = 72
        default:
            print("error")
        }
    }
    
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if deviceNow == .se {
            
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                mainSimpleTitleHeight.constant = 4
                UIView.animate(withDuration: 0.2, animations: {
                    self.view.layoutIfNeeded()
                    let oldFrame = self.mainTitle.frame
                    self.mainTitle.transform = CGAffineTransform(scaleX: 0.2, y: 0.2)
                    self.mainTitle.frame.origin = oldFrame.origin
                    self.mainTitle.alpha = 0
                    self.mainSimpleLine.alpha = 0
                })
            }
            
        } else if deviceNow == .six {
            UIView.animate(withDuration: 0.2, animations: {
                self.paymentLabelTitle.alpha = 0
                self.paymentType.alpha = 0
                self.paymenLabelTappedInfoButton.alpha = 0
            })
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        
        if deviceNow == .se {
            mainSimpleTitleHeight.constant = 63
            UIView.animate(withDuration: 0.2, animations: {
                self.view.layoutIfNeeded()
                self.mainTitle.transform = CGAffineTransform.identity
                self.mainTitle.alpha = 1
                self.mainSimpleLine.alpha = 0.5
                
            })
        } else if deviceNow == .six {
            UIView.animate(withDuration: 0.2, animations: {
                self.paymentLabelTitle.alpha = 1
                self.paymentType.alpha = 1
                self.paymenLabelTappedInfoButton.alpha = 1
            })
        }
    }
    
    @IBAction func endTyping(_ sender: Any) {
        self.view.endEditing(true)
    }
    
    @objc func formatNumber() {
        print("change")
        if sumMainField.text?.count ?? 0 < 3 {
            return
        }
        let number = NSNumber(value: Int(sumMainField.text?.stringByRemovingWhitespaces ?? "") ?? 0)
        print(number)
        let formater = NumberFormatter()
        formater.groupingSeparator = " "
        formater.numberStyle = .decimal
        let formattedNumber = formater.string(from: number)
        sumMainField.text = formattedNumber
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setForCurrentDevice()
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIResponder.keyboardWillHideNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIResponder.keyboardWillShowNotification, object: nil)
//        
        NotificationCenter.default.addObserver(self, selector: #selector(openShadow), name: NSNotification.Name("OpenShadow"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(closeShadow), name: NSNotification.Name("CloseShadow"), object: nil)
        
        sumMainField.delegate = self
        monthsMainField.delegate = self
        percentMainField.delegate = self
        
        sumMainField.addTarget(self, action: #selector(formatNumber), for: .editingChanged)
    }
    
    
    
}


extension String {
    var stringByRemovingWhitespaces: String {
        let componentss = components(separatedBy: .whitespaces)
        return componentss.joined(separator: "")
    }
    
    var stringByNumberWithSeparators: String {
        print("change")
        if self.count < 3 {
            return self
        }
        let number = NSNumber(value: Int(self.stringByRemovingWhitespaces) ?? 0)
        print(number)
        let formater = NumberFormatter()
        formater.groupingSeparator = " "
        formater.numberStyle = .decimal
        let formattedNumber = formater.string(from: number)
        return formattedNumber ?? self
    }
}

extension ViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.text == "0" && string != "" || textField.text?.count ?? 0 > 18 && string != "" {
            return false
        }
        return true
    }
}

extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.4
        animation.values = [-10.0, 10.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}

