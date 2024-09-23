#!/usr/bin/env python3

import json
import os
import sys
from pathlib import Path

sys.stdout.reconfigure(line_buffering=True)

RED = '\033[91m'
GREEN = '\033[92m'
RESET = '\033[0m'

STORE_FILE = Path.home() / '.dotfiles/tooling/bookmarks.json'

def read_store():
    try:
        with open(STORE_FILE, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        return {"bookmarks": [], "lastSelected": None}

def write_store(store):
    with open(STORE_FILE, 'w') as f:
        json.dump(store, f, indent=2)

def list_bookmarks(store):
    if not store['bookmarks']:
        print('No bookmarks yet.')
        return
    
    print('Available bookmarks:')
    for index, bm in enumerate(store['bookmarks']):
        print(f"- index: {index} \n  ref: {RED}{bm['name']}{RESET} \n  path: {GREEN}{bm['path']}{RESET}")

def add_bookmark(store, name, path):
    print(f"Adding bookmark: {name} -> {path}")
    if any(bm['name'] == name for bm in store['bookmarks']):
        print('Bookmark already exists.')
        return store
    
    store['bookmarks'].append({"name": name, "path": path})
    return store

def remove_bookmark(store, identifier):
    bookmarks = store['bookmarks']
    for i, bm in enumerate(bookmarks):
        if bm['name'] == identifier or str(i) == identifier:
            del bookmarks[i]
            print(f"Removed bookmark: {bm['name']}")
            return store
    print('Bookmark not found.')
    return store

def set_last_selected(store, path):
    store['lastSelected'] = path
    return store

def handle_list(store):
    list_bookmarks(store)

def validate_valid_path(path):
    return os.path.exists(path) and os.path.isdir(path)

def handle_add(store, path_arg=None, name_arg=None):
    if not path_arg:
        print('Enter path:')
        path = input('')
    else:
        path = path_arg
    
    if path == '.':
        path = os.getcwd()
    
    if not validate_valid_path(path):
        print(f"Error: '{path}' is not a valid directory.")
        return store
    
    if not name_arg:
        print('Enter name for this bookmark:')
        name = input('')
    else:
        name = name_arg
    
    if path_arg:
        print(f'path: {path}')
    if name_arg:
        print(f'name: {name}')
    return add_bookmark(store, name, path)

def handle_remove(store, identifier_arg=None):
    if not identifier_arg:
        list_bookmarks(store)
        print('Enter reference or index to remove:')
        identifier_arg = input('')
    return remove_bookmark(store, identifier_arg)

def handle_quick_access(store):
    if store['lastSelected']:
        print(f"cd {store['lastSelected']}")
    else:
        print('No bookmark selected yet.')

def handle_select_or_list(store, selection_arg=None):
    if selection_arg is None:
        handle_list(store)
        return store

    bookmarks = store['bookmarks']
    selected = next((bm for bm in bookmarks if bm['name'] == selection_arg or 
                     (selection_arg.isdigit() and bookmarks.index(bm) == int(selection_arg))), None)
    
    if selected:
        print(f"cd {selected['path']}")
        return set_last_selected(store, selected['path'])
    else:
        print('Invalid selection ❌.')
        handle_list(store)
    return store

def main():
    store = read_store()
    args = sys.argv[1:]
    command = args[0] if args else 'ls'

    if command in ['ls', 'list', '']:
        handle_list(store)
    elif command in ['add', 'a', '.']: # if this is . use add . 
        if command == '.':
            store = handle_add(store, path_arg='.', name_arg=None)
        else:
            store = handle_add(store, *args[1:3])
    elif command in ['rm', 'remove']:
        store = handle_remove(store, *args[1:2])
    elif command in ['q', 'prev']:
        handle_quick_access(store)
    else:
        store = handle_select_or_list(store, command)

    write_store(store)

if __name__ == "__main__":
    main()
