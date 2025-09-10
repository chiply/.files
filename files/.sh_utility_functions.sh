function install_lsp_server() {
    local project_dir=$1

    echo "Installing LSP server in $project_dir"
    cd "$project_dir" || exit
    pwd
    rm -rf .venv
    rm -rf poetry.lock
    export POETRY_VIRTUALENVS_IN_PROJECT=true
    poetry config virtualenvs.in-project true
    echo "python executable:"
    echo "$(which python)"
    poetry env use "$(which python)"
    poetry install
    poetry run pip uninstall -y ruff-lsp
    poetry run pip uninstall -y python-lsp-server debugpy ipython ruff basedpyright pyright
    # NOTE using python-lsp-server as I've had issues with the pyright
    # and basedpyright server getting interrupted (Cancelling
    # textDocument/diagnostic(3112) in hook after-change-functions)
    poetry run pip install --upgrade debugpy ipython ruff python-lsp-server
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
