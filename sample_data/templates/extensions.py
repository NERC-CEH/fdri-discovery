import dateparser
from rdf_mapper.lib.template_state import TemplateState
from rdf_mapper.lib.function import register

def end_of_day(text: str, state: TemplateState)-> str|None:
    if text is None or (isinstance(text, str) and len(text) == 0):
        return None
    dt = dateparser.parse(text)
    if dt is None:
        return None
    return dt.replace(hour=23, minute=59, second=59).isoformat()

def append_fragment(text: str, state: TemplateState, fragment: str, fragment_sep: str = '.'):
    if text is not None:
        if '#' in text:
            return text + fragment_sep + fragment
        return text + '#' + fragment

register('append_fragment', append_fragment)
register('endOfDay', end_of_day)
