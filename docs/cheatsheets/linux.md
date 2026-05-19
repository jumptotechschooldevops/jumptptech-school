# Linux Cheatsheet

## Navigation

```bash
pwd                    # current directory
ls -la                 # list files (long, all)
ls -lhS                # sort by size, human readable
cd -                   # previous directory
cd ~                   # home directory
```

## File operations

```bash
cp file dest           # copy file
cp -r dir/ dest/       # copy directory recursively
mv file dest           # move/rename
rm file                # delete file
rm -rf dir/            # delete directory (DESTRUCTIVE)
mkdir -p a/b/c         # create nested directories
touch file.txt         # create empty file or update timestamp
ln -s target link      # create symbolic link
ln target link         # create hard link
```

## Viewing files

```bash
cat file.txt           # print file
less file.txt          # paged view (q to quit, / to search)
head -20 file.txt      # first 20 lines
tail -20 file.txt      # last 20 lines
tail -f /var/log/syslog  # follow live (like streaming)
wc -l file.txt         # count lines
wc -w file.txt         # count words
```

## Searching

```bash
grep "pattern" file.txt           # search in file
grep -r "pattern" /path/          # recursive search
grep -i "pattern" file.txt        # case insensitive
grep -n "pattern" file.txt        # show line numbers
grep -v "pattern" file.txt        # invert match (lines without pattern)
grep -E "regex" file.txt          # extended regex
grep -l "pattern" *.txt           # only show filenames

find . -name "*.py"               # find by name
find . -type f -name "*.log"      # files only
find . -type d                    # directories only
find . -mtime -7                  # modified in last 7 days
find . -size +100M                # larger than 100MB
find . -name "*.tmp" -exec rm {} \;  # find and delete
```

## Text processing

```bash
sort file.txt                     # sort alphabetically
sort -n file.txt                  # sort numerically
sort -rn file.txt                 # reverse numeric sort
sort -k2 file.txt                 # sort by 2nd column
uniq file.txt                     # remove consecutive duplicates
sort file.txt | uniq              # remove all duplicates
uniq -c file.txt                  # count occurrences

cut -d: -f1 /etc/passwd           # get 1st field (delimiter :)
cut -d, -f2,4 data.csv            # fields 2 and 4

awk '{print $1}' file.txt         # print 1st column
awk -F: '{print $1}' /etc/passwd  # custom delimiter
awk '{sum += $1} END {print sum}' numbers.txt  # sum a column

sed 's/old/new/g' file.txt        # replace all occurrences
sed -i 's/old/new/g' file.txt     # in-place replacement
sed -n '10,20p' file.txt          # print lines 10-20
sed '/^#/d' file.txt              # delete comment lines

tr 'a-z' 'A-Z'                    # translate lowercase to uppercase
tr -d '\r'                        # remove carriage returns
tr -s ' '                         # squeeze multiple spaces to one
```

## Pipes and redirection

```bash
cmd1 | cmd2               # pipe stdout of cmd1 to cmd2
cmd1 2>&1 | cmd2          # pipe stdout + stderr
cmd > file.txt            # redirect stdout to file (overwrite)
cmd >> file.txt           # redirect stdout to file (append)
cmd 2> error.log          # redirect stderr
cmd > out.txt 2>&1        # both stdout and stderr to file
cmd < input.txt           # use file as stdin
cmd1 && cmd2              # run cmd2 only if cmd1 succeeds
cmd1 || cmd2              # run cmd2 only if cmd1 fails
cmd1; cmd2                # run both, regardless of exit code
```

## Permissions

```bash
chmod 644 file            # rw-r--r--
chmod 755 script.sh       # rwxr-xr-x
chmod 600 key.pem         # rw-------
chmod +x script.sh        # add execute for all
chmod u+x, g-w file       # add execute for user, remove write for group

chown user file           # change owner
chown user:group file     # change owner and group
chown -R user:group dir/  # recursive

umask 022                 # default umask (022 → 644 files, 755 dirs)
```

## Processes

```bash
ps aux                    # all processes
ps aux | grep nginx        # find specific process
top                        # interactive process monitor
htop                       # better interactive monitor
pgrep nginx                # find PIDs by name
pkill nginx                # kill by name

kill PID                   # send SIGTERM (polite)
kill -9 PID                # send SIGKILL (force)
kill -HUP PID              # send SIGHUP (reload)
killall nginx              # kill all nginx processes

cmd &                      # run in background
jobs                       # list background jobs
fg %1                      # bring job 1 to foreground
nohup cmd > out.log 2>&1 & # survive shell exit
```

## Disk & memory

```bash
df -h                      # filesystem disk usage
df -h /                    # specific filesystem
du -sh /var/log/*          # size of each item
du -sh *                   # size of items in current dir
du -sh * | sort -h         # sorted by size

free -h                    # memory usage
cat /proc/meminfo          # detailed memory info

lsof -i :80                # what's using port 80
lsof -p PID                # files opened by process
```

## Networking

```bash
ip addr                    # network interfaces and IPs
ip route                   # routing table
ss -tlnp                   # listening TCP ports
ss -tnp                    # established TCP connections
netstat -tlnp              # older equivalent of ss

ping host                  # ICMP connectivity test
traceroute host            # show path to host
curl -v https://host/path  # HTTP request with verbose output
wget https://url/file      # download a file
nc -zv host 443            # test port connectivity
```

## systemd

```bash
systemctl start nginx
systemctl stop nginx
systemctl restart nginx
systemctl reload nginx          # reload config without stopping
systemctl status nginx
systemctl enable nginx          # start at boot
systemctl disable nginx
systemctl list-units            # all units
systemctl list-units --state=failed  # failed units

journalctl -u nginx             # service logs
journalctl -u nginx -f          # follow live
journalctl -u nginx -n 50       # last 50 lines
journalctl -b                   # all logs since last boot
```

## SSH

```bash
ssh user@host                   # connect
ssh -p 2222 user@host           # custom port
ssh -i ~/.ssh/key.pem user@host # specific key
ssh -L 8080:localhost:80 user@host  # local port forwarding
ssh -J bastion user@host        # jump through bastion host

scp file.txt user@host:/dest/   # copy to remote
scp user@host:/src/file.txt .   # copy from remote
rsync -avz src/ user@host:dest/ # sync directory (faster than scp for multiple files)
```

## Environment

```bash
env                             # print all environment variables
export VAR=value                # set variable for current session
echo $VAR                       # print variable value
printenv PATH                   # print specific variable
unset VAR                       # remove variable
which python3                   # find command location
type python3                    # show if alias/function/builtin/file
history                         # command history
history | grep ssh              # search history
!!                              # repeat last command
!grep                           # repeat last grep command
```

## Package management (Ubuntu/Debian)

```bash
apt update                      # update package lists
apt upgrade                     # upgrade installed packages
apt install nginx               # install package
apt remove nginx                # remove package
apt autoremove                  # remove unused packages
apt search nginx                # search packages
dpkg -l | grep nginx            # check if installed
```

## User management

```bash
useradd -m -s /bin/bash alice   # create user with home dir
usermod -aG docker alice        # add to group
passwd alice                    # set password
id alice                        # show user info
groups alice                    # show groups
su - alice                      # switch user
sudo -u alice cmd               # run command as user
```
