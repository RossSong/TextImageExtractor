//
//  ViewController.swift
//  TextExtractor
//
//  Created by Ross on 2018. 1. 17..
//  Copyright © 2018년 wanted. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    let delta: CGFloat = -5

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
    func CIImageToNSImage(_ ciImage: CIImage) -> NSImage? {
        let rep: NSCIImageRep = NSCIImageRep(ciImage: ciImage)
        let nsImage: NSImage = NSImage(size: rep.size)
        nsImage.addRepresentation(rep)
        return nsImage
    }
    
    func NSImageToCIImage(_ image: NSImage?) -> CIImage? {
        guard let image = image else { return nil }
        guard let imageData = image.tiffRepresentation else { return nil }
        guard let ciImage = CIImage(data: imageData) else { return nil }
        return ciImage
    }

    func getTextFeatures(_ image: NSImage) -> [CIFeature]? {
        guard let textDetector = CIDetector(ofType: CIDetectorTypeText, context: nil, options: nil) else { return nil }
        guard let ciImage = NSImageToCIImage(image) else { return nil }
        let features = textDetector.features(in: ciImage)
        
        return features
    }
    
    func setupInputTopLeft(_ perspectiveCorrection: CIFilter?, point: CGPoint) {
        var cgPoint = point
        cgPoint.x = cgPoint.x + delta
        cgPoint.y = cgPoint.y - delta
        perspectiveCorrection?.setValue(CIVector(cgPoint: cgPoint), forKey: "inputTopLeft")
    }
    
    func setupInputTopRight(_ perspectiveCorrection: CIFilter?, point: CGPoint) {
        var cgPoint = point
        cgPoint.x = cgPoint.x - delta
        cgPoint.y = cgPoint.y - delta
        perspectiveCorrection?.setValue(CIVector(cgPoint: cgPoint), forKey: "inputTopRight")
    }
    
    func setupInputBottomLeft(_ perspectiveCorrection: CIFilter?, point: CGPoint) {
        var cgPoint = point
        cgPoint.x = cgPoint.x + delta
        cgPoint.y = cgPoint.y + delta
        perspectiveCorrection?.setValue(CIVector(cgPoint: cgPoint), forKey: "inputBottomLeft")
    }
    
    func setupInputBottomRight(_ perspectiveCorrection: CIFilter?, point: CGPoint) {
        var cgPoint = point
        cgPoint.x = cgPoint.x - delta
        cgPoint.y = cgPoint.y + delta
        perspectiveCorrection?.setValue(CIVector(cgPoint: cgPoint), forKey: "inputBottomRight")
    }
    
    func getRectImageFrom(_ image: CIImage, foundRect: CITextFeature) -> CIImage? {
        let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")
        perspectiveCorrection?.setValue(image, forKey: "inputImage")
        setupInputTopLeft(perspectiveCorrection, point: foundRect.topLeft)
        setupInputTopRight(perspectiveCorrection, point: foundRect.topRight)
        setupInputBottomLeft(perspectiveCorrection, point: foundRect.bottomLeft)
        setupInputBottomRight(perspectiveCorrection, point: foundRect.bottomRight)
        return perspectiveCorrection?.outputImage
    }
    
    func extractTextImages(_ image: NSImage?) {
        guard let image = image, let ciImage = NSImageToCIImage(image), let features = getTextFeatures(image) else { return }
        for feature in features {
            let image = getRectImageFrom(ciImage, foundRect: feature as! CITextFeature)
            print(image)
        }
    }
    
    func extractTextImagesFromURL(_ url: URL?) {
        guard let url = url else { return }
        let fileManager = FileManager.default
        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            
            for fileURL in fileURLs {
                let image = NSImage(contentsOf: fileURL)
                extractTextImages(image)
            }
            
            // process files
        } catch {
            print("Error!")
        }
    }
    
    func selectDirectory() -> URL? {
        let openPanel = NSOpenPanel();
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = false
        let i = openPanel.runModal()
        
        if(i.rawValue == NSApplication.ModalResponse.OK.rawValue){
            return openPanel.url
        }
        
        return nil
    }

    @IBAction func buttonExtractPressed(_ sender: Any) {
        let url = selectDirectory()
        extractTextImagesFromURL(url)
    }
}

