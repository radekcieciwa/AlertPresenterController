import UIKit

public class AlertWindow: UIWindow {
    public static let shared = AlertWindow()
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }

    public convenience init() {
        self.init(frame: UIScreen.main.bounds)
        self.setup()
    }

    public override var windowLevel: UIWindowLevel {
        get {
            if #available(iOS 11.0, *) {
                return self.alertWindowLeveliOS11
            }
            return super.windowLevel
        }
        set {
            super.windowLevel = newValue
        }
    }

    fileprivate func setup() {
        self.windowLevel = self.alertWindowLevelDefault
        self.rootViewController = AlertWindowRootViewController()
        self.backgroundColor = .clear
    }

    fileprivate let alertWindowLevelDefault: UIWindowLevel = 100000000
    fileprivate let alertWindowLeveliOS11: UIWindowLevel = 100000001
}

fileprivate final class AlertWindowRootViewController: UIViewController {

    override var prefersStatusBarHidden: Bool {
        guard let rootViewController = self.applicationRootViewController() else {
            return super.prefersStatusBarHidden
        }
        return rootViewController.prefersStatusBarHidden
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        guard let rootViewController = self.applicationRootViewController() else {
            return super.preferredStatusBarStyle
        }
        return rootViewController.preferredStatusBarStyle
    }
    
    override var shouldAutorotate: Bool {
        guard let rootViewController = self.applicationRootViewController() else {
            return super.shouldAutorotate
        }
        return rootViewController.shouldAutorotate
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        guard let rootViewController = self.applicationRootViewController() else {
            return super.supportedInterfaceOrientations
        }
        if let presentedViewController = rootViewController.presentedViewController {
            return presentedViewController.supportedInterfaceOrientations
        }
        return rootViewController.supportedInterfaceOrientations
    }

    fileprivate func applicationRootViewController() -> UIViewController? {
        let rootViewController = UIApplication.shared.keyWindow?.rootViewController ?? self.applicationDelegateRootViewController()
        if rootViewController == nil {
            return nil
        }

        if rootViewController?.presentedViewController != nil {
            return rootViewController?.presentedViewController
        }

        return rootViewController
    }
    
    fileprivate func applicationDelegateRootViewController() -> UIViewController? {
        guard let w = UIApplication.shared.delegate?.window, let window = w else { return nil }
        return window.rootViewController
    }
}
