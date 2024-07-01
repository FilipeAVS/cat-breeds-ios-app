@testable import Network
import XCTest

final class NetworkTests: XCTestCase {
    private let apiHost = "apiHost"
    private let apiKey = "apiKey"

    override func setUp() {
        super.setUp()

        MockURLProtocol.requestHandler = nil
    }

    func test_get_withSuccess_returnsExpectedValue() async throws {
        let sut = makeSut()
        let path = "path"
        let endpoint = MockEndpoint(path: path)
        let decodable = MockDecodable()

        MockURLProtocol.requestHandler = { receivedRequest in
            XCTAssertEqual(receivedRequest.url, URL(string: "https://apiHost/v1/\(path)")!)
            XCTAssertEqual(receivedRequest.httpMethod, "GET")
            XCTAssertEqual(receivedRequest.value(forHTTPHeaderField: "x-api-key"), self.apiKey)
            return (decodable.asData, anyHttpUrlResponse())
        }

        let result: MockDecodable = try await sut.get(endpoint: endpoint)

        XCTAssertEqual(result, decodable)
    }

    func test_get_withSuccess_withInvalidData_returnsExpectedValue() async {
        let sut = makeSut()
        let path = "path"
        let endpoint = MockEndpoint(path: path)

        MockURLProtocol.requestHandler = { receivedRequest in
            XCTAssertEqual(receivedRequest.url, URL(string: "https://apiHost/v1/\(path)")!)
            XCTAssertEqual(receivedRequest.httpMethod, "GET")
            XCTAssertEqual(receivedRequest.value(forHTTPHeaderField: "x-api-key"), self.apiKey)
            return (Data("anydata".utf8), anyHttpUrlResponse())
        }

        do {
            let _: MockDecodable = try await sut.get(endpoint: endpoint)
        } catch {
            XCTAssertEqual(error as? Client.ClientError, .unexpectedResponse)
        }
    }

    func test_post_withSuccess_returnsExpectedValue() async throws {
        let sut = makeSut()
        let path = "path"
        let body = MockDecodable()
        let endpoint = MockEndpoint(path: path, bodyValue: body)

        MockURLProtocol.requestHandler = { receivedRequest in
            XCTAssertEqual(receivedRequest.url, URL(string: "https://apiHost/v1/\(path)")!)
            XCTAssertEqual(receivedRequest.httpMethod, "POST")
            XCTAssertEqual(receivedRequest.value(forHTTPHeaderField: "x-api-key"), self.apiKey)
            XCTAssertEqual(receivedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
            return (body.asData, anyHttpUrlResponse())
        }

        let result: MockDecodable = try await sut.post(endpoint: endpoint)

        XCTAssertEqual(result, body)
    }

    func test_post_withSuccess_withInvalidData_returnsExpectedValue() async {
        let sut = makeSut()
        let path = "path"
        let body = MockDecodable()
        let endpoint = MockEndpoint(path: path, bodyValue: body)

        MockURLProtocol.requestHandler = { receivedRequest in
            XCTAssertEqual(receivedRequest.url, URL(string: "https://apiHost/v1/\(path)")!)
            XCTAssertEqual(receivedRequest.httpMethod, "POST")
            XCTAssertEqual(receivedRequest.value(forHTTPHeaderField: "x-api-key"), self.apiKey)
            XCTAssertEqual(receivedRequest.value(forHTTPHeaderField: "Content-Type"), "application/json")
            return (Data("anydata".utf8), anyHttpUrlResponse())
        }

        do {
            let _: MockDecodable = try await sut.post(endpoint: endpoint)
        } catch {
            XCTAssertEqual(error as? Client.ClientError, .unexpectedResponse)
        }
    }

    func test_delete_withSuccess_doesNotThrow() async throws {
        let sut = makeSut()
        let path = "path"
        let endpoint = MockEndpoint(path: path)
        let expectedResponse = anyHttpUrlResponse()

        MockURLProtocol.requestHandler = { receivedRequest in
            XCTAssertEqual(receivedRequest.url, URL(string: "https://apiHost/v1/\(path)")!)
            XCTAssertEqual(receivedRequest.httpMethod, "DELETE")
            XCTAssertEqual(receivedRequest.value(forHTTPHeaderField: "x-api-key"), self.apiKey)
            return (nil, expectedResponse)
        }

        do {
            try await sut.delete(endpoint: endpoint)
        } catch {
            XCTFail("Expected no error, but got \(error)")
        }
    }

    // MARK: Helpers

    private func makeSut() -> Client {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession(configuration: configuration)
        return Client(
            apiHost: apiHost,
            apiKey: apiKey,
            urlSession: urlSession
        )
    }
}

private struct MockEndpoint: Endpoint {
    var path: String
    var queryItems: [URLQueryItem]?
    var bodyValue: (any Encodable)?

    init(path: String, queryItems: [URLQueryItem]? = nil, bodyValue: (any Encodable)? = nil) {
        self.path = path
        self.queryItems = queryItems
        self.bodyValue = bodyValue
    }
}

private struct MockDecodable: Codable, Hashable {
    var asData: Data {
        let encoder = JSONEncoder()
        return try! encoder.encode(self)
    }
}

public func anyUrlString() -> String {
    return "https://www.google.com"
}

public func anyUrl(string: String = anyUrlString()) -> URL {
    return URL(string: string, encodingInvalidCharacters: false)!
}

public func anyHttpUrlResponse() -> HTTPURLResponse {
    return HTTPURLResponse(url: anyUrl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
}
