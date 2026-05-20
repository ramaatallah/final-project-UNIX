# نستخدم Node.js كأساس
FROM node:18

# نحدد مجلد الشغل داخل الـ Container
WORKDIR /app

# ننسخ ملفات الـ backend
COPY backend/package*.json ./backend/
RUN cd backend && npm install

# ننسخ كل الملفات
COPY . .

# نفتح البورت
EXPOSE 3000

# نشغّل التطبيق
CMD ["node", "backend/server.js"]