//
//  TestHelpers.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation

final class ThreadSafeResult<T> {
    private let queue = DispatchQueue(label: "ThreadSafeQueue")
    private var results: [Result<T, Error>] = []

    func popLast() -> Result<T, Error>? {
        queue.sync {
            results.removeLast()
        }
    }

    func append(_ result: Result<T, Error>) {
        queue.sync {
            results.append(result)
        }
    }
}

public func anyError() -> Error {
    return NSError(domain: "", code: 0)
}
