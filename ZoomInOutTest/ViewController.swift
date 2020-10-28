/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit

enum ZoomStatus {
    case aspectFit
    case aspectFill
    case expanded
}

class ZoomedPhotoViewController: UIViewController {
    
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            return false
        }
         
     }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var zoomStatus: ZoomStatus = .aspectFit
    
    @IBOutlet weak var pinchAnimationView: UIView!
    override func viewDidLoad() {
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.transform = .identity
        scrollView.contentInset = .zero
        zoomStatus = .aspectFit
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for i in 0 ..< scrollView.gestureRecognizers!.count {
            let recognizer = scrollView.gestureRecognizers![i]

            if recognizer is UIPinchGestureRecognizer {
                recognizer.isEnabled = false
            }
        }
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))

        self.scrollView.addGestureRecognizer(pinchGesture)
    }

    @objc func pinch(_ sender: UIPinchGestureRecognizer) {
        
        if UIApplication.shared.statusBarOrientation == .portrait {
            portraitPinchGestured(sender: sender)
        }
        else {
            landscapePinchGestured(sender: sender)
        }
       
    }
    
    func portraitPinchGestured(sender: UIPinchGestureRecognizer) {
        let currentScale = self.imageView.frame.width / self.imageView.bounds.size.width
        
        var aspectFillScale: CGFloat = 1
        if #available(iOS 11.0, *) {
            aspectFillScale = self.view.frame.height / (self.view.safeAreaLayoutGuide.layoutFrame.height - 10)
        }
        
        var newScale = sender.scale
        
        if currentScale * sender.scale < 1 {
            newScale = 1 / currentScale
        }
        else if currentScale * sender.scale > 2 {
            newScale = 2 / currentScale
        }
        else if hasNotch {
            switch zoomStatus {
            case .aspectFit:
                if currentScale * sender.scale > aspectFillScale {
                    newScale = aspectFillScale / currentScale
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                        sender.isEnabled = false
                        sender.isEnabled = true
                        self?.zoomStatus = .aspectFill
                    }
                    showPinchAnimationView()
                }
            case .aspectFill:
                if currentScale * sender.scale > aspectFillScale {
                    zoomStatus = .expanded
                }
                else {
                    zoomStatus = .aspectFit
                }
            case .expanded:
                if currentScale * sender.scale < aspectFillScale {
                    newScale = aspectFillScale / currentScale
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                        sender.isEnabled = false
                        sender.isEnabled = true
                        self?.zoomStatus = .aspectFill
                    }
                    showPinchAnimationView()
                }

            }
        }
            
        self.imageView.transform = self.imageView.transform.scaledBy(x: newScale, y: newScale)
        sender.scale = 1
        
        let imageOriginY: CGFloat = imageView.frame.origin.y
        
        print(imageOriginY)
        
        var safeAreaInsetTop: CGFloat = 0
        var safeAreaInsetBottom: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            safeAreaInsetTop = view.safeAreaInsets.top
            safeAreaInsetBottom = view.safeAreaInsets.bottom
        }
        
        let superViewInset = safeAreaInsetTop + imageView.frame.origin.y
        
        if imageOriginY > -safeAreaInsetTop {
            scrollView.contentInset = UIEdgeInsets(top: -imageView.frame.origin.y + imageOriginY, left: -imageView.frame.origin.x, bottom: imageView.frame.origin.y - imageOriginY, right: imageView.frame.origin.x)
        }
        else {
            scrollView.contentInset = UIEdgeInsets(top: -imageView.frame.origin.y  + imageOriginY - superViewInset, left: -imageView.frame.origin.x, bottom: imageView.frame.origin.y  - imageOriginY - superViewInset, right: imageView.frame.origin.x)
        }
        
        scrollView.contentSize = CGSize(width: imageView.frame.width, height: imageView.frame.height  + (imageOriginY * 2))
    }
    
    func landscapePinchGestured(sender: UIPinchGestureRecognizer) {
        let currentScale = self.imageView.frame.width / self.imageView.bounds.size.width
        
        var aspectFillScale: CGFloat = 1
        if #available(iOS 11.0, *) {
            aspectFillScale = self.view.frame.width / self.view.safeAreaLayoutGuide.layoutFrame.width
        }
        
        var newScale = sender.scale
        
        print(currentScale)
        
        if currentScale * sender.scale < 1 {
            newScale = 1 / currentScale
        }
        else if currentScale * sender.scale > 2 {
            newScale = 2 / currentScale
        }
        else if hasNotch {
            switch zoomStatus {
            case .aspectFit:
                if currentScale * sender.scale > aspectFillScale {
                    newScale = aspectFillScale / currentScale
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                        sender.isEnabled = false
                        sender.isEnabled = true
                        self?.zoomStatus = .aspectFill
                    }
                    showPinchAnimationView()
                }
            case .aspectFill:
                if currentScale * sender.scale > aspectFillScale {
                    zoomStatus = .expanded
                }
                else {
                    zoomStatus = .aspectFit
                }
            case .expanded:
                if currentScale * sender.scale < aspectFillScale {
                    newScale = aspectFillScale / currentScale
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
                        sender.isEnabled = false
                        sender.isEnabled = true
                        self?.zoomStatus = .aspectFill
                    }
                    showPinchAnimationView()
                }

            }
        }
            
        self.imageView.transform = self.imageView.transform.scaledBy(x: newScale, y: newScale)
        sender.scale = 1
                
        var safeAreaInsetLeft: CGFloat = 0
        var safeAreaInsetRight: CGFloat = 0
        
        if #available(iOS 11.0, *) {
            safeAreaInsetLeft = view.safeAreaInsets.left
            safeAreaInsetRight = view.safeAreaInsets.right
        }
        
        let imageLeftInset: CGFloat = imageView.frame.origin.x
        let imageRightInset: CGFloat = imageView.frame.origin.x

        print(imageLeftInset , imageRightInset)

        
        let superViewInset = safeAreaInsetLeft + imageView.frame.origin.x
        
        if imageLeftInset > -safeAreaInsetLeft {
            scrollView.contentInset = UIEdgeInsets(top: -imageView.frame.origin.y, left: -imageView.frame.origin.x + imageLeftInset, bottom: imageView.frame.origin.y, right: imageView.frame.origin.x - imageLeftInset)
        }
        else {
            scrollView.contentInset = UIEdgeInsets(top: -imageView.frame.origin.y, left: -imageView.frame.origin.x + imageLeftInset - superViewInset, bottom: imageView.frame.origin.y, right: imageView.frame.origin.x - imageLeftInset - superViewInset)
        }
        
        scrollView.contentSize = CGSize(width: imageView.frame.width + (imageLeftInset * 2), height: imageView.frame.height)
    }
    
    
    
    
    
    
    
    func showPinchAnimationView() {
        pinchAnimationView.isHidden = false
        UIView.animate(withDuration: 0.2) { [unowned self] in
            pinchAnimationView.alpha = 0.7
            pinchAnimationView.layoutIfNeeded()
        } completion: { (completion) in
            UIView.animate(withDuration: 0.1) { [unowned self] in
                pinchAnimationView.alpha = 0
                pinchAnimationView.layoutIfNeeded()
                
                pinchAnimationView.isHidden = true
            }
        }

    }
    
}


