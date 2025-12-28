#!/usr/bin/env bash

# This CLI tool is designed to make stress testing on problems solutions writed in C++

GENERATOR="/usr/local/lib/cputil/genrand-tc"

if [ ! -x "$GENERATOR" ]; then
    GENERATOR="/usr/lib/cputil/genrand-tc"
fi

if [ ! -x "$GENERATOR" ]; then
    echo "Error: internal generator not found."
    exit 1
fi



# Defalt settings
LIMITS="1 100"
NUM_TESTS=1      
STRESS_ROUNDS=1 
NUM_PER_LINE=1
SHOW_TIME=false
CUSTOM_GENERATOR="" 

show_help() {
    echo "cputil: A simple tool to test your problems solutions"
    echo "Usage: cputil [options] <test-solution> <bruteforce-solution>"
    echo "Options:"
    echo "  -h               Show this help message"
    echo "  -g <file>        Use a custom generator file (overrides internal generator)"
    echo "  -l <num> <num>   Define limits of the generated values [default = "1 100"]"
    echo "  -t <num>         Set the number of test cases (T inside the file) [default = 1]"
    echo "  -r <num>         Set the number of stress rounds (How many times to run)"
    echo "  -i <num>         Set how many numbers will be generated per line [default = 1]"
    echo "  -s               Show time taken to run both solutions"
    echo ""
    echo "Exemple:"
    echo "  cputil -l "1 1e6" -r 100 -t 1 -g my_generator.cpp solution.cpp brute.cpp"
    exit 0
}

# Load defaults from config file
config_file=~/.cputilrc
if [ -f "$config_file" ]; then
    source "$config_file"
fi

while getopts "hg:l:t:r:i:s" opt; do
    case $opt in
        h) 
            show_help 
            ;;
        g)
            CUSTOM_GENERATOR=$OPTARG
            ;;
        l) 
            LIMITS=$OPTARG 
            ;;
        t) 
            NUM_TESTS=$OPTARG 
            ;;
        r)
            STRESS_ROUNDS=$OPTARG
            ;;
        i) 
            NUM_PER_LINE=$OPTARG 
            ;;
        s) 
            SHOW_TIME=true 
            ;;
        \?) 
            echo "Invalid Option: -$OPTARG" >&2
            exit 1
            ;;
    esac
done

shift $((OPTIND -1))

SOLUTION=$1
BRUTEFORCE=$2

if [ -z "$SOLUTION" ] || [ -z "$BRUTEFORCE" ]; then
    echo "Error: No valid files provided."
    echo "Use -h for help."
    exit 1
fi

if [ ! -f "$SOLUTION" ]; then
    echo "Error: Solution file '$SOLUTION' not found."
    exit 1
fi

if [ ! -f "$BRUTEFORCE" ]; then
    echo "Error: Bruteforce file '$BRUTEFORCE' not found."
    exit 1
fi

if [ -n "$CUSTOM_GENERATOR" ]; then
    if [ ! -f "$CUSTOM_GENERATOR" ]; then
        echo "Error: Custom generator file '$CUSTOM_GENERATOR' not found."
        exit 1
    fi
fi

# Visual Feedback 
echo "--- Final Config ---"
echo "Solution: $SOLUTION"
echo "Brute:    $BRUTEFORCE"
if [ -n "$CUSTOM_GENERATOR" ]; then
    echo "Generator:$CUSTOM_GENERATOR (Custom)"
else
    echo "Generator:Internal"
    echo "Limits:   $LIMITS"
    echo "N/Line:   $NUM_PER_LINE"
fi
echo "T (Cases):$NUM_TESTS"
echo "Rounds:   $STRESS_ROUNDS"
echo "Timing:   $SHOW_TIME"
echo "--------------------------"

CXX="g++"
CXXFLAGS="-O2 -std=c++17"

compile_file() {
    local source_file=$1
    local output_bin=$2
    
    echo -n "Compiling $source_file... "
    
    $CXX $CXXFLAGS "$source_file" -o "$output_bin"
    
    if [ $? -eq 0 ]; then
        echo -e "\033[0;32mOK\033[0m" 
    else
        echo -e "\033[0;31mFALHA\033[0m" 
        echo "Erro ao compilar $source_file. Verifique o código."
        exit 1
    fi
}
# Names of the binaries
BIN_SOL="./.bin_sol"
BIN_BRUTE="./.bin_brute"
BIN_GEN="./.bin_gen"

compile_file "$SOLUTION" "$BIN_SOL"
compile_file "$BRUTEFORCE" "$BIN_BRUTE"

if [ -n "$CUSTOM_GENERATOR" ]; then
    compile_file "$CUSTOM_GENERATOR" "$BIN_GEN"
fi

IN_FILE=".input"
OUT_SOL=".out_sol"
OUT_BRUTE=".out_brute"

echo "Starting Tests ($STRESS_ROUNDS rounds)..."

PASSED=true

for ((i=1; i<=STRESS_ROUNDS; i++)); do
    if [ -n "$CUSTOM_GENERATOR" ]; then
        $BIN_GEN "$i" "$NUM_TESTS" "$LIMITS" "$NUM_PER_LINE" > "$IN_FILE"
    else
        "$GENERATOR" "$i" "$NUM_TESTS" "$LIMITS" "$NUM_PER_LINE" > "$IN_FILE"
    fi

    # Timing Start
    if [ "$SHOW_TIME" = true ]; then start_time=$(date +%s%N); fi
    
    $BIN_SOL < "$IN_FILE" > "$OUT_SOL"
    
    # Timing End
    if [ "$SHOW_TIME" = true ]; then
        end_time=$(date +%s%N)
        duration=$(( (end_time - start_time) / 1000000 ))
    fi
    
    $BIN_BRUTE < "$IN_FILE" > "$OUT_BRUTE"

    if ! diff -w -q "$OUT_SOL" "$OUT_BRUTE" > /dev/null; then
        echo -e "\n\033[0;31m[WRONG ANSWER] Fail on round #$i\033[0m"

        echo -e "\033[1;33m=== INPUT (Top 50 lines) ===\033[0m"

        head -n 50 "$IN_FILE"
        if [ $(wc -l < "$IN_FILE") -gt 50 ]; then echo "... (truncated)"; fi

        echo -e "\n\033[1;33m=== DIFF ( < Your Solution | > Bruteforce ) ===\033[0m"
        diff -w --color=always "$OUT_SOL" "$OUT_BRUTE"

        PASSED=false
        break
    fi  
    if [ "$SHOW_TIME" = true ]; then
        echo -ne "Round $i/$STRESS_ROUNDS [${duration}ms] \r"
    else
        echo -ne "Round $i/$STRESS_ROUNDS \r"
    fi

done

echo ""

# Cleanup
if [ "$PASSED" = true ]; then
    echo -e "\033[0;32m[SUCCESS] Passed all $STRESS_ROUNDS rounds!\033[0m"
    rm -f "$IN_FILE" "$OUT_SOL" "$OUT_BRUTE" "$BIN_SOL" "$BIN_BRUTE" "$BIN_GEN"
else
    rm -f "$BIN_SOL" "$BIN_BRUTE" "$BIN_GEN"
fi
