//
//  ViewController.swift
//  BlinkOCR-sample-Swift
//
//  Created by Dino on 15/12/15.
//  Copyright © 2015 Dino. All rights reserved.
//

import UIKit
import MobileCoreServices
import MicroBlink

class ViewController: UIViewController, MBBarcodeOverlayViewControllerDelegate  {
    
    var rawParser: MBRawParser?
    var parserGroupProcessor: MBParserGroupProcessor?
    var blinkInputRecognizer: MBBlinkInputRecognizer?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func didTapScan(_ sender: AnyObject) {
        
        let settings = MBBarcodeOverlaySettings()
        rawParser = MBRawParser()
        parserGroupProcessor = MBParserGroupProcessor(parsers: [rawParser!])
        blinkInputRecognizer = MBBlinkInputRecognizer(processors: [parserGroupProcessor!])
        
        /** Create recognizer collection */
        settings.uiSettings.recognizerCollection = MBRecognizerCollection(recognizers: [blinkInputRecognizer!])
        let overlayVC = MBBarcodeOverlayViewController(settings: settings, andDelegate: self)
        
        weak var recognizerRunnerViewController: (UIViewController & MBRecognizerRunnerViewController)? = MBViewControllerFactory.recognizerRunnerViewController(withOverlayViewController: overlayVC)
        
        /** Present the recognizer runner view controller. You can use other presentation methods as well (instead of presentViewController) */
        present(recognizerRunnerViewController!, animated: true, completion: nil)
    }
    
    
    // MARK: MBBarcodeOverlayViewControllerDelegate delegate
    
    func barcodeOverlayViewControllerDidFinishScanning(_ barcodeOverlayViewController: MBBarcodeOverlayViewController, state: MBRecognizerResultState) {
        
        // check for valid state
        if state == MBRecognizerResultState.valid {
            // first, pause scanning until we process all the results
            barcodeOverlayViewController.recognizerRunnerViewController.pauseScanning()
            DispatchQueue.main.async(execute: {() -> Void in
                print("OCR results are:")
                print("Raw ocr: \(self.rawParser!.result.rawText)")
                let ocrLayout: MBOcrLayout? = self.parserGroupProcessor!.result.ocrLayout
                print("Dimensions of ocrLayout are \(NSStringFromCGRect((ocrLayout?.box)!))")
                barcodeOverlayViewController.recognizerRunnerViewController.resumeScanningAndResetState(true)
            })
        }
    }
    
    func barcodeOverlayViewControllerDidTapClose(_ barcodeOverlayViewController: MBBarcodeOverlayViewController) {
        self.dismiss(animated: true, completion: nil)
    }
}

