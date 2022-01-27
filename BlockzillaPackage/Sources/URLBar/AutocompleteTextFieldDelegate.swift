import Foundation

@objc public protocol AutocompleteTextFieldDelegate: AnyObject {
    @objc optional func autocompleteTextFieldShouldBeginEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool
    @objc optional func autocompleteTextFieldShouldEndEditing(_ autocompleteTextField: AutocompleteTextField) -> Bool
    @objc optional func autocompleteTextFieldShouldReturn(_ autocompleteTextField: AutocompleteTextField) -> Bool
    @objc optional func autocompleteTextField(_ autocompleteTextField: AutocompleteTextField, didTextChange text: String)
}
