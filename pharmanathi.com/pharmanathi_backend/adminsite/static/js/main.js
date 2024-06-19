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

function loadUnverifiedMHPs(){
    location.href = "/custom-admin/MHPs/unverified"
}

function renderDataTable(id){
    new DataTable(id);
}

function loadUser(id){
    location.href = `/custom-admin/users/detail/${id}`
}

document.querySelector("#btn-logout-modal-logout").addEventListener("click", logout)
$(".unverified-mhp-table-row").on("click", e => {
    const MHPID = e.currentTarget.dataset.mhpId
    loadUser(MHPID)
})
