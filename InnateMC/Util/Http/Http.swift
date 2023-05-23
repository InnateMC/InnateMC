//
// Copyright © 2022 InnateMC and contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/
//

import Foundation

public struct Http {
    private static let session = URLSession(configuration: .default)
    
    public static func `get`(_ url: String) -> RequestBuilder {
        return .init(url: URL(string: url)!, method: .get)
    }
    
    public static func post(_ url: String) -> RequestBuilder {
        return .init(url: URL(string: url)!, method: .post)
    }
    
    public static func `get`(url: URL) -> RequestBuilder {
        return .init(url: url, method: .get)
    }
    
    public static func post(url: URL) -> RequestBuilder {
        return .init(url: url, method: .post)
    }
    
    public struct RequestBuilder {
        private var urlRequest: URLRequest
        
        init(url: URL, method: InnateHttpMethod) {
            urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = method.rawValue
            urlRequest.setValue("InnateMC", forHTTPHeaderField: "User-Agent")
        }
        
        func header(_ value: String?, field: String) -> RequestBuilder {
            var builder = self
            builder.urlRequest.setValue(value, forHTTPHeaderField: field)
            return builder
        }
        
        @discardableResult
        func json<T: Encodable>(_ body: T) throws -> RequestBuilder {
            var builder = self
            let jsonData = try JSONEncoder().encode(body)
            builder.urlRequest.httpBody = jsonData
            builder.urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            return builder
        }
        
        @discardableResult
        func string(_ body: String) -> RequestBuilder {
            var builder = self
            builder.urlRequest.httpBody = body.data(using: .utf8)
            builder.urlRequest.setValue("text/plain", forHTTPHeaderField: "Content-Type")
            return builder
        }
        
        @discardableResult
        func body(_ body: Data?) -> RequestBuilder {
            var builder = self
            builder.urlRequest.httpBody = body
            return builder
        }
        
        func request() async throws -> (Data, URLResponse?) {
            let (data, urlResponse) = try await Http.session.data(for: urlRequest)
            return (data, urlResponse)
        }
    }
}
