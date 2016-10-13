// Responses.swift
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
import OHHTTPStubs

func enrollmentInfoResponse(withDeviceAccountToken deviceAccountToken: String) -> OHHTTPStubsResponse {
    let json = [
        "device_account_token": deviceAccountToken,
    ]
    
    return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
}

func enrollmentResponse(enrollmentId id: String?, deviceIdentifier: String?, name: String?, service: String?, notificationToken: String?) -> OHHTTPStubsResponse {
    let json = [
        "id": id ?? "",
        "identifier": deviceIdentifier ?? "",
        "name": name ?? "",
        "push_credentials": [
            "service": service ?? "",
            "token": notificationToken ?? ""
        ]
    ] as [String : Any]
    
    return OHHTTPStubsResponse(jsonObject: json, statusCode: 200, headers: ["Content-Type": "application/json"])
}

func errorResponse(statusCode: Int32, errorCode: String, message: String, error: String? = nil) -> OHHTTPStubsResponse {
    return OHHTTPStubsResponse(jsonObject: ["errorCode": errorCode, "message": message, "statusCode": "\(statusCode)", "error": error ?? message], statusCode: statusCode, headers: ["Content-Type": "application/json"])
}

func successResponse(statusCode: Int32 = 200) -> OHHTTPStubsResponse {
    return OHHTTPStubsResponse(jsonObject: [:], statusCode: statusCode, headers: ["Content-Type": "application/json"])
}
