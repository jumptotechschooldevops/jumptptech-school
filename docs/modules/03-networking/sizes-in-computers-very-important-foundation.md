---
title: "Sizes in Computers (VERY IMPORTANT FOUNDATION)"
description: "P           NUMBER SYSTEMS &amp; HEX ↔ DECIMAL   number systems and specifically how to convert..."
published: 2026-04-16
source: "https://dev.to/jumptotech/sizes-in-computers-very-important-foundation-5d1f"
tags: []
---

# Sizes in Computers (VERY IMPORTANT FOUNDATION)


P

#  NUMBER SYSTEMS & HEX ↔ DECIMAL



number systems and specifically how to convert between hexadecimal and decimal.

In computing and networking, we use different types of number systems. A number system is simply a way to represent numbers.

In everyday life, we use the decimal system, which is base 10. That means it uses digits from 0 to 9.

In computing, there are three other very important number systems:

* Binary (base 2)
* Octal (base 8)
* Hexadecimal (base 16)


Hexadecimal is a positional number system with base 16. It uses 16 symbols:

* 0 to 9
* A, B, C, D, E, F

The letters represent values:

```text id="hexmap"
A = 10
B = 11
C = 12
D = 13
E = 14
F = 15
```



Each position in a hexadecimal number represents a power of 16.

For example, a two-digit hex number has positions:

```text id="pos16"
16^1   16^0
```



# 🧪 EXAMPLE 1 — HEX → DECIMAL

Convert B6 to decimal.

Step 1: Write positional values.

```text id="ex1pos"
B   6
16^1 16^0
```

Step 2: Convert hex to decimal.

```text id="ex1conv"
B = 11
6 = 6
```

Step 3: Multiply by powers.

```text id="ex1math"
11 × 16 = 176
6 × 1 = 6
```

Step 4: Add results.

```text id="ex1sum"
176 + 6 = 182
```

So, B6 in hexadecimal equals 182 in decimal.

---

# 🧪 EXAMPLE 2 — HEX → DECIMAL

Convert A59C to decimal.

Step 1: Positions:

```text id="ex2pos"
A   5   9   C
16^3 16^2 16^1 16^0
```

Step 2: Convert values:

```text id="ex2conv"
A = 10
5 = 5
9 = 9
C = 12
```

Step 3: Multiply:

```text id="ex2math"
10 × 16^3 = 40960
5 × 16^2 = 1280
9 × 16 = 144
12 × 1 = 12
```

Step 4: Add:

```text id="ex2sum"
40960 + 1280 + 144 + 12 = 42396
```

So, A59C equals 42396 in decimal.

---

# 🔁 DECIMAL → HEXADECIMAL

Now we do the reverse.

We convert decimal to hexadecimal using **division by 16**.

---

# 🧪 EXAMPLE 3 — DECIMAL → HEX

Convert 256 to hexadecimal.

Step-by-step:

```text id="ex3steps"
256 ÷ 16 = 16 remainder 0
16 ÷ 16 = 1 remainder 0
1 ÷ 16 = 0 remainder 1
```

Now write remainders from bottom to top:

```text id="ex3result"
100
```

So:

256 = 100 (hex)

---

# 🧪 EXAMPLE 4 — DECIMAL → HEX

Convert 7562 to hexadecimal.

Step-by-step:

```text id="ex4steps"
7562 ÷ 16 = 472 remainder 10
472 ÷ 16 = 29 remainder 8
29 ÷ 16 = 1 remainder 13
1 ÷ 16 = 0 remainder 1
```

Convert remainders:

```text id="ex4conv"
10 = A
8 = 8
13 = D
1 = 1
```

Write bottom to top:

```text id="ex4result"
1D8A
```

So:

7562 = 1D8A (hex)

---

# 🧠 IMPORTANT RULES

### Hex → Decimal

👉 Multiply each digit by powers of 16 and add

### Decimal → Hex

👉 Divide by 16 repeatedly and collect remainders



“Hexadecimal is base 16, which means each position represents powers of 16. To convert from hex to decimal, we multiply each digit by its positional value and add the results. To convert from decimal to hex, we repeatedly divide by 16 and track the remainders.”

---

