#!/bin/bash

if [[ -z "${INPUT_APIKEY}" ]]; then
  echo "INPUT_APIKEY env var not set"
  exit 1
fi

if [[ -z "${INPUT_SLUG}" ]]; then
  echo "INPUT_SLUG env var not set"
  exit 1
fi

echo "generating preview for $INPUT_SLUG"
gen=$(curl -s -d "api_key=$INPUT_APIKEY" https://leanpub.com/$INPUT_SLUG/preview.json | jq -r '.success')

if [[ $gen != "true" ]]; then
  echo "error generating preview"
  exit 1
fi

echo "waiting for preview to be available"
until [ $(curl -s https://leanpub.com/$INPUT_SLUG/job_status.json?api_key=$INPUT_APIKEY | jq -r '.status') == "complete" ]; do
  sleep 10
done

pdfUrl=$(curl -s https://leanpub.com/$INPUT_SLUG.json?api_key=$INPUT_APIKEY | jq -r '.pdf_preview_url')

echo "::set-output name=pdf_url::$pdfUrl"
