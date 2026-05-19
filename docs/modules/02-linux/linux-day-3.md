---
title: "linux day #3"
description: "PS1 Environment Variable (Bash Prompt)            1. What is PS1?   PS1 stands for Prompt..."
published: 2025-12-25
source: "https://dev.to/jumptotech/linux-day-3-2dmc"
tags: []
---

# linux day #3



# PS1 Environment Variable (Bash Prompt)

## 1. What is PS1?

`PS1` stands for **Prompt String 1**.

It defines **how your primary shell prompt looks** — the text you see **before** you type a command.

Example of a prompt:

```bash
aisalkyn@macbook:~/Desktop$
```

Everything before `$` is controlled by `PS1`.

---

## 2. Simple PS1 Change (Basic Example)

You can change PS1 temporarily:

```bash
PS1="hello-bash "
```

Result:

```bash
hello-bash ls
```

This proves:

* PS1 is printed **before every command**
* It is just **text**, unless we add placeholders

---

## 3. Why End PS1 with `$ `?

Best practice:

```bash
PS1="hello-bash$ "
```

Why?

* `$` visually separates **prompt** from **command**
* Easier to read
* Standard across Unix/Linux systems

---

## 4. Using Placeholders (Escape Sequences)

PS1 supports **special placeholders** that get replaced dynamically.

### Common Placeholders

| Placeholder | Meaning                           |
| ----------- | --------------------------------- |
| `\u`        | Username                          |
| `\h`        | Hostname (short)                  |
| `\H`        | Hostname (full)                   |
| `\w`        | Full current directory path       |
| `\W`        | Current directory name only       |
| `\t`        | Time (24-hour)                    |
| `\@`        | Time (12-hour AM/PM)              |
| `\$`        | `$` for normal user, `#` for root |

---

## 5. Example: Username + Hostname

```bash
PS1="\u@\H "
```

Output:

```bash
aisalkyn@MacBook-Pro.local
```

---

## 6. Showing Current Directory

### Full path

```bash
PS1="\w$ "
```

Example:

```bash
/Users/aisalkyn/Desktop$
```

### Only last directory

```bash
PS1="\W$ "
```

Example:

```bash
Desktop$
```

---

## 7. Adding Time

```bash
PS1="\t \@ \W$ "
```

Example:

```bash
17:45 05:45 PM Desktop$
```

---

## 8. Most Common Production Prompt

This is **very common in real environments**:

```bash
PS1="\u@\h:\w\$ "
```

Example:

```bash
aisalkyn@macbook:/Users/aisalkyn/Desktop$
```

---

## 9. Customizing for Personal Use

If you already know:

* your username
* your machine name

You might prefer a **minimal prompt**:

```bash
PS1="\W$ "
```

Example:

```bash
Desktop$
```

This is **clean and efficient**.

---

## 10. Why PS1 Resets When Opening a New Shell

When you open a new terminal:

* Bash **reloads startup configuration**
* Temporary environment variables are lost
* `PS1` gets reset

That’s why changes disappear.

---

## 11. Making PS1 Persistent (Permanent)

You must put it in a **bash startup file**.

### Edit `.bashrc`

```bash
nano ~/.bashrc
```

Add at the bottom:

```bash
PS1="\W$ "
```

Save and exit.

Now:

* Every new shell uses this prompt
* No need to retype it

---

## 12. Why This Is Useful in Real Work

Benefits:

* Always know **where you are**
* Less need for `pwd`
* Faster navigation
* Cleaner workflow
* Very helpful on servers and EC2 instances









![Image](https://upload.wikimedia.org/wikipedia/commons/9/99/DEC_VT100_terminal.jpg)

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/99/DEC_VT100_terminal.jpg/1200px-DEC_VT100_terminal.jpg)

