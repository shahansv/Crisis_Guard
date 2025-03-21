from django.db import models


class Login(models.Model):
    username = models.CharField(max_length=200, unique=True)  
    password = models.CharField(max_length=200) 
    type = models.CharField(max_length=200)


class Camp(models.Model):
    camp_name = models.CharField(max_length=200,unique=True)
    capacity = models.PositiveIntegerField()
    district = models.CharField(max_length=200)
    city = models.CharField(max_length=200)
    pin = models.BigIntegerField()
    email = models.EmailField(max_length=200, unique=True)
    contact_no = models.BigIntegerField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True) 
    updated_at = models.DateTimeField(auto_now=True) 


class CampCoordinator(models.Model):
    LOGIN = models.ForeignKey(Login, on_delete=models.CASCADE)
    CAMP = models.OneToOneField(Camp, on_delete=models.CASCADE)
    name = models.CharField(max_length=200)
    gender = models.CharField(max_length=200)
    dob = models.DateField()
    district = models.CharField(max_length=200)
    city = models.CharField(max_length=200)
    pin = models.BigIntegerField()
    email = models.EmailField(max_length=200, unique=True)
    contact_no = models.BigIntegerField(unique=True)
    aadhaar_number = models.CharField(max_length=19, unique=True) 
    posted_at = models.DateField(auto_now_add=True)
    photo = models.FileField()


class Guideline(models.Model):
    COORDINATOR = models.ForeignKey(CampCoordinator, on_delete=models.CASCADE)
    guideline = models.FileField()
    posted_date = models.DateField(auto_now_add=True)  
    posted_time = models.TimeField(auto_now_add=True) 


class Public(models.Model):
    LOGIN = models.ForeignKey(Login, on_delete=models.CASCADE)
    name = models.CharField(max_length=200)
    gender = models.CharField(max_length=200)
    dob=models.DateField()
    district = models.CharField(max_length=200)
    city = models.CharField(max_length=200)
    pin = models.BigIntegerField()
    email = models.EmailField(max_length=200, unique=True)
    contact_no = models.BigIntegerField(unique=True)
    aadhaar_number = models.CharField(max_length=19, unique=True) 
    photo = models.FileField()
    joined_date = models.DateField(auto_now_add=True)  


class Notification(models.Model):
    title = models.CharField(max_length=200)
    notification = models.TextField() 
    posted_date =models.DateField(auto_now=True) 
    posted_time = models.TimeField(auto_now=True) 
    

class Complaint(models.Model):
    PUBLIC = models.ForeignKey(Public, on_delete=models.CASCADE)
    complaint  = models.CharField(max_length=200)
    posted_at = models.DateTimeField(auto_now_add=True) 
    reply = models.CharField(max_length=200)
    status = models.CharField(max_length=200)
    updated_at = models.DateTimeField(auto_now=True) 


class EmergencyTeam(models.Model):
    LOGIN = models.ForeignKey(Login, on_delete=models.CASCADE)
    department= models.CharField(max_length=200)
    district = models.CharField(max_length=200)
    city = models.CharField(max_length=200)
    pin = models.BigIntegerField()
    email = models.EmailField(max_length=200, unique=True)
    contact_no = models.BigIntegerField(unique=True)
    joined_date = models.DateField(auto_now_add=True)  


class Volunteer(models.Model):
    CAMP = models.ForeignKey(Camp, on_delete=models.CASCADE)
    LOGIN = models.ForeignKey(Login,on_delete=models.CASCADE)
    name = models.CharField(max_length=200)
    gender = models.CharField(max_length=200)
    dob=models.DateField()
    district = models.CharField(max_length=200)
    city = models.CharField(max_length=200)
    pin = models.BigIntegerField()
    email = models.EmailField(max_length=200, unique=True)
    contact_no = models.BigIntegerField(unique=True)
    aadhaar_number = models.CharField(max_length=19, unique=True) 
    photo = models.FileField()
    posted_date = models.DateField(auto_now_add=True) 


