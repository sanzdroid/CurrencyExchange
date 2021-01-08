//
//  ViewController.swift
//  CurrencyExchange
//
//  Created by sanzrush on 7/1/21.
//

import UIKit

struct Forex: Decodable {
    let success: Bool
    let timestamp: Int
    let base, date: String
    let rates: [String: Double]
}

let url = "http://data.fixer.io/api/latest?access_key=94044bdcc5e504b1e71fd404dbff85f2&symbols=CAD,AUD,GBP,JPY,USD"


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    var selectedIndex = 0
    @IBOutlet var lblConvertedCurrency: UILabel!
    @IBOutlet var txtAmount: UITextField!
    var keyArray = NSMutableArray()
    var valueArray = NSMutableArray()
    
    @IBOutlet var curCollectionView: UICollectionView!
    
    override func viewWillLayoutSubviews() {
        dropShadow(view:self.curCollectionView ,color: .systemGreen, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 2, scale: true)
        self.txtAmount.addDashedBorder()
        self.lblConvertedCurrency.accessibilityIdentifier = "curLabel"
        self.txtAmount.accessibilityIdentifier = "curText"
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.txtAmount.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        self.getData()
        
    }
    
    func getForexData(completion: @escaping (Result<Forex, Error>) -> ()){
        guard let mainUrl = URL(string: url) else {return}
        
        URLSession.shared.dataTask(with: mainUrl) { (data, response,error) in
            if let err = error{
                completion(.failure(err))
                return
            }
            do{
                let forex = try JSONDecoder().decode(Forex.self, from: data!)
                completion(.success(forex))
                
            }catch let jsonError{
                completion(.failure(jsonError))
            }
            
        }.resume()
    }
    
    //MARK: UICollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.keyArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "curCell", for: indexPath) as! curCell
        cell.lblCurrency.text = self.keyArray[indexPath.row] as? String
        if indexPath.row == self.selectedIndex{
            cell.lblCurrency.alpha = 1.0
        }else{
            cell.lblCurrency.alpha = 0.5
        }
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedIndex = indexPath.row
        self.curCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        self.lblConvertedCurrency.text = self.calculateAmount(text: self.txtAmount.text ?? "", index: indexPath.row)
        self.curCollectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: 80, height: 80)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let horizontalInset = self.curCollectionView.frame.size.width/2-40
        
        return UIEdgeInsets(top: 0,left: horizontalInset,bottom: 0,right: horizontalInset)
    }
    //MARK: UITextfield Delegate
//        func textFieldDidBeginEditing(_ textField: UITextField) {
//            self.lblConvertedCurrency.text = self.calculateAmount(textfield: self.txtAmount, index: self.selectedIndex)
//        }
        func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
            var fullString = "\(textField.text ?? "")\(string)"
            
            if let char = string.cString(using: String.Encoding.utf8) {
                    let isBackSpace = strcmp(char, "\\b")
                    if (isBackSpace == -92) {
                        fullString = ""
                        self.txtAmount.text = ""
                    }
                }
            
            self.lblConvertedCurrency.text = self.calculateAmount(text: fullString, index: self.selectedIndex)
            return true
        }
    
    
    //MARK: Get Data
    func getData(){
        self.getForexData { (result) in
            switch result {
            case .success(let forex):
                for key in forex.rates.keys{
                    self.keyArray.add(key)
                }
                for value in forex.rates.values{
                    let floatValue = Float(value)
                    self.valueArray.add(floatValue)
                }
                DispatchQueue.main.async {
                    self.curCollectionView.reloadData()
                }
            case .failure(let error):
                print("failed to get data", error)
            }
        }
    }
    
    func calculateAmount(text: String, index: Int) -> String{
        
        let amount = Float(text) ?? 0
        let unit: Float = self.valueArray[index] as! Float
        let convertedAmt = amount * unit
        var finalAmt : String = ""
        switch self.keyArray[index] as! String {
        case "GBP":
            finalAmt = "£ \(convertedAmt)"
        case "AUD":
            finalAmt = "A$ \(convertedAmt)"
        case "JPY":
            finalAmt = "¥ \(convertedAmt)"
        case "USD":
            finalAmt = "$ \(convertedAmt)"
        case "CAD":
            finalAmt = "C$ \(convertedAmt)"
        default:
            print("default")
        }
        return "\(finalAmt)"
    }
    
    //MARK: Keyboard move Up/Down Methods
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.txtAmount.resignFirstResponder()
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
}


