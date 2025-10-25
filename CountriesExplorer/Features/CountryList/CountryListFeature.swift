import Foundation
import ComposableArchitecture

@Reducer
struct CountryListFeature {
  @ObservableState
  struct State: Equatable {
    var countries: [Country] = []
    var query: String = ""
    var isLoading = false
    var selection: Country? // For detail presentation (simple)
    @Presents var alert: AlertState<Action.Alert>?
    var lastErrorMessage: String?
  }

  enum Action: BindableAction, Equatable {
    case onAppear
    case fetchResponseSuccess([Country])
    case fetchResponseFailure(HttpClientError)
    case setQuery(String)
    case setSelection(Country?)

    case binding(BindingAction<State>)
    case alert(PresentationAction<Alert>)

      @CasePathable
      enum Alert {
          case alertOkTapped
      }
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
            await send(.fetchResponseSuccess(list))
          } catch let error {
              await send(.fetchResponseFailure(HttpClientError.mapToHttpClientError(error)))
          }
        }

      case .fetchResponseSuccess(let list):
        state.isLoading = false
        state.countries = list
        return .none

      case .fetchResponseFailure(let error):
        state.isLoading = false
        state.lastErrorMessage = String(describing: error)
        state.alert = AlertState {
          TextState("Failed to load")
        } actions: {
          ButtonState(role: .cancel, action: .alertOkTapped) {
            TextState("OK")
          }
        } message: {
          TextState(error.localizedDescription)
        }
        return .none

      case .setQuery(let q):
        state.query = q
        return .none

      case .setSelection(let country):
        state.selection = country
        return .none

      case .binding:
        return .none

      case .alert(.dismiss):
          state.alert = nil
          return .none

      case .alert(.presented(.alertOkTapped)):
          state.alert = nil
          return .none
      }
    }
  }
}

// Helper for search filtering
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

