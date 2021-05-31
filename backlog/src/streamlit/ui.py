from PIL import Image
from io import BytesIO
import base64
import requests
import json
import streamlit as st


REST_URL = "http://tfserving:8501/v1/models/monet_gen:predict"

st.title("If Monet loved dogs more 🐕")
st.header("TensorFlow Serving + Streamlit")

uploaded_file = st.file_uploader(label="Upload image with doggos",
                                 type=["png", "jpeg", "jpg"])
col1, col2 = st.beta_columns(2)
with col1:
    # Display the predict button once the image is  uploaded
    if not uploaded_file:
        st.warning("Please upload an image first!")
        st.stop()
    else:
        uploaded_img_bytes = uploaded_file.read()
        uploaded_img = Image.open(BytesIO(uploaded_img_bytes))
        st.image(uploaded_img_bytes, use_column_width=True)
        pred_button = st.button("Predict")

with col2:
    if pred_button:
        base64_image = base64.b64encode(uploaded_img_bytes).decode("ascii")
        headers = {"Content-Type": "application/json"}
        request_dict = {"inputs": {"image": [{"b64": base64_image}]}}

        response = requests.post(
            REST_URL,
            json.dumps(request_dict),
            headers=headers,
        )
        pred = dict(response.json())["outputs"]

        # to fix the incorrect padding error
        img_bytes = base64.urlsafe_b64decode(pred + '=' * (-len(pred) % 4))
        im_file = BytesIO(img_bytes)
        img = Image.open(im_file)
        # after decoding, tf serving's output is a 512x512 image
        # resize it to the original dimension of the uploaded image
        img = img.resize(uploaded_img.size)

        st.image(img, use_column_width=True)
