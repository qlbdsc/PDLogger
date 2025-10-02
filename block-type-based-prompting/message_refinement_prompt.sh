prompt_message_refine=$(cat <<EOF
You are a highly skilled Java developer with 15 years of experience, specializing in adding impactful logs for debugging. Your expertise ensures optimal log placement and message refinement.

Instruction:
I want to insert exactly one logging statement using SLF4J at line $closest_value of the Target method. Please provide the complete logging statement.


Let us think step by step,
The target method is below:
Target method:
$function_with_annotation

Let’s think step by step. 

First, the caller methods and callee methods of target method are:
$methodcode

Second, the succeeding and proceeding logs are:
$logslice

Finally, The backward slice of the selected line is:
"$backwardslice"
backward slice contains the dependency path of the selected line which represents the control and data dependencies.

Strict Output Format:
Provide answers without any surrounding symbols, formatting, or extra explanations. Your response should strictly follow this format:
Block Name: #
Detailed Chain-of-Thought: #
Completed Log: #
Do not add any extra text, explanations, or symbols beyond the required output.
EOF
)
