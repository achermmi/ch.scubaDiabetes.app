import SwiftUI

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - Medical Clearance Card View
// Card compatta per mostrare un'idoneità medica nella lista (stile web)
// ─────────────────────────────────────────────────────────────────────────────

struct MedicalClearanceCardView: View {
    let clearance: MedicalClearance
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Icona esito
            Image(systemName: clearance.outcomeIcon)
                .font(.title2)
                .foregroundStyle(clearance.outcomeColor)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                // Date + Status badge
                HStack(spacing: 8) {
                    Text(formattedDateRange)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    statusBadge
                }
                
                // Tipo visita · Medico
                HStack(spacing: 4) {
                    if let type = clearance.type {
                        Text(clearance.typeDisplayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    if let doctor = clearance.doctor, !doctor.isEmpty {
                        if clearance.type != nil {
                            Text("·")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Text("Dr. \(doctor)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Documento link
                if let docUrl = clearance.documentUrl, let docName = clearance.documentName {
                    Link(destination: URL(string: docUrl)!) {
                        HStack(spacing: 4) {
                            Image(systemName: "paperclip")
                                .font(.caption2)
                            Text(docName)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .foregroundStyle(.blue)
                    }
                }
            }
            
            Spacer()
            
            // Pulsante elimina
            Button(role: .destructive, action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .symbolRenderingMode(.hierarchical)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(borderColor, lineWidth: 1)
        )
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Computed Properties
    // ═══════════════════════════════════════════════════════════════════
    
    private var formattedDateRange: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        
        if let startDate = parseDate(clearance.date),
           let endDate = parseDate(clearance.validUntil) {
            let start = dateFormatter.string(from: startDate)
            let end = dateFormatter.string(from: endDate)
            return "\(start) → \(end)"
        }
        
        return "\(clearance.year)"
    }
    
    private var statusBadge: some View {
        Group {
            if let expiryDate = parseDate(clearance.validUntil) {
                let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
                
                if daysUntilExpiry < 0 {
                    // Scaduta
                    Text("SCADUTA")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.red.opacity(0.2))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                } else if daysUntilExpiry <= 30 {
                    // In scadenza
                    Text("\(daysUntilExpiry) gg")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundStyle(.orange)
                        .clipShape(Capsule())
                } else {
                    // Valida
                    Text("VALIDA")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.green.opacity(0.2))
                        .foregroundStyle(.green)
                        .clipShape(Capsule())
                }
            }
        }
    }
    
    private var backgroundColor: Color {
        if let expiryDate = parseDate(clearance.validUntil) {
            let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            
            if daysUntilExpiry < 0 {
                return Color.red.opacity(0.05)
            } else if daysUntilExpiry <= 30 {
                return Color.orange.opacity(0.05)
            }
        }
        return Color(.systemBackground)
    }
    
    private var borderColor: Color {
        if let expiryDate = parseDate(clearance.validUntil) {
            let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
            
            if daysUntilExpiry < 0 {
                return Color.red.opacity(0.3)
            } else if daysUntilExpiry <= 30 {
                return Color.orange.opacity(0.3)
            } else {
                return Color.green.opacity(0.3)
            }
        }
        return Color(.separator)
    }
    
    // ═══════════════════════════════════════════════════════════════════
    // MARK: - Helpers
    // ═══════════════════════════════════════════════════════════════════
    
    private func parseDate(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)
    }
}

// ═══════════════════════════════════════════════════════════════════════════
// MARK: - Preview
// ═══════════════════════════════════════════════════════════════════════════

#Preview("Valida") {
    VStack(spacing: 16) {
        MedicalClearanceCardView(
            clearance: MedicalClearance(
                id: 1,
                year: 2026,
                date: "2026-03-12",
                validUntil: "2027-03-12",
                type: "iperbarica",
                doctor: "Dr. Pippo Baudo",
                outcome: "fit",
                notes: nil,
                documentUrl: "https://example.com/doc.pdf",
                documentName: "Spirometria20250306BN.pdf",
                approvedBy: nil,
                approvedAt: nil,
                approvedNotes: nil
            ),
            onDelete: { print("🗑️ Delete") }
        )
    }
    .padding()
}

#Preview("Scaduta") {
    VStack(spacing: 16) {
        MedicalClearanceCardView(
            clearance: MedicalClearance(
                id: 2,
                year: 2025,
                date: "2025-03-03",
                validUntil: "2026-03-03",
                type: "sportiva",
                doctor: "Dr. Pinco Palla",
                outcome: "fit",
                notes: nil,
                documentUrl: "https://example.com/doc2.pdf",
                documentName: "Achermann-Mirko-2025_ADV.pdf",
                approvedBy: nil,
                approvedAt: nil,
                approvedNotes: nil
            ),
            onDelete: { print("🗑️ Delete") }
        )
    }
    .padding()
}

#Preview("In scadenza") {
    let futureDate = Calendar.current.date(byAdding: .day, value: 15, to: Date())!
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    return VStack(spacing: 16) {
        MedicalClearanceCardView(
            clearance: MedicalClearance(
                id: 3,
                year: 2026,
                date: "2025-03-20",
                validUntil: formatter.string(from: futureDate),
                type: "non_agonistica",
                doctor: "Dr. Mario Rossi",
                outcome: "fit_limited",
                notes: "Con prescrizione",
                documentUrl: nil,
                documentName: nil,
                approvedBy: nil,
                approvedAt: nil,
                approvedNotes: nil
            ),
            onDelete: { print("🗑️ Delete") }
        )
    }
    .padding()
}
