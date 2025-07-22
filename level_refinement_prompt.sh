#!/bin/bash


#prompt to get log explanation
prompt_logex=$(cat << EOF
Please explain the following log statement strictly according to the specified output format. Do not include any additional information.
"$line"

Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Explanation: #
Do not include method names, analysis explanations, or any other text.

EOF
)  

#prompt to get function explanation
prompt_blockex=$(cat << EOF
Please explain the function of the following code block, strictly following the specified output format. Do not include any additional information.
Target block:
"$targetblock"

Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Explanation: #
Do not include method names, analysis explanations, or any other text.

EOF
)  


#prompt to do level refinement
prompt=$(cat << EOF
Given the contextual and metric-based information I provide, please determine whether the log level of the target log statement is most appropriate, and output the most appropriate log level, the log level contains(info, debug, trace, error and warn).

Let us think step to step,
First, the target log is: 
$targetlog

The line number of target log in target method is: $linenumber

Second, the target method is:
$targetmethod

Third, the explanation of log:
"$explanation_of_log"

Forth, the function of the block that contains target log:
"$function_of_block"

Fifth, the sum line of code of the block that contains target log: $sloc


Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Determine Whether Log Level need to be adjusted: # 
Detailed Chain-of-thought: #
Log Level: #
Do not include method names, analysis explanations, or any other text.

EOF
)  

