# Monorepo Setup Guide

## Project Structure

```
root_project/
├── web/                    # Next.js frontend
│   ├── package.json
│   ├── tsconfig.json
│   ├── .eslintrc.json
│   └── src/
├── api/                    # Django backend
│   ├── manage.py
│   ├── pyrightconfig.json
│   ├── requirements.txt
│   ├── .venv/
│   └── myproject/
├── .editorconfig          # Shared editor settings
└── .git/
```

## Quick Setup

Use the Neovim command to auto-generate config files:

```vim
:MonorepoSetup
```

This will create:
- `api/pyrightconfig.json` - Django type checking config
- `.editorconfig` - Shared editor settings
- Prompts to install Python dependencies

## Manual Setup

### 1. Django API (`api/pyrightconfig.json`)

```json
{
  "venvPath": ".",
  "venv": ".venv",
  "pythonVersion": "3.11",
  "typeCheckingMode": "basic",
  "reportMissingImports": true,
  "reportMissingTypeStubs": false,
  "reportAttributeAccessIssue": "none",
  "reportGeneralTypeIssues": "none",
  "extraPaths": ["."],
  "include": ["."],
  "exclude": ["**/node_modules", "**/__pycache__", "**/.venv"],
  "defineConstant": {
    "DJANGO_SETTINGS_MODULE": "myproject.settings"
  }
}
```

### 2. Next.js Web (`web/tsconfig.json`)

Already created by Next.js. Ensure it includes:

```json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "preserve",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": ["next-env.d.ts", "**/*.ts", "**/*.tsx", ".next/types/**/*.ts"],
  "exclude": ["node_modules"]
}
```

### 3. Root EditorConfig (`.editorconfig`)

```ini
root = true

[*]
indent_style = space
indent_size = 2
end_of_line = lf
charset = utf-8
trim_trailing_whitespace = true
insert_final_newline = true

[*.py]
indent_size = 4

[*.md]
trim_trailing_whitespace = false
```

## Python Dependencies

Install in `api/` folder:

```bash
cd api
python -m venv .venv
source .venv/bin/activate
pip install django django-stubs[compatible-mypy] ruff
pip install -r requirements.txt
```

## How It Works

### LSP Auto-Detection

Neovim (LazyVim) automatically detects project roots:

| File | LSP Activated |
|------|---------------|
| `pyrightconfig.json` | basedpyright (Python/Django) |
| `tsconfig.json` / `package.json` | TypeScript LSP (Next.js) |

### Formatter Auto-Detection

conform.nvim applies formatters based on filetype:

| Filetype | Formatter |
|----------|-----------|
| `*.py` | ruff |
| `*.ts`, `*.tsx`, `*.js`, `*.jsx` | prettier |
| `*.html`, `*.css`, `*.json` | prettier |

## Workflow Examples

### Open Django file
```bash
nvim root_project/api/myapp/models.py
# LSP: basedpyright, ruff
# Formatter: ruff
```

### Open Next.js file
```bash
nvim root_project/web/src/app/page.tsx
# LSP: ts_ls, eslint
# Formatter: prettier
```

### Open from root
```bash
nvim root_project/
# Both LSPs work in their respective folders
```

## Verify Setup

Check LSP status in each folder:

```vim
" In api/*.py file
:LspInfo
" Should show: basedpyright, ruff

" In web/*.tsx file
:LspInfo
" Should show: ts_ls (or typescript-language-server), eslint
```

## Troubleshooting

### Django `objects` errors still showing?

1. Ensure `django-stubs` is installed:
   ```bash
   cd api && pip list | grep django-stubs
   ```

2. Check `pyrightconfig.json` exists in `api/` folder

3. Restart LSP: `:LspRestart`

### TypeScript errors in web folder?

1. Ensure `node_modules` is installed:
   ```bash
   cd web && npm install
   ```

2. Check `tsconfig.json` exists

3. Restart LSP: `:LspRestart`

### Formatter not working?

Check formatter status:
```vim
:ConformInfo
```

Install missing formatters via Mason:
```vim
:MasonInstall prettierd ruff
```

## Advanced: Workspace-Level Config

If you prefer a single config at root (not recommended):

```json
{
  "executionEnvironments": [
    {
      "root": "api",
      "venvPath": "api",
      "venv": ".venv",
      "pythonVersion": "3.11",
      "defineConstant": {
        "DJANGO_SETTINGS_MODULE": "myproject.settings"
      }
    }
  ],
  "reportAttributeAccessIssue": "none"
}
```

**Note**: Separate configs per folder are cleaner for monorepos.
