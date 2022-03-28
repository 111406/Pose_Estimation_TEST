import os
import cv2
import math
import time
import numpy as np
import mediapipe as mp

# 註解拿掉安裝套件
# os.system("pip install opencv-python mediapipe numpy")


class poseDetctor():
    def __init__(self, mode=False, upBody=False, smooth=True):
        self.mode = mode
        self.upBody = upBody
        self.smooth = smooth

        self.mpDraw = mp.solutions.drawing_utils
        self.mpPose = mp.solutions.pose
        self.pose = self.mpPose.Pose(
            self.mode, self.upBody, self.smooth)

    def findPose(self, frame, draw=True):
        imgRGB = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        self.results = self.pose.process(imgRGB)
        if self.results.pose_landmarks:
            if draw:
                self.mpDraw.draw_landmarks(
                    frame, self.results.pose_landmarks, self.mpPose.POSE_CONNECTIONS)

            return frame

    def findPosition(self, frame, draw=True):
        self.lmList = []
        if self.results.pose_landmarks:
            for id, lm in enumerate(self.results.pose_landmarks.landmark):
                h, w, c = frame.shape
                cx, cy = int(lm.x*w), int(lm.y*h)
                self.lmList.append([id, cx, cy])
                if draw:
                    cv2.circle(frame, (cx, cy), 5, (0, 0, 255), cv2.FILLED)
        return self.lmList

    def findAngle(self, frame, p1, p2, p3, draw=True):
        _, x1, y1 = self.lmList[p1]
        _, x2, y2 = self.lmList[p2]
        _, x3, y3 = self.lmList[p3]

        angle = math.degrees(math.atan2(y3 - y2, x3 - x2) -
                             math.atan2(y1 - y2, x1 - x2))

        if angle < 0:
            angle = -angle

        if draw:
            color = (0, 0, 255)
            cv2.line(frame, (x1, y1), (x2, y2), (255, 0, 255), 3)
            cv2.line(frame, (x3, y3), (x2, y2), (255, 0, 255), 3)
            cv2.circle(frame, (x1, y1), 10, color, cv2.FILLED)
            cv2.circle(frame, (x1, y1), 15, color, 2)
            cv2.circle(frame, (x2, y2), 10, color, cv2.FILLED)
            cv2.circle(frame, (x2, y2), 15, color, 2)
            cv2.circle(frame, (x3, y3), 10, color, cv2.FILLED)
            cv2.circle(frame, (x3, y3), 15, color, 2)
            cv2.putText(frame, str('%.1f' % angle), (x2 - 20, y2 + 50),
                        cv2.FONT_HERSHEY_PLAIN, 2, (255, 255, 255), 2)
        return angle


class fps():
    cTime, pTime = 0, 0

    def __init__(self):
        pass

    def display(color=(0, 255, 0)):
        fps.cTime = time.time()
        cv2.putText(frame, str(int(1 / (fps.cTime - fps.pTime))), (50, 100),
                    cv2.FONT_HERSHEY_PLAIN, 5, color, 5)
        fps.pTime = fps.cTime


class counter():

    direction = 0
    count = 0
    color = (255, 0, 255)

    def display(percent, color=(0, 0, 255)):
        if percent == 0:
            if counter.direction == 1:
                counter.count += 0.5
                counter.direction = 0

        if percent == 100:

            if counter.direction == 0:
                counter.count += 0.5
                counter.direction = 1

        cv2.putText(frame, str(int(counter.count)), (45, 670),
                    cv2.FONT_HERSHEY_PLAIN, 15, color, 20)


cap = cv2.VideoCapture(0)
detector = poseDetctor()

color = (0, 255, 0)
angle_range = (37, 140)

while cap.isOpened():
    ref, frame = cap.read()
    frame = cv2.resize(frame, (1280, 720))
    img = detector.findPose(frame, False)
    lmList = detector.findPosition(frame, False)

    if len(lmList) != 0:
        # detector.findAngle(frame, 11, 13, 15)
        angle = detector.findAngle(frame, 12, 14, 16)

        # fps.display()

        percent = np.interp(angle, angle_range, (100, 0))
        counter.display(percent)
        cv2.putText(frame, f'{int(percent)}%', (1100, 75),
                    cv2.FONT_HERSHEY_PLAIN, 4, color, 4)
        bar = np.interp(angle, angle_range, (100, 650))
        cv2.rectangle(frame, (1100, int(bar)),
                      (1175, 650), color, cv2.FILLED)
        # cv2.rectangle(frame, (1100, 100), (1175, 650), color, 3)

    cv2.imshow('Test', frame)
    key = cv2.waitKey(10)
    if key == 27:
        break

cap.release()
cv2.destroyAllWindows()
