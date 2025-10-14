import cv2
import mediapipe as mp
import numpy as np
import time
from collections import Counter

# Eye aspect ratio calculation for blink detection
def eye_aspect_ratio(eye_points):
    # eye_points: list of (x, y)
    A = np.linalg.norm(np.array(eye_points[1]) - np.array(eye_points[5]))
    B = np.linalg.norm(np.array(eye_points[2]) - np.array(eye_points[4]))
    C = np.linalg.norm(np.array(eye_points[0]) - np.array(eye_points[3]))
    return (A + B) / (2.0 * C)

def select_camera():
    print("Select camera source for this session:")
    print("  1. Insta360 (indices 4, 5, 6, 7)")
    print("  2. Laptop Webcam (indices 0, 1, 2, 3)")
    source = input("Enter 1 for Insta360 or 2 for Laptop Webcam [default 1]: ")
    if source.strip() == '2':
        idx = input("Enter camera index for Laptop Webcam [default 0]: ")
        try:
            return int(idx)
        except ValueError:
            return 0
    else:
        idx = input("Enter camera index for Insta360 [default 4]: ")
        try:
            return int(idx)
        except ValueError:
            return 4

# --- Prototype Test Settings ---
TEST_DURATION = 60  # seconds
print(f"\n[Prototype Test] This test will run for {TEST_DURATION} seconds and then print a summary.\n")


mp_face_mesh = mp.solutions.face_mesh
face_mesh = mp_face_mesh.FaceMesh(refine_landmarks=True)
cam_index = select_camera()
print(f"[INFO] Using camera index: {cam_index}")
cap = cv2.VideoCapture(cam_index)
if not cap.isOpened():
    print(f"[ERROR] Could not open camera at index {cam_index}. Please check your device and try another index.")
    exit(1)

# Eye landmark indices for MediaPipe FaceMesh
LEFT_EYE_IDX = [33, 160, 158, 133, 153, 144]  # [left, top1, top2, right, bottom2, bottom1]
RIGHT_EYE_IDX = [362, 385, 387, 263, 373, 380]


blink_counter = 0
blink_start_time = time.time()
blink_rate = 0
blink_history = []
fixation_start = time.time()
fixation_duration = 0
fixation_threshold = 10  # pixels
last_gaze = None
fixation_count = 0
frame_count = 0

# --- Prototype Test Data ---
fixation_durations = []
attention_states = []
cognitive_load_states = []
teacher_engagement_history = []  # 1 if gaze in center, else 0
test_start_time = time.time()

def get_eye_points(landmarks, indices, shape):
    return [(int(landmarks[idx].x * shape[1]), int(landmarks[idx].y * shape[0])) for idx in indices]

def get_gaze_center(eye_points):
    xs = [p[0] for p in eye_points]
    ys = [p[1] for p in eye_points]
    return (int(np.mean(xs)), int(np.mean(ys)))


