#!/bin/sh

# copyright Luca Delucchi, Alfredo Gattai 2017
# licenza GLP version 2.0 or higher
# cambiare il bounding box per scaricare i sentieri della vostra zona

command -v osmtogeojson >/dev/null 2>&1 || { echo "It is required osmtogeojson but it's not installed.  Aborting." >&2; exit 1; }
command -v ogr2ogr >/dev/null 2>&1 || { echo "It is required ogr2ogr but it's not installed.  Aborting." >&2; exit 1; }

bounds="44.00216 9.85288 44.19472 9.46235 44.29471 9.49329 44.42793 9.38534 44.46179 9.60329 44.39109 9.75181 44.20212 10.00070 44.11728 10.10109 44.00512 10.08459"

echo '<osm-script>
  <query into="hr" type="relation">
    <has-kv k="route" v="hiking"/>
    <has-kv k="ref"/>
    <has-kv k="ref" modv="not" v="E1"/>
    <has-kv k="ref" modv="not" v="GEA"/>
    <has-kv k="ref" modv="not" v="00"/>
    <polygon-query bounds="'$bounds'"/>
  </query>
  <query into="hrp" type="way">
    <recurse from="hr" type="relation-way"/>
    <polygon-query bounds="'$bounds'"/>
  </query>
  <union>
    <item set="hr"/>
    <item set="hrp"/>
  </union>
  <print mode="body" order="quadtile"/>
  <recurse from="hrp" type="way-node"/>
  <print mode="skeleton" order="quadtile"/>
</osm-script>' > query.txt

wget -c -O sentieri.osm --post-file=query.txt "http://overpass-api.de/api/interpreter"

## si ottengono i sentieri divisi ma con più campi
# osmtogeojson sentieri.osm > sentieri_divisi.geojson
# ogr2ogr sentieri_divisi.shp -nlt LINESTRING sentieri_divisi.geojson

# si ottengono i sentieri uniti con meno campi
osmtogeojson -e -n sentieri.osm > sentieri_uniti.geojson
ogr2ogr sentieri_uniti.shp -nlt LINESTRING sentieri_uniti.geojson
