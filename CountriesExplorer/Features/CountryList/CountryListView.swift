import SwiftUI
import ComposableArchitecture

struct CountryListView: View {
  @Bindable var store: StoreOf<CountryListFeature>

  private struct CountrySelection: Identifiable, Equatable, Sendable {
    let id: Country.ID
  }

  @State private var selection: CountrySelection?

  private var filteredCountries: [Country] {
    store.countries.filter(query: store.query)
  }

  var body: some View {
    NavigationStack {
      Group {
        if store.isLoading && store.countries.isEmpty {
          loadingView
        } else {
          listView
        }
      }
      .navigationTitle("Countries")
      .searchable(text: $store.query, prompt: "Name / Capital / Region")
      .onAppear { store.send(.onAppear) }
      .sheet(item: $selection) { selection in
        if let country = store.countries.first(where: { $0.id == selection.id }) {
          CountryDetailView(country: country)
        } else {
          // Fallback while data is loading or missing
          ProgressView("Loading…")
            .padding()
        }
      }
    }
  }

  // MARK: - Subviews

  @ViewBuilder
  private var loadingView: some View {
    ProgressView("Loading countries…")
  }

  @ViewBuilder
  private var listView: some View {
    List {
      ForEach(filteredCountries) { country in
        CountryRow(country: country) {
          store.send(.setSelection(country))
          selection = .init(id: country.id)
        }
      }
    }
  }
}

private struct CountryRow: View {
  let country: Country
  let onTap: () -> Void

  var body: some View {
    Button(action: onTap) {
      HStack(spacing: 12) {
        AsyncFlagView(urlString: country.flags.png ?? country.flags.svg)
          .frame(width: 36, height: 24)
          .clipShape(RoundedRectangle(cornerRadius: 4))
          .overlay(RoundedRectangle(cornerRadius: 4).stroke(.secondary.opacity(0.2)))

        VStack(alignment: .leading, spacing: 4) {
          Text(country.name.common)
            .font(.headline)
          Text("\(country.capital?.first ?? "—") • \(country.region)")
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        Spacer()
        Text("\(country.population.formatted())")
          .font(.footnote)
          .foregroundStyle(.secondary)
      }
    }
  }
}

private struct AsyncFlagView: View {
  let urlString: String?

  var body: some View {
    if let urlString, let url = URL(string: urlString) {
      AsyncImage(url: url) { image in
        image.resizable().scaledToFill()
      } placeholder: {
        ZStack {
          Color.gray.opacity(0.15)
          ProgressView().controlSize(.mini)
        }
      }
    } else {
      Color.gray.opacity(0.15)
    }
  }
}
