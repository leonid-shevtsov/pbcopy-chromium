# pbcopy-chromium

You know how sometimes an Electron / Chromium app has working internal copy/paste, but the data cannot leave the bounds of the application, or if it does, then in a degraded format?

This is because some Chromium apps use an internal copy/paste container that other apps don't recognize.

This utility is made to be able to extract data from the containers.

I initially made it to copy & paste Obsidian Canvas node elements. The internal format is [well documented](https://jsoncanvas.org), but it was still inaccessible outside of Obsidian. But now I can do:

```sh
# inject into obsidian
ruby generate_nodes.rb | pbcopy-chromium --type=obsidian/canvas

# extract from obsidian
pbcopy-chromium --paste --type obsidian/canvas >tasks.canvas
```

## Known use cases

| Application                     | Use case                                                          | MIME type                          |
| ------------------------------- | ----------------------------------------------------------------- | ---------------------------------- |
| [Obsidian](https://obsidian.md) | [Obsidian Canvas](https://obsidian.md/canvas) nodes and fragments | obsidian/canvas                    |
| [Notion](https://notion.so)     | Structured contents                                               | text/\_notion-blocks-v3-production |

Please let me know / open a PR if you find more!

## Installation

Currently, only works with macOS, although possibly can be ported to other operating systems.

Download the latest release from the “Releases” page and place into a directory on your `$PATH`.

## Usage

```
USAGE: pbcopy-chromium --type <type> [<input-file>] [--paste]

ARGUMENTS:
  <input-file>            Filename to read (or standard input)

OPTIONS:
  --type <type>           MIME type of the contents to copy
  --paste                 Instead of copying, paste the clipboard to standard output
  -h, --help              Show help information.
```

---

&copy; 2024 [Leonid Shevtsov](https://leonid.shevtsov.me), released under the MIT license
