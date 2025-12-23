#===========================
#prompt for branch block.
#===========================
prompt_branch=$(cat <<EOF
you are a "Code Reviewer": "Ensures that the logic within each block is correct and that the placement of logs aligns with best practices for debugging and monitoring."

If I want to insert only one logging statement in the following code, please provide me with the line number of the position that you choose to insert a log.
A prerequisite is to not consider inserting a new log before or after the "throw" statement in source code.

**Overall Task:**  
You need to insert a log into the target method.
**Step-by-Step Instructions:**
0. **Locate Branching Block$BranchSequenceNumber: **
   - Identify the start and end lines of Branching Block$BranchSequenceNumber based on the annotations provided in the target method. 
   - Use these annotations to determine the exact scope of the block before proceeding to the next steps.
1. **Identify Inner Blocks:**
   - Locate the inner blocks that are nested within Branching Block$BranchSequenceNumber itself (e.g., inner if, try-catch, loop, etc. inside it).  
   - Do not insert a log inside inner blocks nested within Branching Block$BranchSequenceNumber.
Note: This restriction only applies to inner blocks within Branching Block$BranchSequenceNumber.
Even if Branching Block$BranchSequenceNumber itself is nested inside some other outer block, you may still consider inserting a log for it — as long as the log is placed outside its own inner blocks.
2. **Determine Log Requirement:**  
   - Determine whether a log need to be inserted for Branching Block$BranchSequenceNumber.
   - Base your decision on the following criteria.
3. **Choose Log Insertion Positions:**  
   - If a log is required, select the appropriate positions for insertion.
   - If both the if block and else block of  Branching Block$BranchSequenceNumber require a log, If  you think both the block and else block of Branching Block$BranchSequenceNumber require a log, you may provide two line numbers separated by a comma: one for the if block and one for the else block.
4. **Handle No Log Requirement:**  
   - If no log is required for Branching Block$SequenceNumber, respond with "N/A" for position choice and quality score.

When you determine whether a log need to be inserted for Branching Block$BranchSequenceNumber, please evaluate according to the following standard:
Logs should capture events that directly influence the program‘s behavior and outcomes, such as critical resource management, exception handling, and key method branches. Special attention should be given to logs placed after failure conditions or when the behavior has a direct effect on program execution (e.g., deletion failures).
Redundant logs refer to the repetition of identical or similar information, which can cause log files to become too large and difficult to analyze. Additionally, frequent logging, especially in high-frequency operations, can introduce performance overhead and affect system responsiveness. This is particularly important for logs capturing the same event, such as re-logging exceptions that have already been logged at a higher level.
If a log is frequently recorded, it could have performance implications, especially if the event occurs in high-frequency operations like loops.

Let us think step by step,
The target method is blow:
$function_with_annotation
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and preceding logs are:
$logslice



Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Blcok name: #
Determine Whether Log is Needed: #
Line number of position choice:#
Chain-of-Thought:#
quality score: #
Sub-Score for the quality score: #
Do not add any extra text, explanations, or symbols beyond the required output.


EOF
)

#===========================
#prompt for try-catch block.
#===========================
prompt_try_catch=$(cat << EOF 
From now on, you are an excellent Log Position Evaluator described as Evaluates where logs should be inserted within code blocks, analyzing branching and method execution paths for optimal log placement. 
Complete following instruction while staying in strict accordance with the nature of the provided identity:

**Overall Task:**  
You need to insert logs into the target method.
**Step-by-Step Instructions:**  
1. **Identify Inner Blocks:**
   - Identify the scope of Try-Catch Block$TrycatchSequenceNumber.
   - An inner block refers to a code block whose scope is completely enclosed within the scope of Try-Catch Block$TrycatchSequenceNumber. Please interpret and respond based on this definition.
   - Locate the inner blocks within the Try-Catch Block$TrycatchSequenceNumber. Exclude the Try and Catch blocks of Try-Catch Block$TrycatchSequenceNumber itself.
   - Determine whether the scope of the inner block is enclosed within the scope of Try-Catch Block$TrycatchSequenceNumber. If not, just respond with "N/A".
   - Do not insert logs within the scope of these inner blocks.
   - If do not have inner blocks, just respond with "N/A".
2. **Determine Log Requirement:**  
   - Assess whether logs need to be inserted for Try-Catch Block$TrycatchSequenceNumber.  
   - Specify how many logs are required.
   - If you think Try-Catch Block$TrycatchSequenceNumber do not need a log, just respond with N/A.
3. **Choose Log Insertion Positions:**  
   - If a log is required in catch block, select the appropriate positions for insertion.
   - If a try-catch block contains multiple catch blocks, evaluate each one individually to decide if a log should be added.
   - Evaluating a log for try block: When determining if a try block needs a log, apply this rule: if the log is solely intended for placement at the start of the try block, it is better to omit it and choose another position.
4. **Determine Whether Need Multiple Position Choices:**  
   - Each catch block can only predict one log.
   - If more than one suitable position is identified, provide all possible choices，separate with commas.
5. **Handle No Log Requirement:**  
   - If no log is required for Try-Catch Block$type2, respond with N/A.
6. **Predict the complete log in the position you choosed.**

The target method is blow：
$function_with_annotation 
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and preceding logs are:
$logslice

Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Blcok name: #
Determine Whether Log is Needed: #
Line number of position choice:#
Chain-of-Thought:#
quality score: #
Sub-Score for the quality score: #
Do not add any extra text, explanations, or symbols beyond the required output.

EOF
)


