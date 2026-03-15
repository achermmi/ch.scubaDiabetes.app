import Foundation
import Combine

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - API Error
// ─────────────────────────────────────────────────────────────────────────────

enum APIError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(code: String, message: String, status: Int)
    case unauthorized          // 401 → trigger refresh
    case forbidden             // 403
    case notFound              // 404
    case networkError(Error)
    case uploadError(String)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:              return String(localized: "error.invalid_url")
        case .noData:                  return String(localized: "error.no_data")
        case .decodingError(let e):    return "\(String(localized: "error.decoding")): \(e.localizedDescription)"
        case .serverError(_, let m, _):return m
        case .unauthorized:            return String(localized: "error.unauthorized")
        case .forbidden:               return String(localized: "error.forbidden")
        case .notFound:                return String(localized: "error.not_found")
        case .networkError(let e):     return e.localizedDescription
        case .uploadError(let m):      return m
        case .unknown(let s):          return "\(String(localized: "error.unknown")) (\(s))"
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - API Response envelope
// ─────────────────────────────────────────────────────────────────────────────

struct APIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data:    T?
    let meta:    APIMeta?
    let error:   APIErrorBody?

    // Il plugin PHP restituisce "meta":[] (array vuoto) invece di {}
    // Gestiamo entrambi i casi con un init custom.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        success = try c.decode(Bool.self, forKey: .success)
        data    = try c.decodeIfPresent(T.self, forKey: .data)
        error   = try c.decodeIfPresent(APIErrorBody.self, forKey: .error)
        // meta puo essere {} oppure [] — proviamo struct, altrimenti nil
        meta    = try? c.decodeIfPresent(APIMeta.self, forKey: .meta)
    }

    private enum CodingKeys: String, CodingKey {
        case success, data, meta, error
    }
}

struct APIMeta: Decodable {
    let pagination: APIPagination?
}

struct APIPagination: Decodable {
    let total:       Int
    let totalPages:  Int
    let currentPage: Int
    let perPage:     Int
    let hasMore:     Bool

    enum CodingKeys: String, CodingKey {
        case total, totalPages = "total_pages", currentPage = "current_page", perPage = "per_page", hasMore = "has_more"
    }
}

struct APIErrorBody: Decodable {
    let code:    String
    let message: String
}

struct PagedResult<T: Decodable>: Decodable {
    let items:      [T]
    let pagination: APIPagination
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - HTTP Method
// ─────────────────────────────────────────────────────────────────────────────

enum HTTPMethod: String {
    case get = "GET", post = "POST", put = "PUT", patch = "PATCH", delete = "DELETE"
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - NetworkManager
// ─────────────────────────────────────────────────────────────────────────────

@MainActor
final class NetworkManager: ObservableObject {

    static let shared = NetworkManager()

    private let session: URLSession
    private let keychain = KeychainManager.shared
    private let decoder  = JSONDecoder()

    /// Notifica il sistema auth quando un token è scaduto
    var onUnauthorized: (() -> Void)?

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest  = AppConstants.API.timeoutInterval
        config.timeoutIntervalForResource = AppConstants.API.uploadTimeoutInterval
        session = URLSession(configuration: config)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601
    }

    // ── Request base ──────────────────────────────────────────────────────

    func request<T: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        body: [String: Any]? = nil,
        queryItems: [URLQueryItem]? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {

        let url = try buildURL(path: path, queryItems: queryItems)
        var req = URLRequest(url: url)
        req.httpMethod = method.rawValue
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        // Identifica il dispositivo
        req.setValue(deviceID(), forHTTPHeaderField: "X-SD-Device-ID")

        if requiresAuth, let token = keychain.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
        }

        return try await executeRequest(req)
    }

    // ── Upload multipart ──────────────────────────────────────────────────

    func upload<T: Decodable>(
        _ path: String,
        fileData: Data,
        fileName: String,
        mimeType: String,
        fieldName: String = "file"
    ) async throws -> T {

        let url = try buildURL(path: path)
        let boundary = "Boundary-\(UUID().uuidString)"

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = keychain.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body

        return try await executeRequest(req)
    }

    // ── CSV / file download ───────────────────────────────────────────────

    func download(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> Data {
        let url = try buildURL(path: path, queryItems: queryItems)
        var req = URLRequest(url: url)
        if let token = keychain.accessToken {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, _) = try await session.data(for: req)
        return data
    }

    // ── Internal execution ────────────────────────────────────────────────

    private func executeRequest<T: Decodable>(_ req: URLRequest) async throws -> T {
        do {
            let (data, response) = try await session.data(for: req)
            guard let http = response as? HTTPURLResponse else { throw APIError.unknown(0) }

            switch http.statusCode {
            case 204:
                // No Content – ritorna tipo vuoto se possibile
                if T.self == EmptyResponse.self {
                    return EmptyResponse() as! T
                }
                throw APIError.noData

            case 200...299:
                do {
                    #if DEBUG
                    if let json = String(data: data, encoding: .utf8) {
                        print("📡 [API] \(req.url?.path ?? "") →\n\(json.prefix(2000))")
                    }
                    #endif
                    let envelope = try decoder.decode(APIResponse<T>.self, from: data)
                    if let data = envelope.data { return data }
                    throw APIError.noData
                } catch let decErr as APIError {
                    throw decErr
                } catch {
                    #if DEBUG
                    print("❌ [DECODE ERROR] \(error)")
                    #endif
                    throw APIError.decodingError(error)
                }

            case 401:
                onUnauthorized?()
                throw APIError.unauthorized

            case 403:
                throw APIError.forbidden

            case 404:
                throw APIError.notFound

            default:
                #if DEBUG
                let rawBody = String(data: data, encoding: .utf8) ?? "<non-utf8>"
                print("❌ [API \(http.statusCode)] \(req.url?.path ?? "") →\n\(rawBody.prefix(3000))")
                #endif
                if let envelope = try? decoder.decode(APIResponse<EmptyResponse>.self, from: data),
                   let err = envelope.error {
                    throw APIError.serverError(code: err.code, message: err.message, status: http.statusCode)
                }
                throw APIError.unknown(http.statusCode)
            }
        } catch let apiError as APIError {
            throw apiError
        } catch {
            throw APIError.networkError(error)
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────

    private func buildURL(path: String, queryItems: [URLQueryItem]? = nil) throws -> URL {
        var components = URLComponents(string: AppConstants.API.baseURL + path)
        if let qi = queryItems, !qi.isEmpty { components?.queryItems = qi }
        guard let url = components?.url else { throw APIError.invalidURL }
        return url
    }

    private func deviceID() -> String {
        if let id = UserDefaults.standard.string(forKey: "device_uuid") { return id }
        let id = UUID().uuidString
        UserDefaults.standard.set(id, forKey: "device_uuid")
        return id
    }
}

/// Usato per risposte 204 No Content
struct EmptyResponse: Decodable {}
