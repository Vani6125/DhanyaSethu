# 🌾 DhanySetu – Smart Paddy Disease Detection & Remedy App

**DhanySetu** is an AI-powered mobile application designed to assist farmers by identifying diseases in rice plants using image classification. It provides timely remedies and agricultural support, helping farmers take informed actions to protect their crops.

## 📱 About the App

DhanySetu enables users to:
- 📷 Upload or capture live plant images to detect diseases
- 🧠 Use a trained Roboflow-powered ML model for real-time classification
- 🧪 Manually input soil report values to get instant remedy suggestions
- 🔍 View disease names, causes, and treatment recommendations
- 📞 Access in-app support through email and phone
- 🧾 Store user profile and data using Firebase

## 🔧 Tech Stack

- **Frontend**: Flutter
- **Backend Services**: Firebase (Auth, Firestore)
- **ML Model**: Roboflow-hosted model (plant disease classification)
- **Languages**: Dart, Python (for Cloud Functions)

## 🧠 Features

- 🔍 **Disease Detection** – Upload or click live plant photos and classify diseases instantly
- 🧪 **Soil Health Dashboard** – Enter nutrient levels (N, P, K) manually and receive remedy suggestions
- 📂 **Firebase Integration** – Secure authentication, cloud image storage, and Firestore for user data
- 🆘 **About & Support Pages** – View app purpose and contact support via phone/email
- 🧑‍🌾 **Farmer Friendly UI** – Intuitive and lightweight design tailored for rural usage


## 📸 Disease Detection Workflow

1. User selects or captures an image of a rice plant
2. Image is uploaded to Firebase Storage
3. A Firebase Cloud Function sends the image to Roboflow API
4. The model returns a predicted class (e.g., "Bacterial Leaf Blight")
5. App displays disease info and remedy

## 🛡️ Firebase Modules Used

- **Authentication** – Email/Password-based user login
- **Storage** – Upload and store plant images
- **Cloud Functions** – Secure communication with Roboflow API

## 🧪 Soil Report Entry

Users can manually enter:
- Nitrogen (N)
- Phosphorus (P)
- Potassium (K)
- pH
- Organic Carbon Value

App gives:
- Nutrient-based suggestions
- Remedy or fertilizer tips

## 🧑‍💻 Team

- **Project Lead**: Manukonda Vani
- **Member** : Prasannatha kandula
- **Member**: Vasuki Anila

## 🚀 How to Run

1. Clone the repository:
   ```bash
   git clone https://github.com/Vani6125/dhanysetu.git
   cd dhanysetu


