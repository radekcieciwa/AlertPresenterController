import UIKit

class AlertPresentationOperation: AsyncOperation {

    public struct PopoverParameter {
        var barButtonItem: UIBarButtonItem? = nil

        var sourceView: UIView? = nil
        var sourceRect = CGRect.zero
        var arrowDirection = UIPopoverArrowDirection.any
    }

    public var presentCompletion: (() -> Void)? = nil
    public var popoverParameter = PopoverParameter()

    fileprivate var alertWindow: AlertWindow? = nil
    fileprivate let alertController: UIAlertController
    fileprivate let presentingController: UIViewController

    public required init(title: String, message: String, style: UIAlertControllerStyle, presentingController: UIViewController) {
        self.alertController = UIAlertController(title: title, message: message, preferredStyle: style)
        self.presentingController = presentingController

        super.init()
    }

    public convenience init(title: String, message: String, style: UIAlertControllerStyle, alertWindow: AlertWindow) {
        guard let presentingController = alertWindow.rootViewController else {
            fatalError("Setup root controller in alert window")
        }
        self.init(title: title, message: message, style: style, presentingController: presentingController)
        self.alertWindow = alertWindow
    }
    
    public func addAction(title: String?, style: UIAlertActionStyle, preffered: Bool, handler: ((UIAlertAction) -> Swift.Void)?) {
        let wrapperHandler = { [weak self] (alertAction: UIAlertAction) in
            if let handler = handler {
                handler(alertAction)
            }
            
            self?.finishOpeation()
        }
        let action = UIAlertAction(title: title, style: style, handler: wrapperHandler)
        self.alertController.addAction(action)
        if preffered {
            self.alertController.preferredAction = action
        }
    }

    public override func cancel() {
        self.bma_dispatchOnMainThread {
            super.cancel()
            self.finishOpeation()
        }
    }
    
    internal override func main() {
        self.bma_dispatchOnMainThread {
            guard !self.isCancelled else { return }

            self.applyPopoverParameter()
            
            self.alertWindow?.isHidden = false
            self.presentingController.present(self.alertController, animated: true, completion: self.presentCompletion)
        }
    }

    fileprivate func applyPopoverParameter() {
        guard UI_USER_INTERFACE_IDIOM() == .pad else { return }

        self.alertController.modalPresentationStyle = .popover
        guard let popoverController = self.alertController.popoverPresentationController else { return }

        popoverController.permittedArrowDirections = self.popoverParameter.arrowDirection
        if let barButtonItem = self.popoverParameter.barButtonItem {
            popoverController.barButtonItem = barButtonItem
        } else if let sourceView = self.popoverParameter.sourceView {
            popoverController.sourceView = sourceView
            popoverController.sourceRect = self.popoverParameter.sourceRect
        } else {
            popoverController.sourceView = self.presentingController.view
            popoverController.sourceRect = CGRect(x: self.presentingController.view.bounds.midX, y: self.presentingController.view.bounds.midY, width: 0, height: 0)
        }
    }
    
    fileprivate func finishOpeation() {
        self.bma_dispatchOnMainThread {
            guard !self.isFinished else { return }
            
            let completion = {
                self.alertWindow?.isHidden = true
                self.finish()
            }
            
            if self.alertController.presentingViewController == self.presentingController {
                self.presentingController.dismiss(animated: true, completion: completion)
            } else {
                completion()
            }
        }
    }
    
    // FIXME: remove later
    fileprivate func bma_dispatchOnMainThread(_ closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}
