# Search Plugins

Locale-based search engines are imported from the Android l10n repos. To import the latest set of plugins, execute the `./scrape_plugins.py` script.

*Do not make changes to `SearchPlugins.plist` -- these changes will be overwritten on the next import!* If you need to make changes to search plugins, you have the following options (in preferred order):

1. Update the plugin directly in the Android l10n repos. This is preferred if your changes apply to both platforms. Since the iOS engines are imported from Android, any changes to the Android l10n repos will be picked up here when the import script is run.
2. Define an overlay. Overlays allow local, iOS-specific modifications to be applied after the files are imported.

## Overlays

### Background
For the most part, the engines are the same on both platforms. There are, however, certain iOS-specific changes that we want to make to some of the engines. Previously, we would modify the engine XML files directly, but this made it difficult to re-import the engines from Android without losing our local changes.

To address this, we've added support for search engine overlays. These are XML files located in the `SearchOverlays` directory that contain document transformations to be applied after each import.

#### Usage
To add an overlay, append the overlay definition to the corresponding XML file (or create it if it doesn't exist) in the search engine in the `SearchOverlays` directory. The overlay file name is based on the plugin file name used in `list.json`; for example, to create a Yahoo overlay, we would add an overlay to `SearchOverlays/yahoo.xml`.

Overlay files have the following structure:
```
<SearchOverlay>
  <append parent="//search:Url[@type='text/html']">
    <!-- Child node to append -->
  </append>
  <replace target="//search:Image">
    <!-- Replacement node -->
  </append>
</SearchOverlay>
```

The root node of an overlay document must be a `SearchOverlay` element. It can have any number of `<append>` or `<replace>` nodes, which will perform those respective actions on the engine matching this file.

### API

##### append
* Node name: `append`
* Required attribute: `parent` - The value for `parent` is an XPath expression identifying elements in the search plugin XML. Note that all nodes must be prefixed by the `search` namespace.
* Children: `append` must have exactly one child element; the element may have any number of children. This element will be appended to any elements matching the `parent` XPath expression.

##### replace
* Node name: `replace`
* Required attribute: `target` - The value for `target` is an XPath expression identifying elements in the search plugin XML. Note that all nodes must be prefixed by the `search` namespace.
* Children: `replace` must have exactly one child element; the element may have any number of children. This element will replace any elements matching the `target` XPath expression.

### Tests
Execute `./run_tests.py` to run tests. This uses test files in the `Tests` directory to check overlay behavior.
