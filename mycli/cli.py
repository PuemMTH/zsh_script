#!/usr/bin/env python3
"""
MyCLI - A simple CLI application built with Click
"""

import click
import os
import sys


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


# Set up Click's built-in completion
mycli.completion = True

if __name__ == '__main__':
    mycli()
