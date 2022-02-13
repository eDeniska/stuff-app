//
//  WidgetURLHandler.swift
//  
//
//  Created by Данис Тазетдинов on 13.02.2022.
//

import Foundation
import CoreData
import Logger

public struct WidgetURLHandler {
    private enum Constants {
        static let urlScheme = "dt-stuff-widget"
        static let path = "/"
        static let checklistIdKey = "checklistId"
    }
    
    public static func url(for checklist: Checklist) -> URL {
        var components = URLComponents()
        components.scheme = Constants.urlScheme
        components.path = Constants.path
        components.queryItems = [URLQueryItem(name: Constants.checklistIdKey, value: checklist.identifier.uuidString)]
        guard let url = components.url else {
            Logger.default.error("could not build URL for checklist!")
            fatalError("could not build URL for checklist!")
        }
        return url
    }
    
    public static func checklist(from url: URL, in context: NSManagedObjectContext) -> Checklist? {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        guard components?.scheme == Constants.urlScheme,
              let queryItem = components?.queryItems?.first(where: { $0.name == Constants.checklistIdKey }),
              let identifierString = queryItem.value,
              let identifier = UUID(uuidString: identifierString) else {
            return nil
        }
        return Checklist.checklist(with: identifier, in: context)
        
    }
}