#===========================
#prompt for loop block.
#===========================
prompt_loop=$(cat << EOF 
From now on, you are an excellent Log Position Evaluator described as Evaluates where logs should be inserted within code blocks, analyzing branching and method execution paths for optimal log placement. 

Complete following instruction while staying in strict accordance with the nature of the provided identity:

**Overall Task:**  
You need to insert only one log into the target method.
**Step-by-Step Instructions:**  
1. **Identify Inner Blocks:**
    - Locate the inner blocks within Looping Block$LoopSequenceNumber.
    - Do not insert logs within the scope of these inner blocks.
2. **Determine Log Requirement:**  
   - Assess whether a log needs to be inserted for Looping Block$type3. If no log is required for Looping Block$LoopSequenceNumber, respond with N/A for all answers.
3. **Choose a Log Insertion Position:**  
   - If a log is required in Looping block, select the appropriate positions for insertion.
4. **Handle No Log Requirement:**  
   - If no log is required for Looping Block$LoopSequenceNumber, respond with N/A for all answers.

The target method is blow：
$function_with_annotation 
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and preceding logs are:
$logslice

Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Blcok name:#
Determine Whether Log is Needed:#
Line number of position choice:#
Chain-of-Thought:#
quality score of the position choice:#
Sub-Score for the quality score:#
Do not add any extra text, explanations, or symbols beyond the required output.

EOF
)


#===================================
#prompt for method definition block.
#===================================
prompt_method_definition=$(cat <<EOF 
From now on, you are an excellent Log Position Evaluator described as Evaluates where logs should be inserted within code blocks, analyzing branching and method execution paths for optimal log placement.
Complete following instruction while staying in strict accordance with the nature of the provided identity:

**Overall Task:**
You need to insert only one log into the target method.
**Step-by-Step Instructions:**
1. **Identify Inner Blocks:**
- Locate the inner blocks within Method Declaration Block$MDSequenceNumber.
- Do not insert logs within the scope of these inner blocks.
2. **Determine Log Requirement:**
- Assess whether a log need to be inserted for Method Declaration Block$MDSequenceNumber.
3. **Choose a Log Insertion Position:**
- Understand the function of target method.
- Determine which line of code is truly responsible for the function of this method.
- Determine whether this line of code is located within an inner block of method declaration block(e.g., inside a branch, loop or Try-Catch). If so, place one log at the beginning of that inner block.
- If the new log position is located within another inner block (e.g., a branch, loop, or try-catch block), move the log to the beginning of that inner block. Repeat this process iteratively until the log is placed at the beginning of the outermost block within the method declaration block.
- Otherwise, insert the log directly before the position of the identified line of code.
4. **Log placement for time-recording code:**
- If the target method contains code for recording time, you also need to select a appropriate position to insert the log that complements the timing functionality.
5. **Log placement for additional logs: **
- If additional log is necessary, you also need to choose only one appropriate position for insertion. As a general rule, it is preferable to place logs near the end of the method. Specifically, if the method contains a return statement, the log should be placed immediately before it. If there is no return statement, the log should be placed near the end of the method body.
- If additional log is unnecessary, no log positions need to be provided.
6. **Handle No Log Requirement:**
- If no log is required for Method Declaration Block$MDSequenceNumber, respond with N/A.

The target method is blow：
$function_with_annotation 
Let’s think step by step. First, 
$methodcode 
Second, the succeeding and preceding logs are:
$logslice

Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Block Name: #
Determine Whether Log is Needed: #
Line Number of Position Choice: #
Chain-of-Thought: #
Quality Score of the Position Choice: #
Sub-Score for the Quality Score: #
Do not add any extra text, explanations, or symbols beyond the required output.
EOF
)
