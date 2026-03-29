---
name: emacs-eval
description: This skill should be used when the user asks to "evaluate elisp", "eval in emacs", "load this file in emacs", "reload this module", "check if this compiles", "verify keybinding", "reinstall package", "rebuild elpaca package", or when Claude has just written or modified an .el file and wants to verify it loads correctly in the running Emacs session. Also use after keybinding changes, package configuration changes, or any elisp that needs live verification.
version: 0.1.0
---

# Emacs Eval

Evaluate arbitrary Elisp in a running Emacs daemon via `emacsclient --eval`. This skill closes the loop between writing elisp and verifying it works in the user's live Emacs session.

## Prerequisites

The user's Emacs must be running with `(server-start)`. The emacsclient binary is at `/opt/homebrew/bin/emacsclient`.

Before any eval operation, verify the daemon is reachable:

```bash
emacsclient --eval '(emacs-version)' 2>&1
```

If this returns an error about sockets, inform the user that the Emacs daemon is not running and suggest they start it with `M-x server-start` or launch Emacs with `emacs --daemon`.

## Core Eval Pattern

All eval operations go through the Bash tool with this pattern:

```bash
emacsclient --eval '<elisp-expression>' 2>&1
```

**Return value**: emacsclient prints the return value of the last expression to stdout (as a printed Elisp representation). Errors go to stderr. The `2>&1` merge ensures both are captured.

### Quoting Rules

Shell-to-elisp quoting is the most common source of errors. Follow these rules strictly:

1. **Outer quotes are single quotes.** The elisp expression is always wrapped in `'...'` for the shell.
2. **Elisp strings use double quotes internally.** Since the outer shell quoting is single-quotes, double quotes inside pass through to Elisp unchanged.
3. **If the elisp itself contains single quotes (as Lisp quote syntax), use the escaped form.** Replace internal `'` with `'\''` (end single-quote, escaped literal single-quote, start single-quote). Alternatively, for complex expressions, use a heredoc approach.
4. **For expressions containing both quote types or very complex nesting**, prefer the printf approach:

```bash
emacsclient --eval "$(printf '%s' "(progn (message \"hello %s\" 'world))")"
```

5. **For multiline elisp**, use `progn`:

```bash
emacsclient --eval '(progn
  (setq my-var 42)
  (message "Value is %d" my-var))'
```

### Wrapper for Parseable Output

For operations where the result matters (not just side effects), wrap the expression to produce structured output:

```bash
emacsclient --eval '(condition-case err
  (let ((result <EXPRESSION>))
    (format "OK: %S" result))
  (error (format "ERROR: %S" err)))' 2>&1
```

This returns either `"OK: <value>"` or `"ERROR: (error-type \"message\")"`, which is unambiguous to parse from stdout.

## Operations

### Ad Hoc Eval

Evaluate a single expression:

```bash
emacsclient --eval '(+ 1 2)' 2>&1
```

For expressions with side effects, report what the expression will do before executing. For expressions that only read state (e.g., checking a variable value), execute directly.

### Load File

After writing or modifying a `.el` file, load it into the running Emacs:

```bash
emacsclient --eval '(condition-case err
  (progn (load-file "/absolute/path/to/file.el") "OK")
  (error (format "LOAD-ERROR: %S" err)))' 2>&1
```

Always use absolute paths. The user's config directory is `~/.zetta.d/`, and module files live at `~/.zetta.d/modules/<category>/<name>.el`.

### Eval Individual Defuns

For targeted changes (e.g., redefining a single function without reloading the whole file), extract and eval just the defun:

```bash
emacsclient --eval '(defun my-function (arg)
  "Docstring."
  (do-something arg))' 2>&1
```

Prefer this over full file reload when only one or two definitions changed, as it avoids re-executing the entire file's side effects (hooks, mode activations, package declarations).

### Byte-Compile Check

Check a file for byte-compiler warnings without loading it:

```bash
emacsclient --eval '(let ((byte-compile-warnings t)
      (byte-compile-error-on-warn nil))
  (byte-compile-file "/absolute/path/to/file.el"))' 2>&1
```

The result is `t` on success or `nil` on failure. Warnings and errors appear in the `*Compile-Log*` buffer inside Emacs. To capture them programmatically:

```bash
emacsclient --eval '(progn
  (byte-compile-file "/absolute/path/to/file.el")
  (with-current-buffer "*Compile-Log*"
    (buffer-substring-no-properties (point-min) (point-max))))' 2>&1
```

Use byte-compile checks after writing new elisp files or making substantial modifications to catch:
- Unbound variable references
- Undefined function calls
- Malformed expressions
- Missing `require` statements

### Verify Keybindings

After keybinding changes, verify they are registered:

```bash
emacsclient --eval '(key-binding (kbd "C-c p"))' 2>&1
```

For keymap-specific lookups:

