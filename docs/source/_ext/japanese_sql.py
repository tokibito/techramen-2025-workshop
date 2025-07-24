"""
Sphinx extension to improve Japanese SQL syntax highlighting.
This extension modifies Pygments behavior for SQL code containing Japanese characters.
"""

from sphinx.highlighting import PygmentsBridge
from pygments.lexers import SqlLexer, get_lexer_by_name
from pygments.token import Token, Name, String, Comment, Keyword, Number, Operator, Punctuation, Whitespace, Error
from pygments.lexer import bygroups
import re


class JapaneseSqlLexer(SqlLexer):
    """SQL lexer that handles Japanese characters better."""
    
    name = 'JapaneseSQL'
    aliases = ['japanese-sql', 'jsql']
    
    def get_tokens_unprocessed(self, text):
        """Override to handle Japanese characters without marking them as errors."""
        # Pattern for Japanese characters
        japanese_pattern = re.compile(r'[\u3000-\u303f\u3040-\u309f\u30a0-\u30ff\u4e00-\u9faf\uff00-\uffef]+')
        
        # First try the parent lexer
        tokens = list(super().get_tokens_unprocessed(text))
        
        # Post-process tokens to fix Japanese character handling
        result = []
        for index, token, value in tokens:
            # If token is marked as error and contains Japanese characters
            if token == Error and japanese_pattern.search(value):
                # Check context to determine appropriate token type
                # If it's in a comment, keep it as comment
                if index > 0 and any(t[1] == Comment.Single for t in tokens[max(0, index-5):index]):
                    result.append((index, Comment.Single, value))
                # If it's likely a string (surrounded by quotes in original text)
                elif value.strip() and text[index-1:index] in ('"', "'") if index > 0 else False:
                    result.append((index, String, value))
                else:
                    # Treat it as a name token (identifier)
                    result.append((index, Name, value))
            else:
                result.append((index, token, value))
        
        return result


def monkey_patch_pygments_bridge(app):
    """Monkey patch PygmentsBridge to use our custom lexer for SQL with Japanese."""
    original_get_lexer = PygmentsBridge.get_lexer
    
    def patched_get_lexer(self, source, lang, opts=None, force=False, location=None):
        """Use Japanese SQL lexer when SQL code contains Japanese characters."""
        if lang in ('sql', 'postgresql', 'postgres'):
            # Check if source contains Japanese characters
            if re.search(r'[\u3000-\u303f\u3040-\u309f\u30a0-\u30ff\u4e00-\u9faf\uff00-\uffef]', source):
                # Use our custom lexer
                return JapaneseSqlLexer()
        
        # Otherwise use the original method
        return original_get_lexer(self, source, lang, opts, force, location)
    
    PygmentsBridge.get_lexer = patched_get_lexer


def setup(app):
    """Setup the extension."""
    # Connect to the builder-inited event to patch after Sphinx is initialized
    app.connect('builder-inited', lambda app: monkey_patch_pygments_bridge(app))
    
    return {
        'version': '0.1',
        'parallel_read_safe': True,
        'parallel_write_safe': True,
    }