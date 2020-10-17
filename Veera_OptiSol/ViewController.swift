//
//  ViewController.swift
//  Veera_OptiSol
//
//  Created by Veeraswamy on 15/10/20.
//  Copyright © 2020 Orbcomm. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import SVProgressHUD
class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
     var images = [Images]()
    var offset :Int = 0
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getBingSearchAPI()
    }

    
    
    @IBAction func loadMoreButtonClicked(_ sender: Any) {
        
        print("LoadMore Button Clicked")
        
        if(offset>=0)
        {
            offset = offset+1
        }
        getBingSearchAPI()
        
    }
    // Api Call
    
    func getBingSearchAPI()  {
        SVProgressHUD.show()
        let headers: HTTPHeaders = [
            "Ocp-Apim-Subscription-Key": "023085f066514c188ea29a5dfacfbd2c",
            "Accept": "application/json"
        ]
        Alamofire.request("https://api.cognitive.microsoft.com/bing/v7.0/images/search?q=cats&count=10&offset=\(offset)&mkt=en-us&safeSearch=Moderate",method: .get,headers:headers).responseJSON { response in
           // SVProgressHUD.dismiss()
            guard response.result.isSuccess else{
                if response.result.error?._code == -1005 {
                 SVProgressHUD.dismiss()
                }else if response.result.error?._code == -1001{
                  SVProgressHUD.dismiss()
                }else{
                   SVProgressHUD.dismiss()
                }
                return print("Error:\(response.result.error?.localizedDescription)")
            }
            if let JSONObj = response.result.value {
               
                let json = JSON(JSONObj)
                let resultjson = json ["value"]
                print("JSON:\(resultjson)")
               for jsonImages in resultjson {
                    let jsonTuple = jsonImages
                    let jsonDict = jsonTuple.1
                    let img = Images()
                    img.name = jsonDict["name"].rawString()!
                    img.datePublished =   jsonDict["datePublished"].rawString()!
                    img.contentUrl =  jsonDict["contentUrl"].rawString()!
                    self.images.append(img)
                    print (self.images)
                    
                }
                SVProgressHUD.dismiss()
                OperationQueue.main.addOperation({() -> Void in
                    
                    self.collectionView.reloadData()
                    
                })
                
            }
        }
    }
    
    // CollectionView DataSource Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        
        cell.lblName.text = self.images[indexPath.row].name
       // cell.lblDatePublished.text = self.images[indexPath.row].datePublished
        
        let queue = DispatchQueue.global(qos: .default)
        queue.async { () -> Void in
            let url = NSURL(string: self.images[indexPath.row].contentUrl)
            let data = NSData(contentsOf: url! as URL)
            
            DispatchQueue.main.async(execute: {
                if data == nil {
                    cell.continerImage.image = UIImage.init(named: "bg-looder")
                }
                else{
                    
                    cell.continerImage.image = UIImage(data: data! as Data)}
                cell.continerImage.layer.cornerRadius = cell.continerImage.frame.size.width / 2
                cell.continerImage.clipsToBounds = true
            })
        }
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.9 )
    }
    
    
     func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if (kind == UICollectionElementKindSectionFooter) {
            let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footerCell", for: indexPath)
            
            // Customize footerView here
            return footerView
        } else if (kind == UICollectionElementKindSectionHeader) {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "CartHeaderCollectionReusableView", for: indexPath)
            // Customize headerView here
            return headerView
        }
        fatalError()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// Model Class

class Images{
    var name : String = ""
    var datePublished : String = ""
    var contentUrl : String = ""
}
