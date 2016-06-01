//
//  ArrayDiffTests.swift
//  ArrayDiffTests
//
//  Created by Eli Perkins on 6/1/16.
//  Copyright © 2016 Venmo. All rights reserved.
//

import XCTest
@testable import ArrayDiff

class ArrayDiffTests: XCTestCase {
    func testSimpleIntInsert() {
        let origin = [1, 2, 3]
        let destination = [1, 2, 3, 4]

        let edits = ArrayDiffCalculator.calculateDiff(origin: origin, destination: destination)

        XCTAssertEqual(edits, [Edit(action: .Insert, value: 4, destination: 3)])
    }

    func testSittingKitten() {
        let origin = "sitting"
        let destination = "kitten"

        let edits = ArrayDiffCalculator.calculateDiff(origin: Array(origin.characters), destination: Array(destination.characters))

        XCTAssertEqual(edits, [
            Edit(action: .Substitute, value: Character("k"), destination: 0),
            Edit(action: .Substitute, value: Character("e"), destination: 4),
            Edit(action: .Delete, value: Character("g"), destination: 6)
        ])
    }

    func testSundaySaturday() {
        let origin = "Sunday"
        let destination = "Saturday"

        let edits = ArrayDiffCalculator.calculateDiff(origin: Array(origin.characters), destination: Array(destination.characters))

        XCTAssertEqual(edits, [
            Edit(action: .Insert, value: Character("a"), destination: 1),
            Edit(action: .Insert, value: Character("t"), destination: 2),
            Edit(action: .Substitute, value: Character("r"), destination: 4)
        ])
    }
}
