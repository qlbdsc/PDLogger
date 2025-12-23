# PDLogger: Automatic Multi-log Generation for Practical Software Development

We present PDLogger, the first end-to-end log generation technique expressly designed for practical, multi-log scenarios. 
### PDLogger Repository Structure

**Main components**  
There are five core components. The code or prompts used by PDLogger’s main components are located in their respective folders.

**block_type_based_prompting**: this folder contains a Java file of abstract blocks, as well as the block-based prompts used for position generation and message generation.

**deduplication**: this folder contains the functional files required for deduplication, as well as prompt examples.

**func-extension**: this folder contains the file that abstracts function-level variables.

**level_refinement**: this folder contains the prompt example for level refinement.

**semantic_dependency_abstract**: this folder contains the file to abstract the semantic dependency information.


**`auxiliary_files/`**

- **`method_scope.java`** – obtains the line-number range of the corresponding method.  
- **`oneline.py`** – converts multi-line log statements in a Java file into a single line **without altering the file’s overall line numbering**.
