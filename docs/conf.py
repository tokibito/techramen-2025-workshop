# Configuration file for the Sphinx documentation builder.
# TechRAMEN 2025 SQLワークショップドキュメント設定

# -- Path setup --------------------------------------------------------------
import os
import sys
sys.path.insert(0, os.path.abspath('.'))

# -- Project information -----------------------------------------------------
project = 'SQL基礎トレーニング'
copyright = '2025, tokibito'
author = 'tokibito'
version = '1.0'
release = '1.0.0'

# -- General configuration ---------------------------------------------------
extensions = [
    'myst_parser',
    'sphinx.ext.autodoc',
    'sphinx.ext.viewcode',
    'sphinx.ext.todo',
]

templates_path = ['_templates']
exclude_patterns = ['_build', 'Thumbs.db', '.DS_Store']

language = 'ja'

# -- Options for HTML output -------------------------------------------------
html_theme = 'sphinx_rtd_theme'
html_static_path = ['_static']
html_theme_options = {
    'display_version': True,
    'prev_next_buttons_location': 'both',
    'style_nav_header_background': '#2980B9',
    'collapse_navigation': False,
    'sticky_navigation': True,
    'navigation_depth': 4,
}

# -- Options for MyST --------------------------------------------------------
myst_enable_extensions = [
    "colon_fence",
    "deflist",
    "dollarmath",
    "html_image",
    "linkify",
    "replacements",
    "smartquotes",
    "substitution",
    "tasklist",
]

myst_heading_anchors = 3

# -- Options for todo extension ----------------------------------------------
todo_include_todos = True