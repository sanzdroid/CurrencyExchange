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
let url = "http://data.fixer.io/api/latest?access_key=94044bdcc5e504b1e71fd404dbff85f2"

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var lblConvertedCurrency: UILabel!
    @IBOutlet var txtAmount: UITextField!
    var keyArray = NSMutableArray()
    var valueArray = NSMutableArray()
    var selectedIndex = 0
    
    @IBOutlet var curCollectionView: UICollectionView!
    
    override func viewWillLayoutSubviews() {
        self.dropShadow(view:self.curCollectionView ,color: .green, opacity: 1, offSet: CGSize(width: -1, height: 1), radius: 2, scale: true)
        self.txtAmount.addDashedBorder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.getData()
    }
    
    func getForexData(completion: @escaping (Result<Forex, Error>) -> ()){
        let urlString = "\(url)&symbols=CAD,AUD,GBP,JPY,USD"
        print(urlString)
        guard let mainUrl = URL(string: urlString) else {return}
        
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
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.curCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        let amount = Float(self.txtAmount.text ?? "0") ?? 0
        let unit: Float = self.valueArray[indexPath.row] as! Float
        let convertedAmt = amount * unit
        self.lblConvertedCurrency.text = "\(convertedAmt)"
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellSize = CGSize(width: 80, height: 80)
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let horizontalInset = self.curCollectionView.frame.size.width/2 - 40
        
        return UIEdgeInsets(top: 0,left: horizontalInset,bottom: 0,right: horizontalInset)
    }
    
    //MARK: Custom Methods
    func dropShadow(view: UIView, color: UIColor, opacity: Float = 0.5, offSet: CGSize, radius: CGFloat = 1, scale: Bool = true) {
        view.layer.masksToBounds = false
        view.layer.shadowColor = color.cgColor
        view.layer.shadowOpacity = opacity
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = radius
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
    
}


