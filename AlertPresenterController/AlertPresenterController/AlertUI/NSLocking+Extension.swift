//
//  NSLock+Extension.swift
//  AlertController
//
//  Created by Руслан Ахапкин on 20.11.2017.
//  Copyright © 2017 roke. All rights reserved.
//

import Foundation

public extension NSLocking {
    public func synchronized(operation: () -> Void) {
        self.lock()
        defer { self.unlock() }
        operation()
    }

    public func synchronized<T>(operation: () -> T) -> T {
        self.lock()
        defer { self.unlock() }
        return operation()
    }
}
