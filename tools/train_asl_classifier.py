from pathlib import Path
import urllib.request

import cv2
import mediapipe as mp
from mediapipe.tasks import python
from mediapipe.tasks.python import vision
import numpy as np
import tensorflow as tf
from sklearn.model_selection import train_test_split

PROJECT_DIR = Path(__file__).resolve().parents[1]  # Корень Flutter-проекта
DATA_DIR = PROJECT_DIR / "ImagePro"  # Папка с датасетом внутри проекта
KERAS_PATH = PROJECT_DIR / "trained_model/asl_landmarks.keras"
MODEL_PATH = PROJECT_DIR / "assets/model.tflite"
TASK_MODEL_PATH = PROJECT_DIR / "assets/hand_landmarker.task"

LETTERS = list("ABCDEFGHIJKLMNOPQRSTUVWXY")  # Классы от A до Y, без Z
FEATURE_COUNT = 42  # 21 ключевая точка * 2 координаты (x, y) = 42
SEED = 42


def download_task_model():
    """Скачивает официальную модель HandLandmarker от Google, если её еще нет."""
    if not TASK_MODEL_PATH.exists():
        TASK_MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)
        print("Скачивается модель hand_landmarker.task для MediaPipe...")
        url = "https://storage.googleapis.com/mediapipe-models/hand_landmarker/hand_landmarker/float16/1/hand_landmarker.task"
        urllib.request.urlretrieve(url, TASK_MODEL_PATH)
        print("Модель успешно скачана!")


def normalize_landmarks(landmarks, handedness):
    """Match landmarkFeatures() in lib/data/letter_landmark_features.dart."""
    points = np.asarray([[point.x, point.y] for point in landmarks], dtype=np.float32)
    wrist = points[0].copy()
    points -= wrist
    palm_scale = np.linalg.norm(points[9])
    if not np.isfinite(palm_scale) or palm_scale < 1e-5:
        return None
    points /= palm_scale
    if handedness == "Left":
        points[:, 0] *= -1
    return points.reshape(FEATURE_COUNT)


def main():
    if not DATA_DIR.is_dir():
        raise FileNotFoundError(
            f"Папка с датасетом не найдена: {DATA_DIR}\n"
            f"Убедитесь, что папка 'ImagePro' находится прямо внутри папки проекта ({PROJECT_DIR})."
        )

    actual_classes = sorted(path.name for path in DATA_DIR.iterdir() if path.is_dir())
    if actual_classes != LETTERS:
        raise ValueError(
            f"ImagePro должна содержать папки классов {LETTERS}; найдено: {actual_classes}"
        )

    # Скачиваем файл модели .task для нового MediaPipe
    download_task_model()

    features = []
    labels = []
    skipped = 0
    image_extensions = {".jpg", ".jpeg", ".png", ".bmp", ".webp"}

    # Настройка детектора через новый MediaPipe Tasks API
    base_options = python.BaseOptions(model_asset_path=str(TASK_MODEL_PATH))
    options = vision.HandLandmarkerOptions(
        base_options=base_options,
        running_mode=vision.RunningMode.IMAGE,
        num_hands=1,
        min_hand_detection_confidence=0.5,
    )

    with vision.HandLandmarker.create_from_options(options) as detector:
        for label, letter in enumerate(LETTERS):
            letter_dir = DATA_DIR / letter
            if not letter_dir.is_dir():
                continue
            paths = sorted(
                path
                for path in letter_dir.iterdir()
                if path.suffix.lower() in image_extensions
            )
            accepted = 0
            for path in paths:
                bgr = cv2.imread(str(path))
                if bgr is None:
                    skipped += 1
                    continue
                rgb = cv2.cvtColor(bgr, cv2.COLOR_BGR2RGB)

                # Конвертация в формат mp.Image для нового API
                mp_image = mp.Image(image_format=mp.ImageFormat.SRGB, data=rgb)
                result = detector.detect(mp_image)

                if not result.hand_landmarks:
                    skipped += 1
                    continue

                handedness = "Right"
                if result.handedness and result.handedness[0]:
                    handedness = result.handedness[0][0].category_name

                vector = normalize_landmarks(
                    result.hand_landmarks[0],
                    handedness,
                )
                if vector is None:
                    skipped += 1
                    continue

                features.append(vector)
                labels.append(label)
                accepted += 1
            print(f"{letter}: {accepted}/{len(paths)} изображений обработано")

    if not features:
        raise RuntimeError("Не удалось извлечь ключевые точки ни из одной картинки в ImagePro.")

    x = np.asarray(features, dtype=np.float32)
    y = np.asarray(labels, dtype=np.int32)
    counts = np.bincount(y, minlength=len(LETTERS))
    if np.any(counts < 2):
        missing = [LETTERS[i] for i, count in enumerate(counts) if count < 2]
        raise ValueError(f"Нужно как минимум 2 примера на каждый класс: {missing}")
    print(f"Всего векторов: {len(x)}; пропущено изображений: {skipped}")

    x_train, x_val, y_train, y_val = train_test_split(
        x,
        y,
        test_size=0.15,
        random_state=SEED,
        stratify=y,
    )

    model = tf.keras.Sequential(
        [
            tf.keras.Input(shape=(FEATURE_COUNT,)),
            tf.keras.layers.Dense(128, activation="relu"),
            tf.keras.layers.Dropout(0.25),
            tf.keras.layers.Dense(64, activation="relu"),
            tf.keras.layers.Dropout(0.15),
            tf.keras.layers.Dense(len(LETTERS), activation="softmax"),
        ]
    )
    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=1e-3),
        loss="sparse_categorical_crossentropy",
        metrics=["accuracy"],
    )

    KERAS_PATH.parent.mkdir(parents=True, exist_ok=True)
    MODEL_PATH.parent.mkdir(parents=True, exist_ok=True)

    callbacks = [
        tf.keras.callbacks.ModelCheckpoint(
            KERAS_PATH,
            monitor="val_accuracy",
            mode="max",
            save_best_only=True,
        ),
        tf.keras.callbacks.EarlyStopping(
            monitor="val_accuracy",
            mode="max",
            patience=12,
            restore_best_weights=True,
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor="val_loss",
            factor=0.5,
            patience=4,
            min_lr=1e-6,
        ),
    ]

    model.fit(
        x_train,
        y_train,
        validation_data=(x_val, y_val),
        epochs=100,
        batch_size=32,
        callbacks=callbacks,
        verbose=1,
    )

    model = tf.keras.models.load_model(KERAS_PATH)
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()

    interpreter = tf.lite.Interpreter(model_content=tflite_model)
    interpreter.allocate_tensors()
    input_shape = tuple(interpreter.get_input_details()[0]["shape"])
    output_details = interpreter.get_output_details()
    output_shapes = [tuple(detail["shape"]) for detail in output_details]
    expected_input = (1, FEATURE_COUNT)
    expected_outputs = [(1, len(LETTERS))]

    if input_shape != expected_input or output_shapes != expected_outputs:
        raise ValueError(
            f"Экспортированная модель имеет input {input_shape} и outputs {output_shapes}; "
            f"ожидалось input {expected_input} и outputs {expected_outputs}."
        )

    MODEL_PATH.write_bytes(tflite_model)
    print(
        f"Модель успешно сохранена в {MODEL_PATH}; input {input_shape}, outputs {output_shapes}; "
        f"порядок классов: {''.join(LETTERS)}"
    )


if __name__ == "__main__":
    main()
