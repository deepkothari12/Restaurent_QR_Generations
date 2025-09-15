from django.http import HttpResponse
from django.shortcuts import render, redirect
import qrcode
from io import BytesIO
import base64



def home_page(request):
    # restaurent_name = request.POST.get('Restaurant_Name')
    # print(restaurent_name)
    return render(request , template_name="index.html")

def submit_data(request):
    if request.method == "POST":
        print("Post method")
        restaurent_name = request.POST.get('Restaurant_Name')
        menu_drive_link = request.POST.get('link')

        # Configure QR Code
        qr = qrcode.QRCode(
            version=10,
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=6,
            border=4,
        )
        qr.add_data(menu_drive_link)
        qr.make(fit=True)

        img = qr.make_image(fill_color="black", back_color="white")

        # Convert image to base64
        buffer = BytesIO()
        img.save(buffer, format="PNG")
        img_str = base64.b64encode(buffer.getvalue()).decode("utf-8")
        # print(img_str)
        context = {
            "qrcode": img_str,
            "restaurent_name": restaurent_name,
            "menu_drive_link": menu_drive_link,
            "qrcode_url": f"data:image/png;base64,{img_str}"
        }
        
        return render(request, template_name="index.html", context=context)
    
    else :
        # print("else part")
        return redirect("home_page")
    

