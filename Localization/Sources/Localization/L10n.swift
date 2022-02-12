import Foundation

public enum L10n {
    public enum Common: String, Localizable {
        case buttonCancel = "button.cancel" // "Cancel"
        case buttonSave = "button.save" // "Save"
        case buttonChoose = "button.choose"
        case buttonDismiss = "button.dismiss"
        // TODO: edit button has shorter version on iPhone/iPad for Russian locale
        case buttonEdit = "button.edit"
        case buttonDelete = "button.delete"
        case buttonDeleteEllipsis = "button.delete.ellipsis"
        case buttonSeparateWindow = "button.separateWindow"
        case numberOfItems = "common.numberOfItems"
    }
}
