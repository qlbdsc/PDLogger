#!/bin/bash

#Overlap with throw messages. throw_statement has had its variables parsed.
prompt_throw=$(cat <<EOF
Your task is to determine whether any log statement and any throw statement are semantically similar, describing the same issue or error. Differences in wording, style, tone, or level of detail should be disregarded.

If one or more matching pairs exist, list each pair using the exact format below. If no such pair exists, output N/A.

Let us think step by step,
Log statements:
$log

Throw statements:
$throw_statement

Relevant method context (target method, callees, and callers):
target method is:
$targetmethod
callees, and callers are:
$relatedmethod

output the result in the following format only:
If there is a match:
Log: [log statement]
Throw statement: [throw statement]
(Repeat the above block for each matching pair.)
Do not include method names, analysis explanations, or any other text.

If no match exists, only output without any other things:
N/A

EOF
)




#2. Contradictory Logs in an if-else Block.
echo "for if-else contrast"
prompt_else=$(cat <<EOF

I will provide you with source code that contains multiple methods. Please analyze the code according to the following instructions:

1. Identify all methods in the code.

2. For each method, find all if-else blocks.

3. Check whether both the if and else branches contain logging statements (e.g., log.info, log.debug, log.warn, log.error, etc.).

4. If both branches contain logs, determine whether the log messages express opposite or contrasting meanings.

5. If they do, output the result in the following format only:
[IF Block Log]: <log message from the if block>  
[ELSE Block Log]: <log message from the else block> 
[Opposite Meaning]: Yes 
Do not include method names, analysis explanations, or any other text.

If no semantically opposite log statements are found in all methods, only output without any other things:
N/A

Let us think step by step,
Relevant method context (target method, callees, and callers):
Target method is: $targetmethod
Related methods (callees/callers): $relatedmethod


EOF
)

#(Repeat the above block for each matching pair.)

python3 openai_demo.py --p "$prompt_else" > ./dedup_position/dedup_else/dedup_else_$method.txt
echo "$prompt_else" >./dedup_position/dedup_else_prompt/dedup_else_$method.txt


count=$(grep -o "\[Opposite Meaning\]: Yes" yourfile.txt | wc -l)

result_counter=$(($result_counter+$count))

log_level_value() {
  case "$1" in
    TRACE) echo 0 ;;
    DEBUG) echo 1 ;;
    INFO)  echo 2 ;;
    WARN)  echo 3 ;;
    ERROR) echo 4 ;;
    FATAL) echo 5 ;;
    *)     echo -1 ;;  # 未知级别
  esac
}

elsecode1=()
while IFS= read -r line; do

  elsecode1+=("$line")
done < <(sed -n 's/.*\[IF Block Log\]: *//p' ./dedup_position/dedup_else/dedup_else_$method.txt)

elsecode2=()
while IFS= read -r line; do
  elsecode2+=("$line")
done < <(sed -n 's/.*\[ELSE Block Log\]: *//p' ./dedup_position/dedup_else/dedup_else_$method.txt)



# 假设 elsecode1 和 elsecode2 已是数组
# 例如：从上一步 while-read 或 mapfile 得到的
# 注意：确保两个数组长度相同（或做额外判断）

for i in "${!elsecode1[@]}"; do
  code1="${elsecode1[$i]}"
  code2="${elsecode2[$i]}"

  # 提取 level，比如从 "...INFO(...)" 中提取 INFO
  level1=$(echo "$code1" | sed -n 's/.*\.\([^()]*\).*/\1/p')
  level2=$(echo "$code2" | sed -n 's/.*\.\([^()]*\).*/\1/p')

  # 转成大写并计算数值
  val1=$(log_level_value "${level1^^}")
  val2=$(log_level_value "${level2^^}")

  echo "第 $i 对比：$level1 vs $level2"

  if [ "$val1" -gt "$val2" ]; then
    echo "$level1 的级别更高"


logline=$(printf '%s\n' "$logline" | grep -v "$code2")

echo "code2:$code2"
echo "$code2" > else_tmp.txt
     sed -i '' '/^[[:space:]]*$/d' else_tmp.txt

if [ -f ./else_tmp.txt ]; then
grep -F -v -f ./else_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi

  elif [ "$val1" -lt "$val2" ]; then
    echo "$level2 的级别更高"


echo "code1:$code1"
echo "$code1" > if_tmp.txt
     sed -i '' '/^[[:space:]]*$/d' if_tmp.txt

if [ -f ./if_tmp.txt ]; then
grep -F -v -f ./if_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi

  else
    echo "两个级别相同"


