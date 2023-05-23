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
import Swifter

extension AccountManager {
    public func setupForAuth() {
        self.serverThread = .init(label: "server")
        
        self.server["/"] = { request in
            if let code = request.queryParams.first(where: { $0.0 == "code" })?.1, let state = request.queryParams.first(where: { $0.0 == "state" })?.1 {
                if let cb = self.stateCallbacks[state] {
                    DispatchQueue.global().async {
                        cb(code)
                    }
                } else {
                    logger.warning("Received authentication redirect without callback being present, skipping")
                    logger.warning("Provided state: \(state)")
                    print(self.stateCallbacks)
                    return HttpResponse.movedTemporarily("http://youtube.com/watch?v=dQw4w9WgXcQ")
                }
                DispatchQueue.main.async {
                    WebViewWindow.current?.window?.close()
                    WebViewWindow.current = nil
                }
                logger.debug("Received succesful authentication redirect")
                return HttpResponse.ok(.text("<html><body>You may close this window now</body></html>"))
            } else {
                logger.error("Missing code/state parameters in request: \(request.queryParams)")
                return HttpResponse.movedTemporarily("http://youtube.com/watch?v=dQw4w9WgXcQ")
            }
        }
        
        self.serverThread?.async {
            do {
                try self.server.start(1989)
                logger.info("Started authentication redirect handler server on port 1989")
            } catch {
                logger.error("Could not start authentication redirect handler server", error: error)
                logger.error("Adding microsoft accounts support will be limited")
            }
        }
    }
    
    public func createAuthWindow() -> WebViewWindow {
        let baseURL = "https://login.microsoftonline.com/consumers/oauth2/v2.0/authorize"
        var urlComponents: URLComponents = .init(string: baseURL)!
        let state = self.state()
        self.stateCallbacks[state] = setupMicrosoftAccount
        
        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: self.clientId),
            URLQueryItem(name: "redirect_uri", value: "http://localhost:1989"),
            URLQueryItem(name: "scope", value: "XboxLive.signin offline_access"),
            URLQueryItem(name: "state", value: state)
        ]
        
        let authUrl = urlComponents.url!
        let window: WebViewWindow = .init(url: authUrl)
        return window
    }
    
    func state() -> String {
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let randomBytes = (0..<24).map { _ in UInt8.random(in: 0..<UInt8.max) }
        let randomData = Data(randomBytes)
        let randomString = randomData.base64EncodedString()
            .filter { characters.contains($0) }
            .prefix(24)
        return String(randomString)
    }
}
