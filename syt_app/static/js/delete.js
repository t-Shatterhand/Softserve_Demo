function delete_note(link, csrftoken){
    const response = fetch(link, {
            method: 'DELETE',
            headers: {
                "X-CSRFToken": csrftoken,
                "wooo": 123213,
            }
        });
    var form = document.getElementById('id_fil_sort_form')
    form.submit()
    location.reload()
};