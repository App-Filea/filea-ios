//
//  String+Extensions.swift
//  Invoicer
//
//  Created by Claude on 2025-01-16.
//  String validation and manipulation extensions
//

import Foundation

extension String {
    // MARK: - Validation

    /// Checks if the string is not empty after trimming whitespace
    var isNotEmpty: Bool {
        !trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Checks if the string is a valid number
    var isNumeric: Bool {
        Double(self) != nil
    }

    /// Checks if the string contains only digits
    var isDigitsOnly: Bool {
        !isEmpty && allSatisfy { $0.isNumber }
    }

    /// Checks if the string is a valid vehicle registration plate format
    var isValidPlate: Bool {
        // French plate format: AA-123-AA or 1234 AB 01
        let patterns = [
            "^[A-Z]{2}-\\d{3}-[A-Z]{2}$",  // New format (AA-123-AA)
            "^\\d{1,4}\\s[A-Z]{1,2}\\s\\d{2}$"  // Old format (1234 AB 01)
        ]

        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        for pattern in patterns {
            if trimmed.range(of: pattern, options: .regularExpression) != nil {
                return true
            }
        }

        return false
    }

    // MARK: - Transformation

    /// Returns the string with first letter capitalized
    var capitalizedFirst: String {
        guard !isEmpty else { return self }
        return prefix(1).uppercased() + dropFirst()
    }

    /// Trims whitespace and newlines from both ends
    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Removes all whitespace from the string
    var removingWhitespace: String {
        components(separatedBy: .whitespaces).joined()
    }

    // MARK: - File Extensions

    /// Returns the file extension (e.g., "jpg", "pdf")
    var fileExtension: String {
        (self as NSString).pathExtension.lowercased()
    }

    /// Checks if the string represents an image file
    var isImageFile: Bool {
        let imageExtensions = ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "heic", "heif"]
        return imageExtensions.contains(fileExtension)
    }

    /// Checks if the string represents a PDF file
    var isPDFFile: Bool {
        fileExtension == "pdf"
    }

    /// Returns a human-readable file type string
    var fileTypeDisplayName: String {
        if isImageFile {
            return "Photo"
        } else if isPDFFile {
            return "PDF"
        } else {
            return "Fichier"
        }
    }

    // MARK: - Number Parsing

    /// Converts the string to a Double if possible, removing common formatting
    var asDouble: Double? {
        let cleaned = self.replacingOccurrences(of: " ", with: "")
                          .replacingOccurrences(of: ",", with: ".")
        return Double(cleaned)
    }
}

// MARK: - Optional String Extensions

extension Optional where Wrapped == String {
    /// Returns true if the optional string is nil or empty
    var isNilOrEmpty: Bool {
        self?.isEmpty ?? true
    }

    /// Returns the unwrapped string or a default value if nil or empty
    func orDefault(_ defaultValue: String) -> String {
        guard let value = self, !value.isEmpty else {
            return defaultValue
        }
        return value
    }
}
