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
        static let actionKey = "action"
        static let actionCreateChecklist = "create-checklist"
        static let actionShowChecklist = "show-checklist"

    }

    public enum Action {
        case showChecklist(Checklist)
        case createChecklist
        
        
        private var actionValue: String {
            switch self {
            case .showChecklist:
                return Constants.actionShowChecklist

            case .createChecklist:
                return Constants.actionCreateChecklist
            }
        }
        
        var url: URL {
            var components = URLComponents()
            components.scheme = Constants.urlScheme
            components.path = Constants.path

            switch self {
            case .showChecklist(let checklist):
                components.queryItems = [
                    URLQueryItem(name: Constants.actionKey, value: actionValue),
                    URLQueryItem(name: Constants.checklistIdKey, value: checklist.identifier.uuidString)
                ]

            case .createChecklist:
                components.queryItems = [URLQueryItem(name: Constants.actionKey, value: actionValue)]
            }
            
            guard let url = components.url else {
                Logger.default.error("could not build URL for checklist!")
                fatalError("could not build URL for checklist!")
            }
            return url
        }
        
        init?(url: URL, in context: NSManagedObjectContext) {
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            guard components?.scheme == Constants.urlScheme,
                  let actionQueryItem = components?.queryItems?.first(where: { $0.name == Constants.actionKey }),
                  let actionString = actionQueryItem.value else {
                return nil
            }
            
            switch actionString {
            case Constants.actionShowChecklist:
                guard let identifierQueryItem = components?.queryItems?.first(where: { $0.name == Constants.checklistIdKey }),
                      let identifierString = identifierQueryItem.value,
                      let identifier = UUID(uuidString: identifierString),
                      let checklist = Checklist.checklist(with: identifier, in: context) else {
                    return nil
                }
                self = .showChecklist(checklist)
                
            case Constants.actionCreateChecklist:
                self = .createChecklist
                
            default:
                return nil
            }
        }
    }
    
    
    public static func createChecklistURL() -> URL {
        Action.createChecklist.url
    }
    
    public static func url(for checklist: Checklist) -> URL {
        Action.showChecklist(checklist).url
    }
    
    public static func action(from url: URL, in context: NSManagedObjectContext) -> Action? {
        Action(url: url, in: context)
    }
}
