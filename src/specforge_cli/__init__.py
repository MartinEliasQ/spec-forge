"""SpecForge CLI — Pre-specification requirements engine."""

import json
import os
import shutil
import stat
import sys
from pathlib import Path

import typer
from rich.console import Console
from rich.panel import Panel
from rich.table import Table

app = typer.Typer(
    name="specforge",
    help="Transform unstructured inputs into structured, traceable feature specs.",
    no_args_is_help=True,
)
console = Console()

VERSION = "0.1.0"

# Agent configurations (extensible like spec-kit)
AGENT_CONFIG = {
    "claude": {
        "folder": ".claude",
        "commands_subdir": "commands",
        "cli": "claude",
    },
}

# Directories to create in user project
PROJECT_DIRS = [
    ".specforge/scripts/bash",
    ".specforge/scripts/powershell",
    ".specforge/templates",
    "requirements/inbox",
    "requirements/units",
    "requirements/synthesis",
    "requirements/features",
]


def _bundled_root() -> Path:
    """Return the path to bundled assets (works both in dev and installed mode)."""
    bundled = Path(__file__).resolve().parent / "bundled"
    if bundled.exists():
        return bundled
    # Fallback: dev mode — assets live at repo root
    repo_root = Path(__file__).resolve().parent.parent.parent
    if (repo_root / "scripts").exists() or (repo_root / "templates").exists():
        return repo_root
    raise FileNotFoundError(
        "Could not locate bundled assets. Reinstall with: "
        "uv tool install specforge-cli --force --from git+https://github.com/..."
    )


def _copy_tree(src: Path, dst: Path) -> int:
    """Copy directory tree, preserving executability. Returns file count."""
    count = 0
    for item in src.rglob("*"):
        if item.is_file():
            rel = item.relative_to(src)
            target = dst / rel
            target.parent.mkdir(parents=True, exist_ok=True)
            shutil.copy2(item, target)
            if os.access(item, os.X_OK):
                target.chmod(target.stat().st_mode | stat.S_IXUSR | stat.S_IXGRP)
            count += 1
    return count


