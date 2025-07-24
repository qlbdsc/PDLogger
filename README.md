# PDLogger: Automated Logging Framework for Practical Software Development

We present PDLogger, the first end-to-end log generation technique expressly designed for practical, multi-log scenarios. 
### PDLogger Repository Structure

**Main components**  
The code or prompts used by PDLogger’s main components are located in their respective folders.

**`auxiliary_files/`**

- **`method_scope.java`** – obtains the line-number range of the corresponding method.  
- **`oneline.py`** – converts multi-line log statements in a Java file into a single line **without altering the file’s overall line numbering**.
