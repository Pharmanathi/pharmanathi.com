from .models import Doctor


def check_mhp_sensitive_fields_update(sender, **kwargs):
    if sender is Doctor:
        print(f"--->> {kwargs}")
        from pharmanathi_backend.users.api.serializers import DoctorPublicListSerializer

        from .tasks import takilu

        instance = kwargs["instance"]
        print(f"---->{sender._is_verified, kwargs['instance']._is_verified}")
        takilu.delay(DoctorPublicListSerializer(instance).data)
