#!/bin/sh
# • L’architecture de votre système d’exploitation ainsi que sa version de kernel.

RESULT="Monitoring.sh starting routine"
RESULT=$RESULT'\n#Architecture:  '$(uname -a)

# • Le nombre de processeurs physiques. 
#can use lscpu to see bunch of relatif stuff too
#https://www.datacenters.com/news/what-is-a-vcpu-and-how-do-you-calculate-vcpu-to-cpu
# https://www.linkedin.com/pulse/understanding-physical-logical-cpus-akshay-deshpande/
# RESULT=$RESULT'\nThere is '$(nproc)' physical processors'
PROCESSOR_COUNT=$(lscpu | grep -m1 "Socket(s):" | cut -d ":" -f2 | tr -d ' ')
CPU_COUNT=$(lscpu | grep -m1 "CPU(s):" | cut -d ":" -f2 | tr -d ' ')
RESULT=$RESULT'\n#CPU physical : '$(($CPU_COUNT * $PROCESSOR_COUNT))

# • Le nombre de processeurs virtuels.
#https://www.looklinux.com/check-number-of-processor-vcpu-on-linux-virtual-private-server/

THREAD_PER_CPU_COUNT=$(lscpu | grep -m1 "Thread(s) per core:" | cut -d ":" -f2 | tr -d ' ')
# RESULT=$RESULT'\nThere is '$(cat /proc/cpuinfo | grep processor | wc -l)' virtual processors'
RESULT=$RESULT'\n#vCPU : '$(($CPU_COUNT * $PROCESSOR_COUNT * $THREAD_PER_CPU_COUNT))

# • La mémoire vive disponible actuelle sur votre serveur ainsi que son taux d’utilisation sous forme de pourcentage.

RESULT=$RESULT'\n#Memory Usage: '$(free -m | grep Mem | tr -s ' ' | cut -d ' ' -f3)/$(free -m | grep Mem | tr -s ' ' | cut -d ' ' -f2)'MB ('$(free | grep Mem | awk '{print $3/$2 * 100.0}')'%)'

# • La mémoire disponible actuelle sur votre serveur ainsi que son taux d’utilisation
# sous forme de pourcentage.

RESULT=$RESULT'\n#Disk Usage: '$(df --block-size=M / | grep / | tr -s ' ' | cut -d ' ' -f4)'b/'$( df --block-size=G / |grep / | tr -s ' ' | cut -d ' ' -f4)'b ('$(df --block-size=G / |grep / | tr -s ' ' | cut -d ' ' -f5)')'

# • Le taux d’utilisation actuel de vos processeurs sous forme de pourcentage.

RESULT=$RESULT'\n#CPU load: '$(top -b | grep MiB -m1 | tr -s ' ' |  awk '{print $8/$4 * 100.0}')'%'

# • La date et l’heure du dernier redémarrage.
RESULT=$RESULT'\n#Last boot: '$( who -b | tr -s ' ' | cut -d ' ' -f4)' '$( who -b | tr -s ' ' | cut -d ' ' -f5)

# • Si LVM est actif ou pas.
# https://askubuntu.com/questions/477/how-do-i-check-modify-lvm-state-on-a-pre-installed-system

# COUNT_ACTIF=$( lvs | grep -v "LV" | tr -s ' ' | cut -d ' ' -f 4 | grep a | wc -l)
COUNT_ACTIF=$( lsblk | grep "lvm" | wc -l)
RESULT=$RESULT'\n#LVM use: '
if [ $COUNT_ACTIF -eq 0 ] 
then
    RESULT=$RESULT"no"
else
    RESULT=$RESULT"yes"
fi

# • Le nombre de connexions actives.
# https://unix.stackexchange.com/questions/131785/regex-that-would-grep-numbers-after-specific-string

RESULT=$RESULT'\n#Connexions TCP : '$(ss -s | grep estab | grep -oP '(?<=estab )[0-9]+' )' ESTABLISHED'

# • Le nombre d’utilisateurs utilisant le serveur.
# https://www.golinuxcloud.com/list-check-active-ssh-connections-linux/

RESULT=$RESULT'\n#User log: '$(who | wc -l)

# • L’adresse IPv4 de votre serveur, ainsi que son adresse MAC (Media Access Control).

RESULT=$RESULT'\n#Network: IP '$(ip route | grep src | cut -d ' ' -f9)' ('$( cat /sys/class/net/enp0s3/address)')'

# • Le nombre de commande executées avec le programme sudo.
# RESULT=$RESULT'\n#Sudo : '$(sudo cat /var/log/sudo/auth.log | grep TTY | wc -l)' cmd'
RESULT=$RESULT'\n#Sudo : '$(sudoreplay -d /var/log/sudo/IO_logs -l | grep TTY | wc -l)' cmd'

# print

RESULT=$RESULT'\nEnd results.'
echo $RESULT | wall -n