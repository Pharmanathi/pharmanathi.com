GLOBAL_CONF = {
    CSRF_TOKEN: null
}

function logout(){
    fetch("/admin/logout/", {method: "POST", headers: {'X-CSRFToken': GLOBAL_CONF.CSRF_TOKEN}})
    .then(res => {
        if(res.ok) location.href = "/custom-admin"
        location.reload()
    })
}

document.querySelector("#btn-logout-modal-logout").addEventListener("click", logout)