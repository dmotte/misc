# tmux-mouse-mode

[**tmux**](https://github.com/tmux/tmux) has a **mouse mode**. Its main advantage is that it enables **mouse wheel scrolling**.

To activate it, press `CTRL+B` and then `:`, then type the following:

```
setw -g mouse on
```

Or just type this command into a tmux's Bash terminal:

```bash
tmux setw -g mouse on
```

If you want to persist this change:

```bash
echo 'setw -g mouse on' >> ~/.tmux.conf
```

When tmux mouse mode is on, you can hold the `SHIFT` key to **select and copy/paste text** from/to the terminal window to other applications normally (i.e. as you would do if the mouse mode was off).

## Links

- [Using the mouse - tmux wiki](https://github.com/tmux/tmux/wiki/Getting-Started#using-the-mouse)
- [Scroll shell output with mouse in tmux - Super User](https://superuser.com/questions/210125/scroll-shell-output-with-mouse-in-tmux/217269#217269)
- [tmux: Select and copy pane text with mouse - Unix and Linux Stack Exchange](https://unix.stackexchange.com/questions/478922/tmux-select-and-copy-pane-text-with-mouse/480200#480200)
