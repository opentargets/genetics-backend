# genetics-backend

Create LUT to map bio feature codes to labels.

New bio features must be added to `create_LUT.py`. The output is then copied to `gs://genetics-portal-data/lut/`

`gsutil cp biofeature_lut_190208.json gs://genetics-portal-data/lut/biofeature_lut_190208.json`
