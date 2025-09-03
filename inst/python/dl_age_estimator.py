# Run the deep learning models to estimate age from standardized otolith pictures
## The code is adapted from Martinsen et al. (2022) https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0277244 available at https://github.com/IverMartinsen/MastersThesis/blob/main/Greenland%20Halibut/make_predictions.py
## Modified by Alf Harbitz, Tine Nilsen, Mikko Vihtakari and Copilot (GPT 4o)

# Import modules

import glob # for file operations
import os # for file operations
import numpy as np # for numerical operations
import pandas as pd # for data manipulation
import tensorflow as tf # the deep learning package
import tf_keras as k3
tf.get_logger().setLevel('ERROR') # suppress tensorflow warnings
from PIL import Image # Image processing package (Pillow)
import re # for regular expressions

# Custom functions run within the main function
## Function to remove the directory path and file extension
def remove_path_and_extension(file_path):
    return re.sub(r'^.*/|\.jpg$', '', file_path)

## Function to extract image ids (comment if you do not use standard ids)
def extract_imageid(strings):
    return [re.match(r'^\d+', s).group() for s in strings]

## Debugging params:
# path_to_images = "inst/extdata/example_images/standardized/"
# path_to_models = os.path.expanduser('~/AgeEstimatoR large files/dl_models')
# path_to_output = None

# The main function
def dl_age_estimator(path_to_images, path_to_models, path_to_output):

  # Definitions and checks  
  path_to_models = os.path.expanduser(path_to_models)
  
  ## Required image size. Must be 256, 256
  required_image_size = 256, 256
  
  # Check if the images directory exists
  if not os.path.exists(path_to_images):
      raise FileNotFoundError("The images directory does not exist. Check path_to_images")
  
  # Check if the models directory exists
  if not os.path.exists(path_to_models):
      raise FileNotFoundError("The models directory does not exist. Check path_to_models")
  
  # Check if the output directory exists, and create it if it doesn't
  if not path_to_output is None:
    if not os.path.exists(os.path.dirname(path_to_output)):
        os.makedirs(os.path.dirname(path_to_output))
  
  ## Load models from path
  models = sorted(os.listdir(path_to_models))
  
  # model = models[0]
  # for model in models:
  #   model_path = os.path.join(path_to_models, model)
  # k3.models.load_model(model_path)
  #   inference_layer = tf.keras.layers.TFSMLayer(model_path, call_endpoint='serving_default')
  # 
  # tf.keras.models.load_model(model_path)
  
  models = [k3.models.load_model(os.path.join(path_to_models, model)) for model in models]
  # models = [tf.keras.models.load_model(os.path.join(path_to_models, model)) for model in models] # this would work for newer models
  
  ## Load images from path
  
  #images = os.listdir(path_to_images)
  images = sorted(glob.glob(path_to_images + "/*.jpg"))
  
  image_names = [remove_path_and_extension(file_path) for file_path in images]
  image_ids = extract_imageid(image_names)
  
  #print(images)
  # Create array for storing predictions
  num_images = len(images)
  num_models = len(models)
  num_preds = 3 # sexes, comes from the model (takes lines 1:3 from the prediction)
  pred_array = np.zeros((num_images, num_models, num_preds))
  
  # Iterate through images
  # image_path = images[0]; model = models[0]; j = 0; i = 0
  for j, image_path in enumerate(images):          
    image = np.array(Image.open(image_path))[None, :, :, :]
    image_size = image.shape[1:3]
  
    predictions = np.zeros((num_models, num_preds))
  
    if image_size != required_image_size:
        image = np.array(Image.open(image_path).resize(required_image_size))[None, :, :, :]
  
    for i, model in enumerate(models):        
        pred_array[j, i, :] = np.array(model.predict(image)[0])[1:]
  
    #print(predictions)
  
  mdic = {'a': pred_array}
  
  out = pd.DataFrame(mdic['a'].reshape(-1, 3), columns = ['female', 'male', 'unknown'])
  out.insert(0, 'model', np.tile(np.arange(num_models) + 1, num_images))
  out.insert(1, 'imageid', np.repeat(image_ids, num_models))
  out.insert(2, 'image', np.repeat(image_names, num_models))
  
  # Save
  if(path_to_output is None):
    print("Age estimates returned as a data frame")
    return out 
  else:
    path_to_output = os.path.splitext(path_to_output)[0] + ".csv"
    out.to_csv(path_to_output, index=False)  
    print("Age estimates saved to", path_to_output)

# Try it
# dl_age_estimator(
#   path_to_images = "inst/extdata/example_images/standardized/",
#   path_to_models = os.path.expanduser('~/AgeEstimatoR large files/dl_models'),
#   path_to_output = "inst/python/ages"
#   )


