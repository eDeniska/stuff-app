import UIKit

public enum L10n {
    public enum Common: String, Localizable {
        case buttonCancel = "button.cancel" // "Cancel"
        case buttonSave = "button.save" // "Save"
        case buttonChoose = "button.choose"
        case buttonDismiss = "button.dismiss"
        case buttonEditMac = "button.edit.mac"
        case buttonEditPhone = "button.edit.phone"
        case buttonDelete = "button.delete"
        case buttonDeleteEllipsis = "button.delete.ellipsis"
        case buttonSeparateWindow = "button.separateWindow"
        case numberOfItems = "common.numberOfItems"
        
        // edit button has shorter version on iPhone/iPad for Russian locale
        public static var buttonEdit: Common {
            if UIDevice.current.userInterfaceIdiom == .mac {
                return .buttonEditMac
            } else {
                return .buttonEditPhone
            }
        }
    }
}
