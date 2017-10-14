//
//  detailViewController.swift
//  COMP327 Assignment2
//
//  Created by Anran Guo on 09/12/2016.
//  Copyright © 2016 Anran Guo. All rights reserved.
//

import UIKit

class detailViewController: UIViewController {
    /*
     initialize jsonResult to save the result from json file;
     initialize jsonPhoto to save the result from json file
     */
    var jsonResult : AnyObject = 0 as AnyObject
    var jsonPhoto : AnyObject = 0 as AnyObject
    //initialize elements of UIView
    @IBOutlet weak var website: UIButton!
    @IBOutlet weak var address: UILabel!
    @IBOutlet weak var phoneNumber: UIButton!
    @IBOutlet weak var image: UIImageView!
    
    /*
     touch the website to visit the website
     */
    @IBAction func tapWebsite(_ sender: Any) {
        if let url = URL(string: ((self.jsonResult["result"] as? NSDictionary)?["website"] as? String)!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    /*
     touch the phone number to make a phone call
     */
    @IBAction func tapPhoneNumber(_ sender: Any) {
        if let url = URL(string: ((self.jsonResult["result"] as? NSDictionary)?["formatted_phone_number"] as? String)!) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
        
    }
    
    /*
     the main func that will be called when the view did load
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        //the website button is hidden
        website.isHidden = true
        //the phone number button is hidden
        phoneNumber.isHidden = true
        
        //load data from the link with placeID
        let url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&key=AIzaSyB579Y7prckL2vXW3qG1XwnRz8whAacy5E")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print(error)
                
            } else {
                if let urlContent = data {
                    
                    do {
                        //get jsonResult
                        self.jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        //show the phone number button and set title with data from jsonResult
                        if let number = (self.jsonResult["result"] as? NSDictionary)?["formatted_phone_number"] as? String{
                            self.phoneNumber.isHidden = false
                            self.phoneNumber.setTitle(number, for: .normal)
                        }
                        //set title of postalAddress with data from jsonResult
                        if let postalAddress = (self.jsonResult["result"] as? NSDictionary)?["formatted_address"] as? String{
                            self.address.text = postalAddress
                        }
                        //show the website button and set title with data from jsonResult
                        if let web = (self.jsonResult["result"] as? NSDictionary)?["website"] as? String{
                            self.website.isHidden = false
                            self.website.setTitle(web, for: .normal)
                        }
                        
                    } catch {
                        print("======\nJSON processing Failed\n=======")
                    }
                    
                }
            }
        }
        task.resume()
        
        //load data from the link with photoReference
        let url2 = URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)=AIzaSyB579Y7prckL2vXW3qG1XwnRz8whAacy5E")!
        let task2 = URLSession.shared.dataTask(with: url2) { (data, response, error) in
            if error != nil {
                print(error)
                
            } else {
                if let urlContent = data {
                    //show the photo with data from jsonPhoto
                    self.jsonPhoto = UIImage(data: urlContent)!
                    self.image.image = self.jsonPhoto as! UIImage
                    
                }
            }
        }
        task2.resume()
       
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
