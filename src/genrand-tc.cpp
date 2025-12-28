#include <cstdlib>
#include <iostream>
#include <sstream>
#include <utility>

// This program can generate random values for stress testing problems solutions 

// This function Generate random values in a certain range
long long gen_rand_in_range(long long a, long long b){
    if(a > b) std::swap(a, b);
    long long value = a + rand() % (b - a + 1);
    return value;
}

/* argv[1] needs to be the seed for generate values
 * argv[2] needs to be the number of test cases
 * argv[3] needs to be the inferior and superior limit of the range
 * argv[4] needs to be the amount of numbers that needs to be generated for each test case
 *
 * */
int main(int argc, char* argv[]){
    srand(atoi(argv[1]));

    long long t = atoi(argv[2]);
    long long min, max;
    std::stringstream ss(argv[3]);
    ss >> min >> max;
    long long n = atoi(argv[4]);
    for(long long i = 0; i < t; i++){
        for(long long i = 0; i < n; i++){
            std::cout << gen_rand_in_range(min, max) << " ";    
        }
        std::cout << "\n";
    }
}
