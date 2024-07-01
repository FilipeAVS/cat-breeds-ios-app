//
//  MockURLProtocol.swift
//
//
//  Created by Filipe Santos on 01/07/2024.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (Data?, URLResponse))?

    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let requestHandler = MockURLProtocol.requestHandler else { return }

        do {
            let (data, response) = try requestHandler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            if let data {
                client?.urlProtocol(self, didLoad: data)
            }
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
