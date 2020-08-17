
import UIKit
import WebKit
import Alamofire
import SwiftyJSON




class NewsViewController: UIViewController,WKNavigationDelegate,WKUIDelegate  {
    var coordinatorDelegate: NewsCoordinatorDelegate?
    
    
    //UAT
    
    //    var loadUrl = URL(string: "https://pguat.credopay.info/credopay/api/visasubmit1.php")!
    //    let redirectionurl = "http://example.com?"
    //    let firstLeg = "https://pguat.credopay.info/credopay/api/CPDirectPG.php";
    //    let cardSubmit = "https://pguat.credopay.info/credopay/api/visasubmit1.php";
    //    let returnUrl = "https://pguat.credopay.info/credopay/api/appresponsemerchant.php?randomgen="
    
    
    //PROD
    
    var loadUrl = URL(string: "https://pg.credopay.in/credopay/api/visasubmit1.php")!
    let redirectionurl = "http://example.com?"
    let firstLeg = "https://pg.credopay.in/credopay/api/CPDirectPG.php";
    let cardSubmit = "https://pg.credopay.in/credopay/api/visasubmit1.php";
    let returnUrl = "https://pg.credopay.in/credopay/api/appresponsemerchant.php?randomgen="
    
    
    
    let amount = "100"
    let key_value = "ec89434eca0835";
    let ivv_value = "347637a3e64493";
    let merchant_id = "E01100000000009";
    
    
    
    let cardnumber = "00000000000000"
    let name_on_card = "NAME"
    let expiry_mm = "02"
    let expiry_yy = "2024"
    let card_cvv = "789"
    
    
    
    
    
    
    
    
    
