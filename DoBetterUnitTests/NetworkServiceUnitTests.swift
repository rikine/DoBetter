//
//  DoBetterUnitTests.swift
//  DoBetterUnitTests
//
//  Created by Никита Шестаков on 27.04.2023.
//

import XCTest
@testable import DoBetter

final class NetworkServiceUnitTests: XCTestCase {
    private var service: NetworkServiceProtocol!

    override func setUpWithError() throws {
        try super.setUpWithError()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        service = FakeNetworkService()
    }

    override func tearDownWithError() throws {
        service = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
    }

    func testUsersFetching() throws {
        let expectation = XCTestExpectation()
        
        Task {
            let users = try await service.request(UsersRequest(lastUid: nil, count: nil, neededUsersIds: nil, filter: nil))
            XCTAssertTrue(users == UsersRequest.models)
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60)
    }
    
    func testUserFetching() throws {
        let expectation = XCTestExpectation()
        
        Task {
            let user = try await service.request(UserRequest(userId: "test1"))
            XCTAssertTrue(user == UsersRequest.models[0])
            
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 60)
    }

    func testUserCreating() throws {
        let expectation = XCTestExpectation()

        Task {
            let user = try await service.request(CreateNewUser(uid: "test1", nickname: "nickname"))
            XCTAssertTrue(user == User.test)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testCheckPhoneExists() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(CheckPhoneExistsRequest(phone: "+12345678900"))
            XCTAssertFalse(result.isExists)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testNicknameExists() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(CheckNicknameExistsRequest(nickname: "test1"))
            XCTAssertFalse(result.isExists)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testUpdateUser() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(UpdateUserRequest(nickname: "test1", name: "testing1", description: nil, image: nil, shouldRemoveImage: false))
            XCTAssertTrue(result.success)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testFollowersRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(FollowersRequest(lastUid: nil, count: nil, neededUserUid: "current", filter: nil))
            XCTAssertTrue(result == Array(UsersRequest.models.suffix(2)))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testFollowingsRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(FollowingsRequest(lastUid: nil, count: nil, neededUserUid: "current", filter: nil))
            XCTAssertTrue(result == Array(UsersRequest.models.suffix(3)))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testFollowRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(FollowRequest(followingUid: "test2"))
            XCTAssertTrue(result.success)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testTaskRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(TaskRequest(uid: "task1"))
            XCTAssertTrue(CreateTaskRequest.tasks[0].uid == result.uid)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testUpdateTaskRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(UpdateTaskRequest(uid: "task1", title: "Task 1", description: nil,
                                                                     endDate: nil, section: .none, color: .accent, image: nil,
                                                                     shouldRemoveImage: false))
            XCTAssertTrue(result.success)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testLikeTaskRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(LikeTaskRequest(uid: "task1"))
            XCTAssertTrue(result.success)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testDoneTaskRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(DoneTaskRequest(uid: "task1"))
            XCTAssertTrue(result.success)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testDeleteTaskRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(DeleteTaskRequest(uid: "task1"))
            XCTAssertTrue(result.success)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testCreateTaskRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(CreateTaskRequest(title: "Task 16", description: nil, endDate: nil,
                                                                     section: .business, color: .gray, image: nil))
            XCTAssertTrue(CreateTaskRequest.tasks[0].uid == result.uid)

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testTasksRequest() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(TasksRequest(lastUid: nil, count: nil, forUserUid: "current", neededIds: nil, filter: nil))
            XCTAssertTrue(result.tasks.map(\.uid) == CreateTaskRequest.tasks.map(\.uid))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }

    func testTasksFollowings() throws {
        let expectation = XCTestExpectation()

        Task {
            let result = try await service.request(FollowingsTasksRequest(lastUid: nil, count: nil, neededIds: nil, forUserUid: nil, filter: nil))
            XCTAssertTrue(result.tasks.map(\.uid) == Array(CreateTaskRequest.tasks.suffix(6)).map(\.uid))

            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 60)
    }
}
