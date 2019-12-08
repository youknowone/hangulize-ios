//
//  HangulizeTests.swift
//  HangulizeTests
//
//  Created by Jeong YunWon on 2019/11/15.
//  Copyright © 2019 Jeong YunWon. All rights reserved.
//

@testable import Hangulize
import XCTest

class HangulizeTests: XCTestCase {
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testShuffleRegex() {
        let code = #"""
        $(function() {
            $( "[name=lang]" ).val( "bel" ).change();
            $( "#word" ).val("\u0411\u0435\u043b\u0430\u0440\u0443\u0441\u044c").keypress();
        });
        """#
        let data = try! API.retrieveData(from: code).get()
        XCTAssertEqual(data, [#"[name=lang]"#: #"bel"#, #"#word"#: #"Беларусь"#])
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
}
