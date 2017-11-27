import Foundation

public class AsyncOperation: Operation {

    fileprivate enum OperationState: Int {
        case ready, executing, finished
    }

    // MARK: - Properties
    fileprivate let stateLock = NSRecursiveLock()
    fileprivate var _state = OperationState.ready
    
    fileprivate var state: OperationState {
        get {
            return self.stateLock.synchronized { self._state }
        }
        set {
            willChangeValue(forKey: "state")
            self.stateLock.synchronized { self._state = newValue }
            didChangeValue(forKey: "state")
        }
    }
    
    public final override var isReady: Bool {
        return super.isReady && self.state == .ready
    }
    
    public final override var isExecuting: Bool {
        return self.state == .executing
    }
    
    public final override var isFinished: Bool {
        return self.state == .finished
    }
    
    public final override var isAsynchronous: Bool {
        return true
    }
    
    // MARK: - NSObject KVO
    @objc private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state"]
    }
    
    @objc private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }
    
    @objc private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }

    public override final func start() {
        guard !self.isCancelled else {
            self.finish()
            return
        }
        self.state = .executing
        self.main()
    }

    /// Call this function after any work is done or after a call to `cancel()`
    /// to move the operation into a completed state.
    public final func finish() {
        self.state = .finished
    }
}

