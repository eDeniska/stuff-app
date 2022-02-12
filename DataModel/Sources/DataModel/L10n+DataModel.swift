//
//  File.swift
//  
//
//  Created by Данис Тазетдинов on 12.02.2022.
//

import Foundation
import Localization

extension L10n {
    enum AppCategory: String, Localizable {
        case pets = "appCategory.pets"
        case clothers = "appCategory.clothers"
        case shoes = "appCategory.shoes"
        case gadgets = "appCategory.gadgets"
        case tableware = "appCategory.tableware"
        case jewelry = "appCategory.jewelry"
        case accessories = "appCategory.accessories"
        case books = "appCategory.books"
        case appliances = "appCategory.appliances"
        case furniture = "appCategory.furniture"
        case sports = "appCategory.sports"
        case tools = "appCategory.tools"
        case music = "appCategory.music"
        case other = "appCategory.other"
    }
    
    enum DetectedItem: String, Localizable {
        case other = "detectedItem.other"
        case bird = "detectedItem.bird"
        case fish = "detectedItem.fish"
        case cat = "detectedItem.cat"
        case dog = "detectedItem.dog"
        case livingThing = "detectedItem.livingThing"
        case food = "detectedItem.food"
        case book = "detectedItem.book"
        case comicBook = "detectedItem.comicBook"
        case magazine = "detectedItem.magazine"
        case hygiene = "detectedItem.hygiene"
        case mug = "detectedItem.mug"
        case plate = "detectedItem.plate"
        case spoon = "detectedItem.spoon"
        case fork = "detectedItem.fork"
        case knife = "detectedItem.knife"
        case sportInventory = "detectedItem.sportInventory"
        case chair = "detectedItem.chair"
        case screwdriver = "detectedItem.screwdriver"
        case hammer = "detectedItem.hammer"
        case glasses = "detectedItem.glasses"
        case fridge = "detectedItem.fridge"
        case player = "detectedItem.player"
        case gadget = "detectedItem.gadget"
        case guitar = "detectedItem.guitar"
        case piano = "detectedItem.piano"
        case instrument = "detectedItem.instrument"
        case clock = "detectedItem.clock"
        case watch = "detectedItem.watch"
        case phone = "detectedItem.phone"
        case computer = "detectedItem.computer"
        case laptop = "detectedItem.laptop"
        case photo = "detectedItem.photo"
        case gun = "detectedItem.gun"
        case tool = "detectedItem.tool"
        case backpack = "detectedItem.backpack"
        case bag = "detectedItem.bag"
        case wallet = "detectedItem.wallet"
        case vehicle = "detectedItem.vehicle"
        case medical = "detectedItem.medical"
        case jewelry = "detectedItem.jewelry"
        case shoes = "detectedItem.shoes"
        case storage = "detectedItem.storage"
        case audio = "detectedItem.audio"
        case tv = "detectedItem.tv"
        case desk = "detectedItem.desk"
        case bed = "detectedItem.bed"
        case table = "detectedItem.table"
        case cabinet = "detectedItem.cabinet"
        case toy = "detectedItem.toy"
        case tie = "detectedItem.tie"
        case umbrella = "detectedItem.umbrella"

        case hat = "detectedItem.hat"
        case denim = "detectedItem.denim"
        case swimsuit = "detectedItem.swimsuit"
        case sweatshirt = "detectedItem.sweatshirt"
        case tShirt = "detectedItem.tShirt"
        case suit = "detectedItem.suit"
        case skirt = "detectedItem.skirt"
        case coat = "detectedItem.coat"
        case clothers = "detectedItem.clothers"

        case beauty = "detectedItem.beauty"
        case bathing = "detectedItem.bathing"
        case lighting = "detectedItem.lighting"
        case stationery = "detectedItem.stationery"
        case kitchen = "detectedItem.kitchen"

        case climate = "detectedItem.climate"
        case washing = "detectedItem.washing"
        case cleaning = "detectedItem.cleaning"
        case appliance = "detectedItem.appliance"
        case coffeeMaker = "detectedItem.coffeeMaker"
        case cooking = "detectedItem.cooking"
        case teaMaker = "detectedItem.teaMaker"

        case accessory = "detectedItem.accessory"
        case houseItem = "detectedItem.houseItem"
        case trashBin = "detectedItem.trashBin"
    }
    
    enum ItemCondition: String, Localizable {
        case unknown = "condition.unknown"
        case brandNew = "condition.brandNew"
        case excellent = "condition.excellent"
        case good = "condition.good"
        case moderate = "condition.moderate"
        case poor = "condition.poor"
        case damaged = "condition.damaged"
    }
    
    enum Item: String, Localizable {
        case unnamed = "item.unnamed"
    }
}
