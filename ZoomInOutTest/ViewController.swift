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
    case aspectToFit
    case aspectToFill
    case expanded
}

class ZoomedPhotoViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var imageViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewTrailingConstraint: NSLayoutConstraint!
    
    var photoName: String?
    var zoomStatus: ZoomStatus = .aspectToFit
    
    @IBOutlet weak var pinchAnimationView: UIView!
    override func viewDidLoad() {
        if let photoName = photoName {
            imageView.image = UIImage(named: photoName)
        }
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
    }
    
    
    func showPinchAnimationView() {
//        UIDevice.vibrate()
        
        pinchAnimationView.isHidden = false
        UIView.animate(withDuration: 0.7) { [unowned self] in
            pinchAnimationView.alpha = 1
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

//MARK:- Sizing
extension ZoomedPhotoViewController {
    func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        imageViewTopConstraint.constant = yOffset
        imageViewBottomConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        imageViewLeadingConstraint.constant = xOffset
        imageViewTrailingConstraint.constant = xOffset
        
        
//        print(imageViewTopConstraint.constant)
//        print(imageViewTrailingConstraint.constant)
        
        if view.frame.width < imageView.frame.width {
            zoomStatus = .expanded
        }
        else {
            zoomStatus = .aspectToFit
        }
        
        
        view.layoutIfNeeded()
    }
    
    func setConstraintsForAspectToFill() {
        imageViewTopConstraint.constant = 0
        imageViewBottomConstraint.constant = 0

        imageViewLeadingConstraint.constant = 0
        imageViewTrailingConstraint.constant = 0
        
        zoomStatus = .aspectToFill
        view.layoutIfNeeded()
    }
}

//MARK:- UIScrollViewDelegate
extension ZoomedPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
                
        print(imageView.frame)
        
//        switch zoomStatus {
//        case .aspectToFit:
//            if view.frame.width <= imageView.frame.width {
//                showPinchAnimationView()
//                setConstraintsForAspectToFill()
//                scrollView.pinchGestureRecognizer?.isEnabled = false
//                scrollView.pinchGestureRecognizer?.isEnabled = true
//                return
//            }
//        case .aspectToFill:
//            break
//        case .expanded:
//            if view.frame.width >= imageView.frame.width {
//                showPinchAnimationView()
//                setConstraintsForAspectToFill()
//                scrollView.pinchGestureRecognizer?.isEnabled = false
//                scrollView.pinchGestureRecognizer?.isEnabled = true
//                return
//            }
//            
//            break
//        }
        
        
        updateConstraintsForSize(view.bounds.size)
    }
    
}
