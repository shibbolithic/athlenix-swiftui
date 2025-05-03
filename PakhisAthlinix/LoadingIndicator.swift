import UIKit

class LoadingIndicator {
    // Singleton instance
    static let shared = LoadingIndicator()
    
    private var blurEffectView: UIVisualEffectView?
    private var loadingContainer: UIView?
    private var activityIndicator: UIActivityIndicatorView?
    
    private init() {} // Private initializer for singleton
    
    // Show loading indicator
    func show(in view: UIView) {
        // If already showing, do nothing
        guard blurEffectView == nil else { return }
        
        DispatchQueue.main.async {
            // Create blur effect
            let blurEffect = UIBlurEffect(style: .light)
            let blurView = UIVisualEffectView(effect: blurEffect)
            blurView.frame = view.bounds
            blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Create container view
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 120, height: 120))
            container.center = view.center
            container.backgroundColor = UIColor(white: 0.9, alpha: 0.7)
            container.layer.cornerRadius = 10
            container.layer.shadowColor = UIColor.black.cgColor
            container.layer.shadowOpacity = 0.2
            container.layer.shadowOffset = CGSize(width: 0, height: 2)
            container.layer.shadowRadius = 4
            
            // Create activity indicator
            let indicator = UIActivityIndicatorView(style: .large)
            indicator.color = .darkGray
            indicator.center = CGPoint(x: container.bounds.midX, y: container.bounds.midY)
            indicator.hidesWhenStopped = false
            
            // Add subviews
            container.addSubview(indicator)
            view.addSubview(blurView)
            view.addSubview(container)
            
            // Start animating
            indicator.startAnimating()
            
            // Save references
            self.blurEffectView = blurView
            self.loadingContainer = container
            self.activityIndicator = indicator
            
            // Ensure the loading indicator is shown on top of all other content
            view.bringSubviewToFront(blurView)
            view.bringSubviewToFront(container)
        }
    }
    
    // Hide loading indicator
    func hide() {
        DispatchQueue.main.async {
            // Animate hiding
            UIView.animate(withDuration: 0.3, animations: {
                self.blurEffectView?.alpha = 0.0
                self.loadingContainer?.alpha = 0.0
            }) { _ in
                self.activityIndicator?.stopAnimating()
                self.blurEffectView?.removeFromSuperview()
                self.loadingContainer?.removeFromSuperview()
                
                // Clear references
                self.blurEffectView = nil
                self.loadingContainer = nil
                self.activityIndicator = nil
            }
        }
    }
}