echo "code1:$code1"
echo "$code1" > if_tmp.txt
     sed -i '' '/^[[:space:]]*$/d' if_tmp.txt

if [ -f ./if_tmp.txt ]; then
grep -F -v -f ./if_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi


  fi
done
echo "2. $result_counter"



#3. Start–End Log Pairs
echo "for logical dedup"
prompt_logical=$(cat <<EOF
I will provide you with a list of log statements. Your task is to analyze these logs and determine whether any two of them form the beginning and end of a logical phase.

Specifically:

1. Identify whether there exists a pair of logs such that:

1.1 The first log indicates the start of a logical process, operation, or phase.

1.2 The second log indicates the completion or end of that same process, operation, or phase.

2. If such a pair exists, extract and output the two log statements.

Please base your reasoning on the semantics of the messages, and common phrases that imply beginning (e.g., "starting", "initializing", "begin") and ending (e.g., "finished", "completed", "done", "successfully", etc.).

Output the result in the following format only, only output one pair:
Start Log: <the log message that indicates the beginning>
End Log: <the log message that indicates the end>
Do not include method names, analysis explanations, or any other text.

If no such pair can be confidently identified, only output without any other things:
N/A

Let us think step by step,

Now here are the logs to analyze:
$logline

Relevant method context (target method, callees, and callers):
target method is:
$targetmethod
callees, and callers are:
$relatedmethod

EOF
)

python3 openai_demo.py --p "$prompt_logical" > ./dedup_position/dedup_logical/dedup_logical_$method.txt
echo "$prompt_logical" >./dedup_position/dedup_logical_prompt/dedup_logical_$method.txt


if grep -q "N/A" ./dedup_position/dedup_logical/dedup_logical_$method.txt; then
    echo "File contains N/A"
else
    ((result_counter++))
    echo "File does NOT contain N/A"
fi

codestart=$(sed -n 's/.*Start Log: *//p' ./dedup_position/dedup_logical/dedup_logical_$method.txt)
codeend=$(sed -n 's/.*End Log: *//p' ./dedup_position/dedup_logical/dedup_logical_$method.txt)

start_line=$(grep -nF "$codestart" $file_pre | cut -d: -f1)
end_line=$(grep -nF "$codeend" $file_pre | cut -d: -f1)
python3 /mnt/storage/shengchenduan/joern-cli/dedup_postdom.py --p "$file_pre" --a $start_line --b $end_line --m $method > postdominate.txt
lastline=$(tail -n 1 postdominate.txt)
echo "$lastline"

levellog1=$(echo "$codestart" | sed -n 's/.*\.\([^()]*\).*/\1/p') #提取第一个.到第一个(的字符
levellog2=$(echo "$codeend" | sed -n 's/.*\.\([^()]*\).*/\1/p') #提取第一个.到第一个(的字符

if [ "$(echo "$levellog1" | tr '[:upper:]' '[:lower:]')" = "trace" ] || \
   [ "$(echo "$levellog2" | tr '[:upper:]' '[:lower:]')" = "trace" ]; then
    echo "log level is trace do nothing."
else
    if [ "$lastline" = "true" ]; then
    # sed -i '' "${start_line}s/.*/ /" $file_pre
    logline=$(printf '%s\n' "$logline" | grep -v "$start_line")

    echo "startline:$start_line"
    echo "$start_line" > start_tmp.txt
     sed -i '' '/^[[:space:]]*$/d' start_tmp.txt

if [ -f ./start_tmp.txt ]; then
    grep -F -v -f ./start_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
    mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi


    elif [ "$lastline" = "false" ]; then
        #通过gpt判断是否在如果在的话，删除
        echo "do nothing"
        # sed -i '' "${start_line}s/.*/ /" $file_pre
    else
    echo "未知值：$lastline"
    fi
fi
echo "3. $result_counter"