while cap.isOpened():
    now = time.time()
    if now - test_start_time > TEST_DURATION:
        print("\n[Prototype Test] Time is up! Generating summary...\n")
        break
    ret, frame = cap.read()
    if not ret:
        print(f"Failed to open camera at index {cam_index}. Try another index.")
        break
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = face_mesh.process(rgb)
    frame_count += 1
    attention = 'Unknown'
    cognitive_load = 'Unknown'

    if results.multi_face_landmarks:
        for face_landmarks in results.multi_face_landmarks:
            shape = frame.shape
            left_eye = get_eye_points(face_landmarks.landmark, LEFT_EYE_IDX, shape)
            right_eye = get_eye_points(face_landmarks.landmark, RIGHT_EYE_IDX, shape)
            for pt in left_eye + right_eye:
                cv2.circle(frame, pt, 2, (0, 255, 0), -1)

            # Blink detection
            left_ear = eye_aspect_ratio(left_eye)
            right_ear = eye_aspect_ratio(right_eye)
            ear = (left_ear + right_ear) / 2.0
            BLINK_THRESH = 0.22
            if ear < BLINK_THRESH:
                if not blink_history or blink_history[-1] == 0:
                    blink_counter += 1
                blink_history.append(1)
            else:
                blink_history.append(0)
            # Only keep last 10 seconds of blink history
            if len(blink_history) > 30 * 10:
                blink_history = blink_history[-30*10:]
            blink_rate = sum(blink_history) / (len(blink_history)/30)  # blinks per second

            # Gaze direction (center of both eyes)
            left_center = get_gaze_center(left_eye)
            right_center = get_gaze_center(right_eye)
            gaze_center = ((left_center[0] + right_center[0]) // 2, (left_center[1] + right_center[1]) // 2)
            cv2.circle(frame, gaze_center, 4, (255, 0, 0), -1)

            # Teacher engagement: is gaze in center third of frame?
            h, w = frame.shape[:2]
            center_left = w // 3
            center_right = 2 * w // 3
            in_center = center_left <= gaze_center[0] <= center_right
            teacher_engagement_history.append(1 if in_center else 0)
            # Draw center region for visualization
            cv2.rectangle(frame, (center_left, 0), (center_right, h), (0, 255, 255), 2)
            cv2.putText(frame, 'Teacher', (center_left + 10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,255), 2)

            # Fixation detection (gaze stability)
            if last_gaze is not None:
                dist = np.linalg.norm(np.array(gaze_center) - np.array(last_gaze))
                if dist < fixation_threshold:
                    fixation_duration = time.time() - fixation_start
                else:
                    fixation_durations.append(time.time() - fixation_start)
                    fixation_start = time.time()
                    fixation_duration = 0
                    fixation_count += 1
            last_gaze = gaze_center

            # Attention and cognitive load estimation (simple heuristics)
            if fixation_duration > 1.5:
                attention = 'Focused'
            else:
                attention = 'Distracted'
            if blink_rate > 0.3:
                cognitive_load = 'High'
            else:
                cognitive_load = 'Normal'

            # Collect for summary
            attention_states.append(attention)
            cognitive_load_states.append(cognitive_load)

            # Display metrics
            teacher_engagement = 100 * sum(teacher_engagement_history) / len(teacher_engagement_history) if teacher_engagement_history else 0
            cv2.putText(frame, f'Blinks: {blink_counter}', (10, 30), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
            cv2.putText(frame, f'Blink Rate: {blink_rate:.2f}/s', (10, 60), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
            cv2.putText(frame, f'Fixation: {fixation_duration:.2f}s', (10, 90), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,255,0), 2)
            cv2.putText(frame, f'Attention: {attention}', (10, 120), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (255,255,0), 2)
            cv2.putText(frame, f'Cognitive Load: {cognitive_load}', (10, 150), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,0,255), 2)
            cv2.putText(frame, f'Teacher Engagement: {teacher_engagement:.1f}%', (10, 180), cv2.FONT_HERSHEY_SIMPLEX, 0.7, (0,128,255), 2)

    cv2.imshow('Eye Tracking - Cognitive Load & Attention', frame)
    if cv2.waitKey(1) & 0xFF == 27:
        print("[Prototype Test] Interrupted by user. Generating summary...\n")
        break
cap.release()
cv2.destroyAllWindows()

# --- Print Prototype Test Summary ---
print("\n========== Prototype Test Summary ==========")
print(f"Test duration: {min(TEST_DURATION, int(time.time() - test_start_time))} seconds")
print(f"Total blinks: {blink_counter}")
if fixation_durations:
    print(f"Average fixation duration: {np.mean(fixation_durations):.2f} s")
else:
    print("Average fixation duration: N/A")
if attention_states:
    attn_counts = Counter(attention_states)
    total = sum(attn_counts.values())
    print("Attention states:")
    for k, v in attn_counts.items():
        print(f"  {k}: {v/total*100:.1f}%")
else:
    print("Attention states: N/A")
if cognitive_load_states:
    cog_counts = Counter(cognitive_load_states)
    total = sum(cog_counts.values())
    print("Cognitive load states:")
    for k, v in cog_counts.items():
        print(f"  {k}: {v/total*100:.1f}%")
else:
    print("Cognitive load states: N/A")
if teacher_engagement_history:
    teacher_engagement = 100 * sum(teacher_engagement_history) / len(teacher_engagement_history)
    print(f"Teacher engagement: {teacher_engagement:.1f}% of time gaze was in center region")
else:
    print("Teacher engagement: N/A")
print("===========================================\n")