CREATE TEMP FUNCTION make_grid(long FLOAT64, lat FLOAT64)
RETURNS ARRAY<STRING>
LANGUAGE js AS r"""
    var res = []
    x_min = Math.floor(long*100)/100 -0.05
    y_min = Math.floor(lat*100)/100 -0.05
    for (var i=0;i<10;i++){
        for (var j=1;j<=10;j++){
        res.push(String([x_min + i/100,y_min+j/100,x_min+i/100+0.01,y_min+j/100+0.01]))
        }
    }
    return (res)
""";

CREATE TEMP FUNCTION make_square_polygon(x0 FLOAT64, y0 FLOAT64, x1 FLOAT64, y1 FLOAT64) 
AS
    (ST_GEOGFROM(
  '{ "type": "Polygon", "coordinates":[[['|| CAST(x0 AS STRING) ||',' || CAST(y0 AS STRING) || '],[ ' || CAST(x0 AS STRING) ||',' || CAST(y1 AS STRING) || '],[' || CAST(x1 AS STRING) ||',' || CAST(y1 AS STRING) || '],[' || CAST(x1 AS STRING) ||',' || CAST(y0 AS STRING) || '],['|| CAST(x0 AS STRING) ||',' || CAST(y0 AS STRING) || ']]] }'
))
;

CREATE OR REPLACE TABLE my.fields_grid_intersections AS
WITH fields_with_grid AS (
SELECT
    field_id,
    field_geom,
    make_grid(field_centroid_lon, field_centroid_lat) as grid
FROM my.fields
)
SELECT
field_id,
ST_INTERSECTION(field_geom, make_square_polygon(lon0,lat0,lon1,lat1)) as field_grid_intersection
FROM (
    SELECT
    * EXCEPT (grid),
    CAST(SPLIT(grid_, ',')[OFFSET(0)] as FLOAT64) as lon0,
    CAST(SPLIT(grid_, ',')[OFFSET(1)] as FLOAT64) as lat0,
    CAST(SPLIT(grid_, ',')[OFFSET(2)] as FLOAT64) as lon1,
    CAST(SPLIT(grid_, ',')[OFFSET(3)] as FLOAT64) as lat1
    from fields_with_grid, UNNEST(grid) as grid_
)
WHERE ST_INTERSECTSBOX(fus_polygon, lon0, lat0, lon1, lat1)