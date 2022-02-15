//
//  L10n+Views.swift
//  
//
//  Created by Данис Тазетдинов on 12.02.2022.
//

import Foundation
import Localization
import UIKit

extension L10n {
    
    enum Category: String, Localizable {
        case sectionTitle = "category.section.title" // Category
        case createCategoryNamed = "category.create.named" // "Create category '\(trimmedTitle)'"
        case customIcon = "category.customIcon" // "Icon"
        case title = "category.title" // "Category"
        case categoryForItem = "category.tile.forItem" // "Category for %@"
        case unnamedCategory = "category.unnamed" // Unnamed
    }
    
    enum ConditionView: String, Localizable {
        case title = "condition.view.title"
        case conditionForItem = "condition.tile.forItem"
    }
    
    enum ItemAssignment: String, Localizable {
        case addItemToChecklistsTitle = "item.assignment.addToChecklists.title" // "Add \(item.title) to checklists"
    }
    
    enum ItemDetails: String, Localizable {
        case newItemTitle = "item.details.newItemTitle" // New item
        case itemTitlePlaceholder = "item.details.itemTitle.placeholder" // "Item title"
        case itemSectionTitle = "item.details.section.item.title" // "Item"
        case detailsPlaceholder = "item.details.itemDetails.placeholder" // "Item details"
        case detailsSectionTitle = "item.details.section.details.title" // "Details"
        case noPlaceIsSet = "item.details.noPlaceIsSet" // "No place is set"
        case shouldRemoveImage = "item.details.shouldRemoveImage" // "Remove image?"
        case removeImageConfirmation = "item.details.removeImage.confirmation" // "Remove"
        case addPhotosTitle = "item.details.addPhotos.title" // "Add photos of the item"
        case takePhotoTitle = "item.details.takePhoto.title" // "Take photo..."
        case choosePhotosTitle = "item.details.choosePhotos.title" // "Choose from library..."
        case noCameraAccessTitle = "item.details.noCameraAccess.title" // "Camera access is not allowed"
        case buttonOpenSettings = "item.details.button.openSettings" // "Open settings"
        case imagesSectionTitle = "item.details.section.images.title" // "Images"
        case predictingTitle = "item.details.predicting.title" // "Predicting..."
        case fetchingImagesTitle = "item.details.fetchingImages.title" // "Fetching images..."
        case buttonAddToChecklist = "item.details.button.addToChecklist" //"Add to checklist"
        case itemNoLongerAvailable = "item.details.noLongerAvailable" // "Item is no longer available"
    }
    
    enum ItemWelcome: String, Localizable {
        case chooseExisting = "item.welcome.chooseExisting" // "Choose existing item"
        case orLabel = "item.welcome.or.label"
        case createNewButton = "item.welcome.createNew.button" // "Add new"
    }
    
    enum ItemsList: String, Localizable {
        case listTitle = "items.list.title"
        case addToChecklistsButton = "items.list.addToChecklists.button" // "Add to checklists..."
        case shouldDeleteItem = "items.list.shouldDeleteItem" // "Delete \(item.title)?"
        case searchPlaceholder = "items.list.searchPlaceholder" // "Search for items..."
        case addItemButton = "items.list.addItem.button" // "Add item"
    }
    
    enum PlaceDetails: String, Localizable {
        case title = "place.details.title" // "Place"
        case placeNoLongerAvailable = "place.details.noLongerAvailable" // "Place is no longer available"
        case placeIsEmpty = "place.details.isEmpty" // "Place is empty"
    }
    
    enum PlacesList: String, Localizable {
        case listTitle = "places.list.title" // "Places"
        case searchPlaceholder = "places.list.searchPlaceholder" // "Search for places..."
        case noPlaceAssigned = "places.list.noPlaceAssigned" // "No place assigned"
        case placeItemsButton = "places.list.placeItems.button" // "Place items..."
        case shouldDeletePlace = "places.list.shouldDeletePlace" // "Delete \(item.title)?"
        case addPlaceButton = "places.list.addPlace.button" // "Add place"
        case placeItemsToTitle = "places.list.placeItemsTo.title" // "Place items to \(place.title)"
        case filterItemsPlaceholder = "places.list.filterItems.placeholder" // "Filter items..."
        case addNewPlaceButton = "places.list.addNewPlace.button" // "Add new place..."
        case placeForItem = "places.list.placeForItem"
    }
    
