# ios-xcuitest-baseline-exporter

`ios-xcuitest-baseline-exporter` is a Swift-based command-line tool that extracts **baseline JSON files** from Xcode `.xcresult` bundles and copies them into your Xcode project.  
It is a key part of the **Baseline V2** workflow for [Evinced XCUISDK](https://github.com/GetEvinced/public-ios-xcuisdk), enabling deterministic UI baseline recording and comparison in CI and local environments.

---

## Overview

When running UI tests with [Evinced XCUISDK](https://github.com/GetEvinced/public-ios-xcuisdk), the SDK can generate **baseline files** that describe the expected accessibility issues for each test.  
These files are stored as **attachments** inside the `.xcresult` bundle produced by `xcodebuild`.  

The `ios-xcuitest-baseline-exporter` CLI:
1. Parses the `.xcresult` bundle
2. Extracts baseline JSON attachments
3. Normalizes their filenames (removing `_index_UUID` suffixes)
4. Copies them into your Xcode project’s baseline folder (e.g. `evinced/baselines`)
5. Prepares the project for subsequent **comparison test runs**

This is especially useful in **CI pipelines** to persist recorded baselines and commit them back to your repository.

---

## Installation

You can run `ios-xcuitest-baseline-exporter` by cloning this repository and using `swift run`.

### Run directly (recommended for CI)
```bash
git clone https://github.com/GetEvinced/ios-xcuitest-baseline-exporter.git
swift run --package-path ios-xcuitest-baseline-exporter export-baselines <xcresult-path>
```
