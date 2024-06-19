GLOBAL_CONF = {
    CSRF_TOKEN: null,
    defaultHTTPRequestHeader: function () { return { 'X-CSRFToken': this.CSRF_TOKEN } }
}

function logout() {
    fetch("/admin/logout/", { method: "POST", headers: GLOBAL_CONF.defaultHTTPRequestHeader() })
        .then(res => {
            if (res.ok) location.href = "/custom-admin"
            location.reload()
        })
}

function viewUser(id) {
    location.href = `/custom-admin/users/detail/${id}`
}

function markMHPAsVerified(mhpId) {
    fetch(`/custom-admin/MHPs/${mhpId}/mark-verified/`, { headers: GLOBAL_CONF.defaultHTTPRequestHeader() })
        .then(res => {
            if (res.ok) location.reload()
            else return res.json()
        })
        .then(data => {
            notify(data.detail, "Error verifying MHP", "danger")
        })
}

function invalidateMHPProfile(mhpId, reason) {
    return fetch(`/custom-admin/MHPs/${mhpId}/invalidate/`, {
        method: "post",
        headers: {
            ...GLOBAL_CONF.defaultHTTPRequestHeader(),
            "Content-Type": "application/json"
        },
        body: JSON.stringify({reason}),
    })
        .then(res => {
            if (res.ok) location.reload()
            else return res.json()
        })
        .then(data => {
            notify(data.detail, "Error invalidating MHP", "danger")
        })
}

function notify(message, title = "", type = "primary") {
    const toastID = `toast-${(new Date()).getTime()}`
    let toastIcon = `exclamation`
    switch (type) {
        case "warning":
            toastIcon = "triangle-exclamation"
            break;
        case "danger":
            toastIcon = "skull-crossbones"
            break;
    }

    document.querySelector(".toast-container").insertAdjacentHTML("afterbegin", `
        <div id="${toastID}" class="toast mb-3" role="alert" aria-live="assertive" aria-atomic="true"
            style="opacity: 1">
            <div class="toast-header bg-${type} text-white">
                <i class="fa-solid fa-${toastIcon} me-2 text-white-50"></i>
                <strong class="me-auto">${title}</strong>
                <small class="text-white-50 ms-2">just now</small>
                <button class="ms-2 mb-1 btn-close btn-close-white" type="button" data-bs-dismiss="toast"
                    aria-label="Close"></button>
            </div>
            <div class="toast-body">${message}</div>
        </div>`)

    const toastElement = new bootstrap.Toast(document.getElementById(toastID), {
        "animation": true,
        "autohide": false
    })
    toastElement.show()
}

function resolveInvalidationReason(irId){
    return fetch(`/custom-admin/IRs/${irId}/resolve/`, {
        headers: {
            ...GLOBAL_CONF.defaultHTTPRequestHeader()
        }
    })
        .then(res => {
            if (res.ok) location.reload()
            else return res.json()
        })
        .then(data => {
            notify(data.detail, `IR resolution error`, "danger")
        })
}

/********************************************  Event Listeners  ***********************ß*********************/
document.querySelector("#btn-logout").addEventListener("click", logout)
document.querySelector("#btn-mhp-validate-mhp-profile").addEventListener("click", (e) => {
    markMHPAsVerified(e.target.dataset.mhpId)
})
document.querySelector("#btn-mhp-invalidate-mhp-profile").addEventListener("click", (e) => {
    (new bootstrap.Modal("#modal-profile-invaliadtion")).show()

})

document.getElementById("btn-confirm-mhp-invalidate-mhp-profile").addEventListener("click", e => {
    const form = new FormData(document.querySelector("[name='frm-invalidate-mhp']"))
    const mhpId = form.get("mhp")
    const reason_text = encodeURIComponent(form.get("reason"))
    invalidateMHPProfile(mhpId, reason_text)
})

$("body").on("click", ".btn-ir-resolver", e => {
    resolveInvalidationReason(e.target.dataset.irId)
})
