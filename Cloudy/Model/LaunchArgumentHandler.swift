// Copyright (c) 2020 Nomad5. All rights reserved.

import Foundation

/// Handle the injected launch arguments
class LaunchArgumentHandler {

    /// Keywords for the query parameters
    private enum Keywords: String {
        case service
        case url
    }

    /// Mapping of an argument to an url
    private let serviceToUrl: [String: URL] = [
        "stadia": Navigator.Config.Url.googleStadia,
        "geforceNowBeta": Navigator.Config.Url.geforceNowBeta,
        "geforceNow": Navigator.Config.Url.geforceNowOld,
        "luna": Navigator.Config.Url.amazonLuna,
    ]

    /// Extract the injected launch url from connection options
    func getLaunchUrl(from options: UIScene.ConnectionOptions) -> URL? {
        // early exit
        guard let url = options.urlContexts.first?.url else {
            return nil
        }
        return getLaunchUrl(from: url)
    }

    /// Extract a launch url from a given url
    func getLaunchUrl(from url: URL) -> URL? {
        Log.i("Processing injected URL: \(url)")
        // generate the url
        guard let parameters = NSURLComponents(url: url, resolvingAgainstBaseURL: true)?.queryItems else {
            return nil
        }
        if let service = parameters.first(where: { $0.name == Keywords.service.rawValue })?.value,
           let mappedUrl = serviceToUrl[service] {
            return mappedUrl
        } else if let siteToLaunch = parameters.first(where: { $0.name == Keywords.url.rawValue })?.value {
            return URL(string: siteToLaunch)
        } else {
            return nil
        }
    }
}
