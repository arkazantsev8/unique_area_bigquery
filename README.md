# Unique Area in BigQuery
Calculating the unique area of a large number (500K+) of intersecting geometries (fields, delivery zones, etc.) in BigQuery

In OneSoil we needed to report % of world arable lands covered with the users of the App. We could not just sum the area of the fields, because there were a lot of intersections for the following reasons:
1. Farmers add a field a few times for each season because there could grow different crops
2. Borders of the fields can change (adjustment, or 2 new fields from 1 old)
3. Different users (i.e. farmer and consultant) could add the same field to their list

First, we calculated unique square of field polygons rasterizing them in GDAL
But this approach was not efficient:
1. It was too long (hours of calculation)
2. We had to download the list of fields from BigQuery all the time

Over time, number of requests from product increased significantly. What was the unique area of fields touched by users last year? last month? last week? In Brazil? In France? How it changed daily during last year?
For each request we had to manually download list of fields satisfying asked conditions, and then wait a few hours, or even days (due to high load of the team). We realized that we need to do something with it.

We thought that it would be cool if we could calculate unique area right in BigQuery. Indeed, there is a [ST_UNION/ST_UNION_AGG](https://cloud.google.com/bigquery/docs/reference/standard-sql/geography_functions#st_union) function, but you can not just feed it with 500K+ polygons. But we can aggregate data in parts.

We follow the algorythm: 
1. Introduce grid with cell of 0.1x0.1 degree size, 3600x1800 ~ 6.5 cells total
2. For each field we calculate its intersections with grid cells.
3. We filter field intersections by condiiton we need and then group them by cells and for each cell make
4. Sum area of each cell's union and get the result

Script `calculate_grid_intersections.sql` executes steps 1-2:

https://github.com/arkazantsev8/unique_area_bigquery/blob/9e0b769f962e975894d2965eb89e71865e7f9be3/calculate_grid_intersections.sql#L1-L42

Script `calculate_unique_area.sql` executes steps 3-4:

https://github.com/arkazantsev8/unique_area_bigquery/blob/9e0b769f962e975894d2965eb89e71865e7f9be3/calculate_unique_area.sql#L1-L13




