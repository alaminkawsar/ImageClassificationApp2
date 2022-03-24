//
//  ViewController.swift
//  ImageClassificationApp2
//
//  Created by Khayrul on 3/24/22.
//

import UIKit

class ViewController: UIViewController {
    
    var cnt: Int = 1
    
    private var modelParser: ModelParser? =
      ModelParser(modelFileInfo: MobileNet.modelInfo, labelsFileInfo: MobileNet.labelsInfo)
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var textField: UITextField!
    @IBAction func next(_ sender: Any) {
        
        textField.text = ""
        //confidence.text = ""
        
        if cnt >= 12 {
            cnt = 1
        }
        else {
            cnt = cnt + 1
            imageView.image = UIImage(named: String(cnt))
        }
        
    }
    @IBAction func predict(_ sender: Any) {
        doInference()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    private func doInference() {
        if let imageAnalysis = imageView?.image {
            sceneLabel(forImage: imageAnalysis)
        }
    }
    
    private func sceneLabel(forImage image:UIImage) {
        if let pixelBuffer = buffer(from: image) {
            guard let getObject = self.modelParser?.runModel(onFrame: pixelBuffer) else {
                return
            }
            let result = getObject.inferences
            
           // print(result[0].confidence, result[1].confidence)
            textField.text = result[0].label
            
        }
    }


}

func buffer(from image: UIImage) -> CVPixelBuffer? {
  let attrs = [
    kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
    kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
  ] as CFDictionary

  var pixelBuffer: CVPixelBuffer?
  let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                   Int(image.size.width),
                                   Int(image.size.height),
                                   kCVPixelFormatType_32BGRA,
                                   attrs,
                                   &pixelBuffer)

  guard let buffer = pixelBuffer, status == kCVReturnSuccess else {
    return nil
  }

  CVPixelBufferLockBaseAddress(buffer, [])
  defer { CVPixelBufferUnlockBaseAddress(buffer, []) }
  let pixelData = CVPixelBufferGetBaseAddress(buffer)

  let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
  guard let context = CGContext(data: pixelData,
                                width: Int(image.size.width),
                                height: Int(image.size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue) else {
    return nil
  }

  context.translateBy(x: 0, y: image.size.height)
  context.scaleBy(x: 1.0, y: -1.0)

  UIGraphicsPushContext(context)
  image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
  UIGraphicsPopContext()

  return pixelBuffer
}

