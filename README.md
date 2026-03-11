

# PDLogger

  An automated multi-log generation scheme.
  



  ## Overview

  `PDLogger` is a research-oriented, prompt-and-script-based pipeline for practical multi-log generation.
  

  ## Repository Structure
  ```text
  PDLogger/
  ├── block-type-based-prompting/
  │   ├── block_abstract.java            # Annotates Branch/Try-Catch/Loop/Method blocks
  │   ├── position_generation.sh         # Prompt templates for log position prediction
  │   └── message_generation.sh          # Prompt template for log message generation
  ├── semantic_dependency_abstract/
  │   ├── backward_slice.sh              # Joern/PDG-based backward slicing pipeline
  │   ├── cg.py                          # Call graph extraction script (Joern)
  │   └── bl_limit.py                    # Bounded-hop backward slicing (default: 7)
  ├── deduplication/
  │   ├── dedup.sh                       # Prompting + post-processing for deduplication
  │   └── ThrowArgResolver.java          # Resolves semantics of throw/fail/failIf arguments
  ├── func-extension/
  │   └── func-extension.java            # Function-level variable extension
  ├── level_refinemnet/
  │   └── level_refinement_prompt.sh     # Prompt template for log-level refinement
  └── auxiliary_files/
      ├── method_scope.java              # Extracts method start/end line range
      └── oneline.py                     # Merges multi-line logs into one line (keeps line mapping)
```
  ## Core Pipeline (Conceptual)

  1. Block Abstraction
     Annotate branch, loop, try-catch, and method blocks in the target Java method.
  2. Log Position Generation
     Predict insertion line(s) using block-type-based prompting strategy and surrounding context.
  3. Semantic Dependency Abstraction
     Build a semantic dependency context using call graph and backward slicing.
  4. Log Message Generation
     Generate concrete log statements for selected positions.
  5. Deduplication
     Remove semantically redundant or conflicting logs.
  6. Level Refinement
     Re-evaluate and adjust info/debug/trace/warn/error levels.


  ### Base Tools

  - Java (recommended 11+)
  - Python 3.8+
  - Bash
  - Joern (for CPG/PDG/call-graph-related steps)

  ### Python Dependency

  - pygraphviz (used by semantic_dependency_abstract/bl_limit.py)

  ### Java Libraries (visible in source)

  - JavaParser (+ symbol solver)
  - Apache Commons CLI
  - Eclipse JDT (used by method_scope.java)

  ## Quick Start (Suggested)

  ### 1) Clone

  git clone https://github.com/qlbdsc/PDLogger.git
  cd PDLogger

  ### 2) Preprocess Target Java File

  - Use block-type-based-prompting/block_abstract.java to annotate code blocks.
  - Use auxiliary_files/oneline.py if you need line-number-stable single-line log formatting.(converts multi-line log statements in a Java file into a single line **without altering the file’s overall line numbering
)
  - 
  ### 3) Generate Positions and Messages

  - Use prompt templates in position_generation.sh for insertion position prediction.
  - Use message_generation.sh to generate complete log statements.

  ### 4) Abstract Semantic Context and Deduplicate

  - Use scripts under semantic_dependency_abstract/ to gather dependency context.
  - Run deduplication/dedup.sh for semantic deduplication.

  ### 5) Refine Log Levels

  - Use level_refinemnet/level_refinement_prompt.sh to refine log levels.

  ## Notes and Limitations

  - Some shell commands use macOS-style sed -i ''; adjust for GNU/Linux if needed.

