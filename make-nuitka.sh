#!/bin/bash
# Create executable from python project using Nuitka
echo "Got arguments:"
for arg in "$@"
do
  echo "${arg}"
done
name="${1}"
entrypoint="${2}"
version="${3}"
dist="${4}"
assets="${5}"
description="${6}"
if [ -z "${name}" ]; then
  name="ezsam"
fi
if [ -z "${entrypoint}" ]; then
  entrypoint="src/${name}/gui/app.py"
fi
if [ -z "${version}" ]; then
  version="0.0.0"
fi
if [ -z "${dist}" ]; then
  dist="dist-nuitka"
fi
if [ -z "${assets}" ]; then
  assets="src/ezsam/gui/assets"
fi
if [ -z "${description}" ]; then
  description='ezsam is a tool to extract objects from images or video via text prompt - info at https://www.ezsam.org'
fi
tempdir="{TEMP}/${name}"
outfile="${name}"
echo "Creating ${name}-${version} at `date` ..."
python -m nuitka --enable-plugin=tk-inter --onefile --assume-yes-for-downloads \
  --onefile-tempdir-spec="${tempdir}" \
  --include-data-dir="${assets}=${assets}" \
  --output-filename="${outfile}" \
  --product-version="${version}" \
  --file-version="${version}" \
  --file-description="${description}" \
  --output-dir="${dist}" "${entrypoint}"
# Move onefile executable to different folder and checksum
cd "${dist}"
mkdir -p "onefile"
mv "${outfile}" "onefile/${outfile}"
cd onefile
sha256sum "${outfile}" > "${outfile}.sha256"
cd ..
base=`basename ${entrypoint} .py`
# Create standalone folder archive and checksum
outdir="${name}-${version}"
mv "${base}.dist" "${outdir}"
zip -r "${outdir}.zip" "${outdir}"
sha256sum "${outdir}.zip" > "${outdir}.zip.sha256"
# Now that we have our archive undo move to prevent future runs of Nuikta from failing
mv "${outdir}" "${base}.dist" 
cd ..
echo "Finished creating ${name}-${version} at `date`"
