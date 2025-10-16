import Foundation
import ComposableArchitecture

@Reducer
struct CountryListFeature {
  @ObservableState
  struct State: Equatable {
    var countries: [Country] = []
    var query: String = ""
    var isLoading = false
    var selection: Country? // 詳細表示用（簡易）
  }

  enum Action: BindableAction, Equatable {
    case onAppear
    case fetchResponse(Result<[Country], APIError>)
    case setQuery(String)
    case setSelection(Country?)
    case binding(BindingAction<State>)
  }

  @Dependency(\.countryClient) var countryClient

  var body: some Reducer<State, Action> {
    BindingReducer()
    Reduce { state, action in
      switch action {
      case .onAppear:
        guard state.countries.isEmpty else { return .none }
        state.isLoading = true
        return .run { send in
          do {
            let list = try await countryClient.fetchAll()
            await send(.fetchResponse(.success(list)))
          } catch let api as APIError {
            await send(.fetchResponse(.failure(api)))
          } catch {
            await send(.fetchResponse(.failure(.unknown)))
          }
        }

      case .fetchResponse(.success(let list)):
        state.isLoading = false
        state.countries = list
        return .none

      case .fetchResponse(.failure):
        state.isLoading = false
        return .none

      case .setQuery(let q):
        state.query = q
        return .none

      case .setSelection(let country):
        state.selection = country
        return .none

      case .binding:
        return .none
      }
    }
  }
}

// 検索フィルタ用のヘルパ
extension Array where Element == Country {
  func filter(query: String) -> [Country] {
    let q = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard q.isEmpty == false else { return self }
    return self.filter {
      $0.name.common.localizedCaseInsensitiveContains(q)
      || ($0.capital?.joined(separator: ", ").localizedCaseInsensitiveContains(q) ?? false)
      || $0.region.localizedCaseInsensitiveContains(q)
    }
  }
}

