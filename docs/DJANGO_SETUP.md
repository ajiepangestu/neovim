# Django ORM Type Checking Setup

## Problem
Pyright doesn't understand Django's dynamic `objects` manager, causing errors like:
```
Cannot access attribute "objects" for class "MyModel"
```

## Solution: basedpyright + django-stubs

### 1. Neovim Configuration (Already Done)

- Switched to `basedpyright` in `lua/config/options.lua`
- Added basedpyright to Mason install list in `lua/plugins/django.lua`
- Configured basedpyright with `typeCheckingMode = "basic"`

### 2. Project-Level Setup (Required for Each Django Project)

#### Install django-stubs in your project:

```bash
# In your Django project's virtual environment
pip install django-stubs[compatible-mypy]
```

#### Create `pyrightconfig.json` in project root:

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
  "defineConstant": {
    "DJANGO_SETTINGS_MODULE": "myproject.settings"
  }
}
```

**Key settings:**
- `reportAttributeAccessIssue: "none"` - Suppresses false positives for Django's dynamic attributes
- `reportGeneralTypeIssues: "none"` - Reduces noise from Django's metaclass magic
- `defineConstant.DJANGO_SETTINGS_MODULE` - Helps basedpyright find your Django settings

#### Alternative: Minimal config (if above is too permissive)

```json
{
  "venvPath": ".",
  "venv": ".venv",
  "pythonVersion": "3.11",
  "typeCheckingMode": "basic",
  "reportAttributeAccessIssue": "warning"
}
```

### 3. Verify Setup

1. Open a Django model file in Neovim
2. Check LSP status: `:LspInfo` - should show `basedpyright` running
3. The `objects` attribute should no longer show errors

## Why basedpyright over pyright?

| Feature | pyright | basedpyright |
|---------|---------|--------------|
| Django ORM support | Poor | Better (with django-stubs) |
| Type checking strictness | Very strict | More configurable |
| False positives | High with Django | Lower with proper config |
| Community | Microsoft | Active fork with Django focus |

## Troubleshooting

### Still seeing `objects` errors?

1. Ensure `django-stubs` is installed in the active venv:
   ```bash
   pip list | grep django-stubs
   ```

2. Check basedpyright is running:
   ```vim
   :LspInfo
   ```

3. Verify `pyrightconfig.json` exists in project root

4. Restart LSP:
   ```vim
   :LspRestart
   ```

### basedpyright not found?

Install via Mason:
```vim
:MasonInstall basedpyright
```

Or manually:
```bash
npm install -g @basedpyright/basedpyright
```

## Additional Django Type Hints

For better type checking, add type hints to your models:

```python
from django.db import models
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from django.db.models import Manager

class MyModel(models.Model):
    if TYPE_CHECKING:
        objects: Manager["MyModel"]
    
    name = models.CharField(max_length=100)
```

This explicitly tells the type checker about the `objects` manager.
