---
title: "simple Linux commands"
description: "✅ So these are SAME:      cd ~ cd /Users/jumptotech        Enter fullscreen mode           ..."
published: 2026-03-27
source: "https://dev.to/jumptotech/simple-linux-commands-1d5d"
tags: []
---

# simple Linux commands





## ✅ So these are SAME:

```bash
cd ~
cd /Users/jumptotech
```



# 🔹 Correct usage examples

### Go to home:

```bash
cd ~
```

---

### Go to Desktop:

```bash
cd ~/Desktop
```

👉 Expands to:

```bash
cd /Users/jumptotech/Desktop
```

---

### Create file in home:

```bash
touch ~/file.txt
```

---

# 🔹 Absolute vs Shortcut

| Type     | Example                     | Meaning       |
| -------- | --------------------------- | ------------- |
| Absolute | `/Users/jumptotech/Desktop` | Full path     |
| Shortcut | `~/Desktop`                 | Same, shorter |

---



👉 `~` ONLY works at the **beginning**

✅ Correct:

```bash
~/Desktop
```

❌ Wrong:

```bash
/Desktop/~
/Users/jumptotech/~
```

---

# 🔹 Real DevOps Example

When installing tools:

```bash
mv terraform ~/bin/
```

👉 Means:

```plaintext
/Users/jumptotech/bin/
```

---



👉
“~ is a shortcut for your home folder.
Don’t mix it with full paths.”

---

# 🔥 Interview answer (short)

👉
“~ represents the current user’s home directory. It is a shortcut used instead of writing the full absolute path.”



# 🔹 1. Navigation Commands

### `pwd`

👉 Show current directory

```bash
pwd
```

### `ls`

👉 List files and folders

```bash
ls
ls -l     # detailed view
ls -a     # show hidden files
```

### `cd`

👉 Change directory

```bash
cd /home/ubuntu
cd ..        # go back one folder
cd ~         # go to home
```

---

# 🔹 2. File & Directory Management

### `mkdir`

👉 Create folder

```bash
mkdir project
```

### `touch`

👉 Create empty file

```bash
touch file.txt
```

### `cp`

👉 Copy files

```bash
cp file.txt backup.txt
cp -r folder1 folder2
```

### `mv`

👉 Move or rename

```bash
mv file.txt newfile.txt
mv file.txt /home/ubuntu/
```

### `rm`

👉 Delete files/folders

```bash
rm file.txt
rm -r folder
rm -rf folder   # force delete (danger)
```

---

# 🔹 3. File Viewing

### `cat`

👉 Show file content

```bash
cat file.txt
```

### `less`

👉 View large file (scroll)

```bash
less file.txt
```

### `head` / `tail`

👉 Show start/end of file

```bash
head file.txt
tail file.txt
tail -f log.txt   # live logs (VERY IMPORTANT)
```

---

# 🔹 4. Permissions & Ownership

### `chmod`

👉 Change permissions

```bash
chmod 777 file.txt
chmod +x script.sh
```

### `chown`

👉 Change owner

```bash
sudo chown ubuntu file.txt
```

---

# 🔹 5. User Management

### `whoami`

👉 Current user

```bash
whoami
```

### `sudo`

👉 Run as admin

```bash
sudo apt update
```

---

# 🔹 6. Package Management (Ubuntu)

### `apt`

👉 Install/update packages

```bash
sudo apt update
sudo apt install nginx
sudo apt remove nginx
```

---

# 🔹 7. Process & System

### `ps`

👉 Show processes

```bash
ps aux
```

### `top`

👉 Live system monitoring

```bash
top
```

### `kill`

👉 Stop process

```bash
kill 1234
```

---

# 🔹 8. Networking

### `ping`

👉 Check connectivity

```bash
ping google.com
```

### `curl`

👉 Call API / URL

```bash
curl http://example.com
```

### `ssh`

👉 Connect to server

```bash
ssh ubuntu@ip-address
```

---

# 🔹 9. Disk & Storage

### `df -h`

👉 Disk usage

```bash
df -h
```

### `du -sh`

👉 Folder size

```bash
du -sh *
```

---

# 🔹 10. Redirection & Output (VERY IMPORTANT)

### `echo`

👉 Print text

```bash
echo "Hello"
```

### `>`

👉 Overwrite file

```bash
echo "Hello" > file.txt
```

### `>>`

👉 Append to file

```bash
echo "World" >> file.txt
```

---

# 🔹 11. Search & Text Processing

### `grep`

👉 Search text

```bash
grep "error" log.txt
```

### `find`

👉 Find files

```bash
find . -name "file.txt"
```

---

# 🔹 12. Archive & Compression

### `tar`

👉 Compress/extract

```bash
tar -cvf archive.tar folder/
tar -xvf archive.tar
```

---

# 🔹 13. History & Help

### `history`

👉 Show commands history

```bash
history
```

### `man`

👉 Command manual

```bash
man ls
```

---

# 🔥 MOST IMPORTANT (Tell your students)

If they remember only these → they will survive:

```bash
ls
cd
pwd
mkdir
touch
cp
mv
rm
cat
tail -f
chmod
sudo
apt
grep
ssh
```


