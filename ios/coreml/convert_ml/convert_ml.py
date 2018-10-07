file_name = "yuruchan"
h5_path = file_name + ".h5"
mlmodel_path = file_name + ".mlmodel"

import coremltools
coreml_model = coremltools.converters.keras.convert(h5_path, input_names = 'image', is_bgr = True, image_scale = 0.00392156863, image_input_names = 'image', class_labels = 'labels.txt')
coreml_model.save(mlmodel_path)