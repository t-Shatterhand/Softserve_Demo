 var codeeditor = document.getElementById("codeeditor");
    var myCodeMirror = CodeMirror.fromTextArea(codeeditor, {
            mode: "",
            styleActiveLine: true,
            theme:"xq-light",
            matchBrackets: true,
            lineNumbers: true,
            readOnly: true,

    });
myCodeMirror.setSize(1000, 548);


