#!/usr/bin/env bash

set -e

password_hash=$(python -c "from notebook.auth import passwd; print(passwd('${TMTK_NOTEBOOK_PASSWORD}'))")

exec jupyter notebook --NotebookApp.password="${password_hash}" --no-browser --ip 0.0.0.0
