py3 << END
import os
import vim
def find_python_exec():
    paths = os.environ.get('PATH')
    python_executable = 'python'
    bin_dir="bin"
    path_split_char = ':'
    if sys.platform.startswith('win'):
        python_executable = 'python.exe'
        path_split_char = ';'
        bin_dir=""
    venv_path = os.environ.get('CONDA_PREFIX')
    if venv_path is None:
        for path in os.environ['path'].split(path_split_char):
            if os.path.exists(f'{path}{os.sep}{python_executable}'):
                venv_path = path.rstrip(os.sep)
                break
    else:
        venv_path = f'{venv_path.rstrip(os.sep)}{os.sep}{bin_dir}'
    python_executable_full_path = f'{venv_path.rstrip(os.sep)}{os.sep}{python_executable}'
    return python_executable_full_path

def set_python_interpreter_for_deoplete_jedi():
    python_interpreter = find_python_exec()
    vim.command(f"let g:deoplete#sources#jedi#python_path='{python_interpreter}'")
END

" --------------------------------------------
" set the python interpreter for deopolete-jedi
" --------------------------------------------

"py3 set_python_interpreter_for_deoplete_jedi()