@app.command()
def init(
    project_dir: str = typer.Argument(
        ".",
        help="Project directory to initialize. Use '.' for current directory.",
    ),
    ai: str = typer.Option(
        "claude",
        "--ai",
        help="AI agent to configure for.",
    ),
    here: bool = typer.Option(
        False,
        "--here",
        help="Initialize in the current directory (alias for '.').",
    ),
):
    """Initialize a new SpecForge project."""
    if here:
        project_dir = "."

    target = Path(project_dir).resolve()

    if ai not in AGENT_CONFIG:
        console.print(f"[red]Unknown agent: {ai}[/red]")
        console.print(f"Supported: {', '.join(AGENT_CONFIG.keys())}")
        raise typer.Exit(1)

    agent = AGENT_CONFIG[ai]
    bundled = _bundled_root()

    console.print(Panel.fit(
        f"[bold green]SpecForge Init[/bold green]\n"
        f"Project: {target}\n"
        f"Agent: {ai}",
        border_style="green",
    ))

    # 1. Create project directory and structure
    target.mkdir(parents=True, exist_ok=True)
    for d in PROJECT_DIRS:
        (target / d).mkdir(parents=True, exist_ok=True)

    # 2. Copy scripts
    scripts_src = bundled / "scripts"
    if scripts_src.exists():
        count = _copy_tree(scripts_src, target / ".specforge" / "scripts")
        console.print(f"  [green]✓[/green] Copied {count} scripts to .specforge/scripts/")

    # 3. Copy templates (non-command .md files)
    templates_src = bundled / "templates"
    if templates_src.exists():
        count = 0
        for f in templates_src.glob("*.md"):
            shutil.copy2(f, target / ".specforge" / "templates" / f.name)
            count += 1
        if count:
            console.print(f"  [green]✓[/green] Copied {count} templates to .specforge/templates/")

    # 4. Copy commands to agent directory
    commands_src = bundled / "templates" / "commands"
    commands_dst = target / agent["folder"] / agent["commands_subdir"]
    commands_dst.mkdir(parents=True, exist_ok=True)
    if commands_src.exists():
        count = 0
        for f in commands_src.glob("*.md"):
            shutil.copy2(f, commands_dst / f.name)
            count += 1
        if count:
            console.print(
                f"  [green]✓[/green] Copied {count} commands to "
                f"{agent['folder']}/{agent['commands_subdir']}/"
            )

    # 5. Create CLAUDE.md with agent definition
    agent_template = bundled / "templates" / "CLAUDE-template.md"
    claude_md = target / "CLAUDE.md"
    if agent_template.exists():
        if claude_md.exists():
            # Append specforge section if CLAUDE.md already exists
            existing = claude_md.read_text()
            if "SpecForge Agent" not in existing:
                with open(claude_md, "a") as f:
                    f.write("\n\n" + agent_template.read_text())
                console.print("  [green]✓[/green] Appended SpecForge config to CLAUDE.md")
            else:
                console.print("  [dim]—[/dim] CLAUDE.md already has SpecForge config")
        else:
            shutil.copy2(agent_template, claude_md)
            console.print("  [green]✓[/green] Created CLAUDE.md")

    # 6. Create requirements index
    index_file = target / "requirements" / "index.md"
    if not index_file.exists():
        index_file.write_text("# Requirements Index\n\n**Last updated**: —\n")
        console.print("  [green]✓[/green] Created requirements/index.md")

    # 7. Append to .gitignore if needed
    gitignore = target / ".gitignore"
    gitignore_content = gitignore.read_text() if gitignore.exists() else ""
    if "requirements/" not in gitignore_content:
        with open(gitignore, "a") as f:
            f.write("\n# SpecForge — generated output\nrequirements/\n.specforge/\n")
        console.print("  [green]✓[/green] Updated .gitignore")

    # 8. Save init options
    meta_dir = target / ".specforge"
    meta_dir.mkdir(parents=True, exist_ok=True)
    (meta_dir / "init-options.json").write_text(
        json.dumps({
            "ai": ai,
            "specforge_version": VERSION,
            "script": "sh" if sys.platform != "win32" else "ps",
        }, indent=2) + "\n"
    )
    console.print("  [green]✓[/green] Saved config to .specforge/init-options.json")

    # 9. Summary
    console.print()
    console.print(Panel.fit(
        "[bold green]SpecForge initialized![/bold green]\n\n"
        "Next steps:\n"
        "  1. Add raw inputs to [cyan]requirements/inbox/[/cyan]\n"
        "  2. Run [cyan]/specforge.distill[/cyan] to extract requirements\n"
        "  3. Run [cyan]/specforge.clarify[/cyan] to resolve uncertainties\n"
        "  4. Run [cyan]/specforge.compose[/cyan] to group into features\n"
        "  5. Run [cyan]/specforge.status[/cyan] to check readiness\n"
        "\n"
        "Or run the full pipeline: [cyan]/specforge.prepare[/cyan]",
        border_style="green",
    ))


@app.command()
def check():
    """Verify that required tools are installed."""
    table = Table(title="SpecForge Environment Check")
    table.add_column("Tool", style="cyan")
    table.add_column("Status", style="green")
    table.add_column("Details")

    # Check bash
    bash_ok = shutil.which("bash") is not None
    table.add_row("bash", "✓" if bash_ok else "✗", shutil.which("bash") or "not found")

    # Check git
    git_ok = shutil.which("git") is not None
    table.add_row("git", "✓" if git_ok else "✗", shutil.which("git") or "not found")

    # Check claude
    claude_ok = shutil.which("claude") is not None
    table.add_row(
        "claude", "✓" if claude_ok else "✗",
        shutil.which("claude") or "not found",
    )

    # Check jq (optional)
    jq_ok = shutil.which("jq") is not None
    table.add_row(
        "jq (optional)", "✓" if jq_ok else "—",
        shutil.which("jq") or "not installed",
    )

    console.print(table)

    if not all([bash_ok, git_ok]):
        console.print("\n[yellow]Some required tools are missing.[/yellow]")
        raise typer.Exit(1)


@app.command()
def version():
    """Show SpecForge version."""
    console.print(f"specforge-cli {VERSION}")


def main():
    app()
