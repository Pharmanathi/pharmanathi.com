from rest_framework import permissions


class IsVerifiedDoctor(permissions.BasePermission):
    message = "Access denied. Your doctor's profile is not verified."
    code = 403

    def has_permission(self, request, view):
        user = request.user
        assert user.is_doctor is True, "Expected User with a MHP(Doctor) profile"
        return user.doctor_profile.is_verified