    enum PlaceWelcome: String, Localizable {
        case chooseExisting = "place.welcome.chooseExisting" // "Choose existing place"
        case orLabel = "place.welcome.or.label"
        case createNewButton = "place.welcome.createNew.button" // "Add new"
    }

    enum EditPlace: String, Localizable {
        case titlePlaceholder = "place.edit.title.placeholder" // "New place title"
        case titleSectionTitle = "place.edit.title.section.title" // "Title"
        case customIcon = "place.edit.customIcon" // "Icon"
        case title = "place.edit.title" // "New place"
        case unnamedPlace = "place.edit.unnamed.title" // "Unnamed place"
    }
    
    enum PhotoViewer: String, Localizable {
        case nextLong = "photoViewer.next.long"
        case previousLong = "photoViewer.previous.long"
        case nextShort = "photoViewer.next.short"
        case previousShort = "photoViewer.previous.short"
        
        static var next: PhotoViewer {
            UIDevice.current.isPhone ? .nextShort : .nextLong
        }
        static var previous: PhotoViewer {
            UIDevice.current.isPhone ? .previousShort : .previousLong
        }
    }

    enum ChecklistsList: String, Localizable {
        case searchPlaceholder = "checklists.list.searchPlaceholder" // "Search for checklists..."
        case listTitle = "checklists.list.title" // "Checklists"
        case addItemsButton = "checklists.list.addItems.button" // "Add items..."
        case shouldDeleteChecklist = "checklists.list.shouldDeleteChecklist" // "Delete \(item.title)?"
        case addChecklistButton = "checklists.list.addChecklist.button" // "Add checklist"
        case assignItemsToTitle = "checklists.list.assignItemsTo.title" // "Add items to
        case filterItemsPlaceholder = "checklists.list.filterItems.placeholder" // "Filter items..."
    }
    
    enum ChecklistWelcome: String, Localizable {
        case chooseExisting = "checklist.welcome.chooseExisting" // "Choose existing checklist"
        case orLabel = "checklist.welcome.or.label"
        case createNewButton = "checklist.welcome.createNew.button" // "Add new"
    }

    enum EditChecklist: String, Localizable {
        case titlePlaceholder = "checklist.edit.title.placeholder" // "New checklist title"
        case titleSectionTitle = "checklist.edit.title.section.title" // "Title"
        case customIcon = "checklist.edit.customIcon" // "Icon"
        case title = "checklist.edit.title" // "New checklist"
        case unnamedChecklist = "checklist.edit.unnamed.title" // "Unnamed checklist"
    }

    enum NewChecklistEnty: String, Localizable {
        case titlePlaceholder = "checklist.entry.new.title.placeholder" // "Title"
        case titleSectionTitle = "checklist.entry.new.title.section.title" // "Title"
        case suggestedItemsSectionTitle = "checklist.entry.new.suggestedItems.section.title" // "Suggested items"
        case customIcon = "checklist.entry.new.customIcon" // "Icon"
        case title = "checklist.entry.new.title" // "Entry"
    }

    enum ChecklistDetails: String, Localizable {
        case checklistNoLongerAvailable = "checklist.details.noLongerAvailable" // "Checklist is no longer available"
        case checklistIsEmpty = "checklist.details.isEmpty" // "Checklist is empty"
        case itemDetailsButton = "checklist.details.itemDetails.button" // "Item details..."
        case markAsUnchecked = "checklist.details.markAsUnchecked" // "Mark as unchecked"
        case markAsChecked = "checklist.details.markAsChecked" // "Mark as checked"
        case sectionPending = "checklist.details.section.pending" // "Pending"
        case sectionChecked = "checklist.details.section.checked" // "Checked"
        case addEntryButton = "checklist.details.addEntry.button" // "Add entry"
    }

}
