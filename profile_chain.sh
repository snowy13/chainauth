#!/bin/bash
case $# in
    2 ) p=$2; n=$1;;
    1 ) p=10, n=$1;;
    * ) n=10; p=10;;
esac

total=$n
cpu_total=0; max_cpu=0; min_cpu=100
mem_total=0; max_mem=0; min_mem=100

greaterthan() {
    if [ 1 -eq "$(echo "$1 > $2" | bc)" ]
    then 
        return 0
    else
        return 1
    fi
}

lessthan() {
    if [ 1 -eq "$(echo "$1 < $2" | bc)" ]
    then 
        return 0
    else
        return 1
    fi
}

printf "%-10s %10s %10s\n" "" "%CPU" "%mem"
while :
do
    set $(ps --format %cpu,%mem -p $(pidof erisdb) --no-headers)
    cpu=$1; mem=$2
    printf "%-10s %10s %10s\n" "($(($total-$n+1)))" $cpu $mem

    # Max and min CPU update
    if greaterthan $cpu $max_cpu; then
        max_cpu=$cpu
    fi
    if lessthan $cpu $min_cpu; then
        min_cpu=$cpu
    fi
    # Max and min memory update
    if greaterthan $mem $max_mem; then
        max_mem=$mem
    fi
    if lessthan $mem $min_mem; then
        min_mem=$mem
    fi
    # Update total 
    cpu_total=$(echo "$cpu_total+$cpu" | bc)
    mem_total=$(echo "$mem_total+$mem" | bc )
    n=$(($n - 1))
    if [ $n -eq 0 ]; then
        break
    fi
    sleep $p
done

# Calaculate avg.
cpu_avg=$(echo "scale=2; $cpu_total/$total" | bc)
mem_avg=$(echo "scale=2; $mem_total/$total" | bc)
cpu_per2phy() {
    local phy_cpu=$(sudo cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq)
    echo "scale=2; $1 * ($phy_cpu/100)" | bc
}
mem_per2phy() {
    local phy_mem=$(cat /proc/meminfo | grep MemTotal | cut -d ":" -d ":" -f 2 | tr -s ' ' | cut -d ' '  -f 2)
    echo "scale=2; $1 * ($phy_mem/100)" | bc
}

echo "Summarize Usage of erisdb"
printf "%-10s %10s %10s\n"  "avg." $cpu_avg $mem_avg
printf "%-10s %10s %10s\n" "max" $max_cpu $max_mem
printf "%-10s %10s %10s\n" "min" $min_cpu $min_mem

echo "Normalized cpu (khz) and memory (kB) info"
printf "%-10s %10s %10s\n"  "avg." $(cpu_per2phy $cpu_avg) $(mem_per2phy $mem_avg)
printf "%-10s %10s %10s\n" "max" $(cpu_per2phy $max_cpu) $(mem_per2phy $max_mem)
printf "%-10s %10s %10s\n" "min" $(cpu_per2phy $min_cpu) $(mem_per2phy $min_mem)

exit 0
