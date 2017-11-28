import UIKit

public enum AlertPresentingRule: Int {
    case oneByOne
    case oneInTime
}

// TBH, I don't like the static access to it.
// Maybe it's because it's the only way of accessing. Untestable.
// The operation queue could be extracted, as it seems an essential to the logic.
// And also One to One pairing with
// Maybe it's worth to create an instance wise one with default, like: NotificationCenter, or DispatchQueue.
// Then you can always inject another instance and make the logic testable as Unit.
public class AlertControllerPresenter: NSObject {
    
    public class func alertPresenter(title: String, message: String) -> Self {
        return self.init(title: title, message: message, style: .alert)
    }
    
    public class func actionSheetPresenter(title: String, message: String = "") -> Self {
        return self.init(title: title, message: message, style: .actionSheet)
    }
    
    public required init(title: String, message: String, style: UIAlertControllerStyle) {
        self.presenterOperation = AlertPresentationOperation(title: title, message: message, style: style, alertWindow: AlertWindow.shared)
        super.init()
    }
    
    // Do we extract this part only to have finishOperation handle?
    public func addDefaultAction(title: String, preffered: Bool = false, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.addAction(title: title, style: .default, preffered: preffered, handler: handler)
    }
    
    public func addDestructiveAction(title: String, preffered: Bool = false, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.addAction(title: title, style: .destructive, preffered: preffered, handler: handler)
    }
    
    public func addCancelAction(title: String, preffered: Bool = false, handler: ((UIAlertAction) -> Swift.Void)? = nil) {
        self.addAction(title: title, style: .cancel, preffered: preffered, handler: handler)
    }

    public func present(fromBarButtonItem barButtonItem: UIBarButtonItem) {
        self.presenterOperation.popoverParameter.barButtonItem = barButtonItem

        self.present()
    }

    public func present(fromSourceView sourceView: UIView, sourceRect: CGRect, arrowDirection: UIPopoverArrowDirection = .any) {
        self.presenterOperation.popoverParameter.sourceView = sourceView
        self.presenterOperation.popoverParameter.sourceRect = sourceRect
        self.presenterOperation.popoverParameter.arrowDirection = arrowDirection

        self.present()
    }

    public func present(presentingRule: AlertPresentingRule = .oneByOne, completion: (() -> Void)? = nil) {
        guard self.state == .configured else {
            assert(false, "Presenting alert controller is forbidden with state \(self.state)")
            return
        }
        self.presenterOperation.presentCompletion = completion

        let presentationQueue = type(of: self).presentationQueue
        // I'm not sure about this logic, needs to be rewised, by default it's off, by why it's cancelling
        self.apply(presentingRule: presentingRule, toQueue: presentationQueue)
        presentationQueue.addOperation(self.presenterOperation)
        self.state = .presented
    }
    
    public func dismiss() {
        guard self.state == .presented else {
            assert(false, "Dismissing alert controller is forbidden with state \(self.state)")
            return
        }
        self.presenterOperation.cancel()
        self.state = .dismissed
    }

    fileprivate enum PresenterState: String {
        case unconfigured, configured, presented, dismissed
    }

    fileprivate var state: PresenterState = .unconfigured
    fileprivate let presenterOperation: AlertPresentationOperation

    fileprivate func addAction(title: String?, style: UIAlertActionStyle, preffered: Bool, handler: ((UIAlertAction) -> Swift.Void)?) {
        guard self.state != .presented, self.state != .dismissed else {
            assert(false, "Adding action to alert controller is forbidden with state \(self.state)")
            return
        }
        self.presenterOperation.addAction(title: title, style: style, preffered: preffered, handler: handler)
        self.state = .configured
    }

    fileprivate func apply(presentingRule: AlertPresentingRule, toQueue presentationQueue: OperationQueue) {
        guard presentingRule == .oneInTime else { return }

        for operation in presentationQueue.operations {
            if operation.isExecuting && !operation.isCancelled {
                operation.cancel()
            }
        }
    }
    
    fileprivate static var presentationQueue: OperationQueue = {
        let presentationQueue = OperationQueue()
        presentationQueue.maxConcurrentOperationCount = 1;
        presentationQueue.qualityOfService = .userInteractive;
        presentationQueue.name = "com.alert.presentation.queue"
        return presentationQueue
    }()
}