class EmergencyRequest(models.Model):
    PUBLIC = models.ForeignKey(Public, on_delete=models.CASCADE,null=True)
    EMERGENCY_TEAM=models.ForeignKey(EmergencyTeam, on_delete=models.CASCADE)
    request = models.CharField(max_length=200)
    status = models.CharField(max_length=200)
    posted_date = models.DateField(auto_now_add=True)  
    posted_time = models.TimeField(auto_now_add=True)
    updated_date = models.DateField(auto_now=True)  
    updated_time =  models.TimeField(auto_now=True) 
    latitude =  models.FloatField()
    longitude =  models.FloatField()


class Member(models.Model):
    CAMP = models.ForeignKey(Camp, on_delete=models.CASCADE)
    name = models.CharField(max_length=200)
    gender = models.CharField(max_length=200)
    dob = models.DateField()
    district = models.CharField(max_length=200)
    city = models.CharField(max_length=200)
    pin = models.BigIntegerField()
    email = models.EmailField(max_length=200, unique=True)
    contact_no = models.BigIntegerField(unique=True)
    aadhaar_number = models.CharField(max_length=19, unique=True) 
    photo = models.FileField()
    joined_date = models.DateField(auto_now_add=True) 


class Needs(models.Model):
    CAMP = models.ForeignKey(Camp, on_delete=models.CASCADE)
    category =  models.CharField(max_length=200)
    product =  models.CharField(max_length=200)
    quantity =  models.IntegerField()
    name =  models.CharField(max_length=200)
    unit =  models.CharField(max_length=200)
    added_on = models.DateTimeField(auto_now_add=True) 


    
class Goods(models.Model):
    PUBLIC = models.ForeignKey(Public, on_delete=models.CASCADE)
    VOLENTEER = models.ForeignKey(Volunteer, on_delete=models.CASCADE,null=True)
    category = models.CharField(max_length=200)
    product = models.CharField(max_length=200)
    name =  models.CharField(max_length=200)
    quantity = models.IntegerField()
    unit =  models.CharField(max_length=200)
    donated_on = models.DateTimeField(auto_now_add=True) 
    status=models.CharField(max_length=100)



class Stock(models.Model):
    CAMP = models.ForeignKey(Camp, on_delete=models.CASCADE)
    category =  models.CharField(max_length=200)
    product =  models.CharField(max_length=200)
    name =  models.CharField(max_length=200)
    quantity =  models.IntegerField()
    unit = models.CharField(max_length=200)
    added_on = models.DateTimeField(auto_now_add=True) 
    donated = models.CharField(max_length=200)



class Asset(models.Model):
    MEMBER = models.ForeignKey(Member, on_delete=models.CASCADE)
    VOLENTEER = models.ForeignKey(Volunteer, on_delete=models.CASCADE,null=True)
    category = models.CharField(max_length=200)
    asset = models.CharField(max_length=200)
    description = models.CharField(max_length=200)
    status = models.CharField(max_length=200)
    missing_date = models.DateField()
    posted_date = models.DateField(auto_now_add=True) 



class Task(models.Model):
    VOLUNTEER = models.ForeignKey(Volunteer, on_delete=models.CASCADE)
    task = models.CharField(max_length=200)
    posted_date = models.DateField(auto_now_add=True)   
    status = models.BooleanField(default=False)


class Payment(models.Model):
    PUBLIC = models.ForeignKey(Public, on_delete=models.CASCADE)
    amount = models.FloatField()
    payment_date = models.DateField(auto_now_add=True) 
    payment_time = models.TimeField(auto_now_add=True)




class GroupChat(models.Model):
    CAMP = models.ForeignKey(Camp, on_delete=models.CASCADE)
    LOGIN = models.ForeignKey(Login, on_delete=models.CASCADE)
    message = models.TextField()
    date = models.DateField(auto_now_add=True)
    time = models.TimeField(auto_now_add=True)