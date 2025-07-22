#!/bin/bash

counter=0
result_counter=0
export result_counter
sum_union=0
sum_sp=0
sum_sgt=0
test_number=30
while IFS= read -r line; do
echo "$line"
cd /mnt/storage/shengchenduan/1twicetest
union=0
sp=0
sgt=0
precision=0
recall=0
echo start execution.....................
read -r package class method javapth<<< "$line"
new_package=$(echo "$package" | sed 's/\./\//g')
filename=$(echo "$javapth" | sed -n 's|.*hadoop-common-project/\([^/]*\)/.*|\1|p').txt
address=$javapth
echo $address
prefix_address=$(echo "$address" | sed 's/\.java.*$//')
address_beforesrc=${address%%/src*}
echo $address_beforesrc > file.txt

echo "method:$method "

#Used to merge multi-line log statements in the project into a single line.
python3 oneline.py --j ./${new_package}/${class}.java


#get method scope
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies_methodscope.jar -j "$javapth" -m "$method" > method_scope.txt
echo "/Users/scduan/Desktop/SCLogger/hadoop-trunk/hadoop-tools/hadoop-azure/src/main/java/"$new_package"/"$class".java"
read first second < method_scope.txt
echo "First: $first"
echo "Second: $second"


#get varlist
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies.jar -i "$address" -o varlist.txt -m "$method" -s ./file.txt -c /mnt/storage/shengchenduan/merged_classes.txt
VarList=$(cat varlist.txt)

#
sed -n "${first},${second}p" "$address" > funclog.txt


if [ $(grep -E '^\s*LOG\.' funclog.txt | wc -l) -ge 2 ]; then
    echo "match successful"

if [ ! -s "funclog.txt" ]; then
        echo "don't have target method aaaaaaaaaaaaa"
        continue  
fi


echo "${new_package}/${class}"




result=$method 

sed -i '1i\
public class A {
' funclog.txt

echo "}" >> funclog.txt 
awk '/^[[:space:]]*LOG\./ {print NR}' funclog.txt > groundtruthnum.txt

sed '/^[[:space:]]*LOG\./s/.*/ /' funclog.txt > funcnolog.txt

funcnolog=$(cat funcnolog.txt)


#abstract blocks
echo "blocktype start.........."
java -jar blockid-0.0.1-SNAPSHOT-jar-with-dependencies.jar -p funcnolog.txt > blcoktyoenum.txt
java -jar blockid-0.0.1-SNAPSHOT-jar-with-dependencies_block_linenum.jar -p funcnolog.txt > block_linenum.txt
awk '{print "line" NR, $0}' funcnolog.txt > numbered_funclog.txt
funccomment=$(cat numbered_funclog.txt)


echo '。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。callee start'
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies_log.jar -i /mnt/storage/shengchenduan/dataset/hadoop/hadoop_jars/"$filename" -p $package -c $class -m $method -d /mnt/storage/shengchenduan/dataset/hadoop/hadoop-3.3.6-src >callee.txt

echo '。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。。calleemethod start'
java -jar j2se-0.0.1-SNAPSHOT-jar-with-dependencies_prompt.jar -i /mnt/storage/shengchenduan/dataset/hadoop/hadoop_jars/"$filename" -p $package -c $class -m $method -d /mnt/storage/shengchenduan/dataset/hadoop/hadoop-3.3.6-src > calleemethod.txt
methodcode=$(cat calleemethod.txt)
sed 's/^\[//;s/\]$//' callee.txt > calleekuohao.txt
sed 's/}, /}\n/g' calleekuohao.txt > calleesort.txt





#get log slice
python3 log_methods_generator.py --cg /mnt/storage/shengchenduan/dataset/hadoop/hadoop_jars/"$filename" --output loggraph.txt
./splitloggraph.sh >splitloggraph.txt
comm -12 <(sort calleesort.txt) <(sort splitloggraph.txt) > log_matchmethod.txt
./methodfinder.sh
grep -E '^\s*LOG\.' log.txt >logwithspace.txt
sed 's/^[[:space:]]*//' logwithspace.txt > finalllog.txt
logslice=$(cat finalllog.txt)


funcsmu=$(cat "./funcsum/${result}_funcsum.txt")



sgt=$(wc -l < groundtruthnum.txt)
echo "sgt:"
echo $sgt

blocknum="blcoktyoenum.txt"
blocknumbers=()
while IFS= read -r line; do
    blocknumbers+=("$line")
done < "$blocknum"
echo "blocknumbers[0]"
echo "${blocknumbers[0]}"





