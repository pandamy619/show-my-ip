import Foundation

extension HTTPClient {
    private static var successStatusCode: Int { 200 }

    func fetchBody(from address: String, maximumSize: Int) async throws(IPProviderError) -> Data {
        guard let url = URL(string: address) else {
            throw .invalidRequest
        }
        let response: HTTPResponse
        do {
            response = try await get(url)
        } catch {
            throw .network
        }
        guard response.statusCode == Self.successStatusCode else {
            throw .unexpectedStatus(response.statusCode)
        }
        guard response.body.count <= maximumSize else {
            throw .responseTooLarge
        }
        return response.body
    }
}
