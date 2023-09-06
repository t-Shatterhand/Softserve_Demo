
    var codeeditor = document.getElementById("codeeditor");
    var myCodeMirror = CodeMirror.fromTextArea(codeeditor, {
            mode: "",
            styleActiveLine: true,
            theme:"xq-light",
            matchBrackets: true,
            lineNumbers: true
    });



    var language_select =document.getElementById("id_language");
    language_select.addEventListener("change", function ()
    {
        language_select.blur();
        languageChanged(language_select.value);
    })
    language_select.onchange="languageChanged(this.value); this.blur();";
    console.log(myCodeMirror.mode);


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
      mode: random_paste_language,
      styleActiveLine: true,
      theme:"xq-dark",
      matchBrackets: true,
      lineNumbers: true,
      readOnly: true

    });
    myCodeMirror333.setSize(550, 507);

    var myCodeMirror334 = CodeMirror(document.getElementById("randomCode2"), {
      value: burn_paste,
      mode:   burn_paste_language,
      styleActiveLine: true,
      theme:"xq-dark",
      matchBrackets: true,
      lineNumbers: true,
      readOnly: true
    });
    myCodeMirror334.setSize(550, 507);




      function languageChanged(language){
          if(language=="text/html")
          {
               var mixedMode =
                   {
                    name: "htmlmixed",
                    scriptTypes: [{matches: /\/x-handlebars-template|\/x-mustache/i,
                           mode: null},
                          {matches: /(text|application)\/(x-)?vb(a|script)/i,
                           mode: "vbscript"}]
               };
               myCodeMirror.setOption("mode", mixedMode);
          }
          else {
               myCodeMirror.setOption("mode", language);
          }

          console.log(language)

      }


function Send(url, csrf){
      const formData = new FormData();
        formData.append('title', document.getElementById("title").value);
        formData.append('language', document.getElementById("id_language").value);
        formData.append('expires', document.getElementById("id_expires").value);
        formData.append('text', myCodeMirror.getValue());
        formData.append('category', document.getElementById("id_category").value);
        try {
                    formData.append('is_private', document.getElementById("isPrivate").checked);
            formData.append('as_guest', document.getElementById("asGuest").checked);
        }
        catch {}

        formData.append('csrfmiddlewaretoken', csrf);
        console.log(formData);
        fetch(url, {
            method: 'POST',
            body: formData
        }).then(res => {
          console.log("Request complete! response:", res['url']);
          window.location.replace(res['url']);
        });}