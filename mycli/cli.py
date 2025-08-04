#!/usr/bin/env python3
"""
MyCLI - A simple CLI application built with Click
"""

import click
import os
import sys
import json
import subprocess
from pathlib import Path


def get_storage_path():
    """Get the path to the storage file."""
    return Path.home() / '.cli_storage'


def load_commands():
    """Load commands from storage file."""
    storage_path = get_storage_path()
    if storage_path.exists():
        try:
            with open(storage_path, 'r') as f:
                return json.load(f)
        except (json.JSONDecodeError, FileNotFoundError):
            return {}
    return {}


def save_commands(commands):
    """Save commands to storage file."""
    storage_path = get_storage_path()
    storage_path.parent.mkdir(exist_ok=True)
    with open(storage_path, 'w') as f:
        json.dump(commands, f, indent=2)


def install_shell_completion(ctx, param, value):
    """Install shell completion for the CLI."""
    if not value:
        return
    
    shell = os.environ.get('SHELL', '').split('/')[-1]
    
    if shell == 'zsh':
        zshrc_path = os.path.expanduser('~/.zshrc')
        
        # Check if completion is already installed
        try:
            with open(zshrc_path, 'r') as f:
                content = f.read()
                if 'MyCLI completion' in content:
                    click.echo("Completion already installed for zsh!")
                    ctx.exit()
        except FileNotFoundError:
            pass
        
        # Generate completion script using Click
        completion_script = f"""# MyCLI completion
eval "$(_MYCLI_COMPLETE=source_zsh mycli)"
"""
        
        # Add completion script to .zshrc
        with open(zshrc_path, 'a') as f:
            f.write(f"\n{completion_script}\n")
        
        click.echo("Shell completion installed for zsh!")
        click.echo("Please restart your terminal or run: source ~/.zshrc")
        ctx.exit()
        
    elif shell == 'bash':
        bashrc_path = os.path.expanduser('~/.bashrc')
        
        # Check if completion is already installed
        try:
            with open(bashrc_path, 'r') as f:
                content = f.read()
                if 'MyCLI completion' in content:
                    click.echo("Completion already installed for bash!")
                    ctx.exit()
        except FileNotFoundError:
            pass
        
        # Generate completion script using Click
        completion_script = f"""# MyCLI completion
eval "$(_MYCLI_COMPLETE=source_bash mycli)"
"""
        
        # Add completion script to .bashrc
        with open(bashrc_path, 'a') as f:
            f.write(f"\n{completion_script}\n")
        
        click.echo("Shell completion installed for bash!")
        click.echo("Please restart your terminal or run: source ~/.bashrc")
        ctx.exit()
        
    else:
        click.echo(f"Shell completion not supported for {shell}")
        click.echo("Supported shells: bash, zsh")
        ctx.exit()


@click.group()
@click.option('--install-completion', is_flag=True, callback=install_shell_completion, 
              help='Install shell completion')
@click.option('--version', is_flag=True, help='Show version and exit')
def mycli(install_completion, version):
    """MyCLI - A simple CLI application with hello and goodbye commands."""
    if version:
        click.echo("MyCLI version 0.1.0")
        return
    pass


@mycli.command()
@click.option('--name', default='World', help='Name to greet')
def hello(name):
    """Say hello to someone."""
    click.echo(f"Hello, {name}!")


@mycli.command()
def goodbye():
    """Say goodbye."""
    click.echo("Goodbye!")


@mycli.command()
@click.option('-c', '--command', required=True, help='Command to add')
@click.option('-k', '--key', help='Alias/key for the command')
def add(command, key):
    """Add a custom command with optional alias."""
    commands = load_commands()
    
    if key:
        # Add with alias
        commands[key] = command
        click.echo(f"Added command '{command}' with alias '{key}'")
    else:
        # Add without alias (use index)
        index = len(commands)
        commands[str(index)] = command
        click.echo(f"Added command '{command}' with index '{index}'")
    
    save_commands(commands)
    click.echo("Command saved successfully!")


@mycli.command()
def list():
    """List all stored commands."""
    commands = load_commands()
    
    if not commands:
        click.echo("No commands stored yet.")
        return
    
    click.echo("Stored commands:")
    click.echo("-" * 40)
    
    for key, command in commands.items():
        click.echo(f"{key}: {command}")


@mycli.command()
@click.argument('key')
def run(key):
    """Run a stored command by key or index in the current shell."""
    commands = load_commands()
    
    if key not in commands:
        click.echo(f"Command with key '{key}' not found.")
        click.echo("Available commands:")
        for k, cmd in commands.items():
            click.echo(f"  {k}: {cmd}")
        return
    
    command = commands[key]
    
    # Output the command to be executed by eval
    click.echo(command)


@mycli.command()
@click.argument('key')
def exec(key):
    """Execute a stored command in the current shell context (for cd commands)."""
    commands = load_commands()
    
    if key not in commands:
        click.echo(f"Command with key '{key}' not found.")
        click.echo("Available commands:")
        for k, cmd in commands.items():
            click.echo(f"  {k}: {cmd}")
        return
    
    command = commands[key]
    
    # For cd commands, we need to execute in the current shell
    if command.strip().startswith('cd '):
        target_dir = command.strip()[3:].strip()
        # Output the command to be executed by the shell
        click.echo(f"cd {target_dir}")
    else:
        # For other commands, just output them
        click.echo(command)


# Set up Click's built-in completion
mycli.completion = True

# Enable completion for all commands
for cmd in [add, list, run, exec, hello, goodbye]:
    cmd.completion = True

if __name__ == '__main__':
    mycli()