    @IBOutlet weak var webViewContainer: UIView!
    
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let webConfiguration = WKWebViewConfiguration()
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        if(cardnumber.prefix(1)=="4")
        {
            
            print("found visa card")
            VisaFlow(merchant_id: merchant_id,name_on_card: name_on_card,cardnumber: cardnumber,expiry_mm: expiry_mm,expiry_yy: expiry_yy,card_cvv: card_cvv)
            
        }
        else if(cardnumber.prefix(1) == "5")
        {
            print("found master card")
            MasterFlow(merchant_id: merchant_id,name_on_card: name_on_card,cardnumber: cardnumber,expiry_mm: expiry_mm,expiry_yy: expiry_yy,card_cvv: card_cvv)
            
        }
        else if (cardnumber.prefix(1) == "6"){
            
            print("found rupay card")
            RupayFlow(merchant_id: merchant_id,name_on_card: name_on_card,cardnumber: cardnumber,expiry_mm: expiry_mm,expiry_yy: expiry_yy,card_cvv: card_cvv)
            
        }
        
        
        
    }
    
    @IBAction func goToFlutter(_ sender: Any) {
        coordinatorDelegate?.navigateToFlutter()
    }
    
    func RupayFlow(merchant_id: String,name_on_card : String,cardnumber : String ,expiry_mm : String,expiry_yy : String,card_cvv : String)
    {
        
        
        let currentDate = Date()
        let merchant_id = self.merchant_id;
        let amount = "1"
        let  currencyCodeChr = "INR"
        let dateFormatter = DateFormatter()
        let modified_date_formatter = DateFormatter()
        modified_date_formatter.dateFormat = "yyyyMMdd hh:mm:ss"
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        let timestamp: String = dateFormatter.string(from: currentDate)
        let Transaction_id = merchant_id + timestamp
        let TransactionType = "AA"
        let PaymentChannel = "Pg"
        let env = "live"
        
        do
        {
            

            let params = [
                "merchant_id" : merchant_id ,
                "&amount" : amount ,
                "&currency" : currencyCodeChr ,
                "&env" : env ,
                "&timestamp" : timestamp ,
                "&Transaction_id" : Transaction_id ,
                "&TransactionType" : TransactionType ,
                "&PaymentChannel" : PaymentChannel ,
                "&redirectionurl" : redirectionurl ,
                "&tax" : "RUPAY" ,
                "&nameoncard" : name_on_card ,
                "&card_num" : cardnumber ,
                "&expiry_mm" : expiry_mm ,
                "&expiry_yy" : expiry_yy ,
                "&card_cvv" : card_cvv ,
                "&buyerEmail" : "buyer@example.com" ,
                "&buyerPhone" : "9874563210" ,
                "&orderid" : Transaction_id ,
                "&buyerFirstName" : "SampleFirst" ,
                "&buyerLastName" : "SampleLast" ,
                "&payment_method" : "smartro"
            ]
            let postString = getPostString(params: params)
            
            var new_req = URLRequest(url: URL(string: firstLeg)!)
            new_req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            new_req.httpMethod = "POST"
            new_req.httpBody = postString.data(using: .utf8)
            self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
            let task = URLSession.shared.dataTask(with: new_req) { (data : Data?, response : URLResponse?, error : Error?) in
                if data != nil
                {
                    if let returnString = String(data: data!, encoding: .utf8)
                    {
                        self.webView.loadHTMLString(returnString, baseURL: URL(string: self.firstLeg)!)
                    }
                }
            }
            task.resume()
            
            
        }
        
        
    }
    
    
    
    func VisaFlow(merchant_id: String,name_on_card : String,cardnumber : String ,expiry_mm : String,expiry_yy : String,card_cvv : String)
    {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        let modified_date_formatter = DateFormatter()
        modified_date_formatter.dateFormat = "yyyyMMdd hh:mm:ss"
        dateFormatter.dateFormat = "yyyyMMddhhmmss"
        let timestamp: String = dateFormatter.string(from: currentDate)
        let Transaction_id = merchant_id + timestamp
        let TransactionType = "AA"
        let PaymentChannel = "Pg"
        let env = "livem"
        let currencyCodeChr = "INR"
        var finaldata_last = ""
        let currencyCodeNum = "356"
        let currencyExponent = "2"
        let final_returnUrl = returnUrl + card_cvv
        let schema = "VISA3DSPIT"
        let modified_expiration:String = String(expiry_yy.suffix(2) + expiry_mm)//yymm
        AF.upload(multipartFormData: {
            multipartFormData in
            multipartFormData.append(Data(self.merchant_id.utf8), withName: "merchant_id")
            multipartFormData.append(Data(self.amount.utf8), withName: "amount")
            multipartFormData.append(Data(currencyCodeChr.utf8), withName: "currency")
            multipartFormData.append(Data(env.utf8), withName: "env")
            multipartFormData.append(Data(timestamp.utf8), withName: "timestamp")
            multipartFormData.append(Data(Transaction_id.utf8), withName: "Transaction_id")
            multipartFormData.append(Data(TransactionType.utf8), withName: "TransactionType")
            multipartFormData.append(Data(PaymentChannel.utf8), withName: "PaymentChannel")
            multipartFormData.append(Data(self.redirectionurl.utf8), withName: "redirectionurl")
            multipartFormData.append(Data(finaldata_last.utf8), withName: "encData")
            multipartFormData.append(Data("VISA".utf8), withName: "tax")
            multipartFormData.append(Data(name_on_card.utf8), withName: "nameoncard")
            multipartFormData.append(Data(cardnumber.utf8), withName: "card_num")
            multipartFormData.append(Data(expiry_mm.utf8), withName: "expiry_mm")
            multipartFormData.append(Data(expiry_yy.utf8), withName: "expiry_yy")
            multipartFormData.append(Data(card_cvv.utf8), withName: "card_cvv")
            multipartFormData.append(Data(Transaction_id.utf8), withName: "ponumber")
            multipartFormData.append(Data("buyer@example.com".utf8), withName: "buyerEmail")
            multipartFormData.append(Data("9999999999".utf8), withName: "buyerPhone")
            multipartFormData.append(Data(Transaction_id.utf8), withName: "orderid")
            multipartFormData.append(Data("SampleFirst".utf8), withName: "buyerFirstName")
            multipartFormData.append(Data("SampleLast".utf8), withName: "buyerLastName")
            
            
        }
            , to: firstLeg)
            .responseJSON
            {
                response in
                print("response")
                if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                    print("Data: \(utf8Text)")
                    if let json = try? JSON(data: data) {
                        let status = json["status"]
                        if(status == "success")
                        {
                            
                            
                            let errorcode = json["errorcode"]
                            let guid = json["guid"]
                            let modulus = json["modulus"]
                            let exponent = json["exponent"]
                            let Mermapid = json["Mermapid"]
                            var tran_id  = json["tran_id"].description
                            var modified_amount = ""
                            let length = 12 - self.amount.count
                            for i in 1...length
                            {
                                modified_amount = modified_amount + "0"
                            }
                            
                            
                            modified_amount = modified_amount + self.amount
                            var modified_time: String = modified_date_formatter.string(from: currentDate)
                            
                            
                            
                            
                            let params = [
                                "schema" : schema ,
                                "&merchantId" : merchant_id ,
                                "&transactionId" : tran_id,
                                "&pan" : cardnumber ,
                                "&expiration" : modified_expiration ,
                                "&purchaseDate" : modified_time ,
                                "&purchaseAmount" : modified_amount ,
                                "&currencyCodeNum" : currencyCodeNum ,
                                "&currencyCodeChr" : currencyCodeChr ,
                                "&currencyExponent" : currencyExponent ,
                                "&mac" : cardnumber ,
                                "&env" : env ,
                                "&returnUrl" :final_returnUrl ,
                                "&serviceUrl" : "mpi.jsp"
                                
                            ]
                            
                            
                            let postString = self.getPostString(params: params)
                            var new_req = URLRequest(url: URL(string: self.cardSubmit)!)
                            new_req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                            new_req.httpMethod = "POST"
                            new_req.httpBody = postString.data(using: .utf8)
                            
                            
                            
                            
                            self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
                            let task = URLSession.shared.dataTask(with: new_req) { (data : Data?, response : URLResponse?, error : Error?) in
                                if data != nil
                                {
                                    if let returnString = String(data: data!, encoding: .utf8)
                                    {
                                        self.webView.loadHTMLString(returnString, baseURL: URL(string: self.cardSubmit)!)
                                    }
                                }
                            }
                            task.resume()
                        }
                        else{
                            print("failure")
                            print(json["errorcode"])
                            print(json["tran_id"])
                            print(json["guid"])
                            print(json["modulus"])
                            print(json["exponent"])
                            print(json["Mermapid"])
                        }
                    }
                    
                }
                
                
        }
        
        
    }
    
    
    func MasterFlow(merchant_id: String,name_on_card : String,cardnumber : String ,expiry_mm : String,expiry_yy : String,card_cvv : String)
       {
           let currentDate = Date()
           let dateFormatter = DateFormatter()
           let modified_date_formatter = DateFormatter()
           modified_date_formatter.dateFormat = "yyyyMMdd hh:mm:ss"
           dateFormatter.dateFormat = "yyyyMMddhhmmss"
           let timestamp: String = dateFormatter.string(from: currentDate)
           let Transaction_id = merchant_id + timestamp
           let TransactionType = "AA"
           let PaymentChannel = "Pg"
           let env = "livem"
           let currencyCodeChr = "INR"
           var finaldata_last = ""
           let currencyCodeNum = "356"
           let currencyExponent = "2"
           let final_returnUrl = returnUrl + card_cvv
           let schema = "MC"
           let modified_expiration:String = String(expiry_yy.suffix(2) + expiry_mm)//yymm
           AF.upload(multipartFormData: {
               multipartFormData in
               multipartFormData.append(Data(self.merchant_id.utf8), withName: "merchant_id")
               multipartFormData.append(Data(self.amount.utf8), withName: "amount")
               multipartFormData.append(Data(currencyCodeChr.utf8), withName: "currency")
               multipartFormData.append(Data(env.utf8), withName: "env")
               multipartFormData.append(Data(timestamp.utf8), withName: "timestamp")
               multipartFormData.append(Data(Transaction_id.utf8), withName: "Transaction_id")
               multipartFormData.append(Data(TransactionType.utf8), withName: "TransactionType")
               multipartFormData.append(Data(PaymentChannel.utf8), withName: "PaymentChannel")
               multipartFormData.append(Data(self.redirectionurl.utf8), withName: "redirectionurl")
               multipartFormData.append(Data(finaldata_last.utf8), withName: "encData")
               multipartFormData.append(Data("MC".utf8), withName: "tax")
               multipartFormData.append(Data(name_on_card.utf8), withName: "nameoncard")
               multipartFormData.append(Data(cardnumber.utf8), withName: "card_num")
               multipartFormData.append(Data(expiry_mm.utf8), withName: "expiry_mm")
               multipartFormData.append(Data(expiry_yy.utf8), withName: "expiry_yy")
               multipartFormData.append(Data(card_cvv.utf8), withName: "card_cvv")
               multipartFormData.append(Data(Transaction_id.utf8), withName: "ponumber")
               multipartFormData.append(Data("buyer@example.com".utf8), withName: "buyerEmail")
               multipartFormData.append(Data("9999999999".utf8), withName: "buyerPhone")
               multipartFormData.append(Data(Transaction_id.utf8), withName: "orderid")
               multipartFormData.append(Data("SampleFirst".utf8), withName: "buyerFirstName")
               multipartFormData.append(Data("SampleLast".utf8), withName: "buyerLastName")
               
               
           }
               , to: firstLeg)
               .responseJSON
               {
                   response in
                   print("response")
                   if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                       print("Data: \(utf8Text)")
                       if let json = try? JSON(data: data) {
                           let status = json["status"]
                           if(status == "success")
                           {
                               
                               
                               let errorcode = json["errorcode"]
                               let guid = json["guid"]
                               let modulus = json["modulus"]
                               let exponent = json["exponent"]
                               let Mermapid = json["Mermapid"]
                               var tran_id  = json["tran_id"].description
                               var modified_amount = ""
                               let length = 12 - self.amount.count
                               for i in 1...length
                               {
                                   modified_amount = modified_amount + "0"
                               }
                               
                               
                               modified_amount = modified_amount + self.amount
                               var modified_time: String = modified_date_formatter.string(from: currentDate)
                               
                               
                               
                               
                               let params = [
                                   "schema" : schema ,
                                   "&merchantId" : merchant_id ,
                                   "&transactionId" : tran_id,
                                   "&pan" : cardnumber ,
                                   "&expiration" : modified_expiration ,
                                   "&purchaseDate" : modified_time ,
                                   "&purchaseAmount" : modified_amount ,
                                   "&currencyCodeNum" : currencyCodeNum ,
                                   "&currencyCodeChr" : currencyCodeChr ,
                                   "&currencyExponent" : currencyExponent ,
                                   "&mac" : cardnumber ,
                                   "&env" : env ,
                                   "&returnUrl" :final_returnUrl ,
                                   "&serviceUrl" : "mpi.jsp"
                                   
                               ]
                               
                               
                               let postString = self.getPostString(params: params)
                               var new_req = URLRequest(url: URL(string: self.cardSubmit)!)
                               new_req.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                               new_req.httpMethod = "POST"
                               new_req.httpBody = postString.data(using: .utf8)
                               
                               
                               
                               
                               self.webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
                               let task = URLSession.shared.dataTask(with: new_req) { (data : Data?, response : URLResponse?, error : Error?) in
                                   if data != nil
                                   {
                                       if let returnString = String(data: data!, encoding: .utf8)
                                       {
                                           self.webView.loadHTMLString(returnString, baseURL: URL(string: self.cardSubmit)!)
                                       }
                                   }
                               }
                               task.resume()
                           }
                           else{
                               print("failure")
                               print(json["errorcode"])
                               print(json["tran_id"])
                               print(json["guid"])
                               print(json["modulus"])
                               print(json["exponent"])
                               print(json["Mermapid"])
                           }
                       }
                       
                   }
                   
                   
           }
           
           
       }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        let url = webView.url?.absoluteString;
        print(url!)
        if((url?.contains("success="))! && (url?.contains("responsecode="))! && Float(webView.estimatedProgress) == 1.0)
        {
            
            
            print("Response====================================")
            print(url!)
            print("Read url for response====================================")
            
            let url_data = URL(string: url!);
            
            print(url_data!["responsecode"]!)
            print(url_data!["merchant_id"]!)
            print(url_data!["transaction_id"]!)
            print(url_data!["amount"]!)
            print(url_data!["currency"]!)
            print(url_data!["TransactionType"]!)
            print(url_data!["success"]!)
            print(url_data!["errordesc"]!)
            print(url_data!["rrn"]!)
            print(url_data!["refNbr"]!)
            
            
        }
        
        
        
    }
    
    
    
    func getPostString(params:[String:String]) -> String
    {
        var data = [String]()
        for(key, value) in params
        {
            data.append(key + "=\(value)")
            
        }
        return data.map { String($0) }.joined(separator: "&")
    }
    func responseCallback(url_data: URL)
    {
        print(url_data["responsecode"]!)
        print(url_data["merchant_id"]!)
        print(url_data["transaction_id"]!)
        print(url_data["amount"]!)
        print(url_data["TransactionType"]!)
        print(url_data["success"]!)
        print(url_data["errordesc"]!)
        print(url_data["refNbr"]!)
        
    }
    
    
    
}








extension URL {
    subscript(queryParam:String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        return url.queryItems?.first(where: { $0.name == queryParam })?.value
    }
}
extension NewsViewController
{
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print(navigationAction.request.url!)
        
        
        let url = navigationAction.request.url?.absoluteString
        
        if(url!.contains("success=") && url!.contains("errordesc="))
        {
            let url_data = URL(string: url!);
            responseCallback(url_data: url_data!);
            
        }
        
        decisionHandler(.allow)
    }
    
    
}
