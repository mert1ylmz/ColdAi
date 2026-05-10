import os
import json
import zipfile
import tempfile
import shutil
import tensorflow as tf

KERAS_DIR = "/Users/mert/Projects/ColdAi/mobile_app/cold_assistant_ai/assets/keras models"
TFLITE_DIR = "/Users/mert/Projects/ColdAi/mobile_app/cold_assistant_ai/assets/models"

if not os.path.exists(TFLITE_DIR):
    os.makedirs(TFLITE_DIR)

def patch_keras_file(keras_path):
    """
    .keras dosyaları aslında zip dosyasıdır.
    İçindeki config.json dosyasından quantization_config ayarını silip
    yeni bir patched.keras oluşturur.
    """
    temp_dir = tempfile.mkdtemp()
    patched_keras = keras_path + "_patched.keras"
    
    with zipfile.ZipFile(keras_path, 'r') as zip_ref:
        zip_ref.extractall(temp_dir)
        
    config_path = os.path.join(temp_dir, 'config.json')
    if os.path.exists(config_path):
        with open(config_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # quantization_config'leri temizle
        content = content.replace(', "quantization_config": null', '')
        content = content.replace('"quantization_config": null,', '')
        content = content.replace('"quantization_config": null', '')
        
        with open(config_path, 'w', encoding='utf-8') as f:
            f.write(content)
            
    # Tekrar zip yap
    with zipfile.ZipFile(patched_keras, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for root, dirs, files in os.walk(temp_dir):
            for file in files:
                file_path = os.path.join(root, file)
                arcname = os.path.relpath(file_path, temp_dir)
                zipf.write(file_path, arcname)
                
    shutil.rmtree(temp_dir)
    return patched_keras

def convert_to_tflite_compatible(keras_file_path, tflite_file_path):
    print(f"Dönüştürülüyor: {os.path.basename(keras_file_path)}...")
    
    patched_path = None
    try:
        patched_path = patch_keras_file(keras_file_path)
        
        model = tf.keras.models.load_model(patched_path, compile=False)
        
        converter = tf.lite.TFLiteConverter.from_keras_model(model)
        converter.target_spec.supported_ops = [
            tf.lite.OpsSet.TFLITE_BUILTINS,
            tf.lite.OpsSet.SELECT_TF_OPS
        ]
        
        tflite_model = converter.convert()
        
        with open(tflite_file_path, "wb") as f:
            f.write(tflite_model)
            
        print(f"BAŞARILI! Kaydedildi -> {tflite_file_path}\n")
    except Exception as e:
        print(f"HATA: {os.path.basename(keras_file_path)} dönüştürülemedi!\nDetay: {e}\n")
    finally:
        if patched_path and os.path.exists(patched_path):
            os.remove(patched_path)

if __name__ == "__main__":
    print("=== TFLite Uyumlu Model Dönüştürme Başlıyor ===\n")
    keras_files = [f for f in os.listdir(KERAS_DIR) if f.endswith('.keras') and not f.endswith('.patched')]
    
    if not keras_files:
        print("Klasörde hiç .keras dosyası bulunamadı!")
    
    for file in keras_files:
        keras_path = os.path.join(KERAS_DIR, file)
        tflite_filename = file.replace('.keras', '.tflite')
        tflite_path = os.path.join(TFLITE_DIR, tflite_filename)
        
        convert_to_tflite_compatible(keras_path, tflite_path)
        
    print("=== İşlem Tamamlandı! ===")


