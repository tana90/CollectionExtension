    import XCTest
    @testable import CollectionExtension

    final class CollectionExtensionTests: XCTestCase {
        
        func testEqualArray() {
            
            let firstArray = ["Car", "House", "Dog"]
            let secondArray = ["House", "Dog", "Car"]

            XCTAssertTrue(firstArray.equal(to: secondArray))
        }
        
        func testHistogram() {
            let array = ["Car", "Car", "Dog"]
            XCTAssertEqual(array.histogram, ["Car": 2, "Dog": 1])
        }
    }
