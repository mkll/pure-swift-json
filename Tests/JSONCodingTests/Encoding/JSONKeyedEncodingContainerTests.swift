import XCTest
@testable import PureSwiftJSONCoding
@testable import PureSwiftJSONParsing

class JSONKeyedEncodingContainerTests: XCTestCase {
  
  func testNestedContainer() {
    struct Object: Encodable {
      let firstName: String
      let surname: String

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
//        var nameContainer = container.nestedContainer(keyedBy: NameCodingKeys.self, forKey: .name)
//        try nameContainer.encode(firstName, forKey: .firstName)
//        try nameContainer.encode(surname, forKey: .surname)
      }

      private enum CodingKeys: String, CodingKey {
        case name = "name"
      }

      private enum NameCodingKeys: String, CodingKey {
        case firstName = "firstName"
        case surname = "surname"
      }
    }
    
    do {
      let object = Object(firstName: "Adam", surname: "Fowler")
      let json = try PureSwiftJSONCoding.JSONEncoder().encode(object)
      
      let parsed = try JSONParser().parse(bytes: json)
      XCTAssertEqual(parsed, .object(["name": .object(["firstName": .string("Adam"), "surname": .string("Fowler")])])) 
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
  func testLastCodingPath() {
    struct SubObject: Encodable {
      let value: Int

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        if let key = encoder.codingPath.last {
          try container.encode(key.stringValue, forKey: .key)
          try container.encode(value, forKey: .value)
        }
      }

      private enum CodingKeys: String, CodingKey {
        case key = "key"
        case value = "value"
      }
    }

    struct Object: Encodable {
      let sub: SubObject
    }

    do {
      let object = Object(sub: SubObject(value: 12))
      let json = try PureSwiftJSONCoding.JSONEncoder().encode(object)
      let parsed = try JSONParser().parse(bytes: json)
      XCTAssertEqual(parsed, .object(["sub": .object(["key": .string("sub"), "value": .number("12")])]))
    }
    catch {
      XCTFail("Unexpected error: \(error)")
    }
  }
  
}



