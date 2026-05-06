from rdf_mapper.lib.template_state import TemplateState
from rdf_mapper.lib.function import register

def append_fragment(text: str, state: TemplateState, fragment: str, fragment_sep: str = '.'):
    if text is not None:
        if '#' in text:
            return text + fragment_sep + fragment
        return text + '#' + fragment

register('append_fragment', append_fragment)
