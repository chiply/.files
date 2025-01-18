function install_lsp_server() {
    local project_dir=$1

    echo "Installing LSP server in $project_dir"
    cd "$project_dir" || exit
    pwd
    rm -rf .venv
    rm -rf poetry.lock
    poetry env use "$(which python)"
    poetry install
    poetry run pip uninstall -y ruff-lsp
    poetry run pip install --upgrade python-lsp-server debugpy ipython ruff
}

function install_all_lsp_servers() {
    local base_dir=$1

    # Check if there's a pyproject.toml in the root and install if it exists
    if [[ -f "$base_dir/pyproject.toml" ]]; then
        install_lsp_server "$base_dir"
        # exit the function
        return
    fi

    # Find all directories with pyproject.toml
    find "$base_dir" -maxdepth 3 -name "pyproject.toml" -exec dirname {} \; | while read -r dir; do
        install_lsp_server "$dir"
    done

}
