//
//  ViewController.swift
//  APoD
//
//  Created by Brian Koga on 4/2/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageTitle: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCopyright: UILabel!
    @IBOutlet weak var imageDescription: UITextView!
    
    @IBOutlet weak var dateTxtField: UITextField!
    
    @IBOutlet weak var canNotDisplay: UILabel!
    var datePicker = UIDatePicker()
    
    let photoInfoController = PhotoInfoController()
    
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // fetch today's APOD
        fetchInfo(self)
        
        canNotDisplay.text = ""
        
        datePicker  = UIDatePicker()
        datePicker.datePickerMode = UIDatePicker.Mode.date
        
        //ToolBar
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 35));
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        

        toolbar.setItems([doneButton], animated: false)

        dateTxtField.inputAccessoryView = toolbar
        
        // set minimum date
        // this is hardcoded as it is the first day APOD published
        // (other than once on june 16th, but that is excluded)
        let calendar = Calendar.current
        var minDateComponent = calendar.dateComponents([.day,.month,.year], from: Date())
        minDateComponent.day = 20
        minDateComponent.month = 06
        minDateComponent.year = 1995
        
        let minDate = calendar.date(from: minDateComponent)
        datePicker.minimumDate = minDate! as Date
        
        // set maximum date
        datePicker.maximumDate = date
    
        dateTxtField.inputView = datePicker
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        date = Date()
        dateTxtField.text = dateFormatter.string(from: date)
    }
    
    
    @IBAction func dateTapped(sender: UITextField) {
        //code for what to do when date field is tapped
        datePicker.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePicker

    }
    
    
    @objc func donedatePicker(){
        //For date formate
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        dateTxtField.text = formatter.string(from: datePicker.date)
        date = datePicker.date
        //dismiss date picker dialog
        self.view.endEditing(true)
        fetchInfo(self)
      }


    @IBAction func fetchInfo(_ sender: AnyObject?) {
        canNotDisplay.text = ""
        
        // always a good idea to let the user know you're up to something
        imageDescription.text = ""
        imageCopyright.text = ""
        imageTitle.text = "Fetching Update"
        imageView.image = nil
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString : String = dateFormatter.string(from: date)
        
        
        // fetchPhotoInfo expects to be handed a closure
        // we'll use the closure to fupdate the interface
        photoInfoController.fetchPhotoInfo(date: dateString) { (photoInfo) in
            if let photoInfo = photoInfo {  // only if we get photo info
                /*
                 Remember how URL tasks run in background threads?
                 So do closures they call. But you can only mess with the
                 UI from the main thread, so this punts the update code
                 into the main thread.
                 */
                DispatchQueue.main.async {
                    // you have to refer to local properties as self.whatever
                    // inside a closure.
                    
                    self.imageTitle.text = photoInfo.title
                    self.imageDescription.text = photoInfo.description
                    if let copyright = photoInfo.copyright {
                        self.imageCopyright.text = "Copyright \(copyright)"
                    } else {
                        self.imageCopyright.isHidden = true
                    }
                    
                    var photoURL : URL
                    
                    // check if it is https
                    // probably not actually necessary as APOD only returns https links
                    if (photoInfo.url.absoluteString.hasPrefix("https")) {
                        photoURL = photoInfo.url
                    } else {
                        var photoURLString : String = photoInfo.url.absoluteString
                        photoURLString = "https" + photoURLString.dropFirst(4)
                        photoURL = URL(string: photoURLString)!
                    }
                    
                    // check if url is an image
                    let imageExtensions = ["png", "jpg", "gif"]
                    let pathExtention = photoURL.pathExtension
                    if imageExtensions.contains(pathExtention) {
                        // Fetch Image Data
                        if let data = try? Data(contentsOf: photoURL) {
                            // Create Image and Update Image View
                            self.imageView.image = UIImage(data: data)
                        } else {
                            self.canNotDisplay.text = "Unable to display image"
                        }
                        
                    } else {
                        // its a video, just display text
                        self.canNotDisplay.text = "Unable to display video"
                    }
                    
                }
            } else {
                DispatchQueue.main.async {
                    // We should probably tell the user if something went wrong
                    // this will most likely be due to the request limit being reached
                    self.imageTitle.text = "Error occurred while fetching data"
                    self.canNotDisplay.text = "Check request limit"
                }
            }
            
        }
    }
    
}

