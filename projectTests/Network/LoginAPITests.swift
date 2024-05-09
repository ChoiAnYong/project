//
//  LoginAPITests.swift
//  projectTests
//
//  Created by 최안용 on 4/21/24.
//

@testable import project
import XCTest

class LoginAPITests: XCTestCase {
    var sut: Provider!
    
    override func setUpWithError() throws {
        sut = ProviderImpl(session: MockURLSession())
    }
    
    func test_fetchAuthentication_whenSuccess_thenProcessRight() {
        let expectation = XCTestExpectation()
        
        let endpoint = APIEndpoints.authenticateUser(with: .init(idToken: "d", name: "최안용", deviceToken: "dkasl"))
        let responsMock = try? JSONDecoder().decode(ServerAuthResponse.self, from: endpoint.sampleData!)
        
        sut.request(with: endpoint) { result in
            switch result {
            case .success(let response):
                XCTAssertEqual(response.accessToken, responsMock?.accessToken)
            case .failure:
                XCTFail()
            }
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_fetchAuthentication_whenFailed_thenProcessRight() {
        sut = ProviderImpl(session: MockURLSession(makeRequestFail: true))
        let expectation = XCTestExpectation()
        
        let endpoint = APIEndpoints.authenticateUser(with: .init(idToken: "d", name: "최안용", deviceToken: "dkasl"))
        
        sut.request(with: endpoint) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                XCTAssertEqual(error.localizedDescription, "status코드가 200~299가 아닙니다.")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func test_image() {
        sut = ProviderImpl(session: MockURLSession(makeRequestFail: true))
        let expectation = XCTestExpectation()
        let url = URL(string: "https://i.ibb.co/py7bBk0/2.png")
        
        sut.request(url!) { result in
            switch result {
            case .success:
                XCTFail()
            case let .failure(error):
                XCTAssertEqual(error.localizedDescription, "status코드가 200~299가 아닙니다.")
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }

}
