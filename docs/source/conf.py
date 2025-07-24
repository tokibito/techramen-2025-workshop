# Configuration file for the Sphinx documentation builder.
#
# For the full list of built-in configuration values, see the documentation:
# https://www.sphinx-doc.org/en/master/usage/configuration.html

# -- Project information -----------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#project-information

project = 'SQL基礎トレーニング～JOIN、GROUP BYの使い方を学ぼう'
copyright = '2025, Shinya Okano'
author = 'Shinya Okano'

# -- General configuration ---------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#general-configuration

import sys
import os
sys.path.insert(0, os.path.abspath('_ext'))

extensions = [
    'sphinxcontrib.mermaid',
    'sphinx_copybutton',
    'japanese_sql',  # カスタム拡張: 日本語SQLの改善
]

templates_path = ['_templates']
exclude_patterns = []

language = 'ja'

# -- Options for HTML output -------------------------------------------------
# https://www.sphinx-doc.org/en/master/usage/configuration.html#options-for-html-output

html_theme = 'bizstyle'
html_static_path = ['_static']
html_theme_options = {
    'maincolor': '#343434',
}
html_css_files = ['custom.css']
html_use_modindex = False
html_use_index = False
html_short_title = 'SQL基礎トレーニング'
html_show_sourcelink = False

# -- Options for Mermaid -----------------------------------------------------
# Mermaid設定
mermaid_version = "10.6.1"

# -- Options for Pygments (syntax highlighting) -------------------------------
# Pygments設定
pygments_style = 'default'
highlight_language = 'sql'

# コードブロックのオプション
highlight_options = {
    'stripall': False,  # 改行を保持
    'stripnl': False,   # 末尾の改行を保持
}

# Sphinxのハイライト設定
# 日本語を含むSQLコードでエラーが発生した場合、自動的にrelaxedモードを使用
suppress_warnings = []  # highlighting_failureの警告は表示するが、relaxedモードは有効