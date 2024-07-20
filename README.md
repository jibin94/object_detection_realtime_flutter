## Integrating TensorFlow Lite Model
- **Different ways of getting ‘tflite’ model file**:- Download the Trained TensorFlow model from the [TensorFlow Hub](https://www.tensorflow.org/hub) and it can be converted into a tflite model file using the [corresponding converter](https://www.tensorflow.org/lite/models/convert/convert_models).
Tflite model files can be created using a [Google Teachable machine](https://teachablemachine.withgoogle.com), using which we can create custom model files based on our requirements.
There are pre-trained [TensorFlow Lite model examples](https://www.tensorflow.org/lite/examples) and can be used in sample apps for a variety of ML applications.<br />
- **Add TensorFlow Lite Model**: Place your downloaded TensorFlow Lite model in the assets folder of your Flutter project.<br />
- **Update the pubspec.yaml file** to include the model in the assets.<br />
  assets:<br />
   — assets/ssd_mobilenet.tflite <br />
   — assets/ssd_mobilenet.txt<br />

## Object Detection in Image
To detect objects in images, we need to load the model using the `Tflite.loadModel` method available in the tflite package. Then, we need to get the image within the app by launching the camera. The camera package provides the `getImage` method that can be used to do it.
After the image is loaded, we feed it into our model using the `Tflite.detectObjectOnImage` method. This method returns the detected class, confidence and points of interests that will help us draw bounding boxes around the objects.