#4. Duplicate Semantics with Shared Variables
echo "for two similar log"
prompt_var=$(cat <<EOF
I will provide you with a list of log statements. Your task is to analyze them and determine whether there are any redundant log pairs based on their meaning and context. Follow these steps:

1. Identify whether any two log statements convey the same or very similar semantic meaning. If such logs appear together in the same Java file, they would be considered redundant.

2. If a redundant pair is found:
a. Check if the two logs share any common parameters or variables (e.g., path, userId, session).
b. If shared parameters exist, output:
- Redundant Log 1: the first log message
- Redundant Log 2: the second log message
- Shared Parameters: only one shared Parameters that you think most important.

3. If there are no shared parameters, then:
a. Determine which log is closer to the core logic or meaningful code context, such as important method calls, exception handling, or state changes
b. Output Retained Log and Discarded Log.

4. If there are multiple redundant log pairs, only output the one you consider the most important.

Semantic similarity between the log messages
Whether the logs reference the same or similar variables
Proximity to key code regions, such as try, catch, save, commit, process, or execute

Output the result in the following format only:

If shared parameters exist:
Redundant Log 1: [log message]
Redundant Log 2: [log message]
Shared Parameters: [parameter]

If no shared parameters:
Retained Log: [the log message closer to important logic]
Discarded Log: [the log message not retained]

Do not include method names, analysis explanations, or any other text.


If no redundant log pair is found, only output without any other things:
N/A

Let us think step by step,

Now here are the logs to analyze:
$logline

Relevant method context (target method, callees, and callers):
target method is:
$targetmethod
callees, and callers are:
$relatedmethod

EOF
)
export OPENAI_API_KEY="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"
python3 openai_demo.py --p "$prompt_var" > ./dedup_position/dedup_var/dedup_var_$method.txt
echo "$prompt_var" >./dedup_position/dedup_var_prompt/dedup_var_$method.txt
if grep -q "N/A" ./dedup_position/dedup_var/dedup_var_$method.txt; then
    echo "File contains N/A"
else
    ((result_counter++))
    echo "File does NOT contain N/A"
fi


log_var1=$(sed -n 's/.*Redundant Log 1: *//p' ./dedup_position/dedup_var/dedup_var_$method.txt)
log_var2=$(sed -n 's/.*Redundant Log 2: *//p' ./dedup_position/dedup_var/dedup_var_$method.txt)
common_var=$(sed -n 's/.*Shared Parameters: *//p' ./dedup_position/dedup_var/dedup_var_$method.txt)

line_var1=$(grep -n "^[[:space:]]*\$log_var1" $file_pre | head -n 1 | cut -d: -f1)
line_var2=$(grep -n "^[[:space:]]*\$log_var2" $file_pre | head -n 1 | cut -d: -f1)

Discarded_log=$(sed -n 's/.*Discarded Log: *//p' ./dedup_position/dedup_var/dedup_var_$method.txt)

if [ "$line_var1" -gt "$line_var2" ]; then
    templog=$log_var1
    log_var1=$log_var2
    log_var2=$templog
    temp=$line_var1
    line_var1=$line_var2
    line_var2=$temp
fi



python3 /mnt/storage/shengchenduan/joern-cli/dedup_var.py --p "$file_pre" --v $common_var --l $line_var1 --k $line_var2 > varidentify.txt
lastline_var=$(tail -n 1 varidentify.txt)
if [ "$lastline_var" = "true" ]; then
    # sed -i '' "${line_var1}s/.*/ /" $file_pre
    echo "log_var1:$log_var1"
    echo "$log_var1" > logvar1_tmp.txt
         sed -i '' '/^[[:space:]]*$/d' logvar1_tmp.txt

if [ -f ./logvar1_tmp.txt ]; then
    grep -F -v -f ./logvar1_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
    mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi


    elif [ "$lastline_var" = "false" ]; then
        #通过gpt判断是否在如果在的话，删除
        # sed -i '' "${line_var2}s/.*/ /" $file_pre

    echo "log_var2:$log_var2"
    echo "$log_var2" > logvar2_tmp.txt
         sed -i '' '/^[[:space:]]*$/d' logvar2_tmp.txt

if [ -f ./logvar2_tmp.txt ]; then
    grep -F -v -f ./logvar2_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
    mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi


    else
    echo "未知值: lastline_var"
fi



if [ "$Discarded_log" = "$log_var1" ]; then
    echo "$log_var1" > logvar1trace_tmp.txt
sed -i '' '/^[[:space:]]*$/d' logvar1trace_tmp.txt
if [ -f ./logvar1trace_tmp.txt ]; then

    grep -F -v -f ./logvar1trace_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
    mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi
    #放弃
    #sed -i '' "${line_var1}s/.*/ /" $file_pre
else
     echo "$log_var2" > logvar2trace_tmp.txt
     sed -i '' '/^[[:space:]]*$/d' logvar2trace_tmp.txt
if [ -f ./logvar2trace_tmp.txt ]; then

    grep -F -v -f ./logvar2trace_tmp.txt ./dedup_position/gtlogmessage.txt > ./dedup_position/gtlogmessage_filtered.txt
    mv ./dedup_position/gtlogmessage_filtered.txt ./dedup_position/gtlogmessage.txt

else
    echo "Error: ./start_tmp.txt does not exist"
fi

    #sed -i '' "${line_var2}s/.*/ /" $file_pre
fi
echo "4. $result_counter"




