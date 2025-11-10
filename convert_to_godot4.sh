#!/bin/bash
# Batch convert Godot 3 to Godot 4 syntax

find /home/user/best_game/scripts -name "*.gd" -type f | while read file; do
    echo "Converting $file..."

    # KinematicBody2D → CharacterBody2D
    sed -i 's/extends KinematicBody2D/extends CharacterBody2D/g' "$file"

    # export → @export
    sed -i 's/^export var /@export var /g' "$file"
    sed -i 's/^export(/\@export(/g' "$file"

    # onready → @onready
    sed -i 's/^onready var /\@onready var /g' "$file"
    sed -i 's/\tonready var /\t\@onready var /g' "$file"

    # yield → await (with .timeout)
    sed -i 's/yield(get_tree()\.create_timer(\([^)]*\)), "timeout")/await get_tree().create_timer(\1).timeout/g' "$file"
    sed -i 's/yield(tween, "tween_all_completed")/await tween.finished/g' "$file"

    # Signal connections: .connect(obj, "method") → .connect(method)
    sed -i 's/\.connect("\([^"]*\)", self, "\([^"]*\)")/.\1.connect(\2)/g' "$file"
    sed -i 's/\.connect("\([^"]*\)", \([^,]*\), "\([^"]*\)")/.\1.connect(\2.\3)/g' "$file"

    # move_and_slide(velocity) → move_and_slide()
    sed -i 's/velocity = move_and_slide(velocity)/move_and_slide()/g' "$file"
    sed -i 's/= move_and_slide(velocity)/move_and_slide()/g' "$file"

done

echo "Conversion complete!"
