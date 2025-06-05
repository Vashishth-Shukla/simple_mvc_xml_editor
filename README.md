# Simple MVC XML Editor

A lightweight and cleanly structured XML editor built in Delphi (RAD Studio) using a simplified MVP (Model-View-Presenter) pattern. Designed to resemble Microsoft XmlNotepad but with a custom and extensible foundation. Tree-based editing is powered by Virtual TreeView 8.1.1.

---

## 🧱 Virtual TreeView Setup

This project includes Virtual TreeView (v8.1.1) inside `Source\Lib\Virtual-TreeView-8.1.1`. You do **not** need to download it separately.

### 🔧 Step-by-Step (Delphi 10.4+)

1. Open the group project:

   ```
   Source\Lib\Virtual-TreeView-8.1.1\Packages\RAD Studio 10.4+\VirtualTreeView.groupproj
   ```

2. In the **Project Manager**:

   * Right-click the root group `VirtualTreeView` → click **Build All**
   * Right-click `VirtualTreesR*.bpl` → click **Install**

3. Verify search path:

   * Right-click your main project → **Options**
   * Go to: Delphi Compiler > Search path
   * Ensure the following path exists:

     ```
     Source\Lib\Virtual-TreeView-8.1.1\Source
     ```

### 📅 Optional: Install Globally

If you'd like to use Virtual TreeView across all Delphi projects:

1. Go to:

   ```
   Tools > Options > Language > Delphi > Library
   ```

2. For **Win32** platform:

   * Select `Win32`
   * Add to *Library Path*:

     ```
     Source\Lib\Virtual-TreeView-8.1.1\Packages\RAD Studio 10.4+\Win32\Release
     ```

3. For **Win64** platform:

   * Select `Win64`
   * Add:

     ```
     Source\Lib\Virtual-TreeView-8.1.1\Packages\RAD Studio 10.4+\Win64\Release
     ```

4. Save and restart Delphi.

---

## 🚀 Running the Project

1. Open the project file:

   ```
   Projects\XML.Editor.dproj
   ```

2. Build and run

3. Use the **File** menu to:

   * Create a new XML file
   * Open an existing XML file
   * Save or Save As

4. Right-click any node to:

   * Rename, delete
   * Add elements (before/after/child)
   * Add attribute, text, comment, CDATA

---

## 📚 Supported XML Features

This editor currently supports the following XML structures:

Elements (tagged nodes)

Attributes (key-value pairs inside elements)

Text nodes

Comments (<!-- -->)

CDATA sections (<![CDATA[ ... ]]>)

All operations are editable via right-click context menu.

---

## 🛋️ Architecture Overview

This project follows a simple MVP architecture:

* **Model**: `TXmlNodeItem` represents elements, attributes, text, comment, etc.
* **View**: `TMainForm` manages the UI using `TVirtualStringTree`
* **Presenter**: `TMainViewController` handles logic like insertions, deletions, save/load

This architecture makes it easy to extend, test, or replace components.

---

## 📦 Dependencies

* [Virtual TreeView](https://github.com/Virtual-TreeView/Virtual-TreeView) (v8.1.1, MIT License)
* Delphi / RAD Studio 10.4 or higher

---

## 📚 TODO (Roadmap)

* [ ] Undo / Redo support
* [ ] Support for the rest of the XML structure
* [ ] Cut / Copy / Paste to and from text form
* [ ] Color by nodetype
* [ ] Drag and drop file
* [ ] Drag and drop to move the nodes
* [ ] Drag and drop Nodes to another instance of the application
* [ ] Search functionality (by name/value)
* [ ] XML schema validation
* [ ] Converters such as JSON to XML and XML to JSON
* ...

---

## 🚪 License

This project is open for learning, modification, and use.
MIT License (for VirtualTreeView) applies.

---

## 🧪 Feedback

Feel free to open issues or send suggestions for improvement.
This project is a work-in-progress XML editor with long-term extensibility goals.
