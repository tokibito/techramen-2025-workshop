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

extensions = []

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