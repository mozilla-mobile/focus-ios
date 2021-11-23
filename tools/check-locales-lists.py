import os
import sys
import ruamel.yaml
from ruamel.yaml import YAML
from pathlib import Path

FILE_EXT = ".lproj"
BLOCKZILLA_FOLDER = os.path.join(os.path.dirname(__file__), '..', 'Blockzilla')
CONFIG_FILE = "l10n-screenshots-config.yml"
DICTIONARY_KEY = "locales"
yaml = ruamel.yaml.YAML()

def get_current_locales_in_project(): 
    locales_files = []

    for file in os.listdir(BLOCKZILLA_FOLDER):
        if file.endswith(FILE_EXT):
            locales_files.append(file)

    # Save only the locale's name
    locales_files = [item.replace(FILE_EXT, "") for item in locales_files]
    locales_list = sorted(locales_files)
    print(locales_list)
    return locales_list

def get_locales_from_list_in_repo():
    with open(CONFIG_FILE) as f:
        my_dict = yaml.load(f)
        return my_dict[DICTIONARY_KEY]

def diff(first_list, second_list):
    second = set(second_list)
    return ([item for item in first_list if item not in second_list])

def modify_local_file(add_locales, remove_locales):
    with open(CONFIG_FILE) as f:
        my_dict = yaml.load(f)

    with open(CONFIG_FILE, 'w') as f:
        # remove
        my_dict[DICTIONARY_KEY] = [i for i in my_dict[DICTIONARY_KEY] if not any([e for e in remove_locales if e in i])]
        # add 
        my_dict[DICTIONARY_KEY].extend(add_locales)
        # sort the changes to easily identify the changes in the PR
        my_dict[DICTIONARY_KEY] = sorted(my_dict[DICTIONARY_KEY])

        yaml.indent(mapping=2, sequence=4, offset=6)
        yaml.dump(my_dict, f)

if __name__ == '__main__':
    locales_project_list = get_current_locales_in_project()
    locales_config_file_list = get_locales_from_list_in_repo()

    # if locales in diff are in config but not in project -> remove from config file
    remove_locales = diff(locales_config_file_list, locales_project_list)
    print(f"Remove:  {remove_locales}")

    # if locales in diff are in project but not in config -> add to config file
    add_locales = diff(locales_project_list, locales_config_file_list)
    print(f"Add: {add_locales}")

    modify_local_file(add_locales, remove_locales)
