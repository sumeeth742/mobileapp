# AI Mock Interview API

This FastAPI service is the secure boundary between Flutter and an LLM provider.
The Flutter application must never contain `LLM_API_KEY`.

## Run locally

```bash
cd backend
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env
uvicorn app.main:app --reload
```

Run tests with `pytest -q`. The default `AI_PROVIDER=mock` is deterministic and
only intended for local development. Set `AI_PROVIDER=openai_compatible` and the
LLM environment variables to use an OpenAI-compatible Chat Completions endpoint.

## Authentication during local development

All interview routes require `Authorization: Bearer <DEV_AUTH_TOKEN>`. Replace
the development token in `.env`; never commit `.env`. Phase 5 will replace this
development adapter with Supabase JWT validation.

## Example

```bash
curl -X POST http://127.0.0.1:8000/api/v1/interviews \
  -H "Authorization: Bearer replace-with-a-long-local-development-token" \
  -H "Content-Type: application/json" \
  -d '{"interview_type":"technical","difficulty":"intermediate","question_count":5,"job_role":"Software Engineer","programming_language":"Python","topics":["Algorithms"]}'
```
