nim arm
ssh oracle killall screen
set -e
scp src/main oracle:~/250
ssh oracle "screen -d -m ~/250/main"
