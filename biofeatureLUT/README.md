# genetics-backend

Create LUT to map bio feature codes to labels.

Scripts to make the original LUT are in `create_original_lut`. After that, LUT has been updated manually. The latest version will be kept in `latest` and `gs://genetics-portal-data/lut/`.

For June 2019 release, we hacked the data to combine (source, feature) columns. Scripts to add these hacked fields are in `hack_for_June2019_release`.
