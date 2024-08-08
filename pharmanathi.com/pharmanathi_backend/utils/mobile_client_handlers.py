from django.shortcuts import redirect


def handle_ios_app_association(request):
    return redirect("/static/apple-app-site-association")

def handle_deeplink_redirect(request):
    print("~~~~~~~~~>>>>", request.query_params)
