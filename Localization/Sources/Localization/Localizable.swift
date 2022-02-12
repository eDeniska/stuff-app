//
//  Localization.swift
//  
//
//  Created by Данис Тазетдинов on 12.02.2022.
//

import Foundation

public protocol Localizable: RawRepresentable where RawValue == String {
    
    var localized: String { get }
    func localized(with args: Any...) -> String
}

public extension Localizable {
    var localized: String {
        NSLocalizedString(rawValue, tableName: nil, bundle: .module, value: rawValue, comment: rawValue)
    }

    func localized(with args: Any...) -> String {
        let cvargs = args.compactMap { $0 as? CVarArg }
        return String(format: localized, locale: Locale.autoupdatingCurrent, arguments: cvargs)
    }
}
