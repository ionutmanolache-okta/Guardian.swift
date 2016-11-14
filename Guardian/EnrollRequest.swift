// EnrollRequest.swift
//
// Copyright (c) 2016 Auth0 (http://auth0.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

/**
 A request to create a Guardian `Enrollment`
 
 - seealso: Guardian.enroll
 - seealso: Guardian.Enrollment
 */
public struct EnrollRequest: Requestable {

    typealias T = Enrollment

    private let api: API
    private let enrollmentTicket: String?
    private let enrollmentUri: String?
    private let notificationToken: String
    private let privateKey: SecKey
    private let publicKey: SecKey

    init(api: API, enrollmentTicket: String? = nil, enrollmentUri: String? = nil, notificationToken: String, privateKey: SecKey, publicKey: SecKey) {
        self.api = api
        self.enrollmentTicket = enrollmentTicket
        self.enrollmentUri = enrollmentUri
        self.notificationToken = notificationToken
        self.privateKey = privateKey
        self.publicKey = publicKey
    }

    /**
     Executes the request in a background thread

     - parameter callback: the termination callback, where the result is
     received
     */
    public func start(callback: @escaping (Result<Enrollment>) -> ()) {
        let ticket: String
        if let enrollmentTicket = enrollmentTicket {
            ticket = enrollmentTicket
        } else if let enrollmentUri = enrollmentUri, let parameters = parameters(fromUri: enrollmentUri), let enrollmentTxId = parameters["enrollment_tx_id"] {
            ticket = enrollmentTxId
        } else {
            return callback(.failure(cause: GuardianError.invalidEnrollmentUri))
        }

        self.api.enroll(withTicket: ticket, identifier: Enrollment.defaultDeviceIdentifier, name: Enrollment.defaultDeviceName, notificationToken: notificationToken, publicKey: publicKey)
            .start { result in
                switch result {
                case .failure(let cause):
                    callback(.failure(cause: cause))
                case .success(let payload):
                    guard
                        let payload = payload,
                        let id = payload["id"] as? String,
                        let token = payload["token"] as? String,
                        let _ = payload["issuer"] as? String,
                        let _ = payload["user"] as? String,
                        let _ = payload["url"] as? String else {
                            return callback(.failure(cause: GuardianError.invalidResponse))
                    }

                    let totpData = payload["totp"] as? [String: Any]
                    let totpSecret = totpData?["secret"] as? String
                    let totpAlgorithm = totpData?["algorithm"] as? String
                    let totpPeriod = totpData?["period"] as? Int
                    let totpDigits = totpData?["digits"] as? Int

                    let enrollment = Enrollment(id: id, deviceToken: token, notificationToken: self.notificationToken, signingKey: self.privateKey, base32Secret: totpSecret, algorithm: totpAlgorithm, digits: totpDigits, period: totpPeriod)
                    callback(.success(payload: enrollment))
                }
        }
    }
}

func parameters(fromUri uri: String) -> [String: String]? {
    guard let components = URLComponents(string: uri), let otp = components.host?.lowercased()
        , components.scheme == "otpauth" && otp == "totp" else {
            return nil
    }
    guard let parameters = components.queryItems?.asDictionary() else {
        return nil
    }
    return parameters
}

private extension Collection where Iterator.Element == URLQueryItem {

    func asDictionary() -> [String: String] {
        return self.reduce([:], { (dict, item) in
            var values = dict
            if let value = item.value {
                values[item.name] = value
            }
            return values
        })
    }
}