```bash
emacsclient --eval '(lookup-key global-map (kbd "C-c p"))' 2>&1
```

For the zetta.d launch-map bindings:

```bash
emacsclient --eval '(lookup-key launch-map (kbd "b"))' 2>&1
```

To verify a which-key description was set:

```bash
emacsclient --eval '(key-description (where-is-internal (quote my-command)))' 2>&1
```

To check what a key sequence is bound to in all active keymaps:

```bash
emacsclient --eval '(help--binding-locus (kbd "C-c p") nil)' 2>&1
```

### Elpaca Package Management

The elpaca package manager stores packages at `~/.zetta.d/elpaca/`.

**Check package status:**

```bash
emacsclient --eval '(elpaca-status)' 2>&1
```

**Trigger a package rebuild in-session:**

```bash
emacsclient --eval '(elpaca-rebuild (quote package-name))' 2>&1
```

**Force a completely fresh install** (destructive -- deletes cached source and build artifacts):

First, confirm with the user before proceeding. Then:

```bash
rm -rf ~/.zetta.d/elpaca/repos/<package-name>/ ~/.zetta.d/elpaca/builds/<package-name>/
```

After deletion, the package must be re-fetched and rebuilt. Trigger this by either:
- Restarting Emacs, or
- Running: `emacsclient --eval '(elpaca-rebuild (quote package-name))' 2>&1`

IMPORTANT: Deleting elpaca repo and build directories is a destructive operation. Always:
1. State which directories will be deleted and their sizes
2. Wait for explicit user confirmation before running `rm -rf`
3. Report the result

**List installed packages:**

```bash
emacsclient --eval '(mapcar (lambda (e) (car e)) (elpaca--queued))' 2>&1
```

### Inspect Emacs State

Useful for debugging and verification:

**Check if a package/feature is loaded:**

```bash
emacsclient --eval '(featurep (quote package-name))' 2>&1
```

**Get a variable's value:**

```bash
emacsclient --eval 'variable-name' 2>&1
```

**List active minor modes:**

```bash
emacsclient --eval '(cl-remove-if-not (lambda (m) (and (boundp m) (symbol-value m))) minor-mode-list)' 2>&1
```

**Check current buffer info (in the server's selected frame):**

```bash
emacsclient --eval '(buffer-name (current-buffer))' 2>&1
```

## Error Handling

When an eval returns an error:

1. Parse the error type and message from the output
2. Report it clearly to the user
3. If the error is in code Claude wrote, attempt to diagnose and fix it
4. After fixing, re-eval to verify the fix

Common error patterns:
- `Symbol's value as variable is void: X` -- missing `require` or variable not defined
- `Symbol's function definition is void: X` -- package not loaded or function not defined
- `Wrong type argument: X` -- type mismatch in elisp
- `Wrong number of arguments: X` -- function called with wrong arity
- `File error: Cannot open load file, no such file or directory, X` -- missing dependency

## When to Auto-Invoke

Invoke this skill automatically (without the user asking) when:

1. An `.el` file under `~/.zetta.d/` was just written or modified -- offer to load it
2. A keybinding was just changed -- offer to verify it
3. A `use-package` declaration was modified -- offer to re-eval it
4. A byte-compile error was mentioned or suspected
5. The user asks about current Emacs state (what mode is active, what a key does, etc.)

When auto-invoking, briefly state the intent before executing. For example: "Let me verify that keybinding was registered correctly in your running Emacs."

## Safety Guidelines

- **Read-only operations** (checking values, keybindings, features): Execute directly.
- **Definition operations** (defun, defvar, setq): Execute after stating intent. These are generally safe as they only redefine symbols.
- **Side-effect operations** (kill-buffer, delete-file, modifying buffer contents): Describe the side effects and ask for confirmation.
- **Elpaca directory deletion**: Always require explicit user confirmation. State exact paths and their sizes.
- **Restarting or quitting Emacs**: Never do this without explicit user request.

## Zetta.d-Specific Patterns

The user's Emacs config uses these patterns that are relevant for eval:

- **Module loading**: `(zetta-load-config-file "category/name.el")` loads a module
- **Bootstrap layer**: Files in `~/.zetta.d/source/bootstrap/` are always loaded
- **use-package with elpaca**: Most packages use `(use-package pkg :ensure (:wait t) ...)`
- **Custom keywords**: `:brushup` (theme faces), `:evil` (evil-mode forms)
- **Keybinding system**: `launch-map` prefix command, `general.el` bindings, meow modal states
- **Guard patterns**: `(when (fboundp 'fn) ...)`, `(with-eval-after-load 'pkg ...)`

When reloading modules, be aware that `use-package` with elpaca may not be idempotent -- the `:ensure` clause triggers package installation. For re-evaluation of already-loaded packages, it is often better to eval just the `:config` or `:init` body rather than the entire `use-package` form.
