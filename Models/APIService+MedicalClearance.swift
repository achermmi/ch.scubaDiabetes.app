import Foundation

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Type Alias
// ─────────────────────────────────────────────────────────────────────────────

typealias APIService = NetworkManager

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - NetworkManager Helper Methods
// ─────────────────────────────────────────────────────────────────────────────

extension NetworkManager {
    /// GET request helper
    func get<T: Decodable>(_ path: String, queryItems: [URLQueryItem]? = nil) async throws -> T {
        return try await request(path, method: .get, queryItems: queryItems)
    }
    
    /// POST request helper
    func post<T: Decodable>(_ path: String, body: [String: Any]? = nil) async throws -> T {
        return try await request(path, method: .post, body: body)
    }
    
    /// PUT request helper
    func put<T: Decodable>(_ path: String, body: [String: Any]? = nil) async throws -> T {
        return try await request(path, method: .put, body: body)
    }
    
    /// DELETE request helper
    func delete<T: Decodable>(_ path: String) async throws -> T {
        return try await request(path, method: .delete)
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - API Service Extension - Medical Clearances
// ─────────────────────────────────────────────────────────────────────────────

extension NetworkManager {
    
    // ═════════════════════════════════════════════════════════════════════
    // MARK: - Get Medical Clearances
    // ═════════════════════════════════════════════════════════════════════
    
    /// Ottiene tutte le idoneità mediche dell'utente corrente
    func getMedicalClearances() async throws -> [MedicalClearance] {
        let endpoint = "/wp-json/sd/v2/profile/clearances"
        let response: DiverProfile = try await get(endpoint)
        return response.clearances
    }
    
    // ═════════════════════════════════════════════════════════════════════
    // MARK: - Save Medical Clearance (con documento)
    // ═════════════════════════════════════════════════════════════════════
    
    /// Salva una nuova idoneità medica con eventuale documento allegato
    /// - Parameters:
    ///   - body: Dizionario con i campi dell'idoneità
    ///   - documentData: Dati del documento (opzionale)
    ///   - documentName: Nome file del documento
    func saveMedicalClearance(
        body: [String: Any],
        documentData: Data? = nil,
        documentName: String? = nil
    ) async throws -> MedicalClearance {
        let endpoint = "/wp-json/sd/v2/profile/clearances"
        
        // Se c'è un documento, usa multipart/form-data
        if let docData = documentData, let fileName = documentName {
            return try await uploadWithDocument(
                endpoint: endpoint,
                method: "POST",
                body: body,
                documentData: docData,
                documentFieldName: "clearance_doc",
                fileName: fileName
            )
        } else {
            // Altrimenti, normale POST JSON
            return try await post(endpoint, body: body)
        }
    }
    
    // ═════════════════════════════════════════════════════════════════════
    // MARK: - Update Medical Clearance
    // ═════════════════════════════════════════════════════════════════════
    
    /// Aggiorna un'idoneità esistente
    func updateMedicalClearance(
        id: Int,
        body: [String: Any],
        documentData: Data? = nil,
        documentName: String? = nil
    ) async throws -> MedicalClearance {
        let endpoint = "/wp-json/sd/v2/profile/clearances/\(id)"
        
        if let docData = documentData, let fileName = documentName {
            return try await uploadWithDocument(
                endpoint: endpoint,
                method: "PUT",
                body: body,
                documentData: docData,
                documentFieldName: "clearance_doc",
                fileName: fileName
            )
        } else {
            return try await put(endpoint, body: body)
        }
    }
    
    // ═════════════════════════════════════════════════════════════════════
    // MARK: - Delete Medical Clearance
    // ═════════════════════════════════════════════════════════════════════
    
    /// Elimina un'idoneità medica
    func deleteMedicalClearance(id: Int) async throws {
        let endpoint = "/wp-json/sd/v2/profile/clearances/\(id)"
        let _: EmptyResponse = try await delete(endpoint)
    }
    
    // ═════════════════════════════════════════════════════════════════════
    // MARK: - Multipart Upload Helper
    // ═════════════════════════════════════════════════════════════════════
    
    /// Upload multipart/form-data per documenti
    private func uploadWithDocument<T: Decodable>(
        endpoint: String,
        method: String,
        body: [String: Any],
        documentData: Data,
        documentFieldName: String,
        fileName: String
    ) async throws -> T {
        guard let url = URL(string: AppConstants.API.baseURL + endpoint) else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        
        // Bearer token da keychain
        if let token = KeychainManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        // Boundary per multipart
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Costruisci body multipart
        var httpBody = Data()
        
        // 1. Aggiungi campi JSON
        for (key, value) in body {
            httpBody.append("--\(boundary)\r\n")
            httpBody.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            httpBody.append("\(value)\r\n")
        }
        
        // 2. Aggiungi documento
        httpBody.append("--\(boundary)\r\n")
        httpBody.append("Content-Disposition: form-data; name=\"\(documentFieldName)\"; filename=\"\(fileName)\"\r\n")
        httpBody.append("Content-Type: \(mimeType(for: fileName))\r\n\r\n")
        httpBody.append(documentData)
        httpBody.append("\r\n")
        
        // 3. Chiudi boundary
        httpBody.append("--\(boundary)--\r\n")
        
        request.httpBody = httpBody
        
        #if DEBUG
        print("📤 [UPLOAD] \(method) \(endpoint)")
        print("   Document: \(fileName) (\(documentData.count) bytes)")
        #endif
        
        // Esegui richiesta
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unknown(0)
        }
        
        #if DEBUG
        print("📥 [UPLOAD] \(httpResponse.statusCode)")
        #endif
        
        // Verifica token scaduto
        if httpResponse.statusCode == 401 {
            throw APIError.unauthorized
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            // Prova a decodificare messaggio errore
            if let errorEnvelope = try? JSONDecoder().decode(APIResponse<EmptyResponse>.self, from: data),
               let apiError = errorEnvelope.error {
                throw APIError.serverError(code: apiError.code, message: apiError.message, status: httpResponse.statusCode)
            }
            throw APIError.unknown(httpResponse.statusCode)
        }
        
        // Decodifica risposta
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
            
            if let responseData = apiResponse.data {
                return responseData
            } else {
                throw APIError.noData
            }
        } catch let decodingError {
            #if DEBUG
            if let jsonString = String(data: data, encoding: .utf8) {
                print("❌ [DECODE ERROR]", decodingError)
                print("📡 Response:", jsonString)
            }
            #endif
            throw APIError.decodingError(decodingError)
        }
    }
    
