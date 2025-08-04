#!/usr/bin/env python3
"""
z Command Tool - Python Implementation
A powerful command storage and execution tool with rainbow-colored output.
"""

import os
import sys
import json
import shlex
import subprocess
import argparse
from pathlib import Path
from typing import List, Optional, Dict, Any
from datetime import datetime
import readline  # For better input handling

# Color codes for terminal output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    MAGENTA = '\033[0;35m'
    CYAN = '\033[0;36m'
    ORANGE = '\033[38;5;208m'
    WHITE = '\033[1;37m'
    RESET = '\033[0m'

class ZCommandTool:
    def __init__(self):
        self.commands_file = Path.home() / '.z_commands'
        self.history_file = Path.home() / '.z_history'
        self.stats_file = Path.home() / '.z_stats'
        self._ensure_files_exist()
    
    def _ensure_files_exist(self):
        """Ensure all necessary files exist."""
        self.commands_file.touch(exist_ok=True)
        self.history_file.touch(exist_ok=True)
        self.stats_file.touch(exist_ok=True)
    
    def _print_colored(self, message: str, color: str):
        """Print colored message to terminal."""
        print(f"{color}{message}{Colors.RESET}")
    
    def print_success(self, message: str):
        """Print success message in green."""
        self._print_colored(f"✓ {message}", Colors.GREEN)
    
    def print_error(self, message: str):
        """Print error message in red."""
        self._print_colored(f"✗ {message}", Colors.RED)
    
    def print_info(self, message: str):
        """Print info message in blue."""
        self._print_colored(f"ℹ {message}", Colors.BLUE)
    
    def print_warning(self, message: str):
        """Print warning message in orange."""
        self._print_colored(f"⚠ {message}", Colors.ORANGE)
    
    def print_header(self, message: str):
        """Print header message in cyan."""
        self._print_colored(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Colors.CYAN)
        self._print_colored(f"{message}", Colors.WHITE)
        self._print_colored(f"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━", Colors.CYAN)
    
    def _load_commands(self) -> List[str]:
        """Load commands from file."""
        try:
            with open(self.commands_file, 'r', encoding='utf-8') as f:
                return [line.strip() for line in f if line.strip()]
        except FileNotFoundError:
            return []
    
    def _save_commands(self, commands: List[str]):
        """Save commands to file."""
        with open(self.commands_file, 'w', encoding='utf-8') as f:
            for cmd in commands:
                f.write(f"{cmd}\n")
    
    def _load_stats(self) -> Dict[str, Any]:
        """Load usage statistics."""
        try:
            with open(self.stats_file, 'r', encoding='utf-8') as f:
                return json.load(f)
        except (FileNotFoundError, json.JSONDecodeError):
            return {"executions": {}, "total_executions": 0}
    
    def _save_stats(self, stats: Dict[str, Any]):
        """Save usage statistics."""
        with open(self.stats_file, 'w', encoding='utf-8') as f:
            json.dump(stats, f, indent=2)
    
    def _update_stats(self, command: str):
        """Update execution statistics."""
        stats = self._load_stats()
        stats["executions"][command] = stats["executions"].get(command, 0) + 1
        stats["total_executions"] += 1
        stats["last_updated"] = datetime.now().isoformat()
        self._save_stats(stats)
    
    def add_command(self, command: str, silent: bool = False) -> bool:
        """Add a command to storage."""
        if not command:
            self.print_error("Command cannot be empty")
            return False
        
        commands = self._load_commands()
        commands.append(command)
        self._save_commands(commands)
        
        if not silent:
            self.print_success(f"Stored command #{len(commands)}: {command}")
        
        return True
    
    def list_commands(self):
        """List all stored commands."""
        commands = self._load_commands()
        
        if not commands:
            self.print_warning("No commands stored yet. Use 'z add \"<command>\"' to add one.")
            return
        
        self.print_info("Stored commands:")
        for i, cmd in enumerate(commands, 1):
            print(f"{i:3d}: {cmd}")
    
    def delete_command(self, number: int) -> bool:
        """Delete a command by number."""
        commands = self._load_commands()
        
        if number < 1 or number > len(commands):
            self.print_error(f"No command found at line {number}")
            return False
        
        deleted_cmd = commands[number - 1]
        commands.pop(number - 1)
        self._save_commands(commands)
        
        self.print_success(f"Deleted command #{number}: {deleted_cmd}")
        return True
    
    def clear_commands(self):
        """Clear all stored commands."""
        commands = self._load_commands()
        
        if not commands:
            self.print_warning("No commands to clear.")
            return
        
        try:
            response = input("Are you sure you want to clear all commands? (y/N): ")
            if response.lower() in ['y', 'yes']:
                self._save_commands([])
                self.print_success("All commands cleared.")
            else:
                self.print_info("Operation cancelled.")
        except KeyboardInterrupt:
            print()
            self.print_info("Operation cancelled.")
    
    def search_commands(self, pattern: str):
        """Search commands by pattern."""
        if not pattern:
            self.print_error("Search pattern cannot be empty")
            return
        
        commands = self._load_commands()
        found = False
        
        for i, cmd in enumerate(commands, 1):
            if pattern.lower() in cmd.lower():
                print(f"{i:3d}: {cmd}")
                found = True
        
        if not found:
            self.print_warning(f"No commands found containing '{pattern}'")
    
    def show_stats(self):
        """Show usage statistics."""
        commands = self._load_commands()
        stats = self._load_stats()
        
        if not commands:
            self.print_warning("No commands stored yet.")
            return
        
        total_commands = len(commands)
        unique_commands = len(set(commands))
        
        self.print_info(f"Total commands: {total_commands}")
        self.print_info(f"Unique commands: {unique_commands}")
        self.print_info(f"Total executions: {stats.get('total_executions', 0)}")
        
        # Find most used command
        if stats.get("executions"):
            most_used = max(stats["executions"].items(), key=lambda x: x[1])
            self.print_info(f"Most used: {most_used[0]} ({most_used[1]} times)")
    
    def execute_command(self, number: int) -> bool:
        """Execute a command by number."""
        commands = self._load_commands()
        
        if number < 1 or number > len(commands):
            self.print_error(f"No command found at line {number}")
            return False
        
        command = commands[number - 1]
        self.print_info(f"Executing: {command}")
        
        # Update statistics
        self._update_stats(command)
        
        # Special handling for cd commands
        if command.strip().startswith('cd '):
            return self._execute_cd_command(command)
        else:
            return self._execute_shell_command(command)
    
    def _execute_cd_command(self, command: str) -> bool:
        """Execute cd command with special handling."""
        try:
            # Extract directory from cd command
            parts = shlex.split(command)
            if len(parts) < 2:
                self.print_error("Invalid cd command")
                return False
            
            directory = parts[1]
            # Expand ~ and environment variables
            directory = os.path.expanduser(directory)
            directory = os.path.expandvars(directory)
            
            # Change directory
            os.chdir(directory)
            current_dir = os.getcwd()
            self.print_success(f"Changed directory to: {current_dir}")
            return True
            
        except Exception as e:
            self.print_error(f"Failed to change directory: {e}")
            return False
    
    def _execute_shell_command(self, command: str) -> bool:
        """Execute shell command."""
        try:
            # Use subprocess to execute the command
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                cwd=os.getcwd()
            )
            
            # Print output
            if result.stdout:
                print(result.stdout)
            if result.stderr:
                print(result.stderr, file=sys.stderr)
            
            return result.returncode == 0
            
        except Exception as e:
            self.print_error(f"Failed to execute command: {e}")
            return False
    
    def show_help(self):
        """Show help information."""
        help_text = """
z - Command Storage and Execution Tool (Python Version)

Usage:
  z add "command"     -- Store a new command
  z attach "command"  -- Store a command silently
  z <number>          -- Execute command by number
  z list | z ls       -- List all stored commands
  z delete <number>   -- Delete command by number
  z clear             -- Clear all commands
  z search "pattern"   -- Search stored commands
  z stats             -- Show statistics
  z help              -- Show this help message

Features:
  ✓ Persistent storage in ~/.z_commands
  ✓ Execute commands in the current shell (cd supported)
  ✓ Command search and statistics
  ✓ Rainbow-colored output
  ✓ Cross-platform compatibility

Note: Make sure this script is executable and in your PATH.
"""
        print(help_text.strip())
    
    def run(self, args: Optional[List[str]] = None):
        """Main entry point."""
        if args is None:
            args = sys.argv[1:]
        
        if not args:
            self.show_help()
            return
        
        command = args[0]
        remaining_args = args[1:]
        
        # Check if command is a number (execute command)
        if command.isdigit():
            self.execute_command(int(command))
            return
        
        # Handle subcommands
        if command == "add":
            if not remaining_args:
                self.print_error("Usage: z add \"command\"")
                return
            self.add_command(remaining_args[0])
        
        elif command == "attach":
            if not remaining_args:
                self.print_error("Usage: z attach \"command\"")
                return
            self.add_command(remaining_args[0], silent=True)
        
        elif command in ["list", "ls"]:
            self.list_commands()
        
        elif command == "delete":
            if not remaining_args or not remaining_args[0].isdigit():
                self.print_error("Usage: z delete <number>")
                return
            self.delete_command(int(remaining_args[0]))
        
        elif command == "clear":
            self.clear_commands()
        
        elif command == "search":
            if not remaining_args:
                self.print_error("Usage: z search \"pattern\"")
                return
            self.search_commands(remaining_args[0])
        
        elif command == "stats":
            self.show_stats()
        
        elif command == "help":
            self.show_help()
        
        else:
            self.print_error(f"Unknown command: {command}")
            self.print_info("Use 'z help' for usage information.")


def main():
    """Main function."""
    tool = ZCommandTool()
    tool.run()


if __name__ == "__main__":
    main() 