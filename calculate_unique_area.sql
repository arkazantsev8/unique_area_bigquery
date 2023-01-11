SELECT
sum(IF(intersection_grid_ratio > 1, grid_area, intersection_area)) as fields_unique_area
FROM (
SELECT
    AVG(ST_AREA(grid_polygon))/1e4 as grid_area, 
    ST_AREA(ST_UNION_AGG(fus_grid_intersection))/1e4 as intersection_area,
    ( ST_AREA(ST_UNION_AGG(fus_grid_intersection))/1e4) / (AVG(ST_AREA(grid_polygon))/1e4) AS intersection_grid_ratio
FROM my.fields as f
LEFT JOIN my.fields_grid_intersections as fgi 
USING (field_id)
WHERE 1=1
    --ENTER CONDITION HERE
)
