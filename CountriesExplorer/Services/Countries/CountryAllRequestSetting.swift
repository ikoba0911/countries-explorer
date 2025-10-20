
struct CountryAllRequestSetting: HttpRequestSetting {
    typealias Output = [Country]
    
    var endpoint: HttpRequestEndpoint {
        HttpRequestEndpoint(
            host: "https://restcountries.com",
            path: "/v3.1/all?fields=name,cca3,capital,region,population,flags"
        )
    }
    
    var method: HttpRequestMethod { .get }
    
    func parameters() async -> [String: Any] { [:] }
    
    func headers() async -> [String: String] {
        ["Accept": "application/json"]
    }
}
