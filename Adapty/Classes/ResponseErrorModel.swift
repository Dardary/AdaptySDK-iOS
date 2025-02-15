//
//  ResponseErrorModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 29/10/2019.
//  Copyright © 2019 Adapty. All rights reserved.
//

import Foundation

struct ResponseErrorModel: JSONCodable {
    let detail: String
    let status: Int
    let source: Parameters
    let code: String

    init?(json: Parameters) throws {
        detail = json["detail"] as? String ?? ""
        if let statusString = json["status"] as? String, let status = Int(statusString) {
            self.status = status
        } else {
            status = 0
        }
        source = json["source"] as? Parameters ?? Parameters()
        code = json["code"] as? String ?? ""

        logMissingRequiredParams()
    }

    var description: String {
        return "Status: \(code). Details: \(detail)"
    }

    private func logMissingRequiredParams() {
        var missingParams: [String] = []
        if detail.isEmpty { missingParams.append("detail") }
        if status == 0 { missingParams.append("status") }
        if source.count == 0 { missingParams.append("source") }
        if code.isEmpty { missingParams.append("code") }
        if !missingParams.isEmpty { LoggerManager.logError(AdaptyError.missingParam("ResponseErrorModel - \(missingParams.joined(separator: ", "))")) }
    }
}

struct ResponseErrorsArray: JSONCodable {
    var errors: [ResponseErrorModel] = []

    init?(json: Parameters) throws {
        guard let errors = json["errors"] as? [Parameters] else {
            return nil
        }

        do {
            try errors.forEach { params in
                if let error = try ResponseErrorModel(json: params) {
                    self.errors.append(error)
                }
            }
        } catch {
            throw AdaptyError.invalidProperty("ResponseErrors – errors", errors)
        }
    }
}
