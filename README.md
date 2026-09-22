# cef-sdk

What it takes to BUILD against our CEF fork, and nothing it takes to run it.

This is the small half of a CEF binary distribution: the headers, the `libcef_dll` wrapper sources a consumer
compiles itself, and the import library. It is about 6 MB. The runtime, `libcef.dll` and the resource and
locale files, is about 420 MB and is NOT here: it is published as a release asset on the fork this is
extracted from, and it is only needed to actually run a browser.

That split is the whole point. A project that embeds CEF can build, and be worked on, without every
contributor downloading 420 MB of Chromium they will not run.

## Layout

```
include/            CEF's public headers
libcef_dll/         the wrapper sources; a consumer compiles these into its own binary
Release/libcef.lib  the import library
LICENSE.txt         CEF's licence, unchanged, which governs everything here
```

The paths mirror a CEF distribution exactly, so a build that pointed at an extracted distribution points here
with no other change.

## Where it comes from

Extracted from a binary distribution of `readycodeio/cef`, our fork, whose surface-lease patch adds API that
does not exist upstream. Regenerate with:

```
./Sync-FromCefDistribution.ps1 -Distribution <path to an extracted cef_binary_... folder>
```

Nothing here is edited by hand. A change belongs in the fork, and arrives here by running that script against
a distribution built from it.

## Versioning

A commit here corresponds to exactly one CEF build. Consumers pin by commit, as a submodule or equivalent, and
move deliberately: the wrapper sources and the headers have to match the runtime they will eventually load, and
a mismatch is a crash rather than a diagnostic.
