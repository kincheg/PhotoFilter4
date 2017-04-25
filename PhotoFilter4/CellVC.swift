//
//  CellVC.swift
//  PhotoFilter4
//
//  Created by kin on 02.09.16.
//  Copyright © 2016 kin. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import CoreImage



class CellVC: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet weak var filterCell: UICollectionView!
    @IBOutlet weak var photoImage: UIImageView!
    
    
    var selectedImage: UIImage!
    var filteredCIImage : CIImage!
    var processImage: UIImage!
    
    
    
    //    let arrayOfFilters: [String] = ["CISepiaTone","CIPixellate","CIGaussianBlur","CIBoxBlur","CIColorMonochrome","CIPhotoEffectTonal","CIPhotoEffectNoir","CIPhotoEffectChrome","CIPhotoEffectFade","CIPhotoEffectInstant","CIPhotoEffectMono","CIPhotoEffectNoir","CIPhotoEffectProcess","CIPhotoEffectTonal","CIPhotoEffectTransfer","CILinearToSRGBToneCurve"]
    
    let arrayOfFilters: [String] = ["CIPhotoEffectNoir","CIPhotoEffectProcess","CIPhotoEffectTonal","CIPhotoEffectTransfer","CILinearToSRGBToneCurve"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filterCell.delegate = self
        filterCell.dataSource = self
        photoImage.contentMode = .scaleAspectFill
        photoImage.image = selectedImage
        filteredCIImage = CIImage(image: photoImage.image!)
        
        
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return arrayOfFilters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) //as! CustomLabelCell
        let filterName = arrayOfFilters [(indexPath as NSIndexPath).row]
        let cellView = UIImageView()
        cellView.image = previewCellFilters(filterName: filterName)
        cellView.contentMode = .scaleAspectFill
        cell.layer.cornerRadius = 20
        cell.backgroundView = cellView
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        applyFilter(arrayOfFilters[(indexPath as NSIndexPath).row])
    }
    
    
    
    // ApplyFilter
    
    func applyFilter(_ filterName: String) {
        let inputImage = CIImage(image: selectedImage)
        let filter = CIFilter(name: filterName)
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        let outputImage = UIImage(ciImage: (filter?.outputImage)!)
        photoImage.image = outputImage
        print(outputImage.size)
        filteredCIImage = filter?.outputImage!
        
    }
    
    
    
    @IBAction func saveImage(_ sender: AnyObject) {
        let softwareContext = CIContext(options: [kCIContextUseSoftwareRenderer:true])
        let cgiimg = softwareContext.createCGImage(filteredCIImage!, from: (filteredCIImage?.extent)!)
        let orientation : ALAssetOrientation = ALAssetOrientation(rawValue: selectedImage.imageOrientation.rawValue)!
        let library = ALAssetsLibrary()
        library.writeImage(toSavedPhotosAlbum: cgiimg, orientation: orientation, completionBlock: nil)
        
    }
    
    
    @IBAction func rotateImages(_ sender: UIBarButtonItem) {
        
        if let originalImage = selectedImage {
            
            let rotateSize = CGSize(width: originalImage.size.height, height: originalImage.size.width)
            UIGraphicsBeginImageContextWithOptions(rotateSize, true, 2.0)
            if let context = UIGraphicsGetCurrentContext() {
                context.rotate(by: 90.0 * CGFloat(M_PI) / 180.0)
                context.translateBy(x: 0, y: -originalImage.size.height)
                originalImage.draw(in: CGRect(x: 0, y: 0, width: originalImage.size.width, height: originalImage.size.height))
                self.photoImage.image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                selectedImage = self.photoImage.image
                filteredCIImage = CIImage(image: self.photoImage.image!)
            }
        }
        
    }
    
  
    
    
    // PreviewCellFilters
    
    func previewCellFilters(filterName: String) -> UIImage {
        
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: selectedImage!)
        let filter = CIFilter(name: filterName )
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        let imageForButton = UIImage(cgImage: filteredImageRef!)
        return imageForButton
    }
    
    
}







