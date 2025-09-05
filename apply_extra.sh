#!/bin/bash

# Extract the appimage
chmod +x beeper.appimage
unappimage beeper.appimage >/dev/null

# Move all the data to /app/extra/beeper
mv squashfs-root beeper

# Clean up
rm beeper.appimage