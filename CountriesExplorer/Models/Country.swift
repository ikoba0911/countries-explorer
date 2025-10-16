import Foundation

struct Country: Equatable, Identifiable, Decodable {
  var id: String { cca3 } // 国コードをIDに
  let name: Name
  let cca3: String
  let capital: [String]?
  let region: String
  let population: Int
  let flags: Flags

  struct Name: Equatable, Decodable {
    let common: String
    let official: String
  }

  struct Flags: Equatable, Decodable {
    let png: String?
    let svg: String?
  }
}
