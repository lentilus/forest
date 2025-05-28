#!/usr/bin/env python3
"""
This script scans all .typst files in the directory specified by $TYPST_ROOT,
looks for the marker "// BACK", and generates an Anki deck using genanki.
It compiles each part to HTML via the typst CLI.
"""
import os
import subprocess
import genanki
import sys

# Constants
deck_name = 'forest'
deck_id = 1441845710
model_id = 1614646389

# Define the model with HTML fields
model = genanki.Model(
    model_id,
    'Forest Card Model',
    fields=[
        {'name': 'Front'},
        {'name': 'Back'},
    ],
    templates=[
        {
            'name': 'Card 1',
            'qfmt': '{{Front}}',
            'afmt': '{{Back}}',
        },
    ]
)

deck = genanki.Deck(deck_id, deck_name)

# Helper to compile Typst to HTML
def compile_typst_to_html(content: str) -> str:
    """
    Runs the typst CLI, reading from stdin and returning HTML output.
    """
    result = subprocess.run(
        ['typst', 'compile', '--format', 'html', '-', '-'],
        input=content,
        text=True,
        capture_output=True,
        check=True
    )
    return result.stdout

# Get TYPST_ROOT environment variable
typst_root = os.environ.get('TYPST_ROOT')
if typst_root is None:
    print("Error: $TYPST_ROOT is not set.")
    sys.exit(1)

# Scan TYPST_ROOT for .typst files
for filename in os.listdir(typst_root):
    if not filename.endswith('.typst'):
        continue

    filepath = os.path.join(typst_root, filename)

    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Find the back marker
    try:
        back_index = next(i for i, line in enumerate(lines) if line.strip() == '// BACK')
    except StopIteration:
        # Skip files without the marker
        continue

    print(f"Processing {filename}.")

    # Raw content segments
    front_raw = ''.join(lines[:back_index])
    back_raw = ''.join(lines)

    # Compile segments to HTML
    try:
        front_html = compile_typst_to_html(front_raw)
        back_html = compile_typst_to_html(back_raw)
    except subprocess.CalledProcessError as e:
        print(f"Error compiling {filename}: {e}")
        continue

    # Create a note and add to the deck
    note = genanki.Note(
        model=model,
        fields=[front_html, back_html],
        guid=filename[:-len(".typst")]
    )
    deck.add_note(note)

# Write the deck to file
output_file = 'forest.apkg'
genanki.Package(deck).write_to_file(output_file)
print(f"Anki deck generated: {output_file}")
