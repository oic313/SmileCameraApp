//
//  SettingViewController.swift
//  SmileCamera
//
//  Created by K.N on 2019/09/16.
//  Copyright © 2019 K.N. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var countTextField: UITextField!
    @IBOutlet weak var secondsTextField: UITextField!
    @IBOutlet weak var UISwitch: UISwitch!
    
    var subjectCount : Int = 1
    var holdSecond : Int = 5
    var closeEyesFlag : Bool = true

    var pickerView1: UIPickerView = UIPickerView()
    let list1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    var pickerView2: UIPickerView = UIPickerView()
    let list2 = [5, 10, 15, 20]
    var tag: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(subjectCount)
        print(holdSecond)
        print(closeEyesFlag)
                
        self.countTextField.text = "\(subjectCount) 人以上"
        self.secondsTextField.text = "\(holdSecond) 秒"
        self.UISwitch.setOn(closeEyesFlag, animated: true)

        pickerView1.delegate = self
        pickerView1.dataSource = self
        pickerView1.showsSelectionIndicator = true
        pickerView1.tag = 1

        let toolbar1 = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem1 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingViewController.done))
        let cancelItem1 = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SettingViewController.cancel))
        toolbar1.setItems([cancelItem1, doneItem1], animated: true)
        
        self.countTextField.inputView = pickerView1
        self.countTextField.inputAccessoryView = toolbar1
        
        pickerView2.delegate = self
        pickerView2.dataSource = self
        pickerView2.showsSelectionIndicator = true
        pickerView2.tag = 2
        
        let toolbar2 = UIToolbar(frame: CGRectMake(0, 0, 0, 35))
        let doneItem2 = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(SettingViewController.done))
        let cancelItem2 = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(SettingViewController.cancel))
        toolbar2.setItems([cancelItem2, doneItem2], animated: true)
        
        self.secondsTextField.inputView = pickerView2
        self.secondsTextField.inputAccessoryView = toolbar2
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        self.closeEyesFlag = sender.isOn
    }
    
    //画面遷移時に呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else {
            //identifierが取得できなかったら処理を終える
            return
        }
        
        if identifier == "toCameraViewController" {
            let CameraViewController = segue.destination as! CameraViewController
            CameraViewController.subjectCount = self.subjectCount
            CameraViewController.holdSecond = self.holdSecond
            CameraViewController.closeEyesFlag = self.closeEyesFlag
        }
    }
    
    //以下pickerの設定
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            self.tag=1
            return list1.count
        } else {
            self.tag=2
            return list2.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            self.subjectCount = list1[row]
            return "\(subjectCount) 人以上"
        } else {
            self.holdSecond = list2[row]
            return "\(holdSecond) 秒"
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            self.subjectCount = list1[row]
            self.countTextField.text = "\(subjectCount) 人以上"
        } else {
            self.holdSecond = list2[row]
            self.secondsTextField.text = "\(holdSecond) 秒"
        }
    }
    
    @objc func cancel(pickerView: UIPickerView) {
        if self.tag == 1 {
            self.subjectCount = 1
            self.countTextField.text = "\(subjectCount) 人以上"
            self.countTextField.endEditing(true)
            
        } else {
            self.holdSecond = 5
            self.secondsTextField.text = "\(holdSecond) 秒"
            self.secondsTextField.endEditing(true)
        }
    }
    
    @objc func done(pickerView: UIPickerView) {
        if self.tag == 1 {
            self.countTextField.endEditing(true)
        } else {
            self.secondsTextField.endEditing(true)
        }
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

