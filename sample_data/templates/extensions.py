from rdf_mapper.lib.template_state import TemplateState
from rdf_mapper.lib.function import XSD, Literal, register

def append_fragment(text: str, state: TemplateState, fragment: str, fragment_sep: str = '.'):
    if text is not None:
        if '#' in text:
            return text + fragment_sep + fragment
        return text + '#' + fragment

def latlon_to_easting(text: str, state: TemplateState, lat: str, lon: str):
    from OSGridConverter import latlong2grid
    lat_float = float(lat)
    lon_float = float(lon)
    g = latlong2grid(lat_float, lon_float)
    return Literal(f"{g.E}", None, XSD.decimal)

def latlon_to_northing(text: str, state: TemplateState, lat: str, lon: str):
    from OSGridConverter import latlong2grid
    lat_float = float(lat)
    lon_float = float(lon)
    g = latlong2grid(lat_float, lon_float)
    return Literal(f"{g.N}", None, XSD.decimal)

register('append_fragment', append_fragment)
register('latlon_to_easting', latlon_to_easting)
register('latlon_to_northing', latlon_to_northing)
