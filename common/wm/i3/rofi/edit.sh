#!/usr/bin/env bash
PROJECTS_DIR="/home/flow/Projects"

if [ -z "$1" ]; then
  # Output project list for Rofi
  if [ -d "$PROJECTS_DIR" ]; then
    find "$PROJECTS_DIR" -maxdepth 3 -name .git -type d | while read -r gitdir; do
      project_dir="$(dirname "$gitdir")"
      relative_path="${project_dir#$PROJECTS_DIR/}"
      echo -e "$relative_path (nvim)\0icon\x1fneovim"
      echo -e "$relative_path (opencode)\0icon\x1falacritty"
    done | sort | uniq
  fi
else
  # Handle project selection: parse and launch
  selected="$1"
  echo "Selected: '$selected'" >> /tmp/edit.log
  project="${selected% (*}"
  editor_temp="${selected#* (}"
  editor="${editor_temp%)*}"
  echo "Parsed project: '$project', editor: '$editor'" >> /tmp/edit.log
  if [[ $editor == "nvim" || $editor == "opencode" ]]; then
    PROJECT_PATH="$PROJECTS_DIR/$project"
    echo "Project: $project, Editor: $editor, Path: $PROJECT_PATH" >> /tmp/edit.log
    if [ -d "$PROJECT_PATH" ]; then
      echo "Launching alacritty in $PROJECT_PATH with $editor" >> /tmp/edit.log
      coproc ( alacritty --working-directory "$PROJECT_PATH" -e "$editor"> /dev/null 2>&1 )
    else
      echo "Directory $PROJECT_PATH does not exist" >> /tmp/edit.log
    fi
  else
    echo "Invalid editor: $editor" >> /tmp/edit.log
  fi
fi
