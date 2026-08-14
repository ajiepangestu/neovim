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
│   ├── pyproject.toml      # OR pyrightconfig.json
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

This will:
- Auto-detect Django folder (api/, backend/, server/, etc.)
- Check for existing `pyproject.toml`
- Create `pyrightconfig.json` OR add to `pyproject.toml`
- Create `.editorconfig`
- Prompt to install Python dependencies

## pyproject.toml Support

The setup command intelligently handles existing `pyproject.toml`:

### Scenario 1: No pyproject.toml
Creates `api/pyrightconfig.json` with basedpyright config.

### Scenario 2: pyproject.toml exists WITH pyright config
Skips creating config (uses existing).

### Scenario 3: pyproject.toml exists WITHOUT pyright config
Prompts you to choose:
- **Add to pyproject.toml** - Appends `[tool.basedpyright]` section
- **Create pyrightconfig.json** - Creates separate config file

### Example: Adding to pyproject.toml

If you choose to add to existing `pyproject.toml`, it appends:

```toml
[tool.basedpyright]
venvPath = "."
venv = ".venv"
pythonVersion = "3.11"
typeCheckingMode = "basic"
reportMissingImports = true
reportMissingTypeStubs = false
reportAttributeAccessIssue = "none"
reportGeneralTypeIssues = "none"
extraPaths = ["."]
include = ["."]
exclude = ["**/node_modules", "**/__pycache__", "**/.venv"]

[tool.basedpyright.defineConstant]
DJANGO_SETTINGS_MODULE = "myproject.settings"
```

### Which to Choose?

**Use pyproject.toml if:**
- ✅ You already use it for other tools (ruff, black, pytest, etc.)
- ✅ You prefer single config file
- ✅ Your team uses pyproject.toml

**Use pyrightconfig.json if:**
- ✅ You want pyright-specific config separate from other tools
- ✅ You have complex pyright settings
- ✅ You don't have pyproject.toml yet

Both work identically for basedpyright.

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

Install in `api/` folder using the safe installer:

```bash
cd api
python -m venv .venv
source .venv/bin/activate
```

Then in Neovim:
```vim
:DjangoInstall
```

This command:
- ✅ Checks if virtualenv is active
- ✅ Prevents installing packages globally
- ✅ Installs django, django-stubs, and ruff safely
- ✅ Shows clear error if venv not activated

### Manual Installation (Alternative)

If you prefer manual installation:

```bash
cd api
python -m venv .venv
source .venv/bin/activate
pip install django django-stubs[compatible-mypy] ruff
pip install -r requirements.txt
```

### Check Virtualenv Status

Use this command to verify venv is active:

```vim
:VenvStatus
```

Output:
- ✅ `Virtualenv active: /path/to/api/.venv` - Safe to install
- ⚠️ `No virtualenv active` - Activate venv first!

## How It Works

### LSP Auto-Detection

Neovim automatically detects project roots (see `lua/config/util.lua`):

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
