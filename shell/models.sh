#!/bin/bash

curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer ${OPENAI_API_KEY}" \
  -H "OpenAI-Organization: ${ORGANIZATION_ID}" \
  -H "OpenAI-Project: ${PROJECT_ID}"
