#!/bin/sh

if [[ -z "${INPUT_APIKEY}" ]]; then
  echo "INPUT_APIKEY env var not set"
  exit 1
fi

if [[ -z "${INPUT_SLUG}" ]]; then
  echo "INPUT_SLUG env var not set"
  exit 1
fi

echo "generating publish for $INPUT_SLUG"

if [[ -n "${INPUT_RELEASE_NOTES}" ]]; then
  publish_data="-d \"publish[email_readers]=true\" -d \"publish[release_notes]=${INPUT_RELEASE_NOTES}\""
fi

curl_cmd="curl -s -d \"api_key=${INPUT_APIKEY}\" $publish_data https://leanpub.com/${INPUT_SLUG}/publish.json"

gen=$(eval $curl_cmd)

if [[ $(echo "$gen" | jq 'has("success")') != "true" ]]; then
  echo "error generating publish"
  echo "$gen"
  exit 1
fi

echo "waiting for publish to be available"
until [ $(curl -s https://leanpub.com/$INPUT_SLUG/job_status.json?api_key=$INPUT_APIKEY | jq -r '.status') == "complete" ]; do
  sleep 10
done

json=$(curl -s https://leanpub.com/$INPUT_SLUG.json?api_key=$INPUT_APIKEY)
pdfUrl=$(echo $json | jq -r '.pdf_published_url')
epubUrl=$(echo $json | jq -r '.epub_published_url')

echo "::set-output name=pdf_url::$pdfUrl"
echo "::set-output name=epub_url::$epubUrl"
