#!/bin/bash

if [[ -z "${INPUT_APIKEY}" ]]; then
  echo "INPUT_APIKEY env var not set"
  exit 1
fi

if [[ -z "${INPUT_SLUG}" ]]; then
  echo "INPUT_SLUG env var not set"
  exit 1
fi

# curl -d "api_key=YOUR_API_KEY" -d "publish[email_readers]=true" -d "publish[release_notes]=please+let+me+know+what+you+think" https://leanpub.com/SLUG/publish.json
echo "generating publish for $INPUT_SLUG"
gen=$(curl -s -d "api_key=$INPUT_APIKEY" -d "publish[email_readers]=true" https://leanpub.com/$INPUT_SLUG/publish.json | jq -r '.success')

if [[ $gen != "true" ]]; then
  echo "error generating publish"
  exit 1
fi

echo "waiting for publish to be available"
until [ $(curl -s https://leanpub.com/$INPUT_SLUG/job_status.json?api_key=$INPUT_APIKEY | jq -r '.status') == "complete" ]; do
  sleep 10
done

json=$(curl -s https://leanpub.com/$INPUT_SLUG.json?api_key=$INPUT_APIKEY)
pdfUrl=$(echo $json | jq -r '.pdf_preview_url')
epubUrl=$(echo $json | jq -r '.epub_preview_url')

echo "::set-output name=pdf_url::$pdfUrl"
echo "::set-output name=epub_url::$epubUrl"
