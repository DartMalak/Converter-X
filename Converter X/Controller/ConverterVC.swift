//
//  ConverterVC.swift
//  Converter X
//
//  Created by Georg on 13.06.2020.
//  Copyright © 2020 Georg. All rights reserved.
//

import UIKit

class ConverterVC: UIViewController {
    let maxLength = 9
    
    var fromCurrency = "RUB"
    var toCurrency = "USD"
    var fromValue = 0.0
    var toValue = 0.0
    var exchangeRate = 1.0
    var currencyTags = [String]()
    
    
    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var toValueLbl: UILabel!
    @IBOutlet weak var toCurrencyLbl: UILabel!
    @IBOutlet weak var fromValueTF: UITextField!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var fromCurrencyLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        
        fromValueTF.delegate = self
        fromValueTF.smartInsertDeleteType = UITextSmartInsertDeleteType.no
        fromValueTF.addTarget(self, action: #selector(textFieldEdited), for: .editingChanged)
        fromValueTF.becomeFirstResponder()
        
        picker.delegate = self
        picker.dataSource = self
        
        updateCurrencies()
        updateRate(from: fromCurrency, to: toCurrency) {
            self.updateConvertedValue(from: self.fromValue, with: self.exchangeRate)
        }
    }
    
    func fetchCurrencies(complete: @escaping ([String], Bool) -> Void) {
        APIService.instance.getCurrencyRates { (exchangeRates) in
            let currencyTagsArray = Array(exchangeRates.rates.keys)
            complete(currencyTagsArray, currencyTagsArray.isEmpty)
        }
    }
    
    func getCurrencyRate(from currencyX: String, to currencyY: String, complete: @escaping (Double, Bool) -> Void) {
        APIService.instance.getCurrencyRates(base: toCurrency) { (exchangeRates) in
            let rate = exchangeRates.rates[self.fromCurrency]
            complete(rate ?? 1.0, rate == nil)
        }
    }
    
    @objc func textFieldEdited() {
        let fromInput = fromValueTF.text!
        let value = Double(fromInput) ?? 0.0
        fromValue = value
        updateConvertedValue(from: fromValue, with: exchangeRate)
    }
    
    func updateConvertedValue(from valueX: Double, with rate: Double) {
        DispatchQueue.main.async {
            let result = valueX / rate
            self.toValue = round(100.0 * result) / 100.0
            self.toValueLbl.text = String(self.toValue)
        }
    }
    
    func updateTags(from tagX: String, to tagY: String) {
        DispatchQueue.main.async {
            self.fromCurrencyLbl.text = tagX
            self.toCurrencyLbl.text = tagY
        }
    }
    
    func updateRate(from currencyX: String, to currencyY: String, complete: @escaping () -> ()) {
        getCurrencyRate(from: currencyX, to: currencyY) { (rate, error) in
            if error {
                print("Unable to fetch rate", self.fromCurrency, self.toCurrency)
                return
            }
            self.exchangeRate = rate
            print("rate:", self.exchangeRate)
            complete()
        }
    }
    
    func updateCurrencies() {
        fetchCurrencies { (tags, error) in
            if error {
                print("Empty tag array")
                return
            }
            self.currencyTags = tags
            print(self.currencyTags)
            
            DispatchQueue.main.async {
                self.picker.reloadAllComponents()
                self.setPickerRows(from: self.fromCurrency, to: self.toCurrency)
            }
        }
    }
    
    func setPickerRows(from tagX: String, to tagY: String) {
        let indexX = self.currencyTags.firstIndex(of: tagX)!
        let indexY = self.currencyTags.firstIndex(of: tagY)!
        
        DispatchQueue.main.async {
            self.picker.selectRow(indexX, inComponent: 0, animated: false)
            self.picker.selectRow(indexY, inComponent: 1, animated: false)
        }
        print("Initial Rows Selected", tagX, tagY)
    }
    
    @IBAction func changeCurrencyPressed(_ sender: Any) {
        picker.isHidden = false
        closeBtn.isHidden = false
        view.endEditing(true)
    }
    
    @IBAction func switchCurrency(_ sender: Any) {
        swap(&fromCurrency, &toCurrency)
        print(fromCurrency, toCurrency)
        self.updateTags(from: self.fromCurrency, to: self.toCurrency)
        self.updateRate(from: self.fromCurrency, to: self.toCurrency) {
            self.updateConvertedValue(from: self.fromValue, with: self.exchangeRate)
        }
        fromValueTF.becomeFirstResponder()
    }
    
    @IBAction func closePressed(_ sender: Any) {
        picker.isHidden = true
        closeBtn.isHidden = true
        fromValueTF.becomeFirstResponder()
    }
    
}

extension ConverterVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let textFieldText = textField.text,
            let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                return false
        }
        let substringToReplace = textFieldText[rangeOfTextToReplace]
        let count = textFieldText.count - substringToReplace.count + string.count
        return count <= maxLength
    }
}

extension ConverterVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        print(currencyTags.count)
        return currencyTags.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        print(currencyTags[row])
        return currencyTags[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedX = pickerView.selectedRow(inComponent: 0)
        let selectedY = pickerView.selectedRow(inComponent: 1)
        self.fromCurrency = currencyTags[selectedX]
        self.toCurrency = currencyTags[selectedY]
        print(fromCurrency, toCurrency)
        updateTags(from: fromCurrency, to: toCurrency)
        updateRate(from: fromCurrency, to: toCurrency) {
            self.updateConvertedValue(from: self.fromValue, with: self.exchangeRate)
        }
    }
}