# 🧠 WHY THIS IS IMPORTANT (NETWORKING)

In networking:

* MAC addresses use hexadecimal
* IPv6 uses hexadecimal
* Memory addresses use hexadecimal

---

# 💻 PRACTICE 

### Convert to decimal:

```text id="practice1"
1A
2F
FF
```

---

### Convert to hex:

```text id="practice2"
100
500
1024
```

---

# 🚀 INTERVIEW ANSWER

“Hexadecimal is a base-16 number system commonly used in computing. Conversion from hex to decimal involves multiplying digits by powers of 16, while conversion from decimal to hex uses repeated division by 16.”

---

# 🎯 FINAL SUMMARY

* Decimal = base 10
* Hex = base 16
* Hex uses 0–9 and A–F
* Use multiplication for hex → decimal
* Use division for decimal → hex





Everything in networking is based on **bits → bytes → IP**

---

## What is a BIT?

👉 A **bit** is the smallest unit of data

```text
bit = 0 or 1
```

* 0 = OFF
* 1 = ON

---

## What is a BYTE?

👉 A **byte = 8 bits**

```text
1 byte = 8 bits
```

Example:

```text
10101010  → 1 byte
```

---

## What is an OCTET?

👉 An **octet = 8 bits (same as byte)**

In networking, we say:

* **byte** → general computing
* **octet** → networking (IP addresses)

---

# 🎯 KEY IDEA

```text
1 octet = 8 bits = numbers from 0 to 255
```

---

# 🎓 2. Why 0–255?

Because:

2^8 = 256

👉 So:

```text
0 to 255 = 256 values
```

---

# 🎓 3. Structure of IP Address

Example:

```text
192.168.1.10
```

This has **4 octets**:

```text
[192] [168] [1] [10]
```

Each one = **8 bits**

Total:

```text
4 × 8 = 32 bits
```

---

# 🎓 4. The “BOX METHOD” (This is what you asked)

This is how you convert numbers like **192 into bits**

---

## Step 1 — Draw boxes

Each octet has **8 boxes (bits)**

```text
128  64  32  16  8  4  2  1
[  ] [  ] [  ] [  ] [ ] [ ] [ ] [ ]
```

👉 These numbers are powers of 2

---

# 🎓 5. Example: Convert 192

We need to make **192 using these numbers**

---

## Step-by-step:

```text
192 - 128 = 64 → use 128 → put 1
64 - 64 = 0   → use 64  → put 1
```

Remaining = 0 → rest are 0

---

## Final boxes:

```text
128  64  32  16  8  4  2  1
 1    1   0   0   0  0  0  0
```

---

## Final answer:

```text
192 = 11000000
```

---

# 🎓 6. Example: Convert 168

---

## Step-by-step:

```text
168 - 128 = 40 → 1
40 - 32 = 8   → 1
8 - 8 = 0     → 1
```

---

## Boxes:

```text
128  64  32  16  8  4  2  1
 1    0   1   0   1  0  0  0
```

---

## Final:

```text
168 = 10101000
```

---

# 🎓 7. Example: Convert 1

```text
00000001
```

---

# 🎓 8. Example: Convert 0

```text
00000000
```

---

# 🎓 9. Full IP in Binary

```text
192.168.1.10 =
11000000.10101000.00000001.00001010
```

---

# 🎓 10. VERY SIMPLE MEMORY TRICK

👉 Think:

```text
Big numbers → left side
Small numbers → right side
```

---

# 🎓 11. Shortcut Table (Memorize This)

| Decimal | Binary   |
| ------- | -------- |
| 128     | 10000000 |
| 192     | 11000000 |
| 224     | 11100000 |
| 240     | 11110000 |
| 248     | 11111000 |
| 252     | 11111100 |
| 255     | 11111111 |

👉 These are used in subnet masks

---

# 🎓 12. Why This Matters

You need this to understand:

* subnet mask
* network vs host
* AWS VPC
* CIDR

---

# 🎓 FINAL SUMMARY

👉 bit = 0 or 1
👉 8 bits = 1 byte = 1 octet
👉 octet = 0–255
👉 IP = 4 octets = 32 bits
👉 boxes = powers of 2
👉 fill with 1s to reach number


