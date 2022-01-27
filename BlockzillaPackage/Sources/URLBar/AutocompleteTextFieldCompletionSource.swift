

public protocol AutocompleteTextFieldCompletionSource: AnyObject {
    func autocompleteTextFieldCompletionSource(_ autocompleteTextField: AutocompleteTextField, forText text: String) -> String?
}
