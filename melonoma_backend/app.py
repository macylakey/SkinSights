from flask import Flask, request, jsonify
import tensorflow as tf
import numpy as np
import os

# Initialize the Flask app
app = Flask(__name__)

# Load the TFLite model
def load_tflite_model(model_path):
    interpreter = tf.lite.Interpreter(model_path=model_path)
    interpreter.allocate_tensors()
    return interpreter

# Function to preprocess the image
def preprocess_image(image_path, target_size=(299, 299)):
    img = tf.keras.preprocessing.image.load_img(image_path, target_size=target_size)
    img_array = tf.keras.preprocessing.image.img_to_array(img) / 255.0
    return np.expand_dims(img_array, axis=0)

# Function to make a prediction using the TFLite model
def predict_confidence(interpreter, image_path):
    input_details = interpreter.get_input_details()
    output_details = interpreter.get_output_details()
    
    # Preprocess the image
    input_data = preprocess_image(image_path)
    
    # Set the input tensor
    interpreter.set_tensor(input_details[0]['index'], input_data.astype(np.float32))
    
    # Run inference
    interpreter.invoke()
    
    # Get the prediction
    output_data = interpreter.get_tensor(output_details[0]['index'])
    confidence_percentage = output_data[0][0] * 100
    return confidence_percentage

# Load the TFLite model
MODEL_PATH = "/Users/shaun/TestingIrvineHacks/melonoma_backend/melanoma_classifier.tflite"
model_interpreter = load_tflite_model(MODEL_PATH)

# Flask route to accept and process image
@app.route('/predict', methods=['POST'])
def predict():
    if 'image' not in request.files:
        return jsonify({"error": "No image file provided"}), 400

    
    image_file = request.files['image']
    
    if image_file.filename == '':
        return jsonify({"error": "No image selected"}), 400
    
    try:
        # Save the uploaded file
        image_path = os.path.join("uploads", image_file.filename)
        os.makedirs("uploads", exist_ok=True)
        image_file.save(image_path)
        
        # Predict confidence
        confidence_percentage = predict_confidence(model_interpreter, image_path)
        
        # Clean up: remove the saved file
        os.remove(image_path)
        print(f"Melanoma_confidence: {confidence_percentage}")

        
        return jsonify({"result": f"{confidence_percentage:.2f}%"})
    
    except Exception as e:
        return jsonify({"error": str(e)}), 500

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)
