from rdf_mapper.lib.template_state import TemplateState
from rdf_mapper.lib.template_support import register_fn, uri_expand
from rdflib import Literal

def slug(text: str, state: TemplateState):
    return '-'.join(text.lower().split())

def with_datatype(text: str, state: TemplateState, dt: str):
    dt_uri = uri_expand(dt, state.spec.namespaces, state)
    if dt_uri is not None:
        return Literal(text, datatype=dt_uri)

register_fn('slug', slug)
register_fn('withDatatype', with_datatype)