# Prompt Templates

## Purpose

- Provide reproducible prompt templates for a more deterministic test generation with AI models

## Templates

### Create a new Karate feature

```txt
Create a new Karate feature in acquisitions/src/main/resources/thunderjet/{{FOLDER}} folder with {{NAME}} name. 
This new feature must perform {{FINE_DETAILS}}.
Use any examples stored in acquisitions/ai/prompt/examples folder if needed.  

Make sure you adhere with our system prompt found in acquisitions/ai/ACQ_{{FOLDER}}_SYSTEM_PROMPT.md.
Make sure the new feature has correct comment, print and header formats, and that we don't deviate from the norms.
Use our reusable features defined in acquisitions/src/main/resources/karate-config.js when necessary. 
At the end add our new feature to acquisitions/src/main/resources/thunderjet/{{FOLDER}}/{{MODULE}}.feature, and the associated Java method to {{FOLDER}}ApiTest. 

Do not create any explanatory markdown guides.
Do not overcomplicate the solution with unknown syntax. 
Do not add scenarios or Java methods in the middle of the file; add them at the end (i.e. append-only). 
Do not run unix-based (e.g. grep, sed, ls, tail, head, etc) or Windows commands (e.g. dir, findstr, etc); use your editor tools to make changes.
Do not run mvn test by yourself, it is too slow. 
Think for longer if needed, be accurate.
```

> Replace `{{FOLDER}}`, `{{NAME}}`, `{{MODULE}}` and populate `{{FINE_DETAILS}}` with test-related fine details