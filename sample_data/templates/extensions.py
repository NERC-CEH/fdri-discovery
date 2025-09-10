from rdf_mapper.lib.template_state import TemplateState
from rdf_mapper.lib.template_support import register_fn, uri_expand
from rdflib import Literal

def slug(text: str, state: TemplateState):
    return '-'.join(text.lower().split()).replace('%', '_').replace('/', '_')

def with_datatype(text: str, state: TemplateState, dt: str):
    dt_uri = uri_expand(dt, state.spec.namespaces, state)
    if dt_uri is not None:
        return Literal(text, datatype=dt_uri)

def append_fragment(text: str, state: TemplateState, fragment: str, fragment_sep: str = '.'):
    if text is not None:
        if '#' in text:
            return text + fragment_sep + fragment
        return text + '#' + fragment

register_fn('slug', slug)
register_fn('withDatatype', with_datatype)
register_fn('append_fragment', append_fragment)