#prompt for each kind of block
#branching block
type1=0
while ((type1<blocknumbers[0])); do
cd /mnt/storage/shengchenduan/1twicetest

((type1++))  
prompt1=$(cat <<EOF
you are a "Code Reviewer": "Ensures that the logic within each block is correct and that the placement of logs aligns with best practices for debugging and monitoring."

If I want to insert only one logging statement in the following code, please provide me with the line number of the position that you choose to insert a log.
A prerequisite is to not consider inserting a new log before or after the "throw" statement in source code.

**Overall Task:**  
You need to insert a log into the target method.
**Step-by-Step Instructions:**
0. **Locate Branching Block$type1: **
   - Identify the start and end lines of Branching Block$type1 based on the annotations provided in the target method. 
   - Use these annotations to determine the exact scope of the block before proceeding to the next steps.
1. **Identify Inner Blocks:**
   - Locate the inner blocks that are nested within Branching Block$type1 itself (e.g., inner if, try-catch, loop, etc. inside it).  
   - Do not insert a log inside inner blocks nested within Branching Block$type1.
Note: This restriction only applies to inner blocks within Branching Block$type1.
Even if Branching Block$type1 itself is nested inside some other outer block, you may still consider inserting a log for it — as long as the log is placed outside its own inner blocks.
2. **Determine Log Requirement:**  
   - Determine whether a log need to be inserted for Branching Block$type1.
   - Base your decision on the following criteria.
3. **Choose Log Insertion Positions:**  
   - If a log is required, select the appropriate positions for insertion.
   - If both the if block and else block of  Branching Block$type1 require a log, If  you think both the block and else block of Branching Block$type1 require a log, you may provide two line numbers separated by a comma: one for the if block and one for the else block.
4. **Handle No Log Requirement:**  
   - If no log is required for Branching Block$type1, respond with "N/A" for position choice and quality score.

When you determine whether a log need to be inserted for Branching Block$type1, please evaluate according to the following standard:
Logs should capture events that directly influence the program‘s behavior and outcomes, such as critical resource management, exception handling, and key method branches. Special attention should be given to logs placed after failure conditions or when the behavior has a direct effect on program execution (e.g., deletion failures).
Redundant logs refer to the repetition of identical or similar information, which can cause log files to become too large and difficult to analyze. Additionally, frequent logging, especially in high-frequency operations, can introduce performance overhead and affect system responsiveness. This is particularly important for logs capturing the same event, such as re-logging exceptions that have already been logged at a higher level.
If a log is frequently recorded, it could have performance implications, especially if the event occurs in high-frequency operations like loops.

Let us think step by step,
The target method is blow:
$funccomment 
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

echo "$prompt1" >./multicase_result_new${test_number}/prompt/"${result}_branch_${type1}_prompt.txt"
export OPENAI_API_KEY="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"
python3 openai_demo.py --p "$prompt1" > ./multicase_result_new${test_number}/"${result}_branch_${type1}.txt"


line1=$(grep -i "^Line number of position choice:" "./multicase_result_new${test_number}/"${result}_branch_${type1}.txt"")

position1=($(echo "$line1" | grep -oE '[0-9]+'))
length1=${#position1[@]}
((sp=sp+length1))
echo "position1:"
echo $position1
check=0
echo "type1:$type1"
for p1 in "${position1[@]}"; do
if grep -q -E "^$((p1+1))$|^$((p1+2))$|^$((p1-1))$|^$((p1-2))$|^$p1$" "./groundtruthnum.txt"; then
        matched_value=$(grep -E "^$((p1+1))$|^$((p1+2))$|^$((p1-1))$|^$((p1-2))$|^$p1$" "./groundtruthnum.txt")
        echo "matched value: "$matched_value

        closest_value=""
        min_diff=999999
        for value in $matched_value; do
            diff=$(($value - $p1))
            diff=${diff#-}  # 取绝对值
            if ((diff < min_diff)); then
                min_diff=$diff
                closest_value=$value
            fi
        done
        echo "closest_value: "$closest_value

        
        ((union++))
        
else
    fp_linenum=$(($first+$p1-1))
fi

done


echo "union: "$union
echo "branching blcok"
echo $type1
done






# #try-catch block
type2=0
echo "The blocknumbers[2] is: ${blocknumbers[1]}"
while (( type2<blocknumbers[1] )); do
    ((type2++))
    prompt2=$(cat << EOF 
From now on, you are an excellent Log Position Evaluator described as Evaluates where logs should be inserted within code blocks, analyzing branching and method execution paths for optimal log placement. 
Complete following instruction while staying in strict accordance with the nature of the provided identity:

**Overall Task:**  
You need to insert logs into the target method.
**Step-by-Step Instructions:**  
1. **Identify Inner Blocks:**
   - Identify the scope of Try-Catch Block$type2.
   - An inner block refers to a code block whose scope is completely enclosed within the scope of Try-Catch Block$type2. Please interpret and respond based on this definition.
   - Locate the inner blocks within the Try-Catch Block$type2. Exclude the Try and Catch blocks of Try-Catch Block$type2 itself.
   - Determine whether the scope of the inner block is enclosed within the scope of Try-Catch Block$type2. If not, just respond with "N/A".
   - Do not insert logs within the scope of these inner blocks.
   - If do not have inner blocks, just respond with "N/A".
2. **Determine Log Requirement:**  
   - Assess whether logs need to be inserted for Try-Catch Block$type2.  
   - Specify how many logs are required.
   - If you think Try-Catch Block$type2 do not need a log, just respond with N/A.
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
$funccomment 
Let’s think step by step. First, 
$methodcode 
Second, 
$funcsmu
Thirdly,the variable list is:
$VarList

Please provide answers without any surrounding symbols or formatting. For example, respond with '9' instead of '[9]' or '(9)' to ensure the answer is plain and unembellished.
Please strictly follow the specified output format below and do not give me other information:
Block Name: [Name of the block]
Determine Whether Log is Needed: [Yes/ N/A]
Line Number of Position Choice: [Line number]
Chain-of-Thought: [Explain your reasoning]
Quality Score of the Position Choice: [Score, 1-10]
Sub-Score for the Quality Score: [Explanation for the sub-score]
Do not add any extra text, explanations, or symbols beyond the required output.

EOF
)
echo "$prompt2" >./multicase_result_new${test_number}/prompt/"${result}_trycatch_${type1}_prompt.txt"
export OPENAI_API_KEY="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"
python3 openai_demo.py --p "$prompt2" > ./multicase_result_new${test_number}/"${result}_Try-catch_${type2}.txt"


line2=$(grep -i "^Line Number of Position Choice:" "./multicase_result_new${test_number}/${result}_Try-catch_${type2}.txt")
position2=($(echo "$line2" | grep -oE '[0-9]+'))
length2=${#position2[@]}
((sp+length2))
check=0
for p2 in "${position2[@]}"; do

    if grep -q -E "^$((p2+1))$|^$((p2+2))$|^$((p2-1))$|^$((p2-2))$|^$p2$" "./groundtruthnum.txt"; then
        matched_value_2=$(grep -E "^$((p2+1))$|^$((p2+2))$|^$((p2-1))$|^$((p2-2))$|^$p2$" "./groundtruthnum.txt")
        echo $matched_value_2

        closest_value=""
        min_diff=999999
        for value in $matched_value_2; do
            diff=$(($value - $p2))
            diff=${diff#-}  # 取绝对值
            if ((diff < min_diff)); then
                min_diff=$diff
                closest_value=$value
            fi
        done
        ((union++))
        
       linenum1_try=$(($closest_value+$first-1))



else
    fp_linenum=$(($first+$p2-1))        
fi
done

echo $union
done






cd /Users/scduan/Desktop/SCLogger/callgraph_file_selection/1twicetest/
#Looping Block
type3=0
while (( type3<blocknumbers[2] )); do
    
    ((type3++)) 
    prompt3=$(cat << EOF 
From now on, you are an excellent Log Position Evaluator described as Evaluates where logs should be inserted within code blocks, analyzing branching and method execution paths for optimal log placement. 

Complete following instruction while staying in strict accordance with the nature of the provided identity:

**Overall Task:**  
You need to insert only one log into the target method.
**Step-by-Step Instructions:**  
1. **Identify Inner Blocks:**
    - Locate the inner blocks within Looping Block$type3.
    - Do not insert logs within the scope of these inner blocks.
2. **Determine Log Requirement:**  
   - Assess whether a log needs to be inserted for Looping Block$type3. If no log is required for Looping Block$type3, respond with N/A for all answers.
3. **Choose a Log Insertion Position:**  
   - If a log is required in Looping block, select the appropriate positions for insertion.
4. **Handle No Log Requirement:**  
   - If no log is required for Looping Block$type3, respond with N/A for all answers.

The target method is blow：
$funccomment 
Let’s think step by step. First, 
$methodcode 
Second, 
$funcsmu
Thirdly,the variable list is:
$VarList

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
echo "$prompt3" >./multicase_result_new${test_number}/prompt/"${result}_loop_${type1}_prompt.txt"
export OPENAI_API_KEY="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"

python3 openai_demo.py --p "$prompt3" > ./multicase_result_new${test_number}/"${result}_looping_${type3}.txt"

line3=$(grep -i "^Line number of position choice:" "./multicase_result_new${test_number}/${result}_looping_${type3}.txt")
position3=($(echo "$line3" | grep -oE '[0-9]+'))
length3=${#position3[@]}
((sp+length3))
check=0
for p3 in "${position3[@]}"; do
echo $p3
    if grep -q -E "^$((p3+1))$|^$((p3+2))$|^$((p3-1))$|^$((p3-2))$|^$p3$" "./groundtruthnum.txt"; then
        matched_value_3=$(grep -E "^$((p3+1))$|^$((p3+2))$|^$((p3-1))$|^$((p3-2))$|^$p3$" "./groundtruthnum.txt")
        echo $matched_value_3

        closest_value=""
        min_diff=999999
        for value in $matched_value_3; do
            diff=$(($value - $p3))
            diff=${diff#-}  # 取绝对值
            if ((diff < min_diff)); then
                min_diff=$diff
                closest_value=$value
            fi
        done
        ((union++))
        


    linenum1_loop=$(($closest_value+$first-1))

        if [ -z "$linenum1_loop" ]; then
            echo "变量 linenum1_loop 不存在或为空"
            break
        fi
        
else
    fp_linenum=$(($first+$p3-1))

fi
done


echo $union
done





#Method Declaration Block
type4=0
while (( type4<blocknumbers[3] )); do
    
    ((type4++)) 
prompt4=$(cat <<EOF 
From now on, you are an excellent Log Position Evaluator described as Evaluates where logs should be inserted within code blocks, analyzing branching and method execution paths for optimal log placement.
Complete following instruction while staying in strict accordance with the nature of the provided identity:

**Overall Task:**
You need to insert only one log into the target method.
**Step-by-Step Instructions:**
1. **Identify Inner Blocks:**
- Locate the inner blocks within Method Declaration Block$type4.
- Do not insert logs within the scope of these inner blocks.
2. **Determine Log Requirement:**
- Assess whether a log need to be inserted for Method Declaration Block$type4.
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
- If additional log is unnecessary , no log positions need to be provided.
6. **Handle No Log Requirement:**
- If no log is required for Method Declaration Block$type4, respond with N/A.

The target method is blow：
$funccomment 
Let’s think step by step. First, 
$methodcode 
Second, 
$funcsmu
Thirdly,the variable list is:
$VarList

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
echo "$prompt4" >./multicase_result_new${test_number}/prompt/"${result}_MD_${type1}_prompt.txt"
export OPENAI_API_KEY="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"
python3 openai_demo.py --p "$prompt4" > ./multicase_result_new${test_number}/"${result}_declaration_${type4}.txt"

line4=$(grep -i "^Line Number of Position Choice:" "./multicase_result_new${test_number}/${result}_declaration_${type4}.txt")
position4=($(echo "$line4" | grep -oE '[0-9]+'))
length4=${#position4[@]}
((sp+length4))
check=0
for p4 in "${position4[@]}"; do
    position4=$(echo "$position4" | tr -d ' ')
    if grep -q -E "^$((p4+1))$|^$((p4+2))$|^$((p4-1))$|^$((p4-2))$|^$p4$" "./groundtruthnum.txt"; then
        matched_value_4=$(grep -E "^$((p4+1))$|^$((p4+2))$|^$((p4-1))$|^$((p4-2))$|^$p4$" "./groundtruthnum.txt")
        echo $matched_value_4

        closest_value=""
        min_diff=999999
        for value in $matched_value_4; do
            diff=$(($value - $p4))
            diff=${diff#-}
            if ((diff < min_diff)); then
                min_diff=$diff
                closest_value=$value
            fi
        done
        ((union++))
        tr -d ' ' < funclog.txt > funlog_nospace.txt
        linenum1_MD=$(($closest_value+$first-1))



        if [ -z "$linenum1_MD" ]; then
            echo "变量 linenum1 不存在或为空"
            break
        fi
       
  echo "MD_linum:$linenum1_MD"


else
    fp_linenum=$(($first+$p4-1))
fi
done

done


cat funlog_nospace.txt > ./function_nospace/${result}.java

cat funclog.txt > ./function/${result}.java
rm log.txt
 else
     echo "匹配失败"
 fi

((sum_sgt=sum_sgt+sgt))
((sum_sp=sum_sp+sp))
((sum_union=sum_union+union))

echo $sum_sgt
echo $sum_sp
echo "union: "$sum_union
echo "运行结束..."
done < pcmoutputcase.txt
echo $sum_sgt
echo $sum_sp
echo $sum_union