![Image](https://upload.wikimedia.org/wikipedia/commons/thumb/9/9f/DEC_VT100_terminal_transparent.png/1200px-DEC_VT100_terminal_transparent.png)


# How Color Works in the Terminal (History → Theory → Practice)


This history explains:

* why colors work the way they do,
* why escape sequences exist,
* why modern terminals behave the way they do today.

---

## 2. Physical Terminals (Before Modern Displays)

In the late 1970s and early 1980s, computers did **not** work like today.

A famous example is the **VT100 terminal** (produced around 1978–1983).

### Important characteristics:

* It was a **physical device** (screen + keyboard).
* It was **not a computer**.
* It was **not connected via HDMI or video cable**.

Instead:

* The computer sent **text instructions** to the terminal.
* The terminal itself:

  * moved the cursor,
  * drew characters,
  * applied colors or styles.

Example (conceptually):

> “Move cursor to row 5, column 10 and print text in green.”

The terminal executed these instructions and displayed the result.

---

## 3. ASCII and Text-Based Output

These terminals relied on **ASCII encoding**:

* 128 characters
* Letters, numbers, punctuation, control characters
* Enough for English text

Everything on screen was **text**, not pixels.

---

## 4. Terminal Emulators (Today)

Modern systems no longer use physical terminals.

Instead, we use **terminal emulator applications**:

* Terminal.app
* iTerm2
* GNOME Terminal
* Windows Terminal

They are called *emulators* because they:

* emulate old hardware terminals (like VT100),
* still understand the same command-based instructions.

This is why:

* terminals today still behave like text devices,
* escape sequences still exist.

---

## 5. Why This History Still Matters

Even today:

* terminals have **capabilities**
* some support colors, bold, underline, blinking, etc.
* others support fewer features

To communicate these capabilities, Unix systems use the environment variable:

```bash
TERM
```

---

## 6. The `TERM` Environment Variable

`TERM` tells programs **what kind of terminal is being used**.

Example:

```bash
echo $TERM
```

Typical output:

```bash
xterm-256color
```

Meaning:

* xterm-compatible
* supports **256 colors**

Most modern terminals use this value.

---

## 7. Why Programs Check `$TERM`

Programs like:

* `ls`
* `vim`
* `less`
* `grep`

check `$TERM` before:

* outputting color,
* using special formatting.

If a terminal **does not support color**, programs avoid sending color codes.

---

## 8. Listing All Known Terminal Types

Terminal capabilities are stored in the **terminfo database**.

To list them:

```bash
toe
```

If nothing appears:

```bash
toe -a
```

This lists **all terminal definitions** available on your system.

---

## 9. Example: VT100 Still Exists

You can search for VT100:

```bash
toe -a | grep vt100
```

Even today:

* systems know how to talk to VT100
* the protocol is still supported

This shows how backward-compatible terminals are.

---

## 10. How the Shell Controls the Terminal

The shell **does not draw pixels**.

Instead, it sends **escape sequences**:

* instructions that start with a special character,
* telling the terminal how to render text.

---

## 11. Escape Sequences (Core Concept)

An escape sequence:

* starts with the **ESC character**
* followed by instructions

In bash, ESC is written as:

```bash
\e
```

To enable escape interpretation in `echo`, use:

```bash
echo -e
```

---

## 12. Simple Example: New Line

```bash
echo -e "Hello\nBash"
```

Output:

```text
Hello
Bash
```

`\n` is interpreted because of `-e`.

---

## 13. Color Escape Sequence Structure

General format:

```bash
\e[<codes>m
```

Example:

```bash
echo -e "\e[30;40m"
```

Explanation:

* `\e` → escape
* `[` → control sequence start
* `30` → foreground color
* `40` → background color
* `m` → apply to text

---

## 14. Example: Black on Black (Not Usable)

```bash
echo -e "\e[30;40m"
```

Result:

* black text
* black background
* terminal becomes unreadable

This shows:

* escape sequences change terminal **state**
* the state persists until reset

---

## 15. Example: Cyan Text on Red Background

```bash
echo -e "\e[36;41m"
```

Result:

* cyan foreground
* red background

Not pretty, but useful for demonstration.

---

## 16. Common Color Codes

| Color   | Foreground | Background |
| ------- | ---------- | ---------- |
| Black   | 30         | 40         |
| Red     | 31         | 41         |
| Green   | 32         | 42         |
| Yellow  | 33         | 43         |
| Blue    | 34         | 44         |
| Magenta | 35         | 45         |
| Cyan    | 36         | 46         |
| White   | 37         | 47         |

> Note: terminals may adjust colors based on themes.

---

## 17. More Than 8 Colors

With `xterm-256color`:

* terminals support **256 colors**
* even full RGB in some cases

But:

* most real-world prompts use basic colors
* simplicity = compatibility

---

## 18. Terminal Capabilities via `infocmp`

To see what your terminal claims to support:

```bash
infocmp
```

This:

* reads `$TERM`
* lists supported features
* shows escape sequences

Example capabilities:

* bold
* underline
* clear screen
* colors

---

## 19. Bold Text Example

Start bold:

```bash
echo -e "\e[1mBold Text"
```

But notice:

* bold stays enabled
* prompt and next commands remain bold

---

## 20. Resetting Terminal Formatting

To reset everything:

```bash
echo -e "\e[0m"
```

This is called **SGR reset**.

Always reset after formatting.

---

## 21. Combining Formatting Safely

```bash
echo -e "\e[1mBold\e[0m Normal"
```

Result:

* “Bold” → bold
* “Normal” → default formatting

---

## 22. Problem with Raw Escape Sequences

Issues:

* hard to remember
* unreadable
* error-prone
* not portable

Example:

```bash
\e[1;36;41m
```

Not human-friendly.

---

## 23. Solution: `tput`

Terminal capabilities have **names** (from `infocmp`).

Example:

* `bold`
* `sgr0`
* `setaf`
* `setab`

Wouldn’t it be nice to use names instead of codes?

That’s exactly what **`tput`** does.












# Command Substitution, `tput`, and PS1 Pitfalls (Very Important)


## Part 1 — Command Substitution (Quick Crash Course)

### What is Command Substitution?

Command substitution allows you to:

* **execute a command**
* **capture its output**
* **insert that output inside another command**

### Syntax (Modern, Recommended)

```bash
$(command)
```

Example:

```bash
echo "This is the output: $(ls)"
```

Result:

* `ls` runs
* its output is captured
* the result is inserted into the string

---

## Why Use Double Quotes?

Always wrap command substitution in **double quotes**:

```bash
echo "Files: $(ls)"
```

This prevents Bash from:

* word splitting
* glob expansion
* unwanted rewriting of the output

This becomes **critical** later when we use `tput`.

---

## Why `ls` Output Changes Format

You observed this correctly.

### Direct terminal output:

```bash
ls
```

→ multiple columns

### Captured output:

```bash
echo "$(ls)"
```

→ one entry per line

Why?

Because `ls` checks:

* “Am I printing directly to a terminal?”
* If **no** (pipe, redirect, substitution), it switches to line mode

Same behavior with pipes:

```bash
ls | cat
```

---

## Using Escape Characters with `echo`

To insert special characters (like newlines):

```bash
echo -e "Output:\n$(ls)"
```

Without `-e`, escape characters like `\n` are ignored.

---

## Why Command Substitution Matters Here

Because:

* `tput` **prints escape sequences**
* command substitution lets us **embed those sequences cleanly**
* we can generate formatting dynamically

This leads us to `tput`.

---

## Part 2 — `tput`: Human-Readable Terminal Control

### Why `tput` Exists

Typing raw escape sequences is:

* unreadable
* hard to remember
* error-prone

`tput` converts **terminfo capability names** into correct escape sequences for your terminal.

---

## Common `tput` Commands

### Clear Screen

```bash
tput clear
```

Same effect as:

```bash
clear
```

### Cursor Position

```bash
tput cup 5 20
```

Moves cursor to:

* row 5
* column 20

Used for:

* interactive UIs
* dashboards
* terminal animations

---

## Text Formatting with `tput`

### Bold Text

```bash
tput bold
```

### Underline Text

```bash
tput smul
```

### Reset Everything (Very Important)

```bash
tput sgr0
```

Without reset:

* formatting persists
* prompt and commands stay bold/colored

---

## Colors with `tput`

### Foreground Color

```bash
tput setaf <number>
```

### Background Color

```bash
tput setab <number>
```

### Common Color Numbers

| Number | Color   |
| ------ | ------- |
| 0      | Black   |
| 1      | Red     |
| 2      | Green   |
| 3      | Yellow  |
| 4      | Blue    |
| 5      | Magenta |
| 6      | Cyan    |
| 7      | White   |

Example:

```bash
tput setaf 4   # blue text
tput setab 3   # yellow background
```

---

## Querying Terminal Capabilities (Real Values)

Unlike `infocmp`, `tput` gives **live values**.

### Number of Lines

```bash
tput lines
```

### Number of Columns

```bash
tput cols
```

### Number of Colors

```bash
tput colors
```

These values **change dynamically** if you resize or zoom your terminal.

---

## Part 3 — The Critical PS1 Escape Sequence Problem

### The Problem

Bash must know:

* how long your prompt is
* where line wrapping occurs
* where the cursor should move

But:

* **escape sequences do not print visible characters**
* Bash still counts them **unless told not to**

This causes:

* broken line wrapping
* cursor jumps
* impossible editing of long commands
* extremely annoying behavior

---

## What Goes Wrong (Symptoms)

When escape sequences are not handled correctly:

* lines wrap too early
* cursor moves to wrong positions
* backspace behaves incorrectly
* multi-line commands break visually

You demonstrated this perfectly.

---

## The Solution: `\[ \]` (Mandatory for PS1)

Bash provides a fix.

### Rule (Very Important)

**Wrap every non-printing escape sequence in:**

```bash
\[
\]
```

This tells Bash:

> “These characters do NOT take screen space. Do not count them.”

---

## Correct PS1 Example (With Colors)

```bash
PS1="\[$(tput setaf 4)\]\W\[$(tput sgr0)\]$ "
```

Explanation:

* `\[` … `\]` → invisible characters
* `tput setaf 4` → blue text
* `\W` → current directory
* `tput sgr0` → reset formatting

---

## What You Must Never Do

❌ Do NOT include visible characters inside `\[ \]`
❌ Do NOT include spaces inside `\[ \]`
❌ Do NOT forget to reset formatting

Bad example:

```bash
\[$(tput sgr0) \]
```

That space **breaks alignment**.

---

## Correct Pattern to Follow

```bash
\[ escape-sequence \] visible-text \[ reset \]
```

---

## Why This Matters in Real Life

Incorrect PS1 formatting leads to:

* unusable shells
* broken SSH sessions
* confusion during incidents
* frustration during interviews

Correct PS1 formatting:

* looks professional
* behaves correctly
* works on servers
* is production-safe
















# Exercise — Create a Custom PS1 Prompt (Using `tput`)


* Bash placeholders (`\W`, `\t`, etc.)
* `tput` for colors and formatting
* Proper escaping so multiline editing works correctly

This is exactly how **real Linux / DevOps engineers** customize their shell.

---

## 🎯 Goal of the Exercise

Create a PS1 prompt that:

* Shows the **current directory**
* Shows the **current time**
* Uses **colors**
* Optionally uses **bold text**
* Ends cleanly so typed commands appear normal
* Works correctly with **long and multiline commands**

---

## 📌 Rules You Must Follow (Very Important)

### 1. Use **double quotes** when assigning PS1

Correct:

```bash
PS1="..."
```

Incorrect:

```bash
PS1='...'   # breaks command substitution
```

Why?

* `$()` only works inside **double quotes**

---

### 2. Command substitution runs **only once**

Example (❌ bad idea):

```bash
PS1="$(ls)"
```

This:

* runs `ls` once
* freezes the output forever
* does NOT update when you change directories

✅ **Use placeholders** (`\W`, `\u`, `\h`) for dynamic values
✅ **Use `tput`** for formatting (its output is constant)

---

### 3. Escape visible `$` characters

If you want a literal `$` in PS1:

```bash
\$
```

Otherwise Bash treats it as a variable.

---

### 4. Unicode is allowed (optional)

You *may* use:

* arrows (`➜`)
* symbols
* emojis

Only if:

* your terminal supports Unicode
* they display correctly

---

### 5. ALWAYS reset formatting at the end

If you don’t:

* your typed commands stay colored or bold
* terminal becomes annoying

Use:

```bash
$(tput sgr0)
```

---

## ⚠️ The Most Important Rule (PS1 Bug Fix)

### Non-printing characters **must be wrapped**

Every `tput` output **must** be wrapped like this:

```bash
\[$(tput setaf 2)\]
```

Why?

* Bash must know which characters **do not take space**
* otherwise cursor movement and line wrapping break

❌ Never put visible characters inside `\[ \]`
❌ Never put spaces inside `\[ \]`

---

## ✅ Step-by-Step Sample Solution

Below is a **clean, stable, professional PS1**.

### What it shows:

* green arrow
* yellow time
* cyan **bold** current directory
* normal text for commands

---

### Final PS1 (Recommended Solution)

```bash
PS1="\[$(tput setaf 2)\]➜ \
\[$(tput setaf 3)\]\t \
\[$(tput setaf 6)$(tput bold)\]\W \
\[$(tput sgr0)\]\$ "
```

---

## 🧠 How This Works (Explained)

| Part                              | Purpose            |
| --------------------------------- | ------------------ |
| `\[$(tput setaf 2)\]`             | Green color        |
| `➜`                               | Unicode arrow      |
| `\t`                              | Current time (24h) |
| `\[$(tput setaf 6)$(tput bold)\]` | Cyan + bold        |
| `\W`                              | Current directory  |
| `\[$(tput sgr0)\]`                | Reset everything   |
| `\$ `                             | Prompt symbol      |

---

## 🧪 Result Example

```text
➜ 14:32 Desktop $
```

* Cursor movement works
* Line wrapping works
* Editing long commands works
* Looks clean and professional

---

## 💾 Make It Permanent

Save it to your `~/.bashrc`:

```bash
nano ~/.bashrc
```

Add at the bottom:

```bash
PS1="..."
```

Reload:

```bash
source ~/.bashrc
```

---


You now understand:

* Command substitution (`$()`)
* `tput` for terminal capabilities
* Why PS1 breaks without `\[ \]`
* How to build a **production-safe prompt**

This knowledge is **interview-level Linux** and **real-world DevOps**.













# Shell Expansions — Filename Expansion & Tilde Expansion



## 1. What Is a Shell Expansion?

A **shell expansion** means:

> Before Bash executes a command, it **rewrites and expands parts of that command**.

So the execution flow looks like this:

1. You type a command
2. Bash **parses and expands** it
3. Bash executes the rewritten command

This expansion happens **before** the command runs.

It may feel like “magic”, but in this chapter we are explicitly uncovering what Bash does behind the scenes.

---

## 2. Filename Expansion (Globbing)

The first expansion we look at is **filename expansion**, also called **globbing**.

### The `*` (asterisk)

The `*` character means:

* match **zero or more characters**
* match **file and directory names**

Example:

```bash
ls *
```

What happens internally:

* Bash looks at the **current directory**
* Replaces `*` with **all filenames**
* Executes `ls` with those filenames as arguments

---

## 3. Proof That Bash Rewrites the Command

Imagine this directory contains only folders, with no spaces in their names.

When you run:

```bash
ls *
```

Bash effectively rewrites it to:

```bash
ls Desktop Documents Downloads Pictures Videos
```

That rewritten command is then executed.

---

## 4. Expansion Works With Any Command

Filename expansion is **not specific to `ls`**.

Example:

```bash
echo *
```

Result:

* prints all filenames in the directory

Because:

* Bash expands `*`
* then passes the expanded list to `echo`

This proves:

> Filename expansion is done by **Bash**, not by the command.

---

## 5. Filtering With Wildcards

### Match Files by Extension

```bash
ls *.txt
```

Meaning:

* match all filenames ending in `.txt`

If the directory contains:

```text
a.txt
b.txt
test.txt
world.txt
```

All will be matched.

---

### The `?` (question mark)

The `?` wildcard matches **exactly one character**.

Example:

```bash
ls ?.txt
```

Matches:

```text
a.txt
b.txt
```

Does NOT match:

```text
test.txt
world.txt
```

---

## 6. Filename Expansion With Paths

Filename expansion also works with paths.

Example:

```bash
echo ~/Documents/*.txt
```

What Bash does:

1. Expands `~` (tilde expansion)
2. Expands `*.txt`
3. Passes full paths to `echo`

You can confirm this by running:

```bash
ls ~/Documents/*.txt
```

Or by manually typing the expanded paths — the result is the same.

---

## 7. Why This Is Powerful

Filename expansion allows you to:

* avoid typing long filenames
* work efficiently with groups of files
* combine expansions with any command

This is one of the most used Bash features in real systems.

---

## 8. Tilde Expansion (`~`)

Now let’s look at **tilde expansion**.

The tilde (`~`) expands to the value of the **`HOME` environment variable**.

Normally:

```bash
~ → /home/username
```

---

## 9. Basic Tilde Expansion Example

```bash
ls ~
```

Lists:

* your home directory

This is equivalent to:

```bash
ls $HOME
```

---

## 10. Demonstrating That It Uses `$HOME`

We can prove this by echoing it:

```bash
echo ~
echo $HOME
```

Both produce the same output.

---

## 11. Changing `$HOME` (Demonstration Only)

If you override the variable:

```bash
HOME=/
```

Now:

```bash
ls ~
```

Lists:

* the root directory

⚠️ This is **not recommended** in practice
It’s only used here to demonstrate how tilde expansion works.

---

## 12. Confirming Expansion With `echo`

Because expansion happens before execution:

```bash
echo ~
```

Shows:

* the expanded path
* not the literal `~`

This confirms Bash rewrites the command first.

---

## 13. Tilde Expansion With Paths

Tilde expansion also works as part of a path:

```bash
ls ~/Documents
```

Meaning:

```bash
ls /home/username/Documents
```

The tilde starts the expansion, and the rest is appended to the path.

---

## 14. `~+` — Current Working Directory

Another useful tilde form:

```bash
~+
```

Expands to:

* the current working directory
* same as `$PWD`

Example:

```bash
echo ~+
```

Equivalent to:

```bash
echo $PWD
```

---

## 15. Keyboard Note (Important Practical Tip)

On some systems:

* typing `~+` directly may create a composed character

Solution:

* type `~`
* press **space**
* then type `+`

This avoids Unicode composition issues.

---

## 16. Summary

You learned:

### Filename Expansion

* `*` → zero or more characters
* `?` → exactly one character
* done by **Bash**, not commands
* works with any command

### Tilde Expansion

* `~` → `$HOME`
* `~/path` → home subdirectory
* `~+` → `$PWD`

### Key Rule

> **Expansions always happen before execution**













# Shell Expansions with Variables

## Variable Expansion, Parameter Expansion & Word Splitting


## 1. Variable Expansion — The Basics

### What is Variable Expansion?

**Variable expansion** means:

> Bash replaces a variable reference with its value **before executing the command**.

This happens during the **expansion phase**, not during command execution.

---

## 2. Syntax of Variable Expansion

All variable expansions start with a **dollar sign (`$`)**.

Common forms:

```bash
$VAR
${VAR}
"$VAR"
"${VAR}"
```

✅ **Recommended best practice**:

```bash
"${VAR}"
```

Why?

* Clearly defines where the variable name ends
* Works safely with concatenation
* Avoids ambiguity

---

## 3. The Dollar Sign Does NOT Belong to the Variable

This is a very important concept.

In Bash:

* The variable name is `HOME`
* NOT `$HOME`

The `$` means:

> “Perform an expansion here”

Example:

```bash
env | grep HOME
```

You will see:

```text
HOME=/home/username
```

No dollar sign exists in the variable name itself.

---

## 4. Why Curly Braces Matter

Consider this example:

```bash
echo "$HOMEpath"
```

Bash looks for:

* variable named `HOMEpath`

Instead of:

```bash
echo "${HOME}path"
```

Which correctly expands:

```text
/home/usernamepath
```

👉 Curly braces explicitly mark **where the variable name ends**.

---

## 5. Expansion Happens Before Execution

Example:

```bash
echo "${HOME}"
```

What really happens internally:

```bash
echo /home/username
```

The `echo` command never knows a variable existed.

---

## 6. Shell Parameter Expansion (Working with Strings)

Shell parameter expansion allows us to **manipulate variable contents**.

This only works on **existing variables**.

---

### 6.1 String Length

```bash
echo "${#PATH}"
```

* Returns the **number of bytes** in the string
* Usually equals character count (ASCII)
* May differ for multi-byte Unicode characters

---

### 6.2 Substring Extraction

```bash
echo "${PATH:4:10}"
```

Meaning:

* Start at index `4`
* Extract `10` characters

Indexes start at **0**.

---

### 6.3 String Replacement (Single Match)

```bash
echo "${HOME/home/Users}"
```

Replaces:

* first occurrence of `home`
* with `Users`

---

### 6.4 Replace All Occurrences

```bash
echo "${PATH//:/ }"
```

* Replaces **all** colons with spaces
* Useful for transforming lists

---

### 6.5 Expansion Does NOT Modify the Variable

This:

```bash
echo "${HOME/home/Users}"
```

❌ does NOT change `$HOME`

To modify it, you must assign it explicitly:

```bash
HOME="${HOME/home/Users}"
```

⚠️ No spaces allowed around `=`.

---

## 7. Variable Expansion vs Assignment (Critical Difference)

| Action        | Result           |
| ------------- | ---------------- |
| `echo "$VAR"` | Reads variable   |
| `VAR=value`   | Assigns variable |
| `$VAR=value`  | ❌ Invalid        |

---

## 8. Word Splitting — What Happens After Expansion

After **all expansions**, Bash performs **word splitting**.

Word splitting means:

> Bash breaks the command into words (arguments).

Example:

```bash
touch a.txt b.txt
```

Split into:

1. `touch` (command)
2. `a.txt` (argument 1)
3. `b.txt` (argument 2)

---

## 9. The `IFS` Variable

Word splitting happens on characters defined in `$IFS`.

Default `IFS` contains:

* space
* tab
* newline

You can inspect it:

```bash
echo "${IFS}"
```

It may look empty — but it is not.

---

## 10. Consecutive Delimiters Are Collapsed

Example:

```bash
touch    c.txt
```

Multiple spaces are treated as **one delimiter**.

Result:

```text
c.txt
```

---

## 11. Disabling Word Splitting with Quotes

Quotes prevent word splitting.

Example **without quotes**:

```bash
touch a file.txt
```

Creates:

* `a`
* `file.txt`

---

### With Quotes (Correct)

```bash
touch "a file.txt"
```

Creates:

* `a file.txt`

Quotes are **not part of the filename**.

---

## 12. Single Quotes vs Double Quotes (Preview)

Both:

* disable word splitting

But:

* **single quotes** disable expansions
* **double quotes** allow expansions

Examples:

```bash
echo '$HOME'
echo "$HOME"
```

Output:

```text
$HOME
/home/username
```

---

## 13. Quotes Allow Whitespace in Filenames

```bash
touch "a file.txt b.txt"
```

Creates **one file** with spaces in its name.

Without quotes:

```bash
touch a file.txt b.txt
```

Creates **three files**.

---

## 14. Why Quotes Are Essential in Bash

Quotes:

* prevent word splitting
* preserve whitespace
* control expansions
* prevent bugs in scripts
* are required for safe variable usage

This is **one of the most important Bash concepts**.

---

## 15. Summary

You learned:

### Variable Expansion

* `$VAR`, `${VAR}`
* expansion happens before execution
* `$` triggers expansion, not part of variable name

### Parameter Expansion

* string length
* substrings
* replacements

### Word Splitting

* happens after expansion
* controlled by `IFS`
* disabled by quotes



















# Quotes, Expansions, and Their Hidden Dangers in Bash

Before we go deeper, here is an important mindset shift.

> **In Bash, the more you know about other programming languages, the more confusing quoting becomes.**



## 1. The Bash Execution Pipeline (Repeat — Very Important)

Every Bash command follows the **same order**:

1. **Expansions** (depending on quotes)
2. **Word splitting**
3. **Quote removal**
4. **Command execution**

Quotes affect **only steps 1 and 2**.
After that, **quotes disappear**.

---

## 2. Three Commands — Three Completely Different Meanings

Let’s analyze this pattern:

```bash
echo $PWD/*.txt
echo '$PWD/*.txt'
echo "$PWD/*.txt"
```

### Case 1 — No Quotes

```bash
echo $PWD/*.txt
```

What happens:

* Variable expansion ✅ (`$PWD`)
* Filename expansion ✅ (`*.txt`)
* Word splitting ✅

Bash rewrites it to something like:

```bash
echo /home/user/docs/a.txt /home/user/docs/b.txt
```

Then `echo` runs.

---

### Case 2 — Single Quotes (Most Restrictive)

```bash
echo '$PWD/*.txt'
```

What happens:

* Variable expansion ❌
* Filename expansion ❌
* Word splitting ❌

Bash passes the text **literally**:

```text
$PWD/*.txt
```

Single quotes mean:

> “Do NOT touch anything inside.”

---

### Case 3 — Double Quotes (Selective Expansion)

```bash
echo "$PWD/*.txt"
```

What happens:

* Variable expansion ✅
* Filename expansion ❌
* Word splitting ❌

Result:

```text
/home/user/docs/*.txt
```

The `*` is now just a character, not a wildcard.

---

## 3. Quotes Do NOT Create Strings

This is a key Bash concept.

Quotes:

* do not create string objects
* do not exist at execution time
* only control parsing rules

Example:

```bash
echo "Hello" "World"
```

Bash rewrites this to:

```bash
echo Hello World
```

Quotes are removed **before execution**.

---

## 4. Quotes Can Wrap Any Part of a Command

These are all valid:

```bash
echo "Hello World"
"echo" Hello World
e"c"ho Hello World
```

Why?

* Quotes are removed before execution
* Bash only cares about the final rewritten command

---

## 5. Quotes Can Break Commands

Example:

```bash
"echo Hello"
```

Why this fails:

* Word splitting is disabled
* Bash treats this as **one word**
* Bash looks for a program literally named:

  ```
  echo Hello
  ```

Which doesn’t exist.

---

## 6. Filename Expansion Can Create Commands (Dangerous!)

Consider this directory:

```text
echo
a.txt
b.txt
```

Now run:

```bash
*
```

What Bash sees:

```bash
echo a.txt b.txt
```

This becomes:

* command: `echo`
* arguments: `a.txt b.txt`

So Bash **executes echo**.

This is not a bug — it is a consequence of expansion order.

---

## 7. Filenames Starting With `-` (Very Dangerous)

Create this file:

```bash
touch ./-al
```

Now run:

```bash
ls *
```

Bash expands to:

```bash
ls -al a.txt b.txt
```

Result:

* `-al` is treated as an **option**
* output format changes unexpectedly

---

## 8. How to Protect Against This

### Rule: Prefix filenames with `./`

```bash
ls ./*
```

Now expansion becomes:

```bash
ls ./-al ./a.txt ./b.txt
```

Why this works:

* arguments no longer start with `-`
* cannot be interpreted as options

This is a **critical defensive habit**.

---

## 9. Variables + Word Splitting = Bugs

Consider this directory:

```text
"My Folder"
```

Now:

```bash
touch $PWD/file.txt
```

Bash rewrites it to:

```bash
touch /home/user/My Folder/file.txt
```

Then **word splitting** happens:

```bash
touch /home/user/My Folder/file.txt
```

Which becomes:

* `/home/user/My`
* `Folder/file.txt`

❌ Wrong.

---

### Correct Way

```bash
touch "${PWD}/file.txt"
```

Why this works:

* Variable expands
* Word splitting disabled
* Path stays intact

---

## 10. Why We Always Use `"${VAR}"`

Best practice:

```bash
"${VAR}"
```

Benefits:

* safe expansion
* no word splitting
* clear variable boundaries
* works with spaces
* works with concatenation

---

## 11. Best Practices Summary (Very Important)

### File Paths

* Prefer:

  ```bash
  ./file.txt
  ```
* Especially when:

  * filenames are unknown
  * filenames start with `-`
  * filenames come from variables

---

### Quotes

Use the **most restrictive quoting possible**:

1. **Single quotes** – safest

   ```bash
   'literal text'
   ```

2. **Double quotes** – when expansion is needed

   ```bash
   "${VAR}"
   ```

3. **No quotes** – only when you explicitly want:

   * filename expansion
   * word splitting

---

### Variables

Always:

```bash
"${VAR}"
```

Never:

```bash
$VAR
```

Unless you fully understand the consequences.

---

## 12. Final Mental Model

* Quotes **do not create strings**
* Quotes **control expansion and splitting**
* Expansions are powerful but dangerous
* Defensive Bash means:

  * quoting carefully
  * prefixing paths
  * assuming filenames are hostile


















As always, remember the key principle:

> **Bash rewrites your command before execution.**
> Escaping and brace expansion control *how* that rewrite happens.

---

## Part 1 — What Is Escaping?

### What Does Escaping Mean?

**Escaping** means:

> Disable the special meaning of the **next character only**.

In Bash, escaping is done using the **backslash**:

```bash
\
```

The backslash tells Bash:

> “Treat the next character literally.”

---

## 2. Escaping Whitespace (Very Common Use Case)

Whitespace normally causes **word splitting**.

Example without escaping:

```bash
cd a folder
```

Bash sees:

* `cd`
* `a`
* `folder`

❌ Wrong — two arguments instead of one.

---

### Escaping the Space

```bash
cd a\ folder
```

Now Bash sees:

* `cd`
* `a folder`

✅ Correct — one argument

---

### Autocompletion Does This Automatically

If you press **Tab** on a path containing spaces, Bash may generate:

```bash
a\ folder
```

This is Bash escaping the space **for you**.

---

### Important: Use a Backslash (`\`), Not a Forward Slash (`/`)

Correct:

```bash
a\ folder
```

Incorrect:

```bash
a/ folder
```

The backslash is the **escape character**.

---

## 3. Escaping Double Quotes

Double quotes normally:

* start a quoted region
* change expansion rules

To print a literal double quote inside double quotes:

```bash
echo "\""
```

Explanation:

* `\"` disables the special meaning of `"`

Output:

```text
"
```

---

### Alternative (Simpler) Method

Use single quotes:

```bash
echo '"'
```

Since:

* single quotes disable **all expansions**
* the double quote inside has no special meaning

---

## 4. Why Escaping Does NOT Work Inside Single Quotes

This is one of the **most confusing Bash rules**, so let’s be very clear.

### Inside single quotes:

* **nothing is escaped**
* backslashes lose their power

Example:

```bash
echo '\''
```

❌ This does **not** work.

Why?

* Single quotes disable **all expansions**
* The backslash is treated as a literal character
* Bash sees an unterminated single-quoted string

---

## 5. How to Print a Single Quote Correctly

### Method 1 — Exit and Re-enter Single Quotes (Recommended)

```bash
echo '\'' 
```

How Bash sees it:

* `'` → start single quotes
* `\'` → escaped single quote (outside)
* `'` → end single quotes

---

### Method 2 — Mix Quote Types

```bash
echo "'" 
```

Explanation:

* double quotes allow literal single quotes
* simple and readable

---

### Key Rule to Remember

> **Backslash does NOT work inside single quotes**

This is **by design** in Bash.

---

## 6. What Escaping Really Does (Mental Model)

Escaping:

* affects **only the next character**
* disables its special meaning
* does NOT create strings
* does NOT persist

Example:

```bash
\*
```

Means:

* literal `*`
* no filename expansion

---

## Part 2 — Brace Expansion

Brace expansion is a **pure text generator**.

It happens:

* **very early**
* before variable expansion
* before filename expansion
* before word splitting

---

## 7. Basic Brace Expansion

```bash
echo data.{csv,txt}
```

Expands to:

```text
data.csv data.txt
```

Bash rewrites this before executing `echo`.

---

## 8. Brace Expansion with Ranges

### Alphabet Range

```bash
echo {a..z}
```

Output:

```text
a b c d ... z
```

---

### Create Files Quickly

```bash
touch file_{1..5}.txt
```

Creates:

```text
file_1.txt
file_2.txt
file_3.txt
file_4.txt
file_5.txt
```

---

### Uppercase Alphabet Example

```bash
touch {A..Z}.txt
```

Creates:

* `A.txt`
* `B.txt`
* …
* `Z.txt`

---

## 9. Brace Expansion Does NOT Work Inside Quotes

These **do NOT expand**:

```bash
echo "{a,b}"
echo '{a,b}'
```

Output:

```text
{a,b}
```

---

### Correct Usage

Brace expansion must be **outside quotes**:

```bash
echo {a,b}".txt"
```

This works because:

* braces expand first
* quotes only apply to `.txt`

---

## 10. Bash Version Note (Important for macOS)

Brace expansion **requires Bash 4+**.

* Linux → usually Bash 4+
* macOS → ships with **Bash 3.x** by default

If brace expansion doesn’t work on macOS:

* it’s not your fault
* it’s a version limitation

---

## 11. Summary — Key Rules to Remember

### Escaping

* Backslash escapes **one character**
* Disables special meaning
* Does **not** work inside single quotes

### Quotes

* Single quotes: disable everything
* Double quotes: allow variable expansion
* Quotes are removed before execution

### Brace Expansion

* Generates text combinations
* Happens very early
* Does NOT work inside quotes

---

## 12. When to Use Brace Expansion

Use brace expansion when:

* creating many files
* generating predictable patterns
* avoiding repetitive typing

Example:

```bash
touch report_{draft,final,backup}.txt
```















# Command Substitution & Process Substitution in Bash




### What Is Command Substitution?

**Command substitution** means:

> Execute a command, capture its output, and replace the expansion with that output.

### Syntax (Recommended)

```bash
$(command)
```

Example:

```bash
echo "Current directory is $(pwd)"
```

What happens internally:

1. Bash runs `pwd` in a **subshell**
2. Captures its output
3. Replaces `$(pwd)` with the result
4. Executes `echo`

---

## Why Use Double Quotes with Command Substitution?

Command substitution output may contain:

* spaces
* newlines

Without quotes:

```bash
touch $(pwd)/file.txt
```

If the directory contains a space:

```text
/home/user/My Folder
```

Bash sees:

```bash
touch /home/user/My Folder/file.txt
```

Then **word splitting** happens:

* `/home/user/My`
* `Folder/file.txt`

❌ Wrong

### Correct Usage

```bash
touch "$(pwd)/file.txt"
```

✔ Word splitting disabled
✔ Path preserved

**Rule: Always quote command substitution unless you explicitly want word splitting.**

---

## Command Substitution vs Variable Expansion

If the value already exists as a variable, prefer variable expansion:

```bash
echo "$PWD"
```

Instead of:

```bash
echo "$(pwd)"
```

Why?

* No subshell
* Faster
* Cleaner

---

## Practical Examples of Command Substitution

### Example 1 — Disk Usage

```bash
echo "Home directory size: $(du -sh "$HOME")"
```

* `du` runs
* output is inserted into the string

---

### Example 2 — Counting Files

```bash
echo "There are $(ls | wc -l) files in this directory"
```

Here:

* `ls` outputs filenames
* `wc -l` counts lines
* result is substituted into the sentence

---

## Legacy Syntax (Not Recommended)

```bash
`command`
```

Example:

```bash
echo "Files: `ls`"
```

Why this is discouraged:

* hard to read
* hard to nest
* confusing with quotes

**Always prefer `$(...)`.**

---

## Important Behavior Note (Why `ls` Looks Different)

Inside command substitution, output is **not sent directly to a terminal**.

So:

```bash
ls
```

→ columns

But:

```bash
$(ls)
```

→ one entry per line

This is because `ls` detects its output is being captured.

---

## Part 2 — Process Substitution

### What Problem Does Process Substitution Solve?

Some commands:

* **require file paths**
* do NOT accept standard input easily

Example:

```bash
diff file1 file2
```

But what if:

* file1 and file2 are **command outputs**?

Without process substitution, you must:

1. redirect output to temp files
2. run the command
3. delete temp files

---

## What Is Process Substitution?

**Process substitution** lets Bash:

> Run a command and expose its output *as a temporary file*.

### Syntax

Output as file:

```bash
<(command)
```

Input as file:

```bash
>(command)
```

---

## Example — Comparing Two Directories (Correct Use Case)

### Without Process Substitution (Manual, Ugly)

```bash
ls folder1 > f1.txt
ls folder2 > f2.txt
diff f1.txt f2.txt
```

---

### With Process Substitution (Clean)

```bash
diff <(ls folder1) <(ls folder2)
```

What happens:

* Bash runs both `ls` commands
* Writes their output to temporary files
* Passes file paths to `diff`
* Automatically cleans up

✔ No temp files
✔ No cleanup
✔ Much cleaner

---

## Process Substitution Produces a File Path

Demonstration:

```bash
echo <(ls)
```

Output:

```text
/proc/self/fd/63
```

That path:

* exists temporarily
* disappears after command execution

---

## Process Substitution vs Pipes

### Pipe (`|`)

```bash
ls | wc -l
```

* connects stdout → stdin
* best when downstream command accepts stdin

---

### Process Substitution

```bash
wc -l <(ls)
```

* exposes output as a file
* required when command expects filenames

Both commands run **concurrently**, but data flow differs.

---

## When Pipes Do NOT Work

Some programs:

* read files by name
* seek backwards
* need multiple passes

Examples:

* `diff`
* `comm`
* `paste`
* some `awk` / `sed` workflows

These often require **process substitution**, not pipes.

---

## Input Process Substitution (`>(command)`)

This is the reverse direction.

Example:

```bash
echo "test" > >(cat)
```

What happens:

* Bash creates a temporary file
* Redirects output into it
* Uses that file as stdin for `cat`

This may look odd because:

* subprocess output may appear *after* the prompt
* execution happens asynchronously

This is expected behavior.

---

## Why Output May Appear After the Prompt

Because:

* the parent shell finishes
* prompt is printed
* subprocess finishes later
* its output arrives afterward

This is normal for background/subshell operations.

---

## Summary — When to Use What

### Command Substitution `$(...)`

Use when:

* you need command output as **text**
* you want to embed output in strings
* you assign output to variables

Example:

```bash
files="$(ls)"
```

---

### Process Substitution `<(...)`

Use when:

* a command expects **file paths**
* you want to avoid temp files
* pipes are insufficient

Example:

```bash
diff <(ls dir1) <(ls dir2)
```

---

## Final Mental Model

| Feature              | Produces  |
| -------------------- | --------- |
| Command substitution | Text      |
| Process substitution | File path |

This distinction is **critical** for correct Bash usage.














# Files on Unix Systems — Concepts and Mental Model


## 1. What Is a File?

A **file** is a container used to **store, access, and manage data**.

Each file is identified by:

* a **name**
* a **path**

Together, they uniquely identify a file’s location in the filesystem.

---

## 2. File Attributes (Metadata)

Every file has metadata associated with it, including:

* **Size** – how much data it contains
* **Permissions** – who can read, write, or execute it
* **Ownership** – which user and group own it
* **Timestamps**:

  * last modification time
  * last access time
  * metadata change time



## 3. How Files Are Stored (Inodes)

On Linux and most Unix filesystems, filenames and file data are **not stored together**.

### The Key Concept: Inodes

* A **filename** is just a directory entry
* It points to an **inode**
* The inode contains:

  * file type
  * permissions
  * owner and group
  * file size
  * number of links
  * pointers to where the data is stored on disk

### Simplified View

```
file.txt  →  inode  →  data blocks on disk
```

Important:

* The inode **does not store the filename**
* Multiple filenames can point to the **same inode** (hard links)

---

## 4. Directories Are Files Too

In Unix:

> **A directory is also a file**

* A directory has:

  * an inode
  * permissions
  * ownership
* Its **data** consists of:

  * mappings between filenames and inode numbers

So a directory is essentially a table:

```
filename → inode
```

This is why directories behave like files internally.

---

## 5. “Everything Is a File” (Unix Philosophy)

On Unix systems:

* regular files
* directories
* devices
* pipes
* sockets

are all represented as files.

This allows:

* consistent access
* unified permissions
* simple tooling

---

## 6. Types of Files on Unix

Common file types include:

| Type                   | Description                   |
| ---------------------- | ----------------------------- |
| Regular file (`-`)     | text files, binaries, data    |
| Directory (`d`)        | folders                       |
| Symbolic link (`l`)    | references to another path    |
| Character device (`c`) | devices like keyboards        |
| Block device (`b`)     | disks                         |
| Named pipe (`p`)       | inter-process communication   |
| Socket (`s`)           | process/network communication |

---

## 7. Viewing File Types with `ls -l`

Use:

```bash
ls -l
```

The **first character** of the permissions column indicates file type:

| Symbol | Meaning       |
| ------ | ------------- |
| `-`    | regular file  |
| `d`    | directory     |
| `l`    | symbolic link |

Example:

```text
drwxr-xr-x  Documents
-rw-r--r--  notes.txt
lrwxrwxrwx  ABC -> Desktop
```

---

## 8. Hidden Files

Files starting with `.` are **hidden**.

To show them:

```bash
ls -la
```

Hidden files are not special internally — they are just named differently.

---

# Symbolic Links (Symlinks)

## 9. What Is a Symbolic Link?

A **symbolic link (symlink)** is a special file that:

* contains a **path to another file or directory**
* is resolved **at access time**

Think of it as a **path reference**, not a copy.

---

## 10. Creating a Symlink

Syntax:

```bash
ln -s TARGET LINK_NAME
```

Example:

```bash
ln -s Desktop ABC
```

This creates:

```text
ABC → Desktop
```

---

## 11. Using a Symlink

If the symlink points to a directory:

```bash
cd ABC
```

You are now working inside the **target directory**, even though the path contains `ABC`.

Any file created inside the symlink:

* actually appears in the target directory

---

## 12. Symlinks Are Resolved at Runtime

Key property:

> Symlinks are resolved **when accessed**, not when created.

That means:

* if the target changes → symlink reflects it
* if the target disappears → symlink breaks

Example:

* unplug USB drive
* symlink still exists
* target path no longer reachable

---

## 13. Identifying Symlinks

Use:

```bash
ls -l
```

You’ll see:

```text
l ABC -> Desktop
```

The arrow (`->`) shows the target path.

---

## 14. Symlinks to Files

Symlinks can point to **files**, not only directories.

Example:

```bash
ln -s ~/Downloads/archive.zip download.zip
```

Both paths now refer to the same underlying data.

---

## 15. Practical Use Case: Redirecting Storage

Symlinks are extremely useful when:

* an application expects files in a specific directory
* but you want data stored somewhere else

Example:

```
app/
└── images/   →  /home/user/images
```

The application:

* still accesses `app/images`
* unaware it’s a symlink
* no code changes required

---

## 16. Symlinks and Removable Media

Mounted devices appear as directories (mount points).

Creating a symlink to removable storage:

* works normally while device is present
* becomes broken when device is removed
* automatically works again if mounted at same path

This behavior is expected and correct.

---

## 17. Key Takeaways

* Filenames are **not data**
* Inodes store metadata and data locations
* Directories are files
* Symlinks store paths, not data
* Symlinks are resolved at runtime
* Unix treats almost everything as a file



















# Hard Links vs Symbolic Links (Soft Links)



## 1. Why Mention Windows at All?

On **Windows**, symbolic links are often called **soft links**, and users are more familiar with **shortcuts**.

On **Linux / Unix**, we clearly distinguish between:

* **symbolic links (symlinks / soft links)**
* **hard links**

They behave **very differently**, and understanding this difference is critical.

---

## 2. Recap: Files, Names, and Inodes

Recall how files work on Linux:

```
filename  →  inode  →  data blocks on disk
```

* The **filename** is just a directory entry
* The **inode** stores:

  * permissions
  * owner
  * size
  * file type
  * disk locations of data

The filename is **not part of the inode**.

---

## 3. What Is a Hard Link?

A **hard link** is simply **another directory entry pointing to the same inode**.

That means:

* multiple filenames
* same inode
* same data
* same permissions
* same ownership

There is **no “original” file**.
Every hard link is equal.

---

## 4. Visual Model of a Hard Link

```
file.txt       → inode → data
message.txt    ↗
```

Both filenames reference the **same inode**.

---

## 5. Link Count and Deletion

The inode keeps track of how many hard links exist.

* If **one hard link is deleted** → data remains
* If **all hard links are deleted** → inode is removed → data is freed

This is why deleting a file does **not immediately delete the data** if another hard link still exists.

---

## 6. Key Properties of Hard Links

Hard links:

* point **directly to an inode**
* work **only within the same filesystem**
* **cannot link directories**
* are resolved by the **filesystem**, not at runtime
* are indistinguishable from the “original” file

---

## 7. Creating a Hard Link

Command:

```bash
ln TARGET LINK_NAME
```

Example:

```bash
ln file.txt message.txt
```

Now:

* `file.txt`
* `message.txt`

are the **same file**.

---

## 8. Observing Hard Links

Both files:

* appear as regular files (`-`)
* have identical size
* have identical permissions
* share the same inode number

You can confirm with:

```bash
ls -li
```

The inode number will be the same.

---

## 9. Editing a Hard Link

Editing **either file** modifies the same data.

Example:

* edit `message.txt`
* changes appear in `file.txt`

This can be **confusing** if users are unaware that hard links exist.

---

## 10. Why Hard Links Can Be Useful

Hard links allow you to:

* organize the same data in **multiple directory structures**
* avoid duplicate storage
* keep files synchronized automatically

Example use cases:

* organizing documents by **date**
* organizing the same documents by **category**

---

## 11. Example: Multiple Organization Views

You might have:

```
By date:
2024/05/15/report.txt

By category:
Bookkeeping/report.txt
```

Both paths refer to the **same inode**.

No duplication.
No syncing.
No symlink resolution.

---

## 12. Hard Links vs Symbolic Links

| Feature                  | Hard Link  | Symbolic Link |
| ------------------------ | ---------- | ------------- |
| Points to                | inode      | path          |
| Cross filesystem         | ❌ No       | ✅ Yes         |
| Can link directories     | ❌ No       | ✅ Yes         |
| Breaks if target deleted | ❌ No       | ✅ Yes         |
| Visible as link          | ❌ No       | ✅ Yes         |
| Resolved                 | filesystem | runtime       |

---

## 13. Copying Directory Trees with Hard Links

You can duplicate a directory **structure** while linking all files:

```bash
cp -al source_dir target_dir
```

Flags:

* `-a` → archive (preserve metadata)
* `-l` → hard link files instead of copying

Result:

* directories are recreated
* files are hard-linked
* almost no extra disk space used

---

## 14. When Hard Links Are Dangerous

Hard links can be problematic when:

* applications assume files are unique
* backup software does not handle hard links correctly
* users delete “the wrong copy” expecting others to remain unchanged

Use with care.

---

# Bonus: Symbolic Links on Windows (Optional)

> This section is **optional** and intended for students who also work on Windows.

---

## 15. Symlinks vs Shortcuts on Windows

Windows has **three different concepts**:

1. **Symbolic links** (real filesystem objects)
2. **Junctions**
3. **Shortcuts (`.lnk` files)**

Only **symbolic links** behave like Linux symlinks in terminals.

---

## 16. Creating a Symlink on Windows (PowerShell)

Requires **Administrator privileges** (unless Developer Mode is enabled).

Example:

```powershell
New-Item -ItemType SymbolicLink `
  -Path C:\Users\User\Desktop\important.tf `
  -Target C:\Users\User\Documents\document.tf
```

---

## 17. Windows Symlink Behavior

* In **terminal tools**, symlinks behave like Linux symlinks
* In **GUI**, they behave closer to shortcuts
* Opening a symlink often opens the **original filename**, not the link name

This is different from Linux.

---

## 18. Symlink vs Shortcut on Windows

| Feature             | Symlink    | Shortcut |
| ------------------- | ---------- | -------- |
| Works in terminal   | ✅ Yes      | ❌ No     |
| Acts like real file | ✅ Yes      | ❌ No     |
| Used by programs    | ✅ Yes      | ❌ No     |
| GUI friendly        | ⚠️ Limited | ✅ Yes    |

Shortcuts are **not filesystem links**.

---

## 19. Practical Windows Use Case

Symlinks are useful when:

* an application writes to a fixed path
* you want data stored elsewhere
* the application must remain unaware

This mirrors Linux symlink use cases.

---

## 20. Final Summary

* **Hard links** are multiple names for the same inode
* **Symlinks** are path references resolved at runtime
* Hard links are faster, safer from deletion, but restricted
* Symlinks are flexible, visible, but can break
* Windows supports symlinks, but behavior differs from Linux










# Inode Limits & Buffered vs Unbuffered I/O

This lecture has **two goals**:

1. Make you aware of the **inode limit problem**
2. Explain the difference between **buffered** and **unbuffered** input/output

Both topics are extremely important for **Linux servers, DevOps, and production systems**.

---

## Part 1 — The Inode Limit Problem

### 1. Reminder: How Files Are Stored

On Linux filesystems, a file is stored like this:

```
directory entry (filename)
        ↓
       inode
        ↓
   data blocks on disk
```

* The **filename** lives in a directory
* The **inode** stores metadata:

  * permissions
  * ownership
  * size
  * timestamps
  * pointers to data blocks
* The inode does **not** store the filename

---

### 2. What Is an Inode Limit?

* Inodes are created **when the filesystem is created**
* A fixed number of inodes is reserved
* This space **cannot be used for data**

👉 Even if you have **free disk space**, you can still run out of **inodes**

---

### 3. Checking Inode Usage

Command:

```bash
df -ih
```

Explanation:

* `-i` → show inode usage
* `-h` → human-readable output

Typical output shows:

* total inodes
* used inodes
* free inodes
* percentage used

Example interpretation:

* 1.6M inodes total
* 230K used
* ~1.4M free
* ~15% inode usage

---

### 4. Why Inodes Matter in Real Systems

Inode exhaustion commonly happens when:

* applications create **many small files**
* package managers install **tens of thousands of files**
* JavaScript / Node.js projects (`node_modules`)
* logs written as many tiny files
* container layers and build artifacts

💥 When inode limit is reached:

* applications fail to start
* file creation fails
* system services may crash
* OS behavior becomes unstable

---

### 5. Disk Space vs Inodes (Important!)

You can have:

* **plenty of disk space**
* **zero free inodes**

Result:
👉 You cannot create new files.

This confuses many engineers.

---

### 6. How to Mitigate Inode Exhaustion

#### Option 1: Remove Unneeded Files

* clean logs
* remove unused packages
* delete temporary files

#### Option 2: Reduce File Count

* bundle files into archives
* use `tar` to combine thousands of files into one

Example:

```bash
tar -cf archive.tar many_small_files/
```

Note:

* `tar` does **not compress**
* it reduces **inode usage**
* compression can be added later (`gzip`, `xz`)

---

#### Option 3: Use Separate Filesystems

* add another disk
* mount it into a directory
* spread inode usage

Example idea:

```bash
/mnt/data
```

---

#### Option 4: Recreate Filesystem With More Inodes

* only safe on new or empty disks
* resizing inode tables on existing filesystems can cause **data loss**
* usually done at filesystem creation time

---

### 7. Key Takeaway About Inodes

* inode limits are real
* inode exhaustion is common in servers
* many small files are dangerous
* monitoring inode usage is essential

You don’t need to panic — just **be aware**.

---

## Part 2 — Buffered vs Unbuffered I/O

Before continuing with devices, we need to clarify these terms.

---

### 8. What Is an I/O Device?

An **I/O device** is anything that:

* produces output
* accepts input

Examples:

* disks
* keyboard
* mouse
* network interfaces
* sensors
* terminals

On Linux, **most I/O devices are represented as files**.

---

### 9. Unbuffered I/O

**Definition:**

* data flows directly between device and program
* no temporary storage

**Advantages:**

* immediate data delivery
* precise timing
* real-time behavior

**Disadvantages:**

* inefficient
* many system calls
* slower for large data

---

### 10. Examples of Unbuffered I/O

* keyboard input
* mouse movement
* sensors
* real-time signals

Example:

```bash
sudo cat /dev/input/mice
```

* raw binary mouse data
* processed immediately
* no buffering
* terminal displays garbage (binary data)

This is **expected behavior**.

---

### 11. Buffered I/O

**Definition:**

* data is collected in a buffer
* processed in chunks

**Advantages:**

* fewer I/O operations
* better performance
* efficient disk and network access
* easier integrity checks

**Disadvantages:**

* slight delay
* not suitable for real-time input

---

### 12. Examples of Buffered I/O

* reading files from disk
* writing logs
* network transfers
* database reads/writes

Buffered I/O allows:

* prefetching
* batching
* reduced system overhead

---

### 13. Why Buffering Improves Performance

Instead of:

* reading 1 byte at a time

Buffered I/O:

* reads 4KB, 8KB, or more at once

This:

* reduces context switches
* improves throughput
* simplifies error detection

---

### 14. When Unbuffered I/O Is Required

Buffered I/O would be **bad** for:

* mouse movement
* keyboard input
* real-time systems
* interactive terminals

You don’t want your mouse cursor to move **seconds later**.

---

### 15. Choosing the Right Model

| Use Case         | Best Choice |
| ---------------- | ----------- |
| Mouse / Keyboard | Unbuffered  |
| Disk files       | Buffered    |
| Network streams  | Buffered    |
| Sensors          | Unbuffered  |
| Logs             | Buffered    |

There is **no universal winner**.

---

## Final Summary

### Inode Limits

* filesystems have a fixed number of inodes
* too many small files can break systems
* disk space ≠ inode availability
* monitoring is critical

### Buffered vs Unbuffered I/O

* unbuffered = real-time, immediate
* buffered = efficient, high-performance
* Linux uses both, depending on context














# Devices in Unix/Linux

## 1. What Is a Device?

In Unix and Linux, you often hear the phrase:

> **“Everything is a file.”**

A more precise and famous formulation (often attributed to Linus Torvalds) is:

> **“Everything is a stream of bytes.”**

### Why this distinction matters

* A **file** usually exists on a filesystem
* A **stream of bytes** may:

  * come from hardware
  * come from the kernel
  * not physically exist on disk

So the second statement is more accurate.

---

## 2. Devices as Files

In Unix-like systems:

* hardware devices
* virtual devices
* kernel interfaces

are exposed as **file-like objects**.

This allows:

* programs to read/write devices
* without knowing hardware details
* using normal system calls (`read`, `write`)

The kernel:

* hides complexity
* translates file operations into hardware operations

---

## 3. Where Devices Live

Most devices are found in:

```bash
/dev
```

This directory contains **device files**, not regular data files.

They act as interfaces between:

* user programs
* the kernel
* hardware or virtual components

---

## 4. Device Types

Unix supports **two main device types**:

### 4.1 Character Devices (`c`)

* unbuffered access
* byte-by-byte or character-by-character
* direct interaction with hardware

Typical use cases:

* keyboard
* mouse
* serial ports
* terminals

Characteristics:

* read/write one byte at a time
* low latency
* real-time behavior

---

### 4.2 Block Devices (`b`)

* buffered access
* data read in fixed-size blocks
* optimized for performance

Typical use cases:

* hard disks
* SSDs
* partitions

Characteristics:

* block sizes (e.g. 512 bytes, 4KB)
* better throughput
* slightly higher latency

---

## 5. Pseudo Devices

Not all devices represent physical hardware.

Some are **virtual (pseudo) devices**:

* implemented by the kernel
* still accessed like files

Examples:

* partitions (`/dev/sda1`)
* terminals
* random generators

These can be:

* character devices
* block devices

---

## 6. Inspecting Devices

Use:

```bash
ls -l /dev
```

First column indicates type:

* `c` → character device
* `b` → block device

Example:

```text
brw-rw---- 1 root disk … sda1
```

This shows:

* a block device
* buffered disk access

---

## 7. Accessing Devices as Files (⚠️ Caution)

You *can* read devices like files:

```bash
sudo cat /dev/sda1
```

But:

* output is binary
* may contain escape sequences
* can break your terminal

**Avoid printing raw binary data to the terminal.**

---

## 8. Terminal Devices (`/dev/tty`, `/dev/pts/*`)

Each terminal has its own device file.

Check current terminal:

```bash
tty
```

Example output:

```text
/dev/pts/0
```

This is your **pseudo-terminal**.

---

### Writing to a Terminal Device

From another terminal:

```bash
echo "Hello World" > /dev/pts/0
```

Result:

* text appears in the other terminal

This works because:

* terminals are devices
* writing to them sends output directly

---

## 9. Why This Matters

Devices allow:

* inter-process communication
* terminal multiplexing
* redirection of input/output
* hardware abstraction

You already use this daily without realizing it.

---

# Important Pseudo Devices

## 10. `/dev/null`

### Behavior

* reading → immediate EOF
* writing → data discarded

### Common usage

Discard output:

```bash
command > /dev/null
```

Discard errors:

```bash
command 2> /dev/null
```

Discard everything:

```bash
command > /dev/null 2>&1
```

---

## 11. `/dev/random`

* cryptographically secure random data
* waits for environmental entropy
* may block

Good for:

* cryptography
* key generation

Example (safe):

```bash
head -c 16 /dev/random > random.bin
```

---

## 12. `/dev/urandom`

* non-blocking
* reuses entropy
* faster

Good for:

* most applications
* IDs
* session tokens

Less ideal for:

* high-security cryptography

---

## 13. Standard Streams as Devices

| Stream | Device        |
| ------ | ------------- |
| stdin  | `/dev/stdin`  |
| stdout | `/dev/stdout` |
| stderr | `/dev/stderr` |

Example:

```bash
echo "Hello" > /dev/stdout
```

Same as:

```bash
echo "Hello"
```

Key insight:

> **All output is written to a file — even the terminal.**

---

# The `/proc` Filesystem

## 14. What Is `/proc`?

* virtual filesystem
* generated by the kernel
* reflects current system state
* files do not exist on disk

Used for:

* system inspection
* debugging
* monitoring

---

## 15. `/proc/cpuinfo`

Shows:

* CPU model
* vendor
* frequency
* cache
* instruction flags
* logical cores

Useful for:

* verifying VM CPU allocation
* checking hardware features

---

## 16. `/proc/meminfo`

Shows:

* total memory
* free memory
* available memory
* buffers/cache

Useful for:

* validating RAM size
* diagnosing memory pressure

---

## 17. `/proc/version`

Shows:

* kernel version
* compiler
* build info

---

## 18. `/proc/uptime`

Shows:

* system uptime (seconds)
* cumulative idle time

Idle time can exceed uptime because:

* multiple CPU cores idle simultaneously

---

## 19. `/proc/loadavg`

Shows:

* load average (1, 5, 15 minutes)
* running processes
* total threads
* last PID

Example:

```text
0.03 0.02 0.00 1/442 12345
```

---

## 20. Why `/proc` Is Important

* real-time system introspection
* no special tools needed
* always up to date
* works on servers and VMs

These are **not real files**, but:

* behave like files
* generated dynamically














# Filesystem Hierarchy Standard (FHS)

## 1. What Is the Filesystem Hierarchy Standard?

The **Filesystem Hierarchy Standard (FHS)** defines **how directories are structured** on Unix-like operating systems.

Its goals are:

* consistency across systems
* predictability of file locations
* easier system administration
* compatibility across distributions

### Important notes

* FHS is a **standard**, not a rule
* systems are **not forced** to follow it
* macOS and some Linux distributions **deviate slightly**
* modern Linux systems increasingly use **symlinks** (the *usr merge*)

Despite that, FHS still gives a **very good mental model** of a Unix system.

---

## 2. The Root Directory (`/`)

The root directory is:

```text
/
```

* top of the filesystem hierarchy
* **all files and directories exist under `/`**
* all absolute paths start here

You can view it via:

```bash
cd /
ls
```

This is the directory you see when opening the “computer” or “filesystem” view in a file browser.

---

## 3. `/bin` – Essential User Binaries

### Purpose

* essential command binaries
* required for basic system operation
* usable by all users

Examples:

* `ls`
* `cp`
* `mv`
* `cat`
* `echo`

### Modern systems (usr merge)

On many modern systems:

```text
/bin → /usr/bin
```

Meaning:

* `/bin` is a **symlink**
* real binaries live in `/usr/bin`

This simplifies the filesystem layout.

---

## 4. `/boot` – Boot Loader Files

### Purpose

Contains files required to **boot the system**:

* Linux kernel (`vmlinuz`)
* initramfs / initrd
* bootloader configuration (e.g. GRUB)

Without `/boot`, the system **cannot start**.

---

## 5. `/dev` – Device Files

### Purpose

Contains **device files** representing:

* hardware devices
* virtual devices
* kernel interfaces

Examples:

* `/dev/sda` – disk
* `/dev/null`
* `/dev/tty`

Devices appear as files so programs can interact with hardware using standard file operations.

---

## 6. `/etc` – System Configuration

### Purpose

Contains **system-wide configuration files**.

Characteristics:

* mostly text files
* editable by administrators
* no binaries

Examples:

* network configuration
* service configuration
* systemd units
* cron jobs
* VPN configuration
* web server configs

Think of `/etc` as:

> **“How the system is configured”**

---

## 7. `/home` – User Home Directories

### Purpose

Stores **personal data for users**.

Structure:

```text
/home/username
```

Contains:

* documents
* downloads
* user configuration
* application settings

Permissions ensure:

* users can access **their own data**
* users cannot access **other users’ data**

---

## 8. `/lib` – Shared Libraries

### Purpose

Contains **libraries required by binaries** in:

* `/bin`
* `/sbin`

Libraries are files that programs load at runtime.

### Architectures

You may see:

* `/lib`
* `/lib32`
* `/lib64`

These support different CPU architectures (32-bit, 64-bit).

### Modern systems

Often merged into:

```text
/lib → /usr/lib
```

---

## 9. `/media` – Removable Media Mount Points

### Purpose

Used for **automatically mounted removable devices**:

* USB drives
* SD cards
* external SSDs

Typical path:

```text
/media/username/device-name
```

These mounts:

* appear in file managers
* are user-friendly
* are meant for temporary storage

---

## 10. `/mnt` – Temporary / Manual Mount Points

### Purpose

Used for **manual or temporary mounts**.

Common use cases:

* mounting extra disks
* mounting network shares
* testing filesystems

Unlike `/media`:

* usually **not shown in GUI**
* typically managed by administrators

---

## 11. `/opt` – Optional Software

### Purpose

Stores **optional or third-party software** not part of the core OS.

Typical structure:

```text
/opt/application-name
```

Usage varies:

* rarely used on Ubuntu/CentOS
* commonly used by:

  * vendor software
  * virtual machine tools
  * macOS Homebrew packages

Think of `/opt` as:

> **“Optional, self-contained software”**

---

## 12. Summary (So Far)

| Directory | Purpose                 |
| --------- | ----------------------- |
| `/`       | Root of filesystem      |
| `/bin`    | Essential user commands |
| `/boot`   | Boot loader & kernel    |
| `/dev`    | Device files            |
| `/etc`    | System configuration    |
| `/home`   | User data               |
| `/lib`    | Shared libraries        |
| `/media`  | Removable media         |
| `/mnt`    | Temporary mounts        |
| `/opt`    | Optional software       |

---

## 13. Key Takeaways

* FHS provides **structure and predictability**
* modern systems use **symlinks** to simplify layout
* not every system follows FHS strictly
* understanding these directories is **essential for Linux administration**














# Filesystem Hierarchy Standard (FHS) — Part 2



## 1. `/proc` — Process & Kernel Information

### What it is

* A **virtual filesystem**
* Usually provided by **procfs**
* Files are **generated on the fly**
* Does **not** store real data on disk

### Purpose

* Exposes information about:

  * running processes
  * CPU
  * memory
  * kernel state

Examples:

```bash
/proc/cpuinfo
/proc/meminfo
/proc/uptime
/proc/loadavg
```

### Key idea

> `/proc` is an **interface to the kernel**, not a real storage location.

You already saw this folder earlier in a dedicated lecture.

---

## 2. `/root` — Home Directory of Root User

### Purpose

* Personal home directory of the **root user**
* Equivalent to `/home/username` for normal users

### Important notes

* Normal users **cannot access** `/root`
* Used for:

  * root configuration files
  * administrative scripts
  * emergency access

This separation is intentional for **security reasons**.

---

## 3. `/run` — Runtime Data

### What it is

* Stores **temporary runtime data**
* Files here:

  * exist only while the system is running
  * are removed on reboot or shutdown

### Examples of data stored

* PID files
* sockets
* runtime state for services (e.g. systemd)
* temporary service configuration

### Backed by tmpfs

On modern Linux systems:

```bash
df -h
```

You’ll usually see:

```text
tmpfs mounted on /run
```

This means:

* data lives in **memory**
* nothing survives reboot

### Key rule

> **Never store permanent data in `/run`.**

---

## 4. `/sbin` — System Binaries

### Purpose

* Essential binaries used mainly by **root**
* System administration tools

Examples:

* package management tools
* disk utilities
* networking tools

### Modern systems

Like `/bin`, `/sbin` is often merged:

```text
/sbin → /usr/sbin
```

This is part of the **usr merge** effort.

---

## 5. `/srv` — Service Data

### Purpose

* Data served by system services

Examples:

* FTP server data
* HTTP server data (alternative to `/var/www`)

### Reality

* Rarely used in practice
* Often empty
* Many distributions prefer `/var`

You’ll often see:

```bash
/srv
```

existing but unused.

---

## 6. `/sys` — Kernel & Device Information (sysfs)

### What it is

* Virtual filesystem
* Provided by **sysfs**
* Exposes:

  * devices
  * drivers
  * kernel features

### Examples

```text
/sys/devices
/sys/class
/sys/kernel
```

### Usage

* Hardware inspection
* Power management
* Kernel tuning
* Advanced diagnostics

> Most users rarely interact with `/sys` directly, but it is critical for system tools.

---

## 7. `/tmp` — Temporary Files

### Purpose

* Stores **temporary files** created by:

  * applications
  * users
  * system processes

### Characteristics

* World-writable
* Files are:

  * often deleted on reboot
  * may be cleaned automatically

### Common use case

Example:

* Web server file upload
* Temporary image processing
* Intermediate computation results

### Application isolation

Some services:

* get **private `/tmp` directories**
* implemented via mount namespaces
* improves security

---

## 8. `/usr` — User System Resources

### Purpose

Contains **shareable, mostly read-only system data**.

Think of `/usr` as:

> **The main system software directory**

### Contains

* `/usr/bin` — binaries
* `/usr/sbin` — admin binaries
* `/usr/lib` — libraries
* `/usr/share` — architecture-independent data

### Shareable design

* Safe to mount from network storage
* Same across multiple machines

---

## 9. `/usr/local` — Local Software

### Purpose

* Software **not managed by the system package manager**
* Machine-specific installations

Examples:

* proprietary tools
* manually compiled programs
* locally installed binaries

### Important distinction

| Directory    | Meaning                          |
| ------------ | -------------------------------- |
| `/usr`       | Shareable system software        |
| `/usr/local` | Local, machine-specific software |

Ideally:

* deleting `/usr/local` does **not delete user data**
* software can be reinstalled

---

## 10. `/var` — Variable Data (CRITICAL)

### Purpose

Stores data that **changes while the system runs**.

### Examples

* logs (`/var/log`)
* databases (`/var/lib/mysql`)
* mail spools
* web content (`/var/www`)
* caches

### Backup importance

> `/var` is one of the **most important directories to back up**.

Especially:

* databases
* websites
* application data

Logs are optional, but data is not.

---

## 11. Distribution-Specific Directories

### Example: `/snap` (Ubuntu)

* Used by **Snap packages**
* Alternative package format
* Not part of classic FHS
* Added later as packaging evolved

Other examples:

* Flatpak
* AppImage (no directory, single files)

These exist **outside FHS**, but are now common.

---

## 12. `lost+found`

### Purpose

* Filesystem recovery directory
* Used by `fsck`

### Behavior

* Appears only at filesystem root
* Stores recovered files after crashes

Usually:

* hidden in GUI
* visible in terminal

You normally **never touch** this folder manually.

---

## 13. Summary Table

| Directory    | Purpose                   |
| ------------ | ------------------------- |
| `/proc`      | Kernel & process info     |
| `/root`      | Root user home            |
| `/run`       | Runtime data (tmpfs)      |
| `/sbin`      | System binaries           |
| `/srv`       | Service data              |
| `/sys`       | Kernel & device info      |
| `/tmp`       | Temporary files           |
| `/usr`       | System software           |
| `/usr/local` | Local software            |
| `/var`       | Variable application data |
| `/snap`      | Snap packages (Ubuntu)    |
| `lost+found` | Filesystem recovery       |

---

## 14. Key Takeaways

* Each directory has a **clear purpose**
* Temporary vs persistent data matters
* `/var` and `/home` are **backup priorities**
* Many directories are now **symlinks** due to usr merge
* Not everything follows FHS strictly, but the model still applies


















# The `/usr` Merge Project — Why It Exists and Why It Matters



## 1. Historical Context: Why Linux Originally Had Separate Directories

Linux (and Unix) originated at a time when:

* Hard drives were **very small**
* Storage was **expensive**
* Systems often used **multiple physical disks**
* Reliability was a real concern

Early systems might have had:

* 100 MB disks
* 500 MB disks
* 1 GB disks (considered large at the time)

Because of these limitations, **disk layout mattered a lot**.

---

## 2. Original Design Goal: Survivability and Recovery

Originally, Linux systems were designed so that:

* The **root filesystem (`/`)** contained only **essential tools**
* The **`/usr` directory** could live on a **separate disk**

### Why was this important?

If:

* The disk containing `/usr` failed, or
* The disk was temporarily unavailable,

Then the system could still:

* Boot into **recovery mode**
* Use essential tools in:

  * `/bin`
  * `/sbin`
  * `/lib`
* Diagnose and repair the system

This separation allowed:

* Minimal system boot
* Emergency maintenance
* Disk flexibility

---

## 3. Original Directory Roles (Before Merge)

| Directory   | Original Purpose                |
| ----------- | ------------------------------- |
| `/bin`      | Essential user commands         |
| `/sbin`     | Essential system/admin commands |
| `/lib`      | Essential shared libraries      |
| `/usr/bin`  | Non-essential user programs     |
| `/usr/sbin` | Non-essential admin programs    |
| `/usr/lib`  | Non-essential libraries         |

**Key idea:**

> Everything needed to boot and repair the system had to be available **without `/usr`**.

---

## 4. Why This Design No Longer Makes Sense (Usually)

Today’s systems are very different:

* SSDs are large and cheap
* Single-disk systems are common
* `/usr` almost always lives on the **same disk** as `/`
* Recovery environments are more advanced
* Initramfs and systemd handle early boot needs

As a result:

* Maintaining duplicate directory trees adds **complexity**
* The separation no longer provides real benefits in most cases

---

## 5. The `/usr` Merge Project: The Modern Approach

The **`/usr` merge project** simplifies the filesystem layout by:

* Moving **all binaries and libraries** into `/usr`
* Replacing old directories with **symbolic links**

### Typical merged layout today:

```text
/bin   → /usr/bin
/sbin  → /usr/sbin
/lib   → /usr/lib
/lib64 → /usr/lib64
```

From the user’s perspective:

* Everything still “works”
* Old paths remain valid via symlinks
* New software only installs into `/usr`

---

## 6. Why This Takes a Long Time

This transition cannot happen instantly because:

* **Old software expects old paths**
* Hard-coded paths still exist
* Scripts rely on `/bin`, `/lib`, etc.

As a result:

* Distributions keep symlinks
* Compatibility is preserved
* Migration happens gradually

This process:

* Has already taken many years
* Will likely continue for many more

---

## 7. Important Clarification

* The **`/usr` merge is NOT part of the Filesystem Hierarchy Standard (FHS)**
* It is a **distribution-level design choice**
* Most modern Linux distributions:

  * Ubuntu
  * Debian
  * Fedora
  * Arch
  * RHEL (newer versions)

have **already implemented** the merge.

---

## 8. Why Everything Lives in `/usr` Today

So when you see:

* `/bin` → `/usr/bin`
* `/sbin` → `/usr/sbin`
* `/lib` → `/usr/lib`

This is **not accidental**.

It is the result of:

* Hardware evolution
* Simpler boot processes
* Reduced need for split disks
* Long-term maintenance decisions

---

## 9. Key Takeaways

* The old layout existed for **hardware limitations**
* Modern systems no longer need that separation
* `/usr` merge simplifies Linux systems
* Symlinks preserve backward compatibility
* This change is **practical**, not theoretical

---

### One-Sentence Summary for Interviews

> “The `/usr` merge simplifies Linux filesystems by moving binaries and libraries into `/usr`, a change made possible by modern storage and boot mechanisms, while maintaining backward compatibility through symlinks.”














# User Management in Linux — Overview and Core Concepts


## 1. Types of Users in Linux

A Linux system can have **different types of users**, each with a specific purpose.

### 1.1 Root User

* The **root user** has the highest privileges on the system
* Can perform **any operation**
* Has **user ID (UID) 0**
* There can be **only one root user** on a Linux system
* Root access is extremely powerful and therefore dangerous if misused

---

### 1.2 Regular Users

* Normal human users of the system
* Have **limited privileges**
* Cannot modify system-wide configuration by default
* Can be granted **temporary root privileges** using `sudo`
* This allows controlled administrative access without logging in as root



### 1.3 Service (System) Users

* Used to run **background services**
* Examples:

  * Web servers
  * Databases
  * SSH daemon
  * Time synchronization services
* These users:

  * Do not represent humans
  * Usually cannot log in
  * Have restricted permissions

**Purpose:**
To isolate services so that even if one service is compromised, the attacker cannot access other users’ data or system files.

---

## 2. Users and Groups

Every Linux user:

* Has **exactly one primary group**
* Can belong to **zero or more secondary groups**

This distinction matters because:

* The **primary group** is stored in one file
* **Secondary groups** are stored in another file

We will see this shortly.

---

## 3. Where User Information Is Stored

Linux stores user-related information in **text files**, primarily in `/etc`.

### 3.1 `/etc/passwd`

This file contains **basic user account information**:

* Username
* User ID (UID)
* Primary group ID (GID)
* User description (comment / full name)
* Home directory
* Default login shell

Despite the name, **it does NOT store passwords**.

#### Why use IDs instead of names?

* IDs are **numbers**, which are faster and more reliable than strings
* Files store ownership by **UID and GID**, not usernames
* Usernames can change; IDs usually do not

---

### Example: Viewing `/etc/passwd`

```bash
cat /etc/passwd
```

Each line represents one user.

#### Root user example:

* UID: `0`
* GID: `0`
* Home directory: `/root`
* Shell: `/bin/bash` (or similar)

#### Regular user example:

* Unique UID
* Own home directory (e.g. `/home/username`)
* Default shell

#### Service users:

* Often have:

  * No login shell (`/usr/sbin/nologin`)
  * No home directory
* Exist only to run services safely

---

## 4. Password Storage — `/etc/shadow`

Passwords are stored separately in:

```
/etc/shadow
```

This file contains:

* Encrypted passwords
* Password aging information
* Last password change date
* Expiration settings

### Security properties:

* **Readable only by root**
* Normal users cannot access it
* Protects encrypted passwords from exposure

#### Attempting access as a normal user:

```bash
cat /etc/shadow
# Permission denied
```

#### Access using sudo:

```bash
sudo cat /etc/shadow
```

---

### Password Encryption

* Passwords are stored as **cryptographic hashes**
* Commonly uses modern hashing algorithms (e.g., yescrypt / bcrypt-like schemes)
* Hashes:

  * Cannot be reversed
  * Cannot be searched online
  * Must be brute-forced to crack

---

### Disabled Passwords

Some users (including `root` on many systems) may show:

```
*
```

or

```
!
```

This means:

* Password login is **disabled**
* Root access is only possible via `sudo` or other controlled mechanisms

This is common and recommended for security.

---

## 5. Group Information — `/etc/group`

Group membership is stored in:

```
/etc/group
```

This file contains:

* Group name
* Group ID (GID)
* List of users belonging to the group

### Important distinction:

* **Primary group** → stored in `/etc/passwd`
* **Secondary groups** → stored in `/etc/group`

---

### Example: Viewing `/etc/group`

```bash
cat /etc/group
```

You will see:

* System groups
* Service groups
* User-defined groups
* Groups with multiple users

This structure allows flexible permission management.

---

## 6. Why We Don’t Edit These Files Manually

Although these files are plain text:

* Editing them directly is **dangerous**
* A single mistake can:

  * Break login
  * Lock users out
  * Corrupt permissions

Instead, Linux provides **dedicated commands** that:

* Safely update these files
* Perform validation
* Handle edge cases correctly


