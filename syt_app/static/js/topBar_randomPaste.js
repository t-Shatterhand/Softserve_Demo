   const nav = document.getElementById('mynav');
    window.onscroll = function () {

    if (window.scrollY >= 80 ) {
        nav.classList.add("nav-colored");
        nav.classList.remove("nav-transparent");
    }
    else {
        nav.classList.add("nav-transparent");
        nav.classList.remove("nav-colored");
    }
};
    var myCodeMirror333 = CodeMirror(document.getElementById("randomCode"), {
      value: random_paste,
      mode:  burn_paste_language,
        styleActiveLine: true,
        theme:"xq-dark",
         matchBrackets: true,
  lineNumbers: true,
        readOnly: true

    });
    myCodeMirror333.setSize(550, 507);
    var myCodeMirror334 = CodeMirror(document.getElementById("randomCode2"), {
      value: burn_paste,
      mode:  random_paste_language,
        styleActiveLine: true,
        theme:"xq-dark",
         matchBrackets: true,
  lineNumbers: true,
        readOnly: true
    });
    myCodeMirror334.setSize(550, 507);

      var mac = CodeMirror.keyMap.default == CodeMirror.keyMap.macDefault;
      CodeMirror.keyMap.default[(mac ? "Cmd" : "Ctrl") + "-Space"] = "autocomplete";
