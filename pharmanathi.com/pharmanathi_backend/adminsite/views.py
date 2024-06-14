from django.contrib.auth.decorators import login_required
from django.shortcuts import render


@login_required
def main(request):
    print(f"------>>> {dir(request.session)}")
    return render(request, "adminsite/index.html", {})
