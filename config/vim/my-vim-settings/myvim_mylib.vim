" ---------------------------------------------------------
" custom function command mapping for plugin install/remove
" ---------------------------------------------------------
let g:myvim_use_dein = 0
if g:myvim_use_dein == 1
    function! myvim_mylib#plug_install()
        call dein#install()
    endfunction

    function! myvim_mylib#plug_uninstall()
        call map(dein#check_clean(), "delete(v:val, 'rf')")
        call dein#recache_runtimepath()
    endfunction

    function! myvim_mylib#plug_update()
        call dein#update()
    endfunction

    command PlugInstall call myvim_mylib#plug_install()
    command PlugUninstall call myvim_mylib#plug_uninstall()
    command PlugUpdate call myvim_mylib#plug_update()
endif

function! myvim_mylib#SetCocPythonPath()
python3 << EOF
import os
import sys
import vim
import json
import time
time.sleep(0.5)
py_executable = 'python'
path_split_char = ':'
if sys.platform.startswith('win'):
    py_executable = 'python.exe'
    path_split_char = ';'

py_interpreter = ''
for path in os.environ['PATH'].split(path_split_char):
    path = path.rstrip(os.sep)
    if os.path.exists(f'{path}{os.sep}{py_executable}'):
        py_interpreter = f'{path}{os.sep}{py_executable}'
        break
if py_interpreter:
    vim.command("let g:py_interpreter_path='{}'".format(py_interpreter))
    vim.command("let g:myvim_mylib_python_setting = coc#util#get_config('python')")
    python_setting = vim.eval('g:myvim_mylib_python_setting')
    if python_setting and not python_setting.get('pythonPath'):
        vim.command("call coc#config('python.pythonPath', '{}')".format(py_interpreter))
    elif not python_setting:
        vim.command("call coc#config('python.pythonPath', '{}')".format(py_interpreter))
EOF
endfunction

function! myvim_mylib#SetCocPowerShellExe()
py3 << EOF
import os
import sys
ps_core_executable = 'pwsh'
ps_executable = 'pwsh'
path_split_char = ':'
if sys.platform.startswith('win'):
    ps_core_executable = 'pwsh.exe'
    ps_executable = 'pwsh.exe'
    path_split_char = ';'

ps_selected = os.environ.get('psinfo', None)
if ps_selected is None:
    for path in os.environ['PATH'].split(path_split_char):
        path = path.rstrip(os.sep)
        ps_executable_with_path = f'{path}{os.sep}{ps_core_executable}'
        if os.path.exists(ps_executable_with_path):
            ps_selected = ps_executable_with_path
            break
        if ps_core_executable == ps_executable:
            continue
        ps_executable_with_path = f'{path}{os.sep}{ps_executable}'
        if os.path.exists(ps_executable_with_path):
            ps_selected = ps_executable_with_path
            break

if ps_selected:
    vim.command("let g:ps_executable_path='{}'".format(ps_selected))
    vim.command("call coc#config('powershell', {{'powerShellExePath': '{}'}})".format(ps_selected))
EOF
endfunction

function! myvim_mylib#GrepArgs(...)
  let list = ['-S', '-smartcase', '-i', '-ignorecase', '-w', '-word',
              \ '-e', '-regex', '-u', '-skip-vcs-ignores', '-t', '-extension']
  return join(list, "\n")
endfunction

function! myvim_mylib#RemoveSinglePairedChar(dir)
    let cur_pos=getcurpos()
    let end_pos=col('$')
    if a:dir == "b"
        normal! hx
    else
        normal! x
        if cur_pos[2] == (end_pos -1)
            call cursor(cur_pos[1], end_pos)
        endif
    endif
endfunction
