# Read input arguments: target line number, file path, and file name
linenum=$1
file_path=$2
file=$3
echo $file_path

# If merged dot file already exists, skip the process. To save time
if [[ -f "./merged/${file}_merged.dot" ]]; then
    echo "file exit"
else
    echo "file not exit"

    # Generate call graph using import.py
    python3 import.py $file_path > cg.txt

    # Filter call graph output
    sed -n '/callgraph:/,$p' cg.txt > cgfilter.txt

    # Extract caller methods
    awk -F',' '{print substr($0, 2, index($0, ",") - 2)}' cgfilter.txt > caller.txt
    sed -i '' '1d' caller.txt

    # Store caller list into an array
    callerarray=()
    while IFS= read -r line; do
        callerarray+=("$line")
    done < caller.txt

    # Extract callee methods
    sed -n 's/.*List(\([^)]*\)).*/\1/p' cgfilter.txt > callee.txt
    calleearray=()
    while IFS= read -r line; do
        calleearray+=("$line")
    done < callee.txt

    # Generate PDG (Program Dependence Graph) using Joern
    ./joern-parse $file_path
    ./joern-export /Users/scduan/bin/joern/joern-cli/cpg.bin --repr pdg --out ./pdg/${file}

    # Merge PDG .dot files into one
    > ./merged/${file}_merged.dot
    echo "111"
    for dot_file in ./pdg/${file}/*.dot; do
        sed '1d;$d' $dot_file >> ./merged/${file}_merged.dot
    done
    echo "222"

    # Add DOT graph header
    sed -i '' '1s/^/digraph merged_graph {\n/' ./merged/${file}_merged.dot
    touch subcall.txt

    echo "length of the array: ${#calleearray[@]}"

    # Clear subcall.txt
    > subcall.txt

    # Match callee with graph nodes
    for element in "${calleearray[@]}"; do
        echo "$element"
        line_number=$(grep -n "\"$element\" \[label = <" ./merged/${file}_merged.dot | cut -d: -f1 | head -n1)
        echo $line_number
        result=$(awk -v line="$line_number" 'NR == line + 1' ./merged/${file}_merged.dot)
        return_value=$(echo "$result" | awk -F'"' '{print $2}')
        echo ' "'"$return_value"'"'>>subcall.txt
    done

    # Add CDG (Control Dependence Graph) labels
    > subcall2.txt
    echo "subucall2"
    for element2 in "${callerarray[@]}"; do
        echo '-> "'"$element2"'"  [ label = "CDG: "];'>>subcall2.txt
    done
    echo "array length of caller: ${#callerarray[@]}"

    # Combine subcall and CDG info
    paste -d ' ' subcall.txt subcall2.txt > callg.txt
    sed -i '' '/^ ""/d' callg.txt
    sed -i '' 's/^/ /' callg.txt 
    cat callg.txt >> ./merged/${file}_merged.dot
    echo "}" >> ./merged/${file}_merged.dot

    # Clean up temp files
    rm subcall2.txt
    rm subcall.txt
fi

# Create result directory and output file
cd result
mkdir ${file}_merged.dot
cd ..
touch output.txt

# Create placeholder output lines equal to Java file line count
javanum=$(wc -l < $file_path | tr -d ' ')
echo $javanum
for ((i=0; i<javanum; i++)); do
    echo "" >> output.txt
done

# Create temporary file for results
touch logsl.txt

# Move to merged directory to locate graph node by line number
cd /mnt/aaa/bin/joern/joern-cli/merged
echo "${file}_merged.dot"
if grep -q "\<${linenum}<BR/>" "${file}_merged.dot"; then
    echo "2223333333333"
    
    # Locate node corresponding to target line number
    grep "${linenum}<BR/>" "${file}_merged.dot" > "${file}.txt"
    while IFS= read -r line; do
        cd merged
        nodenumber=$(echo "$line" | awk -F '"' '{print $2}')
        echo "$nodenumber"

        # Extract backward slice from the node
        python3 bl_limit.py -n $nodenumber -d "${file}_merged.dot"
        cd /Users/scduan/bin/joern/joern-cli
        awk -F'<BR/>' '{print $1}'  /Users/scduan/bin/joern/joern-cli/result/${file}_merged.dot/${nodenumber}lable.txt > mid_line.txt
        awk -F ', ' '{print $NF}' mid_line.txt > lineu.txt
        sed -i '' '/^[^0-9]/d' lineu.txt
        cat lineu.txt > ./backwardlinenum/${file}_${linenum}.txt

        # Store unique line numbers
        linenumber=()
        sort lineu.txt | uniq > temp.txt && mv temp.txt lineu.txt
        while IFS= read -r line; do
            linenumber+=("$line")
        done < lineu.txt
    done < "${file}.txt"
fi

# Final cleanup
cd /Users/scduan/bin/joern/joern-cli
rm output.txt
rm -r ./pdg/${file}
echo "backward slice finish"

