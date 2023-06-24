import sublime
import sublime_plugin
# https://www.sublimetext.com/docs/api_reference.html

class TypstPreviewCommand(sublime_plugin.TextCommand):

  def is_enabled(self):
    syntax = self.view.syntax()
    return syntax and syntax.name == 'Typst'

  def run(self, edit):
    if sel := self.view.sel():
      # "sel" has defined __len__ so it must contains [0] when passed "if"
      if region := self._match_and_expand(sel[0].a, 'markup.math.typst'):
        math = self.view.substr(region)
        task = lambda: self._render_math(math, sel[0].a)
        sublime.set_timeout_async(task)
        return
    sublime.status_message('Typst: not found math element under cursor')

  def _match_and_expand(self, pt, scope):
    if self.view.match_selector(pt, scope):
      return self.view.expand_to_scope(pt, scope)

  def _get_colors(self):
    info = sublime.ui_info()
    c = info.get('color_scheme', {}).get('palette', {})
    canvas, fg = c.get('background'), c.get('foreground')
    t = info.get('theme', {})
    if (style := t.get('style')) and (theme := t.get('resolved_value')):
      if theme == 'Adaptive.sublime-theme':
        # hard to make a calculator now, only apply to the default one
        if style == 'light':
          canvas = '#eff0f0'
        elif style == 'dark':
          canvas = '#3a424b'
    return canvas, fg

  def _render_math(self, math, pt):
    import uuid, base64, pathlib, tempfile, textwrap, subprocess

    name = str(uuid.uuid4())
    tmpdir = tempfile.gettempdir()
    canvas, fg = self._get_colors()

    code = '#set page(width: auto, height: auto, margin: 3pt)\n'
    if canvas:
      code += f'#set page(fill: rgb("{canvas[1:]}"))\n'
    if fg:
      code += f'#set text(fill: rgb("{fg[1:]}"))\n'
    code += math

    src = pathlib.Path(tmpdir, name + '.typ')
    dst = pathlib.Path(tmpdir, name + '.png')
    with open(src, 'w') as file:
      print(code, file=file)

    sublime.status_message('Typst: running preview…')
    si = None
    if sublime.platform() == "windows":
        si = subprocess.STARTUPINFO()
        si.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    proc = subprocess.Popen(
      ['typst', 'c', src, dst],
      stdout=subprocess.PIPE,
      stderr=subprocess.STDOUT,
      startupinfo=si,
      text=True,
      encoding='utf-8',
    )
    try:
      err, _ = proc.communicate(timeout=15)
      if err:
        print(err, end='')
        sublime.status_message('Typst: preview error - ' + err)
        return
    except:
      proc.kill()
      out, err = proc.communicate()
      message = (out or '') + (err or '')
      sublime.status_message('Typst: preview error - ' + message)
      return

    src.unlink()
    with open(dst, 'rb') as file:
      content = file.read()
    dst.unlink()

    data = str(base64.b64encode(content), "utf-8")
    self.view.show_popup(
      f'<img src="data:image/png;base64,{data}">',
      sublime.HIDE_ON_MOUSE_MOVE_AWAY,
      pt,
      *self.view.viewport_extent(),
    )

