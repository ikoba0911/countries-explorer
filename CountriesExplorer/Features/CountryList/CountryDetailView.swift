import SwiftUI

struct CountryDetailView: View {
  let country: Country

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        AsyncImage(url: URL(string: country.flags.png ?? country.flags.svg ?? "")) { img in
          img.resizable().scaledToFit()
        } placeholder: {
          Rectangle().fill(.gray.opacity(0.15)).frame(height: 120)
        }
        .frame(maxWidth: .infinity)

        Text(country.name.official)
          .font(.title2).bold()

        Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 8) {
          GridRow { Text("Code").foregroundStyle(.secondary); Text(country.cca3) }
          GridRow { Text("Capital").foregroundStyle(.secondary); Text(country.capital?.first ?? "—") }
          GridRow { Text("Region").foregroundStyle(.secondary); Text(country.region) }
          GridRow { Text("Population").foregroundStyle(.secondary); Text(country.population.formatted()) }
        }

        Spacer(minLength: 20)
      }
      .padding()
    }
    .presentationDetents([.medium, .large])
    .navigationTitle(country.name.common)
  }
}
