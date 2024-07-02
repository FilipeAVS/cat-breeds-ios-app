//
//  ThreadSafeResult.swift
//  CatBreedsTests
//
//  Created by Filipe Santos on 02/07/2024.
//

import Foundation

final class ThreadSafeResult<T> {
    private let queue = DispatchQueue(label: "ThreadSafeQueue")
    private var results: [Result<T, Error>] = []

    func removeLast() -> Result<T, Error>? {
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
