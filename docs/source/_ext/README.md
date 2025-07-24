# Japanese SQL Extension for Sphinx

This directory contains a custom Sphinx extension that improves the handling of Japanese characters in SQL code blocks.

## Problem

By default, Pygments' SQL lexer treats Japanese characters (Hiragana, Katakana, and Kanji) as errors, causing them to be highlighted with error styling in the generated HTML documentation.

## Solution

The `japanese_sql.py` extension provides:

1. **JapaneseSqlLexer**: A custom lexer that extends Pygments' SqlLexer to properly handle Japanese characters
2. **Automatic detection**: When SQL code contains Japanese characters, the extension automatically uses the custom lexer
3. **Proper tokenization**: Japanese characters in identifiers, comments, and strings are correctly classified

## Features

- Detects Japanese characters in SQL code blocks automatically
- Treats Japanese identifiers (table names, column names) as proper names instead of errors
- Preserves proper syntax highlighting for SQL keywords, operators, and punctuation
- Works seamlessly with existing Sphinx documentation

## Usage

The extension is automatically loaded through conf.py and applies to all SQL code blocks in the documentation.