//
//  ViewController.swift
//  TakePicture
//
//  Created by 竣亦 on 2022/1/19.
//

import UIKit
import Vision


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userPickingImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            imageView.image = userPickingImage
            imagePicker.dismiss(animated: true, completion: nil)
            
            guard let ciImage = CIImage(image: userPickingImage) else {
                
                fatalError("Colud not convert to CIImage.")
                
            }
            
            detect(image: ciImage)
            
        }
        
    }
    
    func detect(image: CIImage){
        
        guard let model = try? VNCoreMLModel(for: SqueezeNetInt8LUT().model) else {
            
            fatalError("Cloud not load NL Model")
            
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            
            guard let results = request.results as? [VNClassificationObservation] else {
                
                fatalError("Cloud not get result")
                
            }
            
            let topResult = results.first
            
            print(topResult)
            
            if (topResult?.identifier.contains("banana"))! {
                
                self.navigationItem.title = "Banana!"
                
            } else {
                
                self.navigationItem.title = "Not Banana!"
                
            }
            
        }
        
        do{
        
            let handler = try? VNImageRequestHandler(ciImage: image, options: [ : ]).perform([request])
        
        } catch{
            
            print(error)
            
        }
        
        
        
        
    }

    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        
        imagePicker.sourceType = UIImagePickerController.SourceType.camera
        imagePicker.allowsEditing = false
        
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
}

