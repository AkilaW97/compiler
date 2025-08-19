# Lexical Analyzer with Symbol Table

This project implements a **lexical analyzer** using [Flex](https://github.com/westes/flex) (Fast Lexical Analyzer Generator).  
It includes a **symbol table** to keep track of identifiers, keywords, and other tokens in C-like source code.

---

## 📂 Project Structure

- **scanner.l**  
  The Flex specification file that defines token rules and the logic for symbol table management.

- **lex.yy.c**  
  Auto-generated C source file produced by running `flex` on `scanner.l`.  
  ⚠️ Do not edit manually. Always regenerate using `flex scanner.l`.

- **a.out**  
  The compiled lexical analyzer executable (produced after running `gcc lex.yy.c`).

- **run.sh**  
  A Bash script that automates:  
  1. Generating `lex.yy.c` from `scanner.l`.  
  2. Compiling the scanner with `gcc`.  
  3. Running the executable on all test cases in the `tests/` folder.

- **tests/**  
  A directory containing `.c` test files. Each file is scanned to produce tokens and update the symbol table.

---

## ⚙️ Build Instructions

Make sure you have **Flex** and **GCC** installed. On Ubuntu/Debian:

```bash
sudo apt-get install flex gcc
