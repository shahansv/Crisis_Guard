from .models import Login, CampCoordinator

def logged_in_user(request):
    user_name = None
    user_photo = None
    coordinator_name = None

    if 'lid' in request.session:
        try:
            user = Login.objects.get(id=request.session['lid'])
            user_name = user.username
            if user.type == 'Coordinator':
                coordinator = CampCoordinator.objects.get(LOGIN=user)
                user_photo = coordinator.photo.url if coordinator.photo else None
                coordinator_name = coordinator.name 
        except (Login.DoesNotExist, CampCoordinator.DoesNotExist):
            pass

    return {'user_name': user_name, 'user_photo': user_photo, 'coordinator_name': coordinator_name}
