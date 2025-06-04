# simple_mvc_xml_editor



## 🧱 Virtual TreeView Setup

This project includes the Virtual TreeView source (version 8.1.1) in the `Lib\Virtual-TreeView-8.1.1` folder. You do **not** need to clone the repo — it's already bundled.

### Delphi / RAD Studio 10.4 and Higher Installation

1. Open the project group:

Lib\Virtual-TreeView-8.1.1\Packages\RAD Studio 10.4+\VirtualTreeView.groupproj


2. In the Project Manager:
- Right-click the root element `VirtualTreeView` → click **Build All**
- Right-click the package `VirtualTreesD*.bpl` → click **Install**

3. Verify:

- Right-click the project → **Options**
- Go to: Delphi Compiler > Search path

- Ensure the above path exists in the list

If it's missing, add it manually to allow the compiler to resolve VST units like `VirtualTrees.pas`.

---


to install the VirtualTreeView globaly 
3. Go to: Tools > Options > Language > Delphi Options > Library


4. For platform **Win32**:
- Select `Win32` from the Platform drop-down
- Click `Library Path > [...]`
- Add:
  ```
  Lib\Virtual-TreeView-8.1.1\Packages\RAD Studio 10.4+\Win32\Release
  ```

5. For platform **Win64**:
- Select `Win64` from the Platform drop-down
- Click `Library Path > [...]`
- Add:
  ```
  Lib\Virtual-TreeView-8.1.1\Packages\RAD Studio 10.4+\Win64\Release
  ```

6. (Optional for C++Builder users) Add the `Source` folder to `Library Path` and `System Include path` under:

7. Click **Save** to apply changes.

---