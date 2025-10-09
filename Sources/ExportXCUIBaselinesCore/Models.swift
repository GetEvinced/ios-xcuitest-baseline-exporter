import Foundation

// MARK: - Data Models
struct Attachment: Codable {
    let exportedFileName: String
    let suggestedHumanReadableName: String
}

struct Entry: Codable {
    let attachments: [Attachment]
    let testIdentifier: String?
}

struct AutomationFile: Decodable {
    let baselineFileName: String
    let baselineComparisonFolderURL: URL
}

extension Attachment {
    init(_ legacy: Legacy.Attachment) {
        self.init(
            exportedFileName: legacy.exportedFileName,
            suggestedHumanReadableName: legacy.suggestedHumanReadableName
        )
    }
}

extension Entry {
    init(_ legacy: Legacy.Entry) {
        self.init(
            attachments: legacy.attachments.map(Attachment.init),
            testIdentifier: legacy.testIdentifier
        )
    }
}

enum Legacy {
    struct Attachment: Equatable, Decodable {
        let exportedFileName: String
        let suggestedHumanReadableName: String
        let payloadReferenceID: String 
    }

    struct Entry: Equatable, Decodable {
        let attachments: [Attachment]
        let testIdentifier: String?

        init(from decoder: Decoder) throws {
            let root = try Root(from: decoder)
            let testIdentifier = root.identifier?._value
            var out: [Attachment] = []

            for act in root.activitySummaries?._values ?? [] {
                collectAttachments(in: act, into: &out)
            }

            self.attachments = out
            self.testIdentifier = testIdentifier
        }
    }

    // MARK: - Private DTOs (xcresult typed JSON)

    private struct TypedString: Decodable {
        let _value: String
    }

    private struct TypedArray<T: Decodable>: Decodable {
        let _values: [T]
    }

    private struct PayloadRefDTO: Decodable {
        let id: TypedString
    }

    private struct ActionTestAttachmentDTO: Decodable {
        let filename: TypedString
        let name: TypedString
        let payloadRef: PayloadRefDTO
        // other fields intentionally ignored
    }

    private struct ActivityDTO: Decodable {
        let activityType: TypedString?
        let title: TypedString?
        let attachments: TypedArray<ActionTestAttachmentDTO>?
        let subactivities: TypedArray<ActivityDTO>?
    }

    private struct Root: Decodable {
        let activitySummaries: TypedArray<ActivityDTO>?
        let identifier: TypedString?
    }

    // MARK: - Recursive walker

    private static func collectAttachments(in activity: ActivityDTO, into sink: inout [Attachment]) {
        if activity.activityType?._value == "com.apple.dt.xctest.activity-type.attachmentContainer" {
            for a in activity.attachments?._values ?? [] {
                sink.append(Attachment(
                    exportedFileName: a.name._value,
                    suggestedHumanReadableName: a.filename._value,
                    payloadReferenceID: a.payloadRef.id._value
                ))
            }
        }
        for sub in activity.subactivities?._values ?? [] {
            collectAttachments(in: sub, into: &sink)
        }
    }
}