    // ═════════════════════════════════════════════════════════════════════
    // MARK: - MIME Type Helper
    // ═════════════════════════════════════════════════════════════════════
    
    private func mimeType(for filename: String) -> String {
        let ext = (filename as NSString).pathExtension.lowercased()
        
        switch ext {
        case "pdf":  return "application/pdf"
        case "jpg", "jpeg": return "image/jpeg"
        case "png":  return "image/png"
        case "zip":  return "application/zip"
        default:     return "application/octet-stream"
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Data Extension per Multipart
// ─────────────────────────────────────────────────────────────────────────────

extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Example Usage
// ─────────────────────────────────────────────────────────────────────────────

/*
 
 // ESEMPIO 1: Salvare idoneità senza documento
 
 let body: [String: Any] = [
     "year": 2026,
     "date": "2026-03-12",
     "valid_until": "2027-03-12",
     "type": "iperbarica",
     "doctor": "Dr. Pippo Baudo",
     "outcome": "fit",
     "notes": "Tutto ok"
 ]
 
 do {
     let clearance = try await APIService.shared.saveMedicalClearance(body: body)
     print("✅ Idoneità salvata:", clearance.id)
 } catch {
     print("❌ Errore:", error)
 }
 
 
 // ESEMPIO 2: Salvare idoneità CON documento PDF
 
 let body: [String: Any] = [
     "year": 2026,
     "date": "2026-03-12",
     "valid_until": "2027-03-12",
     "type": "iperbarica",
     "doctor": "Dr. Pippo Baudo",
     "outcome": "fit"
 ]
 
 // Dati PDF
 let pdfData = ... // Data del PDF selezionato
 let fileName = "Spirometria.pdf"
 
 do {
     let clearance = try await APIService.shared.saveMedicalClearance(
         body: body,
         documentData: pdfData,
         documentName: fileName
     )
     print("✅ Idoneità salvata con documento:", clearance.documentUrl ?? "")
 } catch {
     print("❌ Errore:", error)
 }
 
 
 // ESEMPIO 3: Aggiornare solo i campi, mantenere documento esistente
 
 let body: [String: Any] = [
     "doctor": "Dr. Nuovo Nome",
     "notes": "Aggiornamento note"
 ]
 
 do {
     let updated = try await APIService.shared.updateMedicalClearance(
         id: 123,
         body: body
     )
     print("✅ Idoneità aggiornata")
 } catch {
     print("❌ Errore:", error)
 }
 
 
 // ESEMPIO 4: Eliminare idoneità (e documento associato)
 
 do {
     try await APIService.shared.deleteMedicalClearance(id: 123)
     print("✅ Idoneità eliminata")
 } catch {
     print("❌ Errore:", error)
 }
 
 */